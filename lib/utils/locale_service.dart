import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _key = 'app_language';
  static Locale _locale = const Locale('ta');
  static final List<VoidCallback> _listeners = [];

  static Locale get locale => _locale;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'ta';
    _locale = Locale(code);
  }

  static void addListener(VoidCallback cb) {
    _listeners.add(cb);
  }

  static void removeListener(VoidCallback cb) {
    _listeners.remove(cb);
  }

  static Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
    for (final l in _listeners) {
      l();
    }
  }
}

/// Basic translation helper for small app strings.
class L10n {
  static const Map<String, Map<String, String>> _strings = {
    'ta': {
      // Village Selector
      'select_village': 'கிராமத்தை தேர்ந்தெடுக்கவும்',
      'select_your_village': 'உங்கள் கிராமத்தை தேர்ந்தெடுக்கவும்',
      'select_village_desc':
          'உங்கள் பகுதியின் செய்திகளைப் பார்க்க கிராமத்தை தேர்வு செய்யவும்',
      'continue': 'தொடரவும்',
      'village_selected': 'கிராமம் தேர்ந்தெடுக்கப்பட்டது!',
      'enter_village': 'கிராமம் பெயரை கையால் உள்ளிடவும்',
      'district': 'மாவட்டம்',
      'taluk': 'வட்டம்',
      'village': 'கிராமம்',

      // News Feed
      'news_feed': 'செய்திகள்',
      'all': 'அனைத்தும்',
      'news': 'செய்திகள்',
      'events': 'நிகழ்வுகள்',
      'announcements': 'அறிவிப்புகள்',
      'no_news': 'செய்திகள் இல்லை',
      'no_news_desc': 'இந்த வகையில் இதுவரை செய்திகள் இல்லை',

      // Create Post
      'submit_success': 'இடுகை வெற்றிகரமாக வெளியிடப்பட்டது!',
      'new_post': 'புதிய இடுகை',
      'title': 'தலைப்பு *',
      'title_hint': 'செய்தியின் தலைப்பு',
      'description': 'விளக்கம் *',
      'description_hint': 'உங்கள் செய்தியை இங்கே எழுதவும்...',
      'category': 'வகை *',
      'select_category': 'வகையை தேர்ந்தெடுக்கவும்',
      'title_required': 'தலைப்பு தேவை',
      'description_required': 'விளக்கம் தேவை',
      'publish_post': 'இடுகையை வெளியிடு',
      'image_note':
          'குறிப்பு: Firestore இலவச திட்டத்தில் படங்கள் ஆதரிக்கப்படவில்லை. உரை இடுகைகள் மட்டுமே சேமிக்கப்படும்.',

      // Village messages
      'village_found': 'கிராமம் கண்டுபிடிக்கப்பட்டது',
      'village_created': 'புதிய கிராமம் உருவாக்கப்பட்டது',

      // Settings
      'settings': 'அமைப்புகள்',
      'account': 'கணக்கு',
      'profile': 'சுயவிவரம்',
      'edit_info': 'உங்கள் தகவல்களைத் திருத்தவும்',
      'change_village': 'கிராமம் மாற்று',
      'not_selected': 'தேர்ந்தெடுக்கப்படவில்லை',
      'preferences': 'விருப்பங்கள்',
      'notifications': 'அறிவிப்புகள்',
      'dark_mode': 'இருண்ட பயன்முறை',
      'language': 'மொழி',
      'tamil': 'தமிழ்',
      'english': 'ஆங்கிலம்',
      'information': 'தகவல்',
      'about': 'முரசு பற்றி',
      'version': 'பதிப்பு 1.0.0',
      'help_support': 'உதவி மற்றும் ஆதரவு',
      'privacy_policy': 'தனியுரிமை கொள்கை',
      'notifications_enabled': 'அறிவிப்புகள் இயக்கப்பட்டன',
      'notifications_disabled': 'அறிவிப்புகள் முடக்கப்பட்டன',
      'dark_mode_coming': 'இருண்ட பயன்முறை விரைவில் வரும்!',
      'profile_edit_coming': 'சுயவிவர திருத்தம் விரைவில் வரும்!',
      'help_coming': 'உதவி பக்கம் விரைவில் வரும்!',
      'privacy_coming': 'தனியுரிமை கொள்கை விரைவில் வரும்!',

      // About Dialog
      'about_title': 'முரசு பற்றி',
      'app_name': 'முரசு - உங்கள் கிராமத்தின் குரல்',
      'version_label': 'பதிப்பு: 1.0.0',
      'release_date': 'வெளியீட்டு தேதி: நவம்பர் 2025',
      'app_description':
          'முரசு என்பது உங்கள் கிராம செய்திகள், நிகழ்வுகள் மற்றும் அறிவிப்புகளை பகிர்ந்து கொள்ளும் சமூக வலைதளமாகும்.',
      'copyright': '© 2025 முரசு. அனைத்து உரிமைகளும் பாதுகாக்கப்பட்டவை.',
      'ok': 'சரி',

      // News Detail
      'read_more': 'மேலும் படிக்க',
      'share': 'பகிர்',

      // Splash
      'village_voice': 'உங்கள் கிராமத்தின் குரல்',

      // Bottom Navigation
      'home': 'முகப்பு',
      'search': 'தேடல்',
      'new': 'புதிது',
      'search_coming': 'தேடல் அம்சம் விரைவில் வரும்!',
    },
    'en': {
      // Village Selector
      'select_village': 'Select Village',
      'select_your_village': 'Select your village',
      'select_village_desc': 'Choose your village to see local news',
      'continue': 'Continue',
      'village_selected': 'Village selected!',
      'enter_village': 'Enter village name manually',
      'district': 'District',
      'taluk': 'Taluk',
      'village': 'Village',

      // News Feed
      'news_feed': 'News Feed',
      'all': 'All',
      'news': 'News',
      'events': 'Events',
      'announcements': 'Announcements',
      'no_news': 'No news',
      'no_news_desc': 'No news in this category yet',

      // Create Post
      'submit_success': 'Post submitted successfully!',
      'new_post': 'New Post',
      'title': 'Title *',
      'title_hint': 'News title',
      'description': 'Description *',
      'description_hint': 'Write your news here...',
      'category': 'Category *',
      'select_category': 'Select category',
      'title_required': 'Title is required',
      'description_required': 'Description is required',
      'publish_post': 'Publish Post',
      'image_note':
          'Note: Images are not supported on Firestore free plan. Only text posts are saved.',

      // Village messages
      'village_found': 'Village found',
      'village_created': 'New village created',

      // Settings
      'settings': 'Settings',
      'account': 'Account',
      'profile': 'Profile',
      'edit_info': 'Edit your information',
      'change_village': 'Change Village',
      'not_selected': 'Not selected',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'tamil': 'Tamil',
      'english': 'English',
      'information': 'Information',
      'about': 'About Murasu',
      'version': 'Version 1.0.0',
      'help_support': 'Help & Support',
      'privacy_policy': 'Privacy Policy',
      'notifications_enabled': 'Notifications enabled',
      'notifications_disabled': 'Notifications disabled',
      'dark_mode_coming': 'Dark mode coming soon!',
      'profile_edit_coming': 'Profile editing coming soon!',
      'help_coming': 'Help page coming soon!',
      'privacy_coming': 'Privacy policy coming soon!',

      // About Dialog
      'about_title': 'About Murasu',
      'app_name': 'Murasu - Your Village Voice',
      'version_label': 'Version: 1.0.0',
      'release_date': 'Release Date: November 2025',
      'app_description':
          'Murasu is a community platform for sharing village news, events, and announcements.',
      'copyright': '© 2025 Murasu. All rights reserved.',
      'ok': 'OK',

      // News Detail
      'read_more': 'Read More',
      'share': 'Share',

      // Splash
      'village_voice': 'Your Village Voice',

      // Bottom Navigation
      'home': 'Home',
      'search': 'Search',
      'new': 'New',
      'search_coming': 'Search feature coming soon!',
    }
  };

  static String t(String key) {
    final code = LocaleService.locale.languageCode;
    return _strings[code]?[key] ?? _strings['ta']![key] ?? key;
  }
}
