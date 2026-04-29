# Task Manager App - Flutter CRUD with Back4App

A Flutter-based task manager application that uses Back4App Parse Server as Backend-as-a-Service. The app supports student email registration/login, cloud task CRUD, automatic syncing, and secure logout.

## Features

- User registration and login with email/password
- Back4App Parse User authentication
- Create, read, update, complete, and delete tasks
- Per-user task ownership using a Parse pointer and ACL
- Auto refresh every 8 seconds, with optional Live Query websocket support
- Manual pull-to-refresh and sync button
- Secure logout that invalidates the local session
- Responsive Material 3 UI for web, Android, and desktop targets

## Tech Stack

- Flutter / Dart
- Back4App Parse Server
- `parse_server_sdk_flutter`
- GitHub for version control

## Back4App Configuration

This project is already configured with the provided Back4App app:

- App ID: `yn8KRSfm9hvvLjE2AkcxEDCBnB9VO7YGozMDQfir`
- API URL: `https://parseapi.back4app.com`
- Parse Server: `7.5.2`

The app stores tasks in a Parse class named `Task`. The class is created automatically by Back4App the first time a task is saved, if client class creation is enabled.

Task fields:

- `title` - String
- `description` - String
- `isDone` - Boolean
- `owner` - Pointer to `_User`
- `ACL` - Read/write access for the owner user

## Live Query Setup

The app works without extra setup by querying Back4App and auto-refreshing. For true Live Query websocket updates, enable it in Back4App:

1. Open Back4App dashboard.
2. Go to **App Settings > Server Settings > Server URL and Live Query**.
3. Activate a Back4App subdomain.
4. Enable Live Query.
5. Select the `Task` class for Live Query.
6. Run the app with your subdomain:

```powershell
C:\src\flutter\bin\flutter.bat run -d chrome `
  --dart-define=PARSE_SERVER_URL=https://your-subdomain.b4a.io `
  --dart-define=PARSE_LIVE_QUERY_URL=wss://your-subdomain.b4a.io
```

Back4App Live Query docs: https://www.back4app.com/docs/platform/parse-live-query

## Run Locally

Flutter SDK was installed at `C:\src\flutter`.

```powershell
C:\src\flutter\bin\flutter.bat pub get
C:\src\flutter\bin\flutter.bat run -d chrome
```

For Android:

```powershell
C:\src\flutter\bin\flutter.bat run -d android
```

For Windows desktop builds, enable Windows Developer Mode first because Flutter plugins need symlink support.

## Verification

The project has been checked with:

```powershell
C:\src\flutter\bin\flutter.bat analyze
C:\src\flutter\bin\flutter.bat test
C:\src\flutter\bin\flutter.bat build web
```

## Demo Video Flow

Record a 2-minute video showing:

1. Register with a student email.
2. Logout.
3. Login with the same account.
4. Create a task with title and description.
5. Edit the task.
6. Mark the task completed.
7. Delete the task.
8. Logout securely.

## Presentation

The PowerPoint file is included at:

`docs/Task_Manager_Back4App_Presentation.pptx`

## Screenshots

Login screen:

![Login screen](docs/screenshots/login_screen.png)

Add more screenshots after creating demo data:

- Task list
- Add/Edit task dialog
- Completed task state
