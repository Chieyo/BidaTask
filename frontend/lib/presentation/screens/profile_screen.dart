import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/auth_service.dart';
import '../widgets/user_avatar.dart';
import '../widgets/background/animated_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _autoMatching = true;
  bool _notificationsEnabled = true;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<String> _primaryCategories = [];
  List<String> _matchCategories = [];
  bool _showCategorySelection = false;
  List<String> _selectedCategories = [];
  final List<String> _allCategories = [
    'Household Chores',
    'General Assistance',
    'Personal',
    'Delivery',
    'Shopping',
    'Online Assistance'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final result = await _authService.getProfile();
      if (result['success'] == true && mounted) {
        setState(() {
          _userData = result['user'] ?? {};
          
          // Set default categories that match your database
          final defaultCategories = [
            'Household Chores',
            'General Assistance',
            'Personal',
            'Delivery',
            'Shopping',
            'Online Assistance'
          ];
          
          // Use user's categories if available, otherwise use default categories
          _primaryCategories = List<String>.from(
            _userData?['categories'] ?? 
            _userData?['primaryCategories'] ?? 
            defaultCategories
          );
          
          _matchCategories = List<String>.from(_primaryCategories);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _toggleAutoMatching(bool value) {
    setState(() => _autoMatching = value);
  }

  void _toggleNotifications(bool value) {
    setState(() => _notificationsEnabled = value);
  }

  void _toggleCategorySelection() {
    setState(() {
      _showCategorySelection = !_showCategorySelection;
      if (!_showCategorySelection) {
        // When closing the selection, update the primary categories
        _primaryCategories = List.from(_selectedCategories);
        _matchCategories = List.from(_selectedCategories);
        // Here you would typically save the selected categories to your backend
        // _saveCategoriesToBackend(_selectedCategories);
      } else {
        // When opening the selection, initialize with current selection
        _selectedCategories = List.from(_primaryCategories);
      }
    });
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  Future<void> _saveCategoriesToBackend(List<String> categories) async {
    try {
      // TODO: Implement the API call to save the categories
      // Example:
      // await _authService.updateUserCategories(categories);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categories updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update categories: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated background in header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200, // Height of the header area
            child: AnimatedBackground(
              child: Container(
                color: const Color(0xFF2196F3).withOpacity(0.1),
              ),
            ),
          ),
          // Main content
          Column(
            children: [
              // App bar (fixed at top)
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'My Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
              // Scrollable content
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile header at the top of scrollable content
                        _buildProfileHeader(),
                        const SizedBox(height: 16),
                        // Rest of the content
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 16),
                        _buildPrimaryCategoriesCard(),
                        const SizedBox(height: 16),
                        _buildWalletCard(),
                        const SizedBox(height: 16),
                        _buildSettingsCard(),
                        const SizedBox(height: 24),
                        _buildLogoutButton(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _userData?['data']?['user'] ?? _userData ?? {};
    final displayName = user['name'] ?? user['fullName'] ?? 'User';
    final rating = (user['rating'] ?? 0.0).toDouble();
    final trustTier = user['trustTier'] ?? 0;
    final completedTasks = user['completedTasks'] ?? 0;
    final postedTasks = user['postedTasks'] ?? 0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              UserAvatar(
                initial: displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                size: 100,
                fontSize: 40,
                isAssigned: true,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2196F3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${rating.toStringAsFixed(1)} | Trust Tier $trustTier',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Completed: $completedTasks',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Posted: $postedTasks',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final user = _userData?['data']?['user'] ?? _userData ?? {};
    final bio = user['bio'] ?? 'No bio provided';
    final email = user['email'] ?? 'No email';
    final phone = user['phoneNumber'] ?? user['phone'] ?? user['contactNumber'] ?? 'Not provided';
    final age = user['age']?.toString() ?? 'Not specified';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Personal Info',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Bio:', '"$bio"'),
                const SizedBox(height: 12),
                _buildInfoRow('Email:', email),
                const SizedBox(height: 12),
                _buildInfoRow('Contact Number:', phone),
                const SizedBox(height: 12),
                _buildInfoRow('Age:', age),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryCategoriesCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Primary Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: _toggleCategorySelection,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                  ),
                  child: Text(
                    _showCategorySelection ? 'Save' : 'Edit',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2196F3),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _showCategorySelection
                ? _buildCategorySelection()
                : _buildSelectedCategories(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCategories() {
    if (_primaryCategories.isEmpty) {
      return Text(
        'No categories selected',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _primaryCategories.map((category) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Select categories you want to match with:',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _toggleCategory(category),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFE3F2FD),
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? const Color(0xFF1565C0) : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF2196F3) 
                      : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Wallet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Container(
            padding: const EdgeInsets.all(16),
            // child: Text(
            //   'Balance: \₱${_userData?['walletBalance']?.toStringAsFixed(2) ?? '0.00'}',
            //   style: GoogleFonts.poppins(
            //     fontSize: 14,
            //     color: Colors.black87,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSettingItem(
                  'Enable Auto Matching',
                  _autoMatching,
                  _toggleAutoMatching,
                ),
                if (_matchCategories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Match Category:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _matchCategories.map((category) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _matchCategories.remove(category);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {
                  //       // TODO: Implement edit categories
                  //     },
                  //     style: TextButton.styleFrom(
                  //       padding: EdgeInsets.zero,
                  //       minimumSize: Size.zero,
                  //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //     ),
                  //     child: const Text(
                  //       'Edit',
                  //       style: TextStyle(
                  //         fontSize: 12,
                  //         color: Colors.blue,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
                const SizedBox(height: 16),
                _buildSettingItem(
                  'Enable Nearby Task Notification',
                  _notificationsEnabled,
                  _toggleNotifications,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2196F3),
            activeTrackColor: const Color(0x802196F3),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE53935), // Text and icon color
          side: const BorderSide(color: Color(0xFFE53935)), // Border color
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.transparent, // Make background transparent
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}