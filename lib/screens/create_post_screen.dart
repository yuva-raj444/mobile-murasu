import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/locale_service.dart';

class CreatePostScreen extends StatefulWidget {
  final String villageId;
  final String villageName;

  const CreatePostScreen({
    super.key,
    required this.villageId,
    required this.villageName,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    LocaleService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    LocaleService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      // Save to Firestore
      if (widget.villageId.isNotEmpty) {
        try {
          debugPrint('Attempting to save post to Firestore...');
          debugPrint('Village ID: ${widget.villageId}');
          debugPrint('Village Name: ${widget.villageName}');

          final firestore = FirebaseFirestore.instance;

          // Add news to the village's news subcollection
          final docRef = await firestore
              .collection('villages')
              .doc(widget.villageId)
              .collection('news')
              .add({
            'title': _titleController.text,
            'description': _descriptionController.text,
            'fullContent': _descriptionController.text,
            'category': _selectedCategory ?? 'news',
            'author': 'User',
            'timestamp': FieldValue.serverTimestamp(),
            'likes': 0,
            'comments': 0,
            'shares': 0,
          });

          debugPrint('✅ Post saved successfully! Doc ID: ${docRef.id}');
        } catch (e) {
          debugPrint('❌ Firestore error: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Failed to publish: ${e.toString().contains('permission') ? 'Permission denied. Check Firestore rules.' : e.toString()}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          return;
        }
      } else {
        debugPrint('⚠️ No village ID - cannot save to Firestore');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.t('submit_success')),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(L10n.t('new_post')),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _submitPost),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: L10n.t('title'),
                  hintText: L10n.t('title_hint'),
                  prefixIcon: const Icon(Icons.title),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return L10n.t('title_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: L10n.t('category'),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'news',
                    child: Text(L10n.t('news')),
                  ),
                  DropdownMenuItem(
                    value: 'events',
                    child: Text(L10n.t('events')),
                  ),
                  DropdownMenuItem(
                    value: 'announcements',
                    child: Text(L10n.t('announcements')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return L10n.t('select_category');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: L10n.t('description'),
                  hintText: L10n.t('description_hint'),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return L10n.t('description_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitPost,
                  icon: const Icon(Icons.send),
                  label: Text(
                    L10n.t('publish_post'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
