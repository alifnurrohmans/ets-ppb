import 'package:flutter/material.dart';
import 'package:myinformatika/models/enrollment_model.dart';
import 'package:myinformatika/models/ecourse_model.dart';
import 'package:myinformatika/services/auth_service.dart';
import 'package:myinformatika/services/firebase_service.dart';

class StudentEnrollmentsScreen extends StatelessWidget {
  const StudentEnrollmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _firebaseService = FirebaseService();
    final _authService = AuthService();
    final userId = _authService.currentUserId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Enrollments')),
        body: const Center(child: Text('User not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Enrollments')),
      body: StreamBuilder<List<EnrollmentModel>>(
        stream: _firebaseService.getEnrollmentsByStudent(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final enrollments = snapshot.data ?? [];
          if (enrollments.isEmpty) {
            return const Center(child: Text('You have no enrollments yet'));
          }

          return ListView.builder(
            itemCount: enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = enrollments[index];
              return FutureBuilder<ECourseModel?>(
                future: _firebaseService.getECourse(enrollment.ecourseId),
                builder: (context, courseSnap) {
                  final course = courseSnap.data;
                  return ListTile(
                    title: Text(course?.title ?? enrollment.ecourseId),
                    subtitle: Text('Enrolled at: ${enrollment.enrolledAt.toLocal()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () async {
                        try {
                          await _firebaseService.deleteEnrollment(enrollment.id, enrollment.ecourseId);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unenrolled')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                    ),
                    onTap: course == null
                        ? null
                        : () {
                            Navigator.of(context).pushNamed('/student/course-detail', arguments: course);
                          },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
