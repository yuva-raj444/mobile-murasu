import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/news_item.dart';

class StorageService {
  static const String _villageKey = 'selectedVillage';
  static const String _notificationsKey = 'notifications';
  static const String _darkModeKey = 'darkMode';

  // Save village selection
  static Future<void> saveVillage(VillageData village) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_villageKey, json.encode(village.toJson()));
  }

  // Get saved village
  static Future<VillageData?> getVillage() async {
    final prefs = await SharedPreferences.getInstance();
    final villageJson = prefs.getString(_villageKey);
    if (villageJson != null) {
      return VillageData.fromJson(json.decode(villageJson));
    }
    return null;
  }

  // Save notification preference
  static Future<void> saveNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  // Get notification preference
  static Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Save dark mode preference
  static Future<void> saveDarkModePreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  // Get dark mode preference
  static Future<bool> getDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  // Save liked news
  static Future<void> saveLikedNews(int newsId, bool isLiked) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('liked_$newsId', isLiked);
  }

  // Get liked status
  static Future<bool> isNewsLiked(int newsId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('liked_$newsId') ?? false;
  }
}
