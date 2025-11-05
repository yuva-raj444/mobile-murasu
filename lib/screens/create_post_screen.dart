import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/news_item.dart';
import '../utils/app_data.dart';
import '../utils/storage_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  File? _imageFile;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      final village = await StorageService.getVillage();

      final newPost = NewsItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        description: _descriptionController.text,
        fullContent: _descriptionController.text,
        category: _selectedCategory!,
        author: 'நீங்கள்',
        date: DateTime.now().toString().split(' ')[0],
        time: TimeOfDay.now().format(context),
        likes: 0,
        comments: 0,
        shares: 0,
        village: village?.village ?? 'Unknown',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('இடுகை வெற்றிகரமாக வெளியிடப்பட்டது!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pop(true);
        }
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
        title: const Text('புதிய இடுகை'),
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
                decoration: const InputDecoration(
                  labelText: 'தலைப்பு *',
                  hintText: 'செய்தியின் தலைப்பு',
                  prefixIcon: Icon(Icons.title),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'தலைப்பு தேவை';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'வகை *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'news',
                    child: Text('செய்திகள்'),
                  ),
                  const DropdownMenuItem(
                    value: 'events',
                    child: Text('நிகழ்வுகள்'),
                  ),
                  const DropdownMenuItem(
                    value: 'announcements',
                    child: Text('அறிவிப்புகள்'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'வகையை தேர்ந்தெடுக்கவும்';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'விளக்கம் *',
                  hintText: 'உங்கள் செய்தியை இங்கே எழுதவும்...',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'விளக்கம் தேவை';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image upload
              const Text(
                'படம் (விரும்பினால்)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              if (_imageFile != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                    });
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('படத்தை நீக்கு'),
                ),
              ] else ...[
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'படத்தைத் தேர்ந்தெடுக்க கிளிக் செய்யவும்',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitPost,
                  icon: const Icon(Icons.send),
                  label: const Text(
                    'இடுகையை வெளியிடு',
                    style: TextStyle(fontSize: 16),
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
