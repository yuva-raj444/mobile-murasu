import 'package:flutter/material.dart';
import '../utils/storage_service.dart';
import 'village_selector_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _currentVillage = 'தேர்ந்தெடுக்கப்படவில்லை';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notifications = await StorageService.getNotificationPreference();
    final darkMode = await StorageService.getDarkModePreference();
    final village = await StorageService.getVillage();

    setState(() {
      _notificationsEnabled = notifications;
      _darkModeEnabled = darkMode;
      _currentVillage = village?.village ?? 'தேர்ந்தெடுக்கப்படவில்லை';
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    await StorageService.saveNotificationPreference(value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'அறிவிப்புகள் இயக்கப்பட்டன' : 'அறிவிப்புகள் முடக்கப்பட்டன',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _toggleDarkMode(bool value) async {
    await StorageService.saveDarkModePreference(value);
    setState(() {
      _darkModeEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('இருண்ட பயன்முறை விரைவில் வரும்!'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('முரசு பற்றி'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'முரசு - உங்கள் கிராமத்தின் குரல்',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('பதிப்பு: 1.0.0'),
              Text('வெளியீட்டு தேதி: நவம்பர் 2025'),
              SizedBox(height: 16),
              Text(
                'முரசு என்பது உங்கள் கிராம செய்திகள், நிகழ்வுகள் மற்றும் அறிவிப்புகளை பகிர்ந்து கொள்ளும் சமூக வலைதளமாகும்.',
                style: TextStyle(height: 1.5),
              ),
              SizedBox(height: 16),
              Text(
                '© 2025 முரசு. அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('சரி'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('அமைப்புகள்')),
      body: ListView(
        children: [
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'கணக்கு',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 1,
              ),
            ),
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, color: Color(0xFF6366F1)),
            ),
            title: const Text('சுயவிவரம்'),
            subtitle: const Text('உங்கள் தகவல்களைத் திருத்தவும்'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('சுயவிவர திருத்தம் விரைவில் வரும்!'),
                ),
              );
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: Color(0xFF6366F1)),
            ),
            title: const Text('கிராமம் மாற்று'),
            subtitle: Text(_currentVillage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VillageSelectorScreen(),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Preferences Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'விருப்பங்கள்',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 1,
              ),
            ),
          ),

          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications, color: Color(0xFF6366F1)),
            ),
            title: const Text('அறிவிப்புகள்'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),

          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dark_mode, color: Color(0xFF6366F1)),
            ),
            title: const Text('இருண்ட பயன்முறை'),
            value: _darkModeEnabled,
            onChanged: _toggleDarkMode,
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.language, color: Color(0xFF6366F1)),
            ),
            title: const Text('மொழி'),
            subtitle: const Text('தமிழ்'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('மொழி அமைப்புகள் விரைவில் வரும்!'),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Information Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'தகவல்',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 1,
              ),
            ),
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info, color: Color(0xFF6366F1)),
            ),
            title: const Text('முரசு பற்றி'),
            subtitle: const Text('பதிப்பு 1.0.0'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAboutDialog,
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.help, color: Color(0xFF6366F1)),
            ),
            title: const Text('உதவி மற்றும் ஆதரவு'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('உதவி பக்கம் விரைவில் வரும்!')),
              );
            },
          ),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Color(0xFF6366F1)),
            ),
            title: const Text('தனியுரிமை கொள்கை'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('தனியுரிமை கொள்கை விரைவில் வரும்!'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
