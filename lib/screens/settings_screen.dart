import 'package:flutter/material.dart';
import '../utils/storage_service.dart';
import 'village_selector_screen.dart';
import '../utils/locale_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _currentVillage = '';
  String _language = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
    LocaleService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {
      _language = LocaleService.locale.languageCode == 'en'
          ? L10n.t('english')
          : L10n.t('tamil');
    });
  }

  Future<void> _loadSettings() async {
    final notifications = await StorageService.getNotificationPreference();
    final darkMode = await StorageService.getDarkModePreference();
    final village = await StorageService.getVillage();

    setState(() {
      _notificationsEnabled = notifications;
      _darkModeEnabled = darkMode;
      _currentVillage = village?.village ?? L10n.t('not_selected');
      _language = LocaleService.locale.languageCode == 'en'
          ? L10n.t('english')
          : L10n.t('tamil');
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
            value
                ? L10n.t('notifications_enabled')
                : L10n.t('notifications_disabled'),
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
        SnackBar(
          content: Text(L10n.t('dark_mode_coming')),
          backgroundColor: const Color(0xFFF59E0B),
        ),
      );
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10n.t('about_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L10n.t('app_name'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(L10n.t('version_label')),
              Text(L10n.t('release_date')),
              const SizedBox(height: 16),
              Text(
                L10n.t('app_description'),
                style: const TextStyle(height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                L10n.t('copyright'),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(L10n.t('ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.t('settings'))),
      body: ListView(
        children: [
          // Account Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              L10n.t('account'),
              style: const TextStyle(
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
            title: Text(L10n.t('profile')),
            subtitle: Text(L10n.t('edit_info')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(L10n.t('profile_edit_coming')),
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
            title: Text(L10n.t('change_village')),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              L10n.t('preferences'),
              style: const TextStyle(
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
            title: Text(L10n.t('notifications')),
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
            title: Text(L10n.t('dark_mode')),
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
            title: Text(L10n.t('language')),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(L10n.t('language')),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(L10n.t('tamil')),
                        onTap: () async {
                          await LocaleService.setLocale(const Locale('ta'));
                          setState(() => _language = L10n.t('tamil'));
                          Navigator.of(context).pop();
                        },
                      ),
                      ListTile(
                        title: Text(L10n.t('english')),
                        onTap: () async {
                          await LocaleService.setLocale(const Locale('en'));
                          setState(() => _language = L10n.t('english'));
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Information Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              L10n.t('information'),
              style: const TextStyle(
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
            title: Text(L10n.t('about')),
            subtitle: Text(L10n.t('version')),
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
            title: Text(L10n.t('help_support')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.t('help_coming'))),
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
            title: Text(L10n.t('privacy_policy')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(L10n.t('privacy_coming')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
