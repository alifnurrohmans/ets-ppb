import 'package:flutter/material.dart';
import 'package:myinformatika/models/ecourse_model.dart';
import 'package:myinformatika/models/enrollment_model.dart';
import 'package:myinformatika/models/user_model.dart';
import 'package:myinformatika/services/auth_service.dart';
import 'package:myinformatika/services/firebase_service.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final _firebaseService = FirebaseService();
  final _authService = AuthService();

  late ECourseModel _course;
  UserModel? _instructor;
  bool _isInstructor = false;
  bool _isEnrolled = false;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is ECourseModel) {
      _course = args;
      _loadData();
    } else {
      // If no args, pop back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    try {
      final userId = _authService.currentUserId;
      _isInstructor = userId != null && userId == _course.instructorId;

      // Load instructor info
      _instructor = await _firebaseService.getUser(_course.instructorId);

      // Check enrollment for student
      if (!_isInstructor && userId != null) {
        _isEnrolled = await _firebaseService.isStudentEnrolled(userId, _course.id);
      }
    } catch (e) {
      debugPrint('Error loading course detail: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _enroll() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    setState(() => _actionLoading = true);
    try {
      final enrollment = EnrollmentModel(
        id: '',
        studentId: userId,
        ecourseId: _course.id,
        enrolledAt: DateTime.now(),
      );

      await _firebaseService.createEnrollment(enrollment);
      setState(() => _isEnrolled = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enrolled successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error enrolling: $e')));
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  Future<void> _unenroll() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    setState(() => _actionLoading = true);
    try {
      await _firebaseService.deleteEnrollmentByStudentAndCourse(userId, _course.id);
      setState(() => _isEnrolled = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unenrolled successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error unenrolling: $e')));
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  Future<void> _deleteCourse() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text('Are you sure you want to delete this course? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firebaseService.deleteECourse(_course.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course deleted')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting course: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_loading ? 'Course' : _course.title),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_course.thumbnailUrl != null && _course.thumbnailUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(_course.thumbnailUrl!, height: 180, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _course.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('By ${_instructor?.name ?? _course.instructorId}'),
                  const SizedBox(height: 12),
                  Text(_course.description),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_course.category != null) Chip(label: Text(_course.category!)),
                      const SizedBox(width: 8),
                      if (_course.price != null)
                        Text('\$${_course.price!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_isInstructor) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/instructor/create-course', arguments: _course).then((_) => _loadData());
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Course'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _deleteCourse,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Course'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pushNamed('/instructor/enrollments', arguments: _course.id),
                      child: const Text('View Enrollments'),
                    ),
                  ] else ...[
                    _actionLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _isEnrolled ? _unenroll : _enroll,
                            child: Text(_isEnrolled ? 'Unenroll' : 'Enroll'),
                          ),
                  ],
                ],
              ),
            ),
    );
  }
}
