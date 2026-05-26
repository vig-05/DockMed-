import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  
  late TextEditingController _nameCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _genderCtrl;
  late TextEditingController _bloodGroupCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _emergencyNameCtrl;
  late TextEditingController _emergencyRelationCtrl;
  late TextEditingController _emergencyPhoneCtrl;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _initControllers(user);
  }

  void _initControllers(UserProvider user) {
    _nameCtrl = TextEditingController(text: user.name == 'Guest' ? '' : user.name);
    _dobCtrl = TextEditingController(text: user.dob == 'Not set' ? '' : user.dob);
    _genderCtrl = TextEditingController(text: user.gender == 'Not set' ? '' : user.gender);
    _bloodGroupCtrl = TextEditingController(text: user.bloodGroup == 'Not set' ? '' : user.bloodGroup);
    _heightCtrl = TextEditingController(text: user.height == '0' ? '' : user.height);
    _weightCtrl = TextEditingController(text: user.weight == '0' ? '' : user.weight);
    _emergencyNameCtrl = TextEditingController(text: user.emergencyName == 'Not set' ? '' : user.emergencyName);
    _emergencyRelationCtrl = TextEditingController(text: user.emergencyRelation == 'Not set' ? '' : user.emergencyRelation);
    _emergencyPhoneCtrl = TextEditingController(text: user.emergencyPhone == 'Not set' ? '' : user.emergencyPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _genderCtrl.dispose();
    _bloodGroupCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _emergencyNameCtrl.dispose();
    _emergencyRelationCtrl.dispose();
    _emergencyPhoneCtrl.dispose();
    super.dispose();
  }

  Widget _buildFieldRow(String label, TextEditingController controller, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _isEditing
                ? TextField(
                    controller: controller,
                    keyboardType: type,
                    textAlign: TextAlign.end,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  )
                : Text(
                    controller.text.isEmpty ? '--' : controller.text,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    if (!user.isLoaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: () {
                user.updateUser(
                  name: _nameCtrl.text.isEmpty ? 'Guest' : _nameCtrl.text,
                  dob: _dobCtrl.text.isEmpty ? 'Not set' : _dobCtrl.text,
                  gender: _genderCtrl.text.isEmpty ? 'Not set' : _genderCtrl.text,
                  bloodGroup: _bloodGroupCtrl.text.isEmpty ? 'Not set' : _bloodGroupCtrl.text,
                  height: _heightCtrl.text.isEmpty ? '0' : _heightCtrl.text,
                  weight: _weightCtrl.text.isEmpty ? '0' : _weightCtrl.text,
                  emergencyName: _emergencyNameCtrl.text.isEmpty ? 'Not set' : _emergencyNameCtrl.text,
                  emergencyRelation: _emergencyRelationCtrl.text.isEmpty ? 'Not set' : _emergencyRelationCtrl.text,
                  emergencyPhone: _emergencyPhoneCtrl.text.isEmpty ? 'Not set' : _emergencyPhoneCtrl.text,
                );
                setState(() => _isEditing = false);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Top Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 50,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified_rounded, color: Colors.green, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Aadhaar Linked',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Info Cards
            _buildCard('Personal Details', [
              _buildFieldRow('Full Name', _nameCtrl),
              const Divider(height: 16),
              _buildFieldRow('Date of Birth', _dobCtrl),
              const Divider(height: 16),
              _buildFieldRow('Gender', _genderCtrl),
              const Divider(height: 16),
              _buildFieldRow('Blood Group', _bloodGroupCtrl),
            ]),

            _buildCard('Body Stats', [
              _buildFieldRow('Height (cm)', _heightCtrl, type: const TextInputType.numberWithOptions(decimal: true)),
              const Divider(height: 16),
              _buildFieldRow('Weight (kg)', _weightCtrl, type: const TextInputType.numberWithOptions(decimal: true)),
              const Divider(height: 16),
              if (!_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('BMI', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      Text(user.bmi.toStringAsFixed(1), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ],
                  ),
                )
            ]),

            _buildCard('Emergency Contact', [
              _buildFieldRow('Name', _emergencyNameCtrl),
              const Divider(height: 16),
              _buildFieldRow('Relationship', _emergencyRelationCtrl),
              const Divider(height: 16),
              _buildFieldRow('Phone', _emergencyPhoneCtrl, type: TextInputType.phone),
            ]),

            if (!_isEditing) ...[
              // Settings Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildListTile('Edit Profile', Icons.edit_rounded, () {
                      _initControllers(user); // reset to current state
                      setState(() => _isEditing = true);
                    }),
                    const Divider(height: 1),
                    _buildListTile('Notifications', Icons.notifications_rounded, () {}),
                    const Divider(height: 1),
                    _buildListTile('Privacy & Security', Icons.security_rounded, () {}),
                    const Divider(height: 1),
                    _buildListTile('Help & Support', Icons.help_outline_rounded, () {}),
                    const Divider(height: 1),
                    _buildListTile('About DockMed', Icons.info_outline_rounded, () {}),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout_rounded),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]
          ],
        ),
      ),
    );
  }
}
