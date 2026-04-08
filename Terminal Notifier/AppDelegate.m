#import "AppDelegate.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import <objc/runtime.h>
NSString * const TerminalNotifierBundleID = @"fr.julienxx.oss.terminal-notifier";

NSString *_fakeBundleIdentifier = nil;

@implementation NSBundle (FakeBundleIdentifier)

// Overriding bundleIdentifier works, but overriding NSUserNotificationAlertStyle does not work.

- (NSString *)__bundleIdentifier;
{
  if (self == [NSBundle mainBundle]) {
    return _fakeBundleIdentifier ? _fakeBundleIdentifier : TerminalNotifierBundleID;
  } else {
    return [self __bundleIdentifier];
  }
}

@end

static BOOL
InstallFakeBundleIdentifierHook()
{
  Class class = objc_getClass("NSBundle");
  if (class) {
    method_exchangeImplementations(class_getInstanceMethod(class, @selector(bundleIdentifier)),
                                   class_getInstanceMethod(class, @selector(__bundleIdentifier)));
    return YES;
  }
  return NO;
}

@implementation NSUserDefaults (SubscriptAndUnescape)
- (id)objectForKeyedSubscript:(id)key;
{
  id obj = [self objectForKey:key];
  if ([obj isKindOfClass:[NSString class]] && [(NSString *)obj hasPrefix:@"\\"]) {
    obj = [(NSString *)obj substringFromIndex:1];
  }
  return obj;
}
@end


@implementation AppDelegate

+(void)initializeUserDefaults
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  // initialize the dictionary with default values depending on OS level
  NSDictionary *appDefaults;
  appDefaults = @{@"sender": @"com.apple.Terminal"};

  // and set them appropriately
  [defaults registerDefaults:appDefaults];
}

- (void)printHelpBanner;
{
  const char *appName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"] UTF8String];
  const char *appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] UTF8String];
  printf("%s (%s) is a command-line tool to send macOS User Notifications.\n" \
         "\n" \
         "Usage: %s -[message|list|remove] [VALUE|ID|ID] [options]\n" \
         "\n" \
         "   Either of these is required (unless message data is piped to the tool):\n" \
         "\n" \
         "       -help              Display this help banner.\n" \
         "       -version           Display terminal-notifier version.\n" \
         "       -message VALUE     The notification message.\n" \
         "       -remove ID         Removes a notification with the specified 'group' ID.\n" \
         "       -list ID           If the specified 'group' ID exists show when it was delivered,\n" \
         "                          or use 'ALL' as ID to see all notifications.\n" \
         "                          The output is a tab-separated list.\n"
         "\n" \
         "   Optional:\n" \
         "\n" \
         "       -title VALUE       The notification title. Defaults to 'Terminal'.\n" \
         "       -subtitle VALUE    The notification subtitle.\n" \
         "       -sound NAME        The name of a sound to play when the notification appears. The names are listed\n" \
         "                          in Sound Preferences. Use 'default' for the default notification sound.\n" \
         "       -group ID          A string which identifies the group the notifications belong to.\n" \
         "                          Old notifications with the same ID will be removed.\n" \
         "       -activate ID       The bundle identifier of the application to activate when the user clicks the notification.\n" \
         "       -sender ID         The bundle identifier of the application that should be shown as the sender, including its icon.\n" \
         "       -appIcon URL       The URL of an image to display as a thumbnail in the notification.\n" \
         "       -contentImage URL  The URL of an image to display attached to the notification.\n" \
         "       -open URL          The URL of a resource to open when the user clicks the notification.\n" \
         "       -execute COMMAND   A shell command to perform when the user clicks the notification.\n" \
         "\n" \
         "When the user activates a notification, the results are logged to the system logs.\n" \
         "Use Console.app to view these logs.\n" \
         "\n" \
         "Note that in some circumstances the first character of a message has to be escaped in order to be recognized.\n" \
         "An example of this is when using an open bracket, which has to be escaped like so: '\\['.\n" \
         "\n" \
         "For more information see https://github.com/julienXX/terminal-notifier.\n",
         appName, appVersion, appName);
}

- (void)printVersion;
{
  const char *appName = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"] UTF8String];
  const char *appVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] UTF8String];
  printf("%s %s.\n", appName, appVersion);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
{
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;

  if ([[[NSProcessInfo processInfo] arguments] indexOfObject:@"-help"] != NSNotFound) {
    [self printHelpBanner];
    exit(0);
  }

  if ([[[NSProcessInfo processInfo] arguments] indexOfObject:@"-version"] != NSNotFound) {
    [self printVersion];
    exit(0);
  }

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  NSString *subtitle = defaults[@"subtitle"];
  NSString *message  = defaults[@"message"];
  NSString *remove   = defaults[@"remove"];
  NSString *list     = defaults[@"list"];
  NSString *sound    = defaults[@"sound"];

  // If there is no message and data is piped to the application, use that
  // instead.
  if (message == nil && !isatty(STDIN_FILENO)) {
    NSData *inputData = [NSData dataWithData:[[NSFileHandle fileHandleWithStandardInput] readDataToEndOfFile]];
    message = [[NSString alloc] initWithData:inputData encoding:NSUTF8StringEncoding];
  }

  if (message == nil && remove == nil && list == nil) {
    // When launched by clicking a notification, there are no arguments.
    // Wait briefly for didReceiveNotificationResponse: to fire.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
      dispatch_get_main_queue(), ^{
        [self printHelpBanner];
        exit(1);
    });
    return;
  }

  if (list) {
    [self listNotificationWithGroupID:list];
    exit(0);
  }

  // Install the fake bundle ID hook so we can fake the sender. This also
  // needs to be done to be able to remove a message.
  if (defaults[@"sender"]) {
    @autoreleasepool {
      if (InstallFakeBundleIdentifierHook()) {
        _fakeBundleIdentifier = defaults[@"sender"];
      }
    }
  }

  if (remove) {
    [self removeNotificationWithGroupID:remove];
    if (message == nil || ([message length] == 0)) {
        exit(0);
    }
  }

  if (message) {
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    if (defaults[@"activate"]) options[@"bundleID"]         = defaults[@"activate"];
    if (defaults[@"group"])    options[@"groupID"]          = defaults[@"group"];
    if (defaults[@"execute"])  options[@"command"]          = defaults[@"execute"];
    if (defaults[@"appIcon"])  options[@"appIcon"]          = defaults[@"appIcon"];
    if (defaults[@"contentImage"]) options[@"contentImage"] = defaults[@"contentImage"];

    if (defaults[@"open"]) {
      NSURL *url = [NSURL URLWithString:defaults[@"open"]];
      if ((url && url.scheme && url.host) || [url isFileURL]) {
        options[@"open"] = defaults[@"open"];
      }else{
        NSLog(@"'%@' is not a valid URI.", defaults[@"open"]);
        exit(1);
      }
    }

    [self deliverNotificationWithTitle:defaults[@"title"] ?: @"Terminal"
                              subtitle:subtitle
                               message:message
                               options:options
                                 sound:sound];
  }
}

- (UNNotificationAttachment *)attachmentFromURL:(NSString *)url identifier:(NSString *)identifier;
{
  NSURL *imageURL = [NSURL URLWithString:url];
  if ([[imageURL scheme] length] == 0) {
    imageURL = [NSURL fileURLWithPath:url];
  }
  // Convert via NSImage to handle any format (icns, tiff, etc.)
  NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
  if (!image) return nil;
  CGImageRef cgRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
  if (!cgRef) return nil;
  NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
  NSData *pngData = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
  if (!pngData) return nil;

  NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
    [NSString stringWithFormat:@"%@.png", [[NSUUID UUID] UUIDString]]];
  if (![pngData writeToFile:tempPath atomically:YES]) return nil;

  NSError *error = nil;
  UNNotificationAttachment *attachment = [UNNotificationAttachment
    attachmentWithIdentifier:identifier
    URL:[NSURL fileURLWithPath:tempPath]
    options:nil
    error:&error];
  // UNNotificationAttachment moves the file; clean up on failure
  if (error) {
    NSLog(@"Failed to create attachment: %@", error);
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
  }
  return attachment;
}

- (void)deliverNotificationWithTitle:(NSString *)title
                            subtitle:(NSString *)subtitle
                             message:(NSString *)message
                             options:(NSDictionary *)options
                               sound:(NSString *)sound;
{
  if (options[@"groupID"]) [self removeNotificationWithGroupID:options[@"groupID"]];

  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];

  [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound)
    completionHandler:^(BOOL granted, NSError *error) {
    if (!granted) {
      NSLog(@"Notification authorization denied.");
      dispatch_async(dispatch_get_main_queue(), ^{ exit(1); });
      return;
    }

    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = title;
    content.subtitle = subtitle ?: @"";
    content.body = message;
    content.userInfo = options;

    if (sound) {
      content.sound = [sound isEqualToString:@"default"]
        ? [UNNotificationSound defaultSound]
        : [UNNotificationSound soundNamed:sound];
    }

    NSMutableArray *attachments = [NSMutableArray array];
    for (NSString *key in @[@"appIcon", @"contentImage"]) {
      if (options[key]) {
        UNNotificationAttachment *att = [self attachmentFromURL:options[key] identifier:key];
        if (att) [attachments addObject:att];
      }
    }
    if (attachments.count > 0) content.attachments = attachments;

    if (options[@"groupID"]) {
      content.threadIdentifier = options[@"groupID"];
    }

    NSString *requestID = options[@"groupID"] ?: [[NSUUID UUID] UUIDString];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestID
                                                                          content:content
                                                                          trigger:nil];
    [center addNotificationRequest:request withCompletionHandler:^(NSError *reqError) {
      if (reqError) {
        NSLog(@"Failed to deliver notification: %@", reqError);
        dispatch_async(dispatch_get_main_queue(), ^{ exit(1); });
        return;
      }
      dispatch_async(dispatch_get_main_queue(), ^{ exit(0); });
    }];
  }];
}

- (void)removeNotificationWithGroupID:(NSString *)groupID;
{
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  if ([@"ALL" isEqualToString:groupID]) {
    [center removeAllDeliveredNotifications];
  } else {
    [center removeDeliveredNotificationsWithIdentifiers:@[groupID]];
  }
}

- (void)listNotificationWithGroupID:(NSString *)listGroupID;
{
  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  dispatch_semaphore_t sem = dispatch_semaphore_create(0);
  [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *notifications) {
    NSMutableArray *lines = [NSMutableArray array];
    for (UNNotification *notification in notifications) {
      UNNotificationContent *content = notification.request.content;
      NSString *groupID = content.threadIdentifier ?: @"";
      if ([@"ALL" isEqualToString:listGroupID] || [groupID isEqualToString:listGroupID]) {
        [lines addObject:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\t%@",
          groupID, content.title, content.subtitle, content.body,
          [notification.date description]]];
      }
    }
    if (lines.count > 0) {
      printf("GroupID\tTitle\tSubtitle\tMessage\tDelivered At\n");
      for (NSString *line in lines) {
        printf("%s\n", [line UTF8String]);
      }
    }
    dispatch_semaphore_signal(sem);
  }];
  dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
}

- (void)userActivatedNotification:(NSDictionary *)userInfo;
{
  NSString *groupID  = userInfo[@"groupID"];
  NSString *bundleID = userInfo[@"bundleID"];
  NSString *command  = userInfo[@"command"];
  NSString *open     = userInfo[@"open"];

  NSLog(@"User activated notification:");
  NSLog(@" group ID: %@", groupID);
  NSLog(@"bundle ID: %@", bundleID);
  NSLog(@"  command: %@", command);
  NSLog(@"     open: %@", open);

  BOOL success = YES;
  if (bundleID) success &= [self activateAppWithBundleID:bundleID];
  if (command)  success &= [self executeShellCommand:command];
  if (open)     success &= [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:open]];

  exit(success ? 0 : 1);
}

- (BOOL)activateAppWithBundleID:(NSString *)bundleID;
{
  id app = [SBApplication applicationWithBundleIdentifier:bundleID];
  if (app) {
    [app activate];
    return YES;

  } else {
    NSLog(@"Unable to find an application with the specified bundle indentifier.");
    return NO;
  }
}

- (BOOL)executeShellCommand:(NSString *)command;
{
  NSPipe *pipe = [NSPipe pipe];
  NSFileHandle *fileHandle = [pipe fileHandleForReading];

  NSTask *task = [NSTask new];
  task.launchPath = @"/bin/sh";
  task.arguments = @[@"-c", command];
  task.standardOutput = pipe;
  task.standardError = pipe;
  [task launch];

  NSData *data = nil;
  NSMutableData *accumulatedData = [NSMutableData data];
  while ((data = [fileHandle availableData]) && [data length]) {
    [accumulatedData appendData:data];
  }

  [task waitUntilExit];
  NSLog(@"command output:\n%@", [[NSString alloc] initWithData:accumulatedData encoding:NSUTF8StringEncoding]);
  return [task terminationStatus] == 0;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;
{
  completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler;
{
  NSDictionary *userInfo = response.notification.request.content.userInfo;
  [self userActivatedNotification:userInfo];
  completionHandler();
}

@end
