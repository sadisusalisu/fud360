import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fud360/models/user.dart';
import 'package:fud360/providers/auth_provider.dart';
import 'package:fud360/theme/app_theme.dart';
import 'package:fud360/widgets/custom_button.dart';
import 'package:fud360/widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _organizationController;

  bool _isEditing = false;
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _organizationController = TextEditingController(text: user?.organization ?? '');
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final profileData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'organization': _organizationController.text.trim(),
    };

    final success = await authProvider.updateProfile(profileData);

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          // Profile header with avatar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: AppTheme.primaryColor,
            child: Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _pickImage : null,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : (user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null) as ImageProvider?,
                          child: user.profileImageUrl == null && _profileImage == null
                              ? Text(
                            user.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getRoleText(user.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Stats'),
              Tab(text: 'Settings'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Profile tab
                _buildProfileTab(user),

                // Stats tab
                _buildStatsTab(user),

                // Settings tab
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;

                    if (!_isEditing) {
                      // Reset controllers if canceling edit
                      _nameController.text = user.name;
                      _emailController.text = user.email;
                      _phoneController.text = user.phone;
                      _organizationController.text = user.organization ?? '';
                      _profileImage = null;
                    }
                  });
                },
                child: Text(_isEditing ? 'Cancel' : 'Edit'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_isEditing) ...[
            // Edit form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _phoneController,
                    labelText: 'Phone',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _organizationController,
                    labelText: 'Organization (Optional)',
                    hintText: 'Enter your organization',
                    prefixIcon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Save Changes',
                    isLoading: Provider.of<AuthProvider>(context).isLoading,
                    onPressed: _updateProfile,
                  ),
                ],
              ),
            ),
          ] else ...[
            // Display information
            _buildInfoTile('Full Name', user.name),
            _buildInfoTile('Email', user.email),
            _buildInfoTile('Phone', user.phone),
            if (user.organization != null && user.organization!.isNotEmpty)
              _buildInfoTile('Organization', user.organization!),
            _buildInfoTile('Joined', '${_getMonthName(user.joinedDate.month)} ${user.joinedDate.year}'),

            const SizedBox(height: 24),

            // Help & Support and Account Settings buttons
            _buildActionTile(
              'Help & Support',
              Icons.help_outline,
                  () {
                // Navigate to help screen
              },
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Account Settings',
              Icons.settings_outlined,
                  () {
                // Navigate to settings screen or switch to settings tab
                _tabController.animateTo(2);
              },
            ),
            const SizedBox(height: 24),

            // Logout button
            CustomButton(
              text: 'Sign Out',
              icon: Icons.logout,
              isOutlined: true,
              onPressed: _logout,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsTab(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Impact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Impact stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                user.role == UserRole.donor ? '15' : '8',
                user.role == UserRole.donor ? 'Donations Made' : 'Items Claimed',
                user.role == UserRole.donor ? Icons.restaurant_outlined : Icons.shopping_basket_outlined,
              ),
              _buildStatCard(
                '${user.impactPoints}',
                'Impact Points',
                Icons.star_outlined,
              ),
              _buildStatCard(
                user.role == UserRole.donor ? '35' : '12',
                'People Fed',
                Icons.people_outlined,
              ),
              _buildStatCard(
                user.role == UserRole.donor ? '12' : '4',
                'kg Food Saved',
                Icons.eco_outlined,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Achievements section
          const Text(
            'Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Achievements grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildAchievementCard(
                'First Donation',
                Icons.emoji_events_outlined,
                Colors.green,
                true,
              ),
              _buildAchievementCard(
                '10+ Donations',
                Icons.emoji_events_outlined,
                Colors.amber,
                true,
              ),
              _buildAchievementCard(
                '50+ Donations',
                Icons.emoji_events_outlined,
                Colors.purple,
                false,
              ),
              _buildAchievementCard(
                'Super Saver',
                Icons.save_alt_outlined,
                Colors.blue,
                true,
              ),
              _buildAchievementCard(
                'Community Hero',
                Icons.volunteer_activism_outlined,
                Colors.red,
                false,
              ),
              _buildAchievementCard(
                'Eco Warrior',
                Icons.eco_outlined,
                Colors.teal,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Notification settings
          _buildSwitchTile(
            'Push Notifications',
            'Receive alerts on your device',
            true,
                (value) {
              // Update push notification setting
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            'Email Notifications',
            'Receive alerts via email',
            true,
                (value) {
              // Update email notification setting
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            'SMS Notifications',
            'Receive alerts via text message',
            false,
                (value) {
              // Update SMS notification setting
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Privacy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Privacy settings
          _buildSwitchTile(
            'Show Profile Picture',
            'Display your photo to other users',
            true,
                (value) {
              // Update profile picture visibility
            },
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            'Share Location',
            'Allow approximate location sharing',
            true,
                (value) {
              // Update location sharing setting
            },
          ),

          const SizedBox(height: 24),
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Account settings
          CustomButton(
            text: 'Change Password',
            isOutlined: true,
            onPressed: () {
              // Navigate to change password screen
            },
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Delete Account',
            isOutlined: true,
            onPressed: () {
              // Show delete account confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Delete account logic
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, IconData icon, Color color, bool unlocked) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? color.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: unlocked ? color.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: unlocked ? color.withOpacity(0.2) : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: unlocked ? color : Colors.grey[400],
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: unlocked ? Colors.black87 : Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          if (!unlocked)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Locked',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  String _getRoleText(UserRole role) {
    switch (role) {
      case UserRole.donor:
        return 'Food Donor';
      case UserRole.receiver:
        return 'Food Receiver';
      case UserRole.volunteer:
        return 'Volunteer Rider';
      case UserRole.admin:
        return 'Admin';
      default:
        return 'User';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
