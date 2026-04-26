import 'package:flutter/material.dart';
import 'package:myinformatika/models/enrollment_model.dart';
import 'package:myinformatika/models/user_model.dart';
import 'package:myinformatika/services/firebase_service.dart';

class InstructorEnrollmentsScreen extends StatelessWidget {
  const InstructorEnrollmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final ecourseId = args is String ? args : null;

    if (ecourseId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Enrollments')),
        body: const Center(child: Text('No course specified')),
      );
    }

    final _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Enrollments')),
      body: StreamBuilder<List<EnrollmentModel>>(
        stream: _firebaseService.getEnrollmentsByECourse(ecourseId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final enrollments = snapshot.data ?? [];
          if (enrollments.isEmpty) {
            return const Center(child: Text('No enrollments yet'));
          }

          return ListView.builder(
            itemCount: enrollments.length,
            itemBuilder: (context, index) {
              final enrollment = enrollments[index];
              return FutureBuilder<UserModel?>(
                future: _firebaseService.getUser(enrollment.studentId),
                builder: (context, userSnap) {
                  final student = userSnap.data;
                  return ListTile(
                    title: Text(student?.name ?? enrollment.studentId),
                    subtitle: Text('Enrolled at: ${enrollment.enrolledAt.toLocal()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () async {
                        try {
                          await _firebaseService.deleteEnrollment(enrollment.id, enrollment.ecourseId);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrollment removed')));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      },
                    ),
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
