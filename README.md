# Kinetiq - AI Pose Analysis

Kinetiq is a modern FitTech application built with Flutter that allows users to analyze their posture and movement. It captures an image, sends it to a Python backend for MediaPipe keypoint extraction, and provides a visual overlay of the detected pose. The results are saved locally and synced to the cloud.

## Features

* *Image Capture*: Analyze poses from the device camera or gallery.
* *AI Pose Detection*: A Python backend with MediaPipe extracts 33 body landmarks.
* *Local & Cloud Sync*: Session data is saved to a local SQLite database and synced to Firebase Firestore & Storage.
* *Visual Analysis*: View the detected pose skeleton mapped directly onto your image.
* *Modern UI*: A sleek, animated, dark-themed interface built for a great user experience.

## Setup Instructions

To run this project, you need to set up both the Flutter frontend and the Python backend.

#### A. Flutter Frontend Setup

1.  *Prerequisites*:
    * Flutter SDK (Stable channel)
    * A code editor like VS Code or Android Studio.
    * A physical device or emulator for running the app.

2.  *Firebase Configuration*:
    * Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    * Enable *Firestore Database* and *Firebase Storage*.
    * *Crucially, set up your security rules* for development. Go to the "Rules" tab for both Firestore and Storage and set them to allow reads/writes:
        
        // Firestore Rules
        rules_version = '2';
        service cloud.firestore {
          match /databases/{database}/documents {
            match /{document=**} {
              allow read, write: if true; 
            }
          }
        }

        // Storage Rules
        rules_version = '2';
        service firebase.storage {
          match /b/{bucket}/o {
            match /{allPaths=**} {
              allow read, write: if true;
            }
          }
        }
        
        *Warning*: These rules are for development only. Secure your rules before production.
    * Install the FlutterFire CLI and run flutterfire configure in your project root to connect your app to Firebase. This will generate the firebase_options.dart file.

3.  *Project Dependencies*:
    * Run flutter pub get to install all the dependencies listed in pubspec.yaml.

4.  *Backend URL Configuration*:
    * Open the file lib/src/data/datasources/api_service.dart.
    * Change the _baseUrl variable to your computer's local network IP address where the Python backend will be running (e.g., http://192.168.1.7:5000).

#### B. Python Backend Setup

1.  *Prerequisites*: Python 3.x installed.

2.  *Create Project Folder*:
    * Create a new folder on your computer (e.g., kinetiq_backend).
    * Inside it, create app.py and requirements.txt with the code provided.

3.  *Set Up Virtual Environment (Windows)*:
    sh
    # Navigate to your backend folder
    cd kinetiq_backend

    # Create a virtual environment
    python -m venv venv

    # Activate it
    .\venv\Scripts\activate
    

4.  *Install Dependencies*:
    sh
    pip install -r requirements.txt
    

5.  *Run the Server*:
    sh
    python app.py
    
    The server will start on port 5000 and will now be ready to accept requests from the Flutter app.

## Description of Architecture

The application is built using a clean, layered architecture to separate concerns and improve maintainability.

#### Folder Structure

The lib/src directory is organized into three main layers:

* **data/**: The data layer is the single source of truth for all application data.
    * models/: Contains the PoseData model class.
    * datasources/: Contains services that directly interact with external data sources: api_service.dart (for the Python backend), firebase_service.dart, sqlite_helper.dart, and image_picker_service.dart.
    * repositories/: The pose_repository.dart orchestrates the datasources to execute the app's business logic (e.g., fetching keypoints, saving locally, then syncing to the cloud).
* **presentation/**: The presentation layer is responsible for the UI and state management.
    * screens/: Contains the main app screens (HistoryScreen, PoseDetailScreen, etc.).
    * widgets/: Contains reusable UI components like PosePainter and ShimmerLoadingCard.
    * providers/: Manages the application's state.
* **core/**: Contains shared utilities used across the app, such as the AppLogger.

#### State Management

* The app uses the *Provider* package for state management.
* A central PoseProvider is used to hold the application's state (the list of pose history, loading status, etc.).
* The UI widgets listen to the provider for changes and rebuild automatically when the state is updated. The provider interacts with the PoseRepository to perform data operations, completely decoupling the UI from the data layer.

## How Errors are Handled/Logged

Error handling is implemented at multiple levels to ensure the app is robust.

1.  *Centralized Logging*: A custom AppLogger class in lib/src/core/logger.dart is used for all logging. It prints detailed messages, error objects, and stack traces to the console during development (kDebugMode) and does nothing in a release build.

2.  *Service-Level Error Handling*: Each service in the datasources folder is wrapped in try-catch blocks.
    * **ApiService**: Catches network exceptions (e.g., if the backend server is offline) and HTTP errors (e.g., 404, 500), logs them, and returns null.
    * **FirebaseService**: Catches FirebaseException (e.g., permission denied) during image upload or Firestore writes, logs the specific Firebase error code, and returns null or re-throws the exception.
    * **SQLiteHelper**: Catches database exceptions during insert or read operations, logs them, and re-throws.

3.  *Repository-Level Orchestration*: The PoseRepository contains the main workflow logic and has its own top-level try-catch block. If any step in the process fails (e.g., the ApiService returns null), it catches the exception, logs a high-level message like "Error in the main processing flow," and returns a false success status to the provider, preventing the app from crashing.

4.  *UI Feedback*: The PoseProvider receives the success/failure status from the repository. If an operation fails, it can set an _errorMessage in its state, which the UI can then display to the user in a SnackBar or other widget.