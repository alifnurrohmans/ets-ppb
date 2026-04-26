import 'package:flutter/material.dart';
import 'package:myinformatika/models/ecourse_model.dart';
import 'package:myinformatika/services/firebase_service.dart';
import 'package:myinformatika/services/auth_service.dart';

class CoursesListScreen extends StatefulWidget {
  final bool isInstructor;

  const CoursesListScreen({
    Key? key,
    this.isInstructor = false,
  }) : super(key: key);

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _firebaseService = FirebaseService();
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isInstructor ? 'My Courses' : 'Available Courses'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ECourseModel>>(
        stream: isInstructor
            ? _firebaseService.getECoursesByInstructor(_authService.currentUserId!)
            : _firebaseService.getAllECourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final courses = snapshot.data ?? [];

          if (courses.isEmpty) {
            return Center(
              child: Text(
                isInstructor
                    ? 'No courses created yet'
                    : 'No courses available',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: course.thumbnailUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(
                            course.thumbnailUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.school, color: Colors.white),
                        ),
                  title: Text(course.title),
                  subtitle: Text(
                    course.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (course.price != null)
                        Text(
                          '\$${course.price!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (course.enrollmentCount != null)
                        Text(
                          '${course.enrollmentCount} enrolled',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                  onTap: () {
                    if (isInstructor) {
                      Navigator.of(context).pushNamed(
                        '/instructor/course-detail',
                        arguments: course,
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        '/student/course-detail',
                        arguments: course,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isInstructor
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/instructor/create-course'),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  bool get isInstructor => widget.isInstructor;
}
