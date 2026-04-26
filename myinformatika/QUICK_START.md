# Quick Start Recipe - My Informatika Flutter Project

## 🚀 5-Minute Quick Start

### 1. Prerequisites Check
```bash
flutter --version  # Should be 3.11.0+
flutter doctor -v  # All green except possibly iOS/Android if not needed
```

### 2. Initial Setup
```bash
# Navigate to project
cd myinformatika

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Firebase Setup Required
- You should have `firebase_options.dart` already configured
- Firestore database must be created in Firebase Console
- Authentication must be enabled (Email/Password)

## 📱 Testing the App

### Test Flow 1: Authentication
```
1. Tap "Sign Up"
2. Fill in: Name, Email, Password, Confirm Password
3. Select Role: Student or Instructor
4. Tap "Sign Up"
5. Login with the created account
```

### Test Flow 2: As Instructor
```
1. Login as Instructor
2. Home screen shows "Manage Courses"
3. Tap "Create New Course"
4. Fill course details
5. View course in "Manage Courses"
```

### Test Flow 3: As Student
```
1. Login as Student
2. Home screen shows "Browse Courses"
3. Tap "Browse Courses"
4. Select a course and enroll
5. Notification should appear
6. Check "My Enrollments"
```

### Test Flow 4: Camera
```
1. Tap "Take Photo" from home screen
2. Tap camera button to take photo
3. Tap video button to record video (tap again to stop)
4. Tap switch camera to change front/back
```

### Test Flow 5: Location
```
1. Tap "Check Location" from home screen
2. Grant location permission when prompted
3. Tap "Get Current Location"
4. Tap "Start Location Tracking" for real-time updates
```

## 🔑 Key Code Snippets

### Initialize Firebase & Notifications
```dart
// Already done in main.dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
await NotificationService().initialize();
```

### Sign Up New User
```dart
final authService = AuthService();
await authService.signUp(
  email: 'student@example.com',
  password: 'password123',
  name: 'John Doe',
  role: UserRole.student,
);
```

### Create a Course
```dart
final firebaseService = FirebaseService();
final courseId = await firebaseService.createECourse(
  ECourseModel(
    id: '', // Will be set by Firestore
    instructorId: userId,
    title: 'Flutter Basics',
    description: 'Learn Flutter fundamentals',
    createdAt: DateTime.now(),
  ),
);
```

### Listen to Courses
```dart
firebaseService.getAllECourses().listen((courses) {
  print('Courses: ${courses.length}');
  for (final course in courses) {
    print('- ${course.title} by ${course.instructorId}');
  }
});
```

### Enroll in Course
```dart
final enrollmentId = await firebaseService.createEnrollment(
  EnrollmentModel(
    id: '',
    studentId: userId,
    ecourseId: courseId,
    enrolledAt: DateTime.now(),
  ),
);

// Show notification
await NotificationService().showEnrollmentNotification(
  courseName: 'Flutter Basics',
  instructorName: 'Instructor Name',
);
```

### Take Photo
```dart
final cameraService = CameraService();
await cameraService.initialize();
final photo = await cameraService.takePicture();
print('Photo saved: ${photo?.path}');
await cameraService.dispose();
```

### Get Current Location
```dart
final locationService = LocationService();
final position = await locationService.getCurrentLocation();
print('Lat: ${position?.latitude}, Lng: ${position?.longitude}');
```

### Real-time Location Stream
```dart
final positionStream = locationService.getPositionStream();
positionStream.listen((position) {
  print('Updated location: ${position.latitude}, ${position.longitude}');
});
```

## 📊 Database Schema Overview

```
users (collection)
├── id: string (primary key, Firebase UID)
├── name: string
├── email: string
├── role: string ("instructor" or "student")
├── profileImageUrl: string (optional)
└── createdAt: timestamp

ecourses (collection)
├── id: string (primary key)
├── instructorId: string (foreign key → users.id)
├── title: string
├── description: string
├── thumbnailUrl: string (optional)
├── category: string (optional)
├── price: number (optional)
├── enrollmentCount: number
└── createdAt: timestamp

enrollments (collection)
├── id: string (primary key)
├── studentId: string (foreign key → users.id)
├── ecourseId: string (foreign key → ecourses.id)
├── enrolledAt: timestamp
├── completed: boolean
└── completedAt: timestamp (optional)
```

## ⚠️ Common Issues & Solutions

### Issue: "FirebaseException: [core/no-app]"
**Solution**: Ensure Firebase initialization is complete before running the app
```dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### Issue: Camera preview not showing
**Solution**: Check permissions in AndroidManifest.xml or Info.plist
- Android: Add `<uses-permission android:name="android.permission.CAMERA" />`
- iOS: Add `NSCameraUsageDescription` to Info.plist

### Issue: Location returns null
**Solution**: Enable location services on device and grant permission
```dart
final serviceEnabled = await locationService.isLocationServiceEnabled();
if (!serviceEnabled) {
  // Prompt user to enable location
}
```

### Issue: Notifications not showing
**Solution**: Check notification channels are initialized
```dart
await NotificationService().initialize();
```

### Issue: App crashes on startup
**Solution**: Run Flutter analyze and fix issues
```bash
flutter analyze
flutter pub get --offline
flutter clean && flutter pub get
flutter run
```

## 🔐 Firebase Security Rules (Copy to Firebase Console)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Anyone can read courses, only instructors can create
    match /ecourses/{courseId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                       request.resource.data.instructorId == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.instructorId;
    }
    
    // Enrollments - students can create/modify their own
    match /enrollments/{enrollmentId} {
      allow read: if request.auth.uid == resource.data.studentId || 
                     request.auth.uid == get(/databases/$(database)/documents/ecourses/$(resource.data.ecourseId)).data.instructorId;
      allow create: if request.auth.uid == request.resource.data.studentId;
      allow update, delete: if request.auth.uid == resource.data.studentId;
    }
  }
}
```

## 📱 Platform-Specific Setup

### Android Build Configuration
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    ndkVersion "25.1.8937393"
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### iOS Build Configuration
```
iOS Deployment Target: 12.0
Enable bitcode: No (for Firebase)
```

## 🧪 Testing Commands

```bash
# Run with verbose logging
flutter run -v

# Run on specific device
flutter run -d <device-id>

# List available devices
flutter devices

# Run tests
flutter test

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios

# Check for issues
flutter analyze

# Format code
dart format lib/
```

## 📦 Dependency Versions (as of implementation)

```yaml
firebase_core: ^4.7.0
cloud_firestore: ^6.3.0
firebase_auth: ^6.4.0
awesome_notifications: 0.10.1
camera: ^0.11.0+1
geolocator: ^11.0.0
provider: ^6.0.0
http: ^1.1.0
image_picker: ^1.0.4
```

## 🚢 Production Deployment Checklist

- [ ] Test on real Android device
- [ ] Test on real iOS device
- [ ] Generate signed APK/IPA
- [ ] Configure Firebase security rules
- [ ] Enable backup for Firebase data
- [ ] Set up crash reporting
- [ ] Test push notifications
- [ ] Review and optimize performance
- [ ] Create privacy policy (required for app store)
- [ ] Generate app icons and splash screens
- [ ] Create demo video
- [ ] Upload to GitHub

## 🤝 Contributing

When adding new features:
1. Maintain singleton pattern for services
2. Use streams for real-time data
3. Add proper error handling
4. Document new models in SETUP_GUIDE.md
5. Test on both platforms
6. Update this Quick Start if adding public APIs

## 📞 Support

For issues with specific packages:
- Camera issues: Check [camera plugin docs](https://pub.dev/packages/camera)
- Location issues: Check [geolocator docs](https://pub.dev/packages/geolocator)
- Firebase issues: Check [Firebase docs](https://firebase.google.com/docs)
- Notifications: Check [awesome_notifications docs](https://pub.dev/packages/awesome_notifications)

---

**Last Updated**: April 2026
**Project Status**: Feature-Complete for Mini Project Requirements
