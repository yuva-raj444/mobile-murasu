import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_item.dart';
import '../utils/app_data.dart';
import '../utils/locale_service.dart';
import '../widgets/news_card.dart';
import 'village_selector_screen.dart';
import 'news_detail_screen.dart';
import 'create_post_screen.dart';
import 'settings_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  final String villageId;
  final String villageName;

  const NewsFeedScreen({
    super.key,
    required this.villageId,
    required this.villageName,
  });

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String selectedCategory = 'all';
  bool isGridView = true;
  List<NewsItem> newsItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNews();
    LocaleService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleService.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  Future<void> _loadNews() async {
    if (widget.villageId.isEmpty) {
      // Use sample data if no village ID
      setState(() {
        newsItems = AppData.getSampleNews();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('villages')
          .doc(widget.villageId)
          .collection('news')
          .orderBy('timestamp', descending: true)
          .get();

      final List<NewsItem> loadedNews = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp =
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

        loadedNews.add(NewsItem(
          id: doc.id.hashCode, // Convert string ID to int
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          fullContent: data['fullContent'] ?? data['description'] ?? '',
          category: data['category'] ?? 'general',
          author: data['author'] ?? 'Anonymous',
          date: '${timestamp.day}/${timestamp.month}/${timestamp.year}',
          time:
              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
          likes: data['likes'] ?? 0,
          comments: data['comments'] ?? 0,
          shares: data['shares'] ?? 0,
          village: widget.villageName,
        ));
      }

      setState(() {
        newsItems = loadedNews;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading news: $e');
      setState(() {
        newsItems = [];
        _isLoading = false;
      });
    }
  }

  List<NewsItem> get filteredNews {
    if (selectedCategory == 'all') {
      return newsItems;
    }
    return newsItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VillageSelectorScreen()),
            );
          },
        ),
        title: Text(widget.villageName),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', L10n.t('all')),
                const SizedBox(width: 8),
                _buildFilterChip('news', L10n.t('news')),
                const SizedBox(width: 8),
                _buildFilterChip('events', L10n.t('events')),
                const SizedBox(width: 8),
                _buildFilterChip('announcements', L10n.t('announcements')),
              ],
            ),
          ),

          // News Feed
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              L10n.t('no_news'),
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              L10n.t('no_news_desc'),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: filteredNews.length,
                            itemBuilder: (context, index) {
                              return NewsCard(
                                news: filteredNews[index],
                                isGridView: true,
                                onTap: () =>
                                    _navigateToDetail(filteredNews[index]),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredNews.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: NewsCard(
                                  news: filteredNews[index],
                                  isGridView: false,
                                  onTap: () =>
                                      _navigateToDetail(filteredNews[index]),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.t('search_coming'))),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(
                    villageId: widget.villageId,
                    villageName: widget.villageName,
                  ),
                ),
              );
              break;
            case 3:
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: L10n.t('home')),
          BottomNavigationBarItem(
              icon: const Icon(Icons.search), label: L10n.t('search')),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle),
            label: L10n.t('new'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: L10n.t('settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreatePostScreen(
                villageId: widget.villageId,
                villageName: widget.villageName,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String category, String label) {
    final isSelected = selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedCategory = category;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFF6B85C),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFFF6B85C) : const Color(0xFFE2E8F0),
        width: 2,
      ),
    );
  }

  void _navigateToDetail(NewsItem news) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(
      builder: (_) => NewsDetailScreen(
        news: news,
        villageId: widget.villageId,
      ),
    ));

    if (result == true) {
      _loadNews();
    }
  }
}
