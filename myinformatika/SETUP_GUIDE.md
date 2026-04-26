# My Informatika - Flutter & Firebase Project

A comprehensive Flutter application implementing a course management system with Firebase integration, including CRUD operations, authentication, notifications, and smartphone features (camera & GPS).

## Features Implemented

### 1. **CRUD with Relational Database** (10%)
- **Firestore Collections**:
  - `users`: Student and Instructor profiles
  - `ecourses`: Course information with instructor relations
  - `enrollments`: Many-to-many relationship between students and courses
- Full CRUD operations for all entities via `FirebaseService`

### 2. **Firebase Authentication** (5%)
- Sign up with email and password
- Login with authentication
- Sign out functionality
- Password reset capability
- Role-based user management (Instructor/Student)

### 3. **Storing Data in Firebase** (5%)
- Cloud Firestore for all data persistence
- Real-time data synchronization
- Automatic timestamp management
- Profile image URL storage

### 4. **Notifications** (5%)
- Awesome Notifications integration
- Channel-based notifications (basic, course, enrollment)
- Enrollment success notifications
- New course notifications
- Customizable notification payloads

### 5. **Smartphone Resources** (5%)
- **Camera**: Take photos and record videos
- **GPS/Location**: Real-time location tracking with accuracy details

### 6. **Project Submission** (10%)
- Demo video (to be recorded)
- GitHub repository (to be created)

## Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase init
├── models/                   # Data models
│   ├── user_model.dart       # User with role enum
│   ├── ecourse_model.dart    # Course model with instructor relation
│   ├── enrollment_model.dart # Enrollment join table
│   └── index.dart
├── services/                 # Business logic
│   ├── auth_service.dart     # Firebase Auth operations
│   ├── firebase_service.dart # Firestore CRUD operations
│   ├── notification_service.dart # Notifications
│   ├── camera_service.dart   # Camera operations
│   └── location_service.dart # GPS/Location operations
├── screens/                  # UI Screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart      # Role-based home
│   ├── camera_screen.dart    # Camera interface
│   ├── location_screen.dart  # GPS tracking
│   └── courses_list_screen.dart
└── widgets/                  # Reusable widgets
```

## Database Schema

### Users Collection
```
users/
├── id (Primary Key) -> Firebase Auth UID
├── name (String)
├── email (String)
├── role (String) -> 'instructor' or 'student'
├── profileImageUrl (String, optional)
└── createdAt (DateTime)
```

### ECourses Collection
```
ecourses/
├── id (Primary Key)
├── instructorId (Foreign Key -> users.id)
├── title (String)
├── description (String)
├── thumbnailUrl (String, optional)
├── category (String, optional)
├── price (Double, optional)
├── enrollmentCount (Integer)
└── createdAt (DateTime)
```

### Enrollments Collection
```
enrollments/
├── id (Primary Key)
├── studentId (Foreign Key -> users.id)
├── ecourseId (Foreign Key -> ecourses.id)
├── enrolledAt (DateTime)
├── completed (Boolean)
└── completedAt (DateTime, optional)
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.11.0 or higher)
- Firebase Project configured
- Android SDK for Android testing
- Xcode for iOS testing

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd myinformatika
```

2. **Get dependencies**
```bash
flutter pub get
```

3. **Configure Android Permissions**

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
    <!-- Camera permissions -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    
    <!-- Storage permissions (for saving photos/videos) -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <!-- For notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
</manifest>
```

4. **Configure iOS Permissions**

Edit `ios/Runner/Info.plist`:
```xml
<dict>
    <!-- Camera permission -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to take photos</string>
    
    <!-- Location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs your location for GPS tracking</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs your location for GPS tracking</string>
    
    <!-- Background location (optional) -->
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This app needs your location in the background</string>
    
    <!-- Photo library permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs access to your photo library</string>
</dict>
```

5. **Run the app**
```bash
flutter run
```

## Dependencies Added

```yaml
dependencies:
  firebase_core: ^4.7.0        # Firebase initialization
  cloud_firestore: ^6.3.0      # Cloud database
  firebase_auth: ^6.4.0        # Authentication
  awesome_notifications: 0.10.1 # Local notifications
  camera: ^0.11.0+1            # Camera functionality
  geolocator: ^11.0.0          # GPS/Location services
  provider: ^6.0.0             # State management
  http: ^1.1.0                 # HTTP client
  image_picker: ^1.0.4         # Image gallery picker
```

## Key Services

### AuthService
Handles user authentication:
```dart
final authService = AuthService();
await authService.signUp(email: email, password: password, name: name, role: role);
await authService.signIn(email: email, password: password);
await authService.signOut();
```

### FirebaseService
Manages CRUD operations:
```dart
final firebaseService = FirebaseService();
// Users
await firebaseService.createUser(userModel);
UserModel? user = await firebaseService.getUser(userId);

// Courses
String courseId = await firebaseService.createECourse(courseModel);
var courseStream = firebaseService.getECoursesByInstructor(instructorId);

// Enrollments
String enrollmentId = await firebaseService.createEnrollment(enrollmentModel);
```

### CameraService
For camera operations:
```dart
final cameraService = CameraService();
await cameraService.initialize();
XFile? photo = await cameraService.takePicture();
await cameraService.startVideoRecording();
XFile? video = await cameraService.stopVideoRecording();
```

### LocationService
For GPS tracking:
```dart
final locationService = LocationService();
Position? position = await locationService.getCurrentLocation();
var positionStream = locationService.getPositionStream();
double distance = locationService.calculateDistance(lat1, lon1, lat2, lon2);
```

### NotificationService
For notifications:
```dart
final notificationService = NotificationService();
await notificationService.initialize();
await notificationService.showEnrollmentNotification(
  courseName: 'Flutter Basics',
  instructorName: 'John Doe',
);
```

## Usage Examples

### User Registration
```dart
final authService = AuthService();
await authService.signUp(
  email: 'student@example.com',
  password: 'password123',
  name: 'John Doe',
  role: UserRole.student,
);
```

### Creating a Course (Instructor)
```dart
final firebaseService = FirebaseService();
final course = ECourseModel(
  id: 'course-001',
  instructorId: userId,
  title: 'Flutter Development',
  description: 'Learn Flutter from basics',
  createdAt: DateTime.now(),
);
await firebaseService.createECourse(course);
```

### Enrolling in a Course (Student)
```dart
final firebaseService = FirebaseService();
final enrollment = EnrollmentModel(
  id: 'enrollment-001',
  studentId: userId,
  ecourseId: courseId,
  enrolledAt: DateTime.now(),
);
await firebaseService.createEnrollment(enrollment);

// Show notification
final notificationService = NotificationService();
await notificationService.showEnrollmentNotification(
  courseName: course.title,
  instructorName: instructorName,
);
```

### Streaming Real-time Data
```dart
// Listen to user's enrollments in real-time
firebaseService.getEnrollmentsByStudent(userId).listen((enrollments) {
  print('Enrollments updated: ${enrollments.length}');
});

// Listen to all courses
firebaseService.getAllECourses().listen((courses) {
  print('Courses updated: ${courses.length}');
});
```

## Important Notes

### Camera Storage
- Photos are saved to device storage
- Videos are saved with timestamps
- Implement cleanup for old media files if needed

### Location Tracking
- Requires user permission
- High accuracy setting used
- Real-time streaming available with configurable updates

### Firestore Security Rules
Configure appropriate security rules in Firebase Console:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /ecourses/{courseId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth.uid == resource.data.instructorId;
      allow delete: if request.auth.uid == resource.data.instructorId;
    }
    match /enrollments/{enrollmentId} {
      allow read: if request.auth.uid == resource.data.studentId || 
                     request.auth.uid == get(/databases/$(database)/documents/ecourses/$(resource.data.ecourseId)).data.instructorId;
      allow create: if request.auth.uid == request.resource.data.studentId;
      allow update, delete: if request.auth.uid == resource.data.studentId;
    }
  }
}
```

## Testing

### Test Login
1. Use "Sign Up" to create accounts with different roles
2. Test login with created credentials
3. Verify role-based UI differences (Instructor vs Student)

### Test Courses
1. Create a course as an instructor
2. Browse all courses as a student
3. Enroll in a course and verify notification
4. Check enrollment count update

### Test Camera & Location
1. Navigate to camera screen and take photos
2. Check location screen for GPS data
3. Start real-time tracking and move around

## Building & Submission

### Generate APK (Android)
```bash
flutter build apk
```

### Generate IPA (iOS)
```bash
flutter build ios
```

### Prepare Demo Video
- Record 2-3 minute video demonstrating:
  - User registration and login
  - Role-based features (Instructor/Student)
  - Creating/browsing courses
  - Enrollment with notification
  - Camera functionality
  - GPS tracking

### Upload to GitHub
```bash
git init
git add .
git commit -m "Initial commit: My Informatika Flutter Firebase project"
git remote add origin <github-repo-url>
git push -u origin main
```

## Troubleshooting

**Camera not working?**
- Ensure camera permission is granted
- Check AndroidManifest.xml and Info.plist permissions
- Verify device has a camera

**Location showing null?**
- Enable location services on device
- Grant location permission in app
- Check location accuracy settings

**Firebase connection issues?**
- Verify Firebase project credentials in firebase_options.dart
- Check Firestore security rules
- Ensure emulator has internet access

**Notifications not showing?**
- Check notification channel configuration
- Verify permission on Android 12+
- Test in foreground first

## Support & Documentation

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Camera Plugin Docs](https://pub.dev/packages/camera)
- [Geolocator Plugin Docs](https://pub.dev/packages/geolocator)
- [Awesome Notifications Docs](https://pub.dev/packages/awesome_notifications)

## License

This project is part of the ETS PPB course at Informatika.

## Creator

Created as a mini project for mastering Flutter development with Firebase integration.
