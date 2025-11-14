import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_item.dart';
import '../utils/storage_service.dart';
import '../utils/app_data.dart';
import '../utils/locale_service.dart';
import 'news_feed_screen.dart';

class VillageSelectorScreen extends StatefulWidget {
  const VillageSelectorScreen({super.key});

  @override
  State<VillageSelectorScreen> createState() => _VillageSelectorScreenState();
}

class _VillageSelectorScreenState extends State<VillageSelectorScreen> {
  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedVillage;
  final _manualController = TextEditingController();

  List<String> taluks = [];
  List<String> villages = [];

  @override
  void initState() {
    super.initState();
    LocaleService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _manualController.dispose();
    LocaleService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('select_village')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Icon(Icons.location_on, size: 80, color: Color(0xFF6366F1)),
            const SizedBox(height: 24),
            Text(
              L10n.t('select_your_village'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              L10n.t('select_village_desc'),
              style: const TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Manual village entry
            TextField(
              controller: _manualController,
              decoration: InputDecoration(
                labelText: L10n.t('enter_village'),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 24),

            // District Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedDistrict,
              decoration: InputDecoration(
                labelText: L10n.t('district'),
                prefixIcon: const Icon(Icons.place),
              ),
              items: AppData.districts.keys.map((String district) {
                return DropdownMenuItem(value: district, child: Text(district));
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedDistrict = value;
                  selectedTaluk = null;
                  selectedVillage = null;
                  taluks = value != null ? AppData.districts[value]! : [];
                  villages = [];
                });
              },
            ),
            const SizedBox(height: 24),

            // Taluk Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedTaluk,
              decoration: InputDecoration(
                labelText: L10n.t('taluk'),
                prefixIcon: const Icon(Icons.apartment),
              ),
              items: taluks.map((String taluk) {
                return DropdownMenuItem(value: taluk, child: Text(taluk));
              }).toList(),
              onChanged: selectedDistrict == null
                  ? null
                  : (String? value) {
                      setState(() {
                        selectedTaluk = value;
                        selectedVillage = null;
                        villages =
                            value != null && AppData.villages.containsKey(value)
                                ? AppData.villages[value]!
                                : [];
                      });
                    },
            ),
            const SizedBox(height: 24),

            // Village Dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedVillage,
              decoration: InputDecoration(
                labelText: L10n.t('village'),
                prefixIcon: const Icon(Icons.home),
              ),
              items: villages.map((String village) {
                return DropdownMenuItem(value: village, child: Text(village));
              }).toList(),
              onChanged: selectedTaluk == null
                  ? null
                  : (String? value) {
                      setState(() {
                        selectedVillage = value;
                      });
                    },
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final manual = _manualController.text.trim();

                  String district = selectedDistrict ?? '';
                  String taluk = selectedTaluk ?? '';
                  String villageName = selectedVillage ?? '';

                  if (manual.isNotEmpty) {
                    villageName = manual;
                  }

                  if (villageName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(L10n.t('enter_village'))),
                    );
                    return;
                  }

                  // Use Firestore to lookup or create village (skip on web for now)
                  if (!kIsWeb) {
                    try {
                      final firestore = FirebaseFirestore.instance;
                      final lower = villageName.toLowerCase();
                      final query = await firestore
                          .collection('villages')
                          .where('nameLower', isEqualTo: lower)
                          .limit(1)
                          .get();

                      if (query.docs.isNotEmpty) {
                        // exists
                        final doc = query.docs.first;
                        final data = doc.data();
                        district = data['district'] ?? district;
                        taluk = data['taluk'] ?? taluk;
                        villageName = data['name'] ?? villageName;
                      } else {
                        // create
                        await firestore.collection('villages').add({
                          'name': villageName,
                          'nameLower': lower,
                          'district': district,
                          'taluk': taluk,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                      }
                    } catch (e) {
                      // Firestore not configured or error - continue with local storage
                      debugPrint('Firestore error: $e');
                    }
                  }

                  final villageData = VillageData(
                    district: district.isNotEmpty ? district : 'Unknown',
                    taluk: taluk.isNotEmpty ? taluk : 'Unknown',
                    village: villageName,
                  );

                  await StorageService.saveVillage(villageData);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(L10n.t('village_selected')),
                      backgroundColor: const Color(0xFF10B981),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  await Future.delayed(const Duration(seconds: 1));

                  if (!context.mounted) return;

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const NewsFeedScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(L10n.t('continue'),
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
