# My Informatika - Complete API Reference

## 📚 Table of Contents
1. [Models](#models)
2. [Services](#services)
3. [Screens](#screens)
4. [Examples](#examples)

---

## Models

### UserModel
Represents a user in the system (Student or Instructor)

```dart
class UserModel {
  final String id;                    // Firebase UID
  final String name;                  // User's full name
  final String email;                 // User's email
  final UserRole role;                // 'instructor' or 'student'
  final DateTime createdAt;           // Account creation date
  final String? profileImageUrl;      // Optional profile picture
}

enum UserRole { instructor, student }
```

**Usage:**
```dart
final user = UserModel(
  id: 'uid123',
  name: 'Budi Santoso',
  email: 'budi@example.com',
  role: UserRole.student,
  createdAt: DateTime.now(),
);

// Convert to/from Firestore
Map<String, dynamic> map = user.toMap();
UserModel user = UserModel.fromMap(map);
```

---

### ECourseModel
Represents a course offered by an instructor

```dart
class ECourseModel {
  final String id;                    // Firestore document ID
  final String instructorId;          // FK to users.id
  final String title;                 // Course title
  final String description;           // Course description
  final String? thumbnailUrl;         // Course image
  final DateTime createdAt;           // Course creation date
  final String? category;             // e.g., 'Flutter', 'Web'
  final double? price;                // Course price (optional)
  final int? enrollmentCount;         // Number of enrolled students
}
```

**Usage:**
```dart
final course = ECourseModel(
  id: 'course-001',
  instructorId: 'instructor-uid',
  title: 'Flutter Development Fundamentals',
  description: 'Learn Flutter basics and advanced concepts',
  createdAt: DateTime.now(),
  category: 'Mobile Development',
  price: 49.99,
);

Map<String, dynamic> map = course.toMap();
ECourseModel course = ECourseModel.fromMap(map);
```

---

### EnrollmentModel
Represents a student's enrollment in a course (Many-to-Many relationship)

```dart
class EnrollmentModel {
  final String id;                    // Firestore document ID
  final String studentId;             // FK to users.id
  final String ecourseId;             // FK to ecourses.id
  final DateTime enrolledAt;          // Enrollment date
  final bool completed;               // Course completion status
  final DateTime? completedAt;        // Completion date (optional)
}
```

**Usage:**
```dart
final enrollment = EnrollmentModel(
  id: 'enrollment-001',
  studentId: 'student-uid',
  ecourseId: 'course-001',
  enrolledAt: DateTime.now(),
);

Map<String, dynamic> map = enrollment.toMap();
EnrollmentModel enrollment = EnrollmentModel.fromMap(map);
```

---

## Services

### AuthService
Handles Firebase Authentication operations

**Singleton Pattern:**
```dart
final authService = AuthService(); // Same instance everywhere
```

**Properties:**
```dart
User? currentUser              // Get current Firebase user
Stream<User?> authStateChanges // Listen to auth state changes  
String? currentUserId          // Get current user's UID
```

**Methods:**

#### Sign Up
```dart
Future<UserCredential> signUp({
  required String email,
  required String password,
  required String name,
  required UserRole role,
})
```
- Creates Firebase Auth user
- Creates user document in Firestore
- Returns UserCredential

**Example:**
```dart
try {
  await authService.signUp(
    email: 'student@example.com',
    password: 'securePassword123',
    name: 'Ahmad Pratama',
    role: UserRole.student,
  );
} catch (e) {
  print('Sign up failed: $e');
}
```

#### Sign In
```dart
Future<UserCredential> signIn({
  required String email,
  required String password,
})
```
- Authenticates user with Firebase
- Returns UserCredential

**Example:**
```dart
try {
  await authService.signIn(
    email: 'student@example.com',
    password: 'securePassword123',
  );
} catch (e) {
  print('Login failed: $e');
}
```

#### Sign Out
```dart
Future<void> signOut()
```
- Signs out current user
- Clears authentication

**Example:**
```dart
await authService.signOut();
Navigator.pushReplacementNamed(context, '/login');
```

#### Reset Password
```dart
Future<void> resetPassword({required String email})
```
- Sends password reset email

**Example:**
```dart
await authService.resetPassword(email: 'user@example.com');
```

#### Update Profile
```dart
Future<void> updateUserProfile({
  required String displayName,
  String? photoUrl,
})
```
- Updates Firebase Auth profile

**Example:**
```dart
await authService.updateUserProfile(
  displayName: 'Ahmad Pratama',
  photoUrl: 'https://example.com/photo.jpg',
);
```

#### Get User Role
```dart
Future<UserRole?> getUserRole(String userId)
```
- Retrieves user's role from Firestore

**Example:**
```dart
UserRole? role = await authService.getUserRole(userId);
if (role == UserRole.instructor) {
  // Show instructor features
} else {
  // Show student features
}
```

---

### FirebaseService
Handles all CRUD operations with Firestore

**Singleton Pattern:**
```dart
final firebaseService = FirebaseService();
```

#### User Operations

**Create User:**
```dart
Future<void> createUser(UserModel user)
```
```dart
await firebaseService.createUser(userModel);
```

**Get User:**
```dart
Future<UserModel?> getUser(String userId)
```
```dart
UserModel? user = await firebaseService.getUser('user-id-123');
```

**Get User by Email:**
```dart
Future<UserModel?> getUserByEmail(String email)
```
```dart
UserModel? user = await firebaseService.getUserByEmail('user@example.com');
```

**Update User:**
```dart
Future<void> updateUser(UserModel user)
```
```dart
final updatedUser = user.copyWith(name: 'New Name');
await firebaseService.updateUser(updatedUser);
```

**Delete User:**
```dart
Future<void> deleteUser(String userId)
```
```dart
await firebaseService.deleteUser(userId);
```

**Get Users by Role (Stream):**
```dart
Stream<List<UserModel>> getUsersByRole(UserRole role)
```
```dart
firebaseService.getUsersByRole(UserRole.instructor).listen((instructors) {
  print('Found ${instructors.length} instructors');
});
```

---

#### ECourse Operations

**Create Course:**
```dart
Future<String> createECourse(ECourseModel ecourse)
```
- Returns the course ID
```dart
String courseId = await firebaseService.createECourse(courseModel);
```

**Get Course:**
```dart
Future<ECourseModel?> getECourse(String ecourseId)
```
```dart
ECourseModel? course = await firebaseService.getECourse('course-id');
```

**Update Course:**
```dart
Future<void> updateECourse(ECourseModel ecourse)
```
```dart
final updatedCourse = course.copyWith(price: 79.99);
await firebaseService.updateECourse(updatedCourse);
```

**Delete Course:**
```dart
Future<void> deleteECourse(String ecourseId)
```
```dart
await firebaseService.deleteECourse('course-id');
```

**Get Courses by Instructor (Stream):**
```dart
Stream<List<ECourseModel>> getECoursesByInstructor(String instructorId)
```
```dart
firebaseService.getECoursesByInstructor(instructorId).listen((courses) {
  setState(() {
    myCourses = courses;
  });
});
```

**Get All Courses (Stream):**
```dart
Stream<List<ECourseModel>> getAllECourses()
```
```dart
firebaseService.getAllECourses().listen((courses) {
  print('Total courses: ${courses.length}');
});
```

---

#### Enrollment Operations

**Create Enrollment:**
```dart
Future<String> createEnrollment(EnrollmentModel enrollment)
```
- Automatically increments course enrollment count
- Returns enrollment ID

```dart
String enrollmentId = await firebaseService.createEnrollment(enrollmentModel);
```

**Get Enrollment:**
```dart
Future<EnrollmentModel?> getEnrollment(String enrollmentId)
```
```dart
EnrollmentModel? enrollment = await firebaseService.getEnrollment('enrollment-id');
```

**Update Enrollment:**
```dart
Future<void> updateEnrollment(EnrollmentModel enrollment)
```
```dart
final completedEnrollment = enrollment.copyWith(
  completed: true,
  completedAt: DateTime.now(),
);
await firebaseService.updateEnrollment(completedEnrollment);
```

**Delete Enrollment:**
```dart
Future<void> deleteEnrollment(String enrollmentId, String ecourseId)
```
- Automatically decrements course enrollment count

```dart
await firebaseService.deleteEnrollment(enrollmentId, courseId);
```

**Get Enrollments by Student (Stream):**
```dart
Stream<List<EnrollmentModel>> getEnrollmentsByStudent(String studentId)
```
```dart
firebaseService.getEnrollmentsByStudent(studentId).listen((enrollments) {
  print('Student enrolled in ${enrollments.length} courses');
});
```

**Get Enrollments by Course (Stream):**
```dart
Stream<List<EnrollmentModel>> getEnrollmentsByECourse(String ecourseId)
```
```dart
firebaseService.getEnrollmentsByECourse(courseId).listen((enrollments) {
  print('${enrollments.length} students enrolled');
});
```

**Check if Student is Enrolled:**
```dart
Future<bool> isStudentEnrolled(String studentId, String ecourseId)
```
```dart
bool isEnrolled = await firebaseService.isStudentEnrolled(studentId, courseId);
if (isEnrolled) {
  // Show "Already Enrolled" or "Go to Course"
}
```

**Get Student Enrollment Count:**
```dart
Future<int> getStudentEnrollmentCount(String studentId)
```
```dart
int count = await firebaseService.getStudentEnrollmentCount(studentId);
print('Student has $count enrollments');
```

---

### CameraService
Handles device camera operations

**Singleton Pattern:**
```dart
final cameraService = CameraService();
```

**Properties:**
```dart
CameraController controller    // Flutter CameraController
bool isInitialized             // Is camera initialized?
```

**Methods:**

**Initialize Camera:**
```dart
Future<void> initialize()
```
```dart
try {
  await cameraService.initialize();
} catch (e) {
  print('Camera init failed: $e');
}
```

**Switch Camera:**
```dart
Future<void> switchCamera()
```
- Toggles between front and back camera
```dart
await cameraService.switchCamera();
```

**Take Picture:**
```dart
Future<XFile?> takePicture()
```
- Returns XFile with photo path

```dart
XFile? photo = await cameraService.takePicture();
if (photo != null) {
  print('Photo saved at: ${photo.path}');
}
```

**Start Video Recording:**
```dart
Future<void> startVideoRecording()
```
```dart
await cameraService.startVideoRecording();
setState(() { isRecording = true; });
```

**Stop Video Recording:**
```dart
Future<XFile?> stopVideoRecording()
```
- Returns XFile with video path

```dart
XFile? video = await cameraService.stopVideoRecording();
setState(() { isRecording = false; });
```

**Dispose:**
```dart
Future<void> dispose()
```
- Always call when leaving screen
```dart
@override
void dispose() {
  cameraService.dispose();
  super.dispose();
}
```

---

### LocationService
Handles device GPS and location services

**Singleton Pattern:**
```dart
final locationService = LocationService();
```

**Methods:**

**Check Location Service Enabled:**
```dart
Future<bool> isLocationServiceEnabled()
```
```dart
bool enabled = await locationService.isLocationServiceEnabled();
if (!enabled) {
  print('Location services disabled');
}
```

**Request Permission:**
```dart
Future<LocationPermission> requestLocationPermission()
```
```dart
LocationPermission permission = 
    await locationService.requestLocationPermission();
```

**Get Current Location:**
```dart
Future<Position?> getCurrentLocation()
```
- Returns Position with lat/lng/altitude/accuracy

```dart
Position? position = await locationService.getCurrentLocation();
if (position != null) {
  print('Lat: ${position.latitude}');
  print('Lng: ${position.longitude}');
}
```

**Get Position Stream (Real-time):**
```dart
Stream<Position> getPositionStream({
  int distanceFilter = 10,      // meters between updates
  int timeInterval = 5000,      // milliseconds between updates
})
```
```dart
locationService.getPositionStream()
  .listen((Position position) {
    print('Updated: ${position.latitude}, ${position.longitude}');
  });
```

**Calculate Distance:**
```dart
double calculateDistance(
  double lat1, double lon1,
  double lat2, double lon2
)
```
- Returns distance in meters

```dart
double distance = locationService.calculateDistance(
  -6.2088, 106.8456,  // Jakarta
  -6.3667, 106.8333,  // Bogor
);
print('Distance: ${(distance / 1000).toStringAsFixed(2)} km');
```

**Check Permission Status:**
```dart
Future<LocationPermission> checkPermission()
```
```dart
LocationPermission permission = await locationService.checkPermission();
```

**Open Location Settings:**
```dart
Future<bool> openLocationSettings()
```
```dart
await locationService.openLocationSettings();
```

**Format Position:**
```dart
String formatPosition(Position position)
```
```dart
String formatted = locationService.formatPosition(position);
print(formatted); // "Latitude: -6.2088, Longitude: 106.8456"
```

---

### NotificationService
Handles local push notifications

**Singleton Pattern:**
```dart
final notificationService = NotificationService();
```

**Initialize (Required in main.dart):**
```dart
Future<void> initialize()
```
```dart
await NotificationService().initialize();
```

**Show Basic Notification:**
```dart
Future<void> showNotification({
  required String title,
  required String body,
  String? summary,
  String channelKey = 'basic_channel',
  NotificationLayout notificationLayout = NotificationLayout.Default,
  Map<String, String>? payload,
  int id = 0,
})
```
```dart
await notificationService.showNotification(
  title: 'Course Update',
  body: 'New lessons available in Flutter Basics',
  channelKey: 'course_channel',
  id: 1,
);
```

**Show Enrollment Notification:**
```dart
Future<void> showEnrollmentNotification({
  required String courseName,
  required String instructorName,
  String? payload,
})
```
```dart
await notificationService.showEnrollmentNotification(
  courseName: 'Flutter Development',
  instructorName: 'John Doe',
);
```

**Show New Course Notification:**
```dart
Future<void> showNewCourseNotification({
  required String courseName,
  required String instructorName,
})
```
```dart
await notificationService.showNewCourseNotification(
  courseName: 'Web Development with React',
  instructorName: 'Jane Smith',
);
```

**Set Badge Count:**
```dart
Future<void> setBadgeCount(int count)
```
```dart
await notificationService.setBadgeCount(3);
```

**Cancel Notification:**
```dart
Future<void> cancelNotification(int id)
```
```dart
await notificationService.cancelNotification(1);
```

**Cancel All Notifications:**
```dart
Future<void> cancelAllNotifications()
```
```dart
await notificationService.cancelAllNotifications();
```

---

## Screens

### LoginScreen
User login interface

**Route:** `/login`

**Features:**
- Email input
- Password input with visibility toggle
- Error message display
- Loading indicator
- Navigation to signup

**Usage:**
```dart
Navigator.pushNamed(context, '/login');
```

---

### SignupScreen
User registration interface

**Route:** `/signup`

**Features:**
- Name, email, password inputs
- Password confirmation
- Role selection (Student/Instructor)
- Form validation
- Error handling

**Usage:**
```dart
Navigator.pushNamed(context, '/signup');
```

---

### HomeScreen
Main dashboard (role-based)

**Route:** `/home`

**Features for Students:**
- Browse Courses
- My Enrollments
- Camera
- Location

**Features for Instructors:**
- Manage Courses
- Create New Course
- View Enrollments
- Camera
- Location

---

### CameraScreen
Takes photos and records videos

**Route:** `/camera`

**Features:**
- Live camera preview
- Switch camera (front/back)
- Take photo button
- Record video button
- Real-time recording indicator

---

### LocationScreen
GPS tracking interface

**Route:** `/location`

**Features:**
- Current location display
- Get location button
- Real-time tracking toggle
- Location details (lat, lng, altitude, accuracy)
- Settings access for permissions

---

### CoursesListScreen
Lists courses

**Route:** `/student/courses` or `/instructor/courses`

**Constructor:**
```dart
CoursesListScreen({isInstructor: false})
```

**Features:**
- Course list with streaming updates
- Course thumbnail, title, description
- Price and enrollment count
- Search and filter (to implement)

---

### CreateCourseScreen
Create new course (Instructor only)

**Route:** `/instructor/create-course`

**Features:**
- Title input
- Description input
- Category input
- Price input
- Thumbnail URL input
- Form validation
- Submit button

---

## Examples

### Complete Sign Up Flow
```dart
// 1. Navigate to signup
Navigator.pushNamed(context, '/signup');

// 2. User fills form and submits
// 3. AuthService.signUp() called with:
//    - email: 'user@example.com'
//    - password: 'password123'
//    - name: 'Ahmad'
//    - role: UserRole.student

// 4. AuthService creates:
//    a) Firebase Auth user
//    b) User document in Firestore

// 5. User auto-logged in and navigated to HomeScreen
```

### Complete Course Creation Flow (Instructor)
```dart
// 1. Navigate to create course screen
Navigator.pushNamed(context, '/instructor/create-course');

// 2. Fill course details and submit
// 3. CreateCourseScreen calls:
ECourseModel course = ECourseModel(
  id: '', // Generated by Firestore
  instructorId: userId,
  title: 'Flutter Basics',
  description: 'Learn Flutter fundamentals',
  createdAt: DateTime.now(),
);
String courseId = await firebaseService.createECourse(course);

// 4. Course appears in instructor's course list via stream
```

### Complete Enrollment Flow (Student)
```dart
// 1. Student browses courses
// 2. Views course details
// 3. Clicks "Enroll"
// 4. EnrollmentModel created:
EnrollmentModel enrollment = EnrollmentModel(
  id: '', // Generated by Firestore
  studentId: userId,
  ecourseId: courseId,
  enrolledAt: DateTime.now(),
);
String enrollmentId = await firebaseService.createEnrollment(enrollment);

// 5. Enrollment count incremented
// 6. Notification shown:
await notificationService.showEnrollmentNotification(
  courseName: course.title,
  instructorName: instructorName,
);

// 7. Course now appears in student's "My Enrollments"
```

### Real-time Synced Course List
```dart
// In build method
StreamBuilder<List<ECourseModel>>(
  stream: firebaseService.getAllECourses(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    List<ECourseModel> courses = snapshot.data ?? [];
    
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return CourseCard(course: courses[index]);
      },
    );
  },
)
// Updates automatically when any instructor creates a course
```

### Camera with Location Tagging
```dart
// Get location
Position? position = await locationService.getCurrentLocation();

// Take photo
XFile? photo = await cameraService.takePicture();

// Save photo metadata with location
if (photo != null && position != null) {
  // Could save to Firebase Storage with metadata
  // photoId, location, timestamp, userId
}
```

---

## Error Handling Examples

```dart
try {
  await authService.signIn(
    email: email,
    password: password,
  );
} on FirebaseAuthException catch (e) {
  // Handled in AuthService._handleAuthException()
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Unexpected error: $e')),
  );
}
```

---

**End of API Reference**
