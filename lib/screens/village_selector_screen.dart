import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_item.dart';
import '../utils/storage_service.dart';
import '../utils/locale_service.dart';
import 'news_feed_screen.dart';

class VillageSelectorScreen extends StatefulWidget {
  const VillageSelectorScreen({super.key});

  @override
  State<VillageSelectorScreen> createState() => _VillageSelectorScreenState();
}

class _VillageSelectorScreenState extends State<VillageSelectorScreen> {
  final _villageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LocaleService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _villageController.dispose();
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
            const Icon(Icons.location_on, size: 80, color: Color(0xFFF6B85C)),
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
            const SizedBox(height: 48),

            // Manual village entry
            TextField(
              controller: _villageController,
              decoration: InputDecoration(
                labelText: L10n.t('enter_village'),
                hintText: L10n.t('enter_village'),
                prefixIcon: const Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
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

  Future<void> _handleContinue() async {
    final villageName = _villageController.text.trim();

    if (villageName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.t('enter_village'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String district = '';
    String taluk = '';
    String villageId = '';

    // Use Firestore to lookup or create village
    if (true) {
      try {
        debugPrint('Checking Firestore for village: $villageName');
        final firestore = FirebaseFirestore.instance;
        final lower = villageName.toLowerCase();
        final query = await firestore
            .collection('villages')
            .where('nameLower', isEqualTo: lower)
            .limit(1)
            .get();

        debugPrint('Query completed. Found ${query.docs.length} documents');

        if (query.docs.isNotEmpty) {
          // Village exists - get data
          final doc = query.docs.first;
          final data = doc.data();
          villageId = doc.id;
          district = data['district'] ?? '';
          taluk = data['taluk'] ?? '';

          debugPrint('✅ Village found! ID: $villageId');

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${L10n.t('village_found')}: $villageName'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        } else {
          // Create new village
          debugPrint('Creating new village in Firestore...');
          final docRef = await firestore.collection('villages').add({
            'name': villageName,
            'nameLower': lower,
            'district': district,
            'taluk': taluk,
            'createdAt': FieldValue.serverTimestamp(),
          });
          villageId = docRef.id;

          debugPrint('✅ Village created! ID: $villageId');

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${L10n.t('village_created')}: $villageName'),
              backgroundColor: const Color(0xFF3B82F6),
            ),
          );
        }
      } catch (e) {
        // Firestore not configured or error - continue with local storage
        debugPrint('❌ Firestore error: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Firestore Error: ${e.toString().contains('permission') ? 'Permission denied! Check Firebase Console.' : e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final villageData = VillageData(
      id: villageId,
      name: villageName,
      district: district.isNotEmpty ? district : 'Unknown',
      taluk: taluk.isNotEmpty ? taluk : 'Unknown',
      village: villageName,
    );

    await StorageService.saveVillage(villageData);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => NewsFeedScreen(
          villageId: villageId,
          villageName: villageName,
        ),
      ),
    );
  }
}
