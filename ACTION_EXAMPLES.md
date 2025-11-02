# Action Button Usage Examples

This document provides concrete, practical examples of using terminal-notifier's action button features.

## Basic Action Buttons

### Simple Yes/No Question
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Ready to deploy to production?" \
  -title "Deployment" \
  -action "Yes" \
  -action "No")

if echo "$RESPONSE" | grep -q "action_0"; then
  echo "User chose Yes - deploying..."
  deploy_production
elif echo "$RESPONSE" | grep -q "action_1"; then
  echo "User chose No - deployment cancelled"
fi
```

### Multiple Choice Actions
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Choose an action:" \
  -title "Build Complete" \
  -action "View Logs" \
  -action "Restart Build" \
  -action "Deploy")

ACTION_ID=$(echo "$RESPONSE" | sed 's/ACTION://')
case "$ACTION_ID" in
  "action_0")
    open_build_logs
    ;;
  "action_1")
    restart_build
    ;;
  "action_2")
    deploy_application
    ;;
esac
```

## Text Input Actions (Prompt/Reply)

### Collect User Input
```bash
# Simple input collection
USER_INPUT=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter your commit message:" \
  -prompt "Commit")

# Extract the text (format: ACTION:action_0:text)
COMMIT_MSG=$(echo "$USER_INPUT" | sed 's/ACTION:action_0://')

if [ -n "$COMMIT_MSG" ]; then
  git commit -m "$COMMIT_MSG"
fi
```

### Prompt with Cancel Option
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Add a note to this task:" \
  -prompt "Save Note" \
  -action "Skip")

if echo "$RESPONSE" | grep -q "action_0:"; then
  # User entered text and clicked "Save Note"
  NOTE=$(echo "$RESPONSE" | sed 's/ACTION:action_0://')
  echo "$NOTE" >> task_notes.txt
  echo "Note saved: $NOTE"
elif echo "$RESPONSE" | grep -q "action_1"; then
  # User clicked "Skip"
  echo "Note skipped"
fi
```

### Direct Pipeline Usage
```bash
# Extract and use input in a single pipeline
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter filename to create:" \
  -prompt "Create" | \
  sed 's/ACTION:action_0://' | \
  xargs -I {} touch {}

# Multiple operations in pipeline
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter commit message:" \
  -prompt "Commit" | \
  sed 's/ACTION:action_0://' | \
  xargs -I {} sh -c 'git add . && git commit -m "{}" && git push'
```

### Input Validation
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter email address:" \
  -prompt "Submit")

EMAIL=$(echo "$RESPONSE" | sed 's/ACTION:action_0://')

if [[ "$EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
  echo "Valid email: $EMAIL"
  send_notification "$EMAIL"
else
  echo "Invalid email format"
  exit 1
fi
```

## Destructive Actions

### Confirmation for Destructive Operations
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "This will delete all local changes. Continue?" \
  -title "Warning" \
  -action "Cancel" \
  -action-destructive "Delete All")

if echo "$RESPONSE" | grep -q "action_1"; then
  echo "Deleting all changes..."
  git reset --hard HEAD
  git clean -fd
else
  echo "Operation cancelled"
fi
```

### Multiple Destructive Options
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Choose cleanup action:" \
  -action "Cancel" \
  -action-destructive "Clear Cache" \
  -action-destructive "Reset Database" \
  -action-destructive "Delete All")

if echo "$RESPONSE" | grep -q "action_1"; then
  rm -rf ~/cache/*
elif echo "$RESPONSE" | grep -q "action_2"; then
  database_reset
elif echo "$RESPONSE" | grep -q "action_3"; then
  rm -rf project_data/*
fi
```

## Action Buttons with Icons (macOS 12.0+)

### Icons for Better UX
```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "New message received" \
  -action-icon "Reply:envelope.fill" \
  -action-icon "Mark Read:checkmark.circle.fill" \
  -action-icon "Delete:trash.fill")

# Process response based on action
if echo "$RESPONSE" | grep -q "action_0"; then
  open_reply_window
elif echo "$RESPONSE" | grep -q "action_1"; then
  mark_as_read
elif echo "$RESPONSE" | grep -q "action_2"; then
  delete_message
fi
```

### Mixed Actions with Icons
```bash
./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Code review requested" \
  -action-icon "Approve:checkmark.seal.fill" \
  -action-icon "Request Changes:xmark.circle.fill" \
  -action-text "Add Comment" \
  -action "Dismiss"
```

## Complex Real-World Examples

### Git Workflow Integration
```bash
#!/bin/bash
# git-interactive-commit.sh

# Show git status
git status --short

# Prompt for commit message
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Enter commit message:" \
  -title "Git Commit" \
  -prompt "Commit" \
  -action "Skip")

if echo "$RESPONSE" | grep -q "action_0:"; then
  MSG=$(echo "$RESPONSE" | sed 's/ACTION:action_0://')
  
  # Ask for confirmation
  CONFIRM=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
    -message "Commit: $MSG" \
    -action "Yes, Commit" \
    -action-destructive "Cancel")
  
  if echo "$CONFIRM" | grep -q "action_0"; then
    git commit -m "$MSG"
    ./terminal-notifier.app/Contents/MacOS/terminal-notifier \
      -message "Commit created successfully" \
      -title "Git" \
      -sound "default"
  fi
fi
```

### Build System Integration
```bash
#!/bin/bash
# build-notifier.sh

# Run build
./build.sh

if [ $? -eq 0 ]; then
  RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
    -message "Build successful! Next step?" \
    -title "Build Complete" \
    -action-icon "Deploy:arrow.up.circle.fill" \
    -action-icon "Test:play.fill" \
    -action "View Logs" \
    -action-destructive "Clean Build")
  
  case "$(echo "$RESPONSE" | sed 's/ACTION://')" in
    "action_0")
      deploy_to_production
      ;;
    "action_1")
      run_tests
      ;;
    "action_2")
      view_build_logs
      ;;
    "action_3")
      clean_build_artifacts
      ;;
  esac
else
  ./terminal-notifier.app/Contents/MacOS/terminal-notifier \
    -message "Build failed! Check logs?" \
    -title "Build Failed" \
    -action "View Error Logs" \
    -action-destructive "Retry Build"
fi
```

### Task Management
```bash
#!/bin/bash
# task-manager.sh

TASK="Fix authentication bug"

RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Task: $TASK" \
  -title "Task Reminder" \
  -action-icon "Start:play.circle.fill" \
  -action-icon "Snooze:clock.fill" \
  -action-text "Add Note" \
  -action-destructive "Dismiss")

ACTION=$(echo "$RESPONSE" | sed 's/ACTION://')

if [[ "$ACTION" == action_0 ]]; then
  echo "$TASK - STARTED $(date)" >> tasks.log
  start_task "$TASK"
elif [[ "$ACTION" == action_1 ]]; then
  # Snooze for 1 hour
  echo "Task snoozed"
elif [[ "$ACTION" == action_2:* ]]; then
  NOTE=$(echo "$ACTION" | sed 's/action_2://')
  echo "$TASK - NOTE: $NOTE ($(date))" >> tasks.log
elif [[ "$ACTION" == action_3 ]]; then
  echo "$TASK - DISMISSED $(date)" >> tasks.log
  mark_task_done "$TASK"
fi
```

### Code Review Workflow
```bash
#!/bin/bash
# code-review.sh

PR_TITLE="Add user authentication"
PR_AUTHOR="john@example.com"

RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "PR: $PR_TITLE by $PR_AUTHOR" \
  -title "Code Review Request" \
  -action-icon "Approve:checkmark.seal.fill" \
  -action-icon "Request Changes:xmark.circle.fill" \
  -action-text "Add Review Comment" \
  -action "View PR")

if echo "$RESPONSE" | grep -q "action_2:"; then
  COMMENT=$(echo "$RESPONSE" | sed 's/ACTION:action_2://')
  
  # Confirm comment submission
  CONFIRM=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
    -message "Submit comment: $COMMENT" \
    -action "Submit" \
    -action-destructive "Cancel")
  
  if echo "$CONFIRM" | grep -q "action_0"; then
    submit_review_comment "$PR_TITLE" "$COMMENT"
  fi
fi
```

### Deployment Pipeline
```bash
#!/bin/bash
# deploy-pipeline.sh

STAGE="staging"
VERSION="v2.1.0"

RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Deploy $VERSION to $STAGE?" \
  -title "Deployment" \
  -action-icon "Deploy:rocket.fill" \
  -action-icon "Test First:flask.fill" \
  -action-text "Add Deployment Note" \
  -action-destructive "Cancel Deployment")

ACTION=$(echo "$RESPONSE" | sed 's/ACTION://')

if [[ "$ACTION" == action_0 ]]; then
  deploy_to_staging "$VERSION"
  
  # Notify completion
  ./terminal-notifier.app/Contents/MacOS/terminal-notifier \
    -message "Deployment to $STAGE completed" \
    -title "Deployment Status"
    
elif [[ "$ACTION" == action_1 ]]; then
  run_tests
  if [ $? -eq 0 ]; then
    deploy_to_staging "$VERSION"
  fi
  
elif [[ "$ACTION" == action_2:* ]]; then
  NOTE=$(echo "$ACTION" | sed 's/action_2://')
  deploy_to_staging "$VERSION" --note "$NOTE"
  
elif [[ "$ACTION" == action_3 ]]; then
  echo "Deployment cancelled by user"
fi
```

## Response Format Reference

### Regular Action
```
ACTION:action_0
ACTION:action_1
```

### Text Input Action
```
ACTION:action_0:user_entered_text
ACTION:action_2:Hello World
```

### Parsing Examples
```bash
# Extract action identifier only
ACTION_ID=$(echo "$RESPONSE" | sed 's/ACTION://' | cut -d: -f1)

# Extract text from text input action
TEXT=$(echo "$RESPONSE" | sed 's/ACTION:action_0://')

# Check if response has text (text input action)
if echo "$RESPONSE" | grep -q ":"; then
  # Has text input
  TEXT=$(echo "$RESPONSE" | sed 's/ACTION:action_0://')
else
  # Regular action
  ACTION=$(echo "$RESPONSE" | sed 's/ACTION://')
fi

# Using awk for parsing
ACTION=$(echo "$RESPONSE" | awk -F: '{print $2}')
TEXT=$(echo "$RESPONSE" | awk -F: '{print $3}')

# Using cut
ACTION=$(echo "$RESPONSE" | cut -d: -f2)
TEXT=$(echo "$RESPONSE" | cut -d: -f3-)
```

## Best Practices

1. **Always check for empty responses**: User might dismiss notification
2. **Extract text safely**: Handle cases where text might be empty
3. **Validate user input**: Check text input format/content
4. **Use descriptive action titles**: Make it clear what each action does
5. **Order actions logically**: Primary actions first, destructive last
6. **Provide feedback**: Send confirmation notification after action

## Error Handling

```bash
RESPONSE=$(./terminal-notifier.app/Contents/MacOS/terminal-notifier \
  -message "Continue?" \
  -action "Yes" \
  -action "No")

# Check if response is empty (user dismissed or timed out)
if [ -z "$RESPONSE" ]; then
  echo "No response received (notification dismissed or timed out)"
  exit 1
fi

# Extract and validate
if echo "$RESPONSE" | grep -q "ACTION:"; then
  ACTION=$(echo "$RESPONSE" | sed 's/ACTION://')
  process_action "$ACTION"
else
  echo "Invalid response format: $RESPONSE"
  exit 1
fi
```
