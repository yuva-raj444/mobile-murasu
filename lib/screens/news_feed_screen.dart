import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../utils/app_data.dart';
import '../utils/storage_service.dart';
import '../widgets/news_card.dart';
import 'village_selector_screen.dart';
import 'news_detail_screen.dart';
import 'create_post_screen.dart';
import 'settings_screen.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String selectedCategory = 'all';
  bool isGridView = true;
  String villageName = 'முரசு';
  List<NewsItem> newsItems = [];

  @override
  void initState() {
    super.initState();
    _loadVillageName();
    _loadNews();
  }

  Future<void> _loadVillageName() async {
    final village = await StorageService.getVillage();
    if (village != null) {
      setState(() {
        villageName = village.village;
      });
    }
  }

  void _loadNews() {
    setState(() {
      newsItems = AppData.getSampleNews();
    });
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
        title: Text(villageName),
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
                _buildFilterChip('all', 'அனைத்தும்'),
                const SizedBox(width: 8),
                _buildFilterChip('news', 'செய்திகள்'),
                const SizedBox(width: 8),
                _buildFilterChip('events', 'நிகழ்வுகள்'),
                const SizedBox(width: 8),
                _buildFilterChip('announcements', 'அறிவிப்புகள்'),
              ],
            ),
          ),

          // News Feed
          Expanded(
            child: filteredNews.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'செய்திகள் இல்லை',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
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
                        onTap: () => _navigateToDetail(filteredNews[index]),
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
                          onTap: () => _navigateToDetail(filteredNews[index]),
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
                const SnackBar(content: Text('தேடல் அம்சம் விரைவில் வரும்!')),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
              break;
            case 3:
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'முகப்பு'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'தேடல்'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'புதிது',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'அமைப்புகள்',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreatePostScreen()));
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
      selectedColor: const Color(0xFF6366F1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
        width: 2,
      ),
    );
  }

  void _navigateToDetail(NewsItem news) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)));

    if (result == true) {
      _loadNews();
    }
  }
}
