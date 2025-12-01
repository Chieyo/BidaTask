import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../widgets/background/animated_background.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await _authService.getProfile();
      if (result['success'] == true) {
        setState(() {
          _userData = result['user'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userData == null
                ? const Center(child: Text('Failed to load profile'))
                : _buildProfileContent(),
      ),
    );
  }

  Widget _buildProfileContent() {
    final String fullName = _userData!['fullName'] ?? 'User';
    final String email = _userData!['email'] ?? 'No email';
    final String contactNumber = _userData!['contactNumber'] ?? 'No contact';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Header
          Column(
            children: [
              UserAvatar(
                initial: fullName.isNotEmpty ? fullName[0] : 'U',
                size: 100,
                fontSize: 40,
              ),
              const SizedBox(height: 16),
              Text(
                fullName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              if (contactNumber.isNotEmpty)
                Text(
                  contactNumber,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // User Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, 'About', _userData!['about'] ?? 'No information provided'),
                  const Divider(),
                  _buildInfoRow(Icons.location_on, 'Location', _userData!['location'] ?? 'Not specified'),
                  const Divider(),
                  _buildInfoRow(Icons.work, 'Skills', _userData!['skills']?.join(', ') ?? 'Not specified'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Card(
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.edit,
                  title: 'Edit Profile',
                  onTap: () {
                    // Handle edit profile
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    // Handle notifications
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.help,
                  title: 'Help & Support',
                  onTap: () {
                    // Handle help
                  },
                ),
                const Divider(height: 1),
                _buildListTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  textColor: Colors.red,
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}