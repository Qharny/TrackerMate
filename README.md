# TrackMate

TrackMate: Find your device, anytime, anywhere.

## Description

TrackMate is a mobile application developed for Nokia mobile accessories to help users track their devices in case they go missing. The app provides real-time location tracking, user authentication, and a map interface to locate lost devices.

## Features

- User registration and authentication
- Real-time device location tracking
- Map interface to display device location
- Remote location retrieval
- Persistent location permission requests

## Technologies Used

- Flutter for cross-platform mobile development
- Dart programming language
- Firebase for backend services:
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Analytics

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- Firebase account

### Installation

1. Clone the repository:
> git clone https://github.com/qharny/trackermate.git

1. Navigate to the project directory:
> cd trackmate

1. Install dependencies:
> flutter pub get

1. Set up Firebase:
- Create a new Firebase project
- Add your Android and iOS apps to the Firebase project
- Download and add the configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)

1. Run the app:
flutter run

## Project Structure
lib/
├── main.dart
├── screens/
├── services/
├── widgets/
├── models/
├── utils/
└── routes.dart

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

- Nokia mobile accessories for the project idea
- Flutter and Firebase teams for their excellent documentation

## Contact

For any queries, please contact Kabutey Mansseh at kabuteymanasseh5@gmail.com.