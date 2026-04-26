import 'package:flutter/material.dart';
import 'package:myinformatika/models/user_model.dart';
import 'package:myinformatika/services/auth_service.dart';
import 'package:myinformatika/services/firebase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _firebaseService = FirebaseService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId != null) {
        final user = await _firebaseService.getUser(userId);
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Informatika'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('Profile'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              } else if (value == 'profile') {
                Navigator.of(context).pushNamed('/profile');
              } else if (value == 'settings') {
                Navigator.of(context).pushNamed('/settings');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('Error loading user data'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_currentUser!.role == UserRole.instructor) {
      return _buildInstructorContent();
    } else {
      return _buildStudentContent();
    }
  }

  Widget _buildInstructorContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Welcome, ${_currentUser!.name}!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            title: 'Manage Courses',
            icon: Icons.school,
            onTap: () => Navigator.of(context).pushNamed('/instructor/courses'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'Create New Course',
            icon: Icons.add_circle,
            onTap: () => Navigator.of(context).pushNamed('/instructor/create-course'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'View Enrollments',
            icon: Icons.people,
            onTap: () => Navigator.of(context).pushNamed('/instructor/enrollments'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'Take Photo',
            icon: Icons.camera_alt,
            onTap: () => Navigator.of(context).pushNamed('/camera'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'Check Location',
            icon: Icons.location_on,
            onTap: () => Navigator.of(context).pushNamed('/location'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            'Welcome, ${_currentUser!.name}!',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            title: 'Browse Courses',
            icon: Icons.library_books,
            onTap: () => Navigator.of(context).pushNamed('/student/courses'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'My Enrollments',
            icon: Icons.my_library_books,
            onTap: () => Navigator.of(context).pushNamed('/student/enrollments'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'Take Photo',
            icon: Icons.camera_alt,
            onTap: () => Navigator.of(context).pushNamed('/camera'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            title: 'Check Location',
            icon: Icons.location_on,
            onTap: () => Navigator.of(context).pushNamed('/location'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _authService.signOut().then((_) {
                Navigator.of(context).pushReplacementNamed('/login');
              });
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
