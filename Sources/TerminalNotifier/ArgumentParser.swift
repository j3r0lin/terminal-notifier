import Foundation

// MARK: - Argument Parser
class ArgumentParser {
    private let notificationManager: NotificationManager
    
    init(notificationManager: NotificationManager) {
        self.notificationManager = notificationManager
    }
    
    func parseArguments(_ arguments: [String]) {
        var options: [String: Any] = [:]
        var message: String?
        var title = "Terminal"
        var subtitle: String?
        var sound: String?
        var remove: String?
        var list: String?
        
        // Parse arguments
        var i = 1
        while i < arguments.count {
            let arg = arguments[i]
            
            switch arg {
            case "-message":
                if i + 1 < arguments.count {
                    message = arguments[i + 1]
                    i += 1
                }
                
            case "-title":
                if i + 1 < arguments.count {
                    title = arguments[i + 1]
                    i += 1
                }
                
            case "-subtitle":
                if i + 1 < arguments.count {
                    subtitle = arguments[i + 1]
                    i += 1
                }
                
            case "-sound":
                if i + 1 < arguments.count {
                    sound = arguments[i + 1]
                    i += 1
                }
                
            case "-group":
                if i + 1 < arguments.count {
                    options["groupID"] = arguments[i + 1]
                    i += 1
                }
                
            case "-activate":
                if i + 1 < arguments.count {
                    options["bundleID"] = arguments[i + 1]
                    i += 1
                }
                
            case "-sender":
                if i + 1 < arguments.count {
                    options["sender"] = arguments[i + 1]
                    i += 1
                }
                
            case "-appIcon":
                if i + 1 < arguments.count {
                    options["appIcon"] = arguments[i + 1]
                    i += 1
                }
                
            case "-contentImage":
                if i + 1 < arguments.count {
                    options["contentImage"] = arguments[i + 1]
                    i += 1
                }
                
            case "-open":
                if i + 1 < arguments.count {
                    let urlString = arguments[i + 1]
                    if let url = URL(string: urlString), (url.scheme != nil && url.host != nil) || url.isFileURL {
                        options["open"] = urlString
                    } else {
                        print("'\(urlString)' is not a valid URI.")
                        exit(1)
                    }
                    i += 1
                }
                
            case "-execute":
                if i + 1 < arguments.count {
                    options["command"] = arguments[i + 1]
                    i += 1
                }
                
            case "-remove":
                if i + 1 < arguments.count {
                    remove = arguments[i + 1]
                    i += 1
                }
                
            case "-list":
                if i + 1 < arguments.count {
                    list = arguments[i + 1]
                    i += 1
                }
                
            case "-ignoreDnD":
                options["ignoreDnD"] = true
                
            case "--debug":
                DEBUG_MODE = true
                
            case "-useUserNotifications", "--useUserNotifications":
                options["useUserNotifications"] = true
                
            case "-useNSUserNotificationCenter", "--useNSUserNotificationCenter":
                options["useNSUserNotificationCenter"] = true
                
            default:
                break
            }
            
            i += 1
        }
        
        // Check for piped input if no message provided
        if message == nil && isatty(STDIN_FILENO) == 0 {
            let inputData = FileHandle.standardInput.readDataToEndOfFile()
            message = String(data: inputData, encoding: .utf8)
        }
        
        // Validate required arguments
        if message == nil && remove == nil && list == nil {
            notificationManager.printHelpBanner()
            exit(1)
        }
        
        // Handle list command
        if let list = list {
            notificationManager.listNotifications(groupID: list)
            exit(0)
        }
        
        // Handle remove command
        if let remove = remove {
            notificationManager.removeNotification(groupID: remove)
            if message == nil || message?.isEmpty == true {
                exit(0)
            }
        }
        
        // Handle message delivery
        if let message = message {
            notificationManager.deliverNotification(
                title: title,
                subtitle: subtitle,
                message: message,
                options: options,
                sound: sound
            )
        } else {
            // No message provided, show help and exit
            notificationManager.printHelpBanner()
            exit(0)
        }
    }
}