import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../utils/storage_service.dart';
import '../utils/app_data.dart';
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

  List<String> taluks = [];
  List<String> villages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('கிராமத்தை தேர்ந்தெடுக்கவும்'),
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
            const Text(
              'உங்கள் கிராமத்தை தேர்ந்தெடுக்கவும்',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'உங்கள் பகுதியின் செய்திகளைப் பார்க்க கிராமத்தை தேர்வு செய்யவும்',
              style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // District Dropdown
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: const InputDecoration(
                labelText: 'மாவட்டம்',
                prefixIcon: Icon(Icons.place),
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
              value: selectedTaluk,
              decoration: const InputDecoration(
                labelText: 'வட்டம்',
                prefixIcon: Icon(Icons.apartment),
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
              value: selectedVillage,
              decoration: const InputDecoration(
                labelText: 'கிராமம்',
                prefixIcon: Icon(Icons.home),
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
                onPressed: selectedVillage == null
                    ? null
                    : () async {
                        final villageData = VillageData(
                          district: selectedDistrict!,
                          taluk: selectedTaluk!,
                          village: selectedVillage!,
                        );

                        await StorageService.saveVillage(villageData);

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('கிராமம் தேர்ந்தெடுக்கப்பட்டது!'),
                            backgroundColor: Color(0xFF10B981),
                            duration: Duration(seconds: 1),
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('தொடரவும்', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
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
