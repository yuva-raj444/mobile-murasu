import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_item.dart';
import '../utils/app_data.dart';
import '../utils/storage_service.dart';
import '../utils/locale_service.dart';
import '../widgets/news_card.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem news;
  final String villageId;

  const NewsDetailScreen(
      {super.key, required this.news, required this.villageId});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late NewsItem news;
  List<NewsItem> relatedNews = [];
  bool _isLoadingRelated = false;

  @override
  void initState() {
    super.initState();
    news = widget.news;
    _loadLikedStatus();
    _loadRelatedNews();
  }

  Future<void> _loadLikedStatus() async {
    final isLiked = await StorageService.isNewsLiked(news.id);
    setState(() {
      news.isLiked = isLiked;
    });
  }

  Future<void> _loadRelatedNews() async {
    if (widget.villageId.isEmpty) {
      return;
    }

    setState(() {
      _isLoadingRelated = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore
          .collection('villages')
          .doc(widget.villageId)
          .collection('news')
          .orderBy('timestamp', descending: true)
          .limit(4) // Get 4 to exclude current one
          .get();

      final List<NewsItem> loadedNews = [];
      for (var doc in snapshot.docs) {
        // Skip the current news item
        if (doc.id.hashCode == news.id) continue;

        final data = doc.data();
        final timestamp =
            (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

        loadedNews.add(NewsItem(
          id: doc.id.hashCode,
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
          village: news.village,
        ));

        if (loadedNews.length >= 3) break; // Only need 3 related items
      }

      setState(() {
        relatedNews = loadedNews;
        _isLoadingRelated = false;
      });
    } catch (e) {
      debugPrint('Error loading related news: $e');
      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    setState(() {
      news.isLiked = !news.isLiked;
      news.likes += news.isLiked ? 1 : -1;
    });
    await StorageService.saveLikedNews(news.id, news.isLiked);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            news.isLiked ? L10n.t('liked') : L10n.t('unliked'),
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _shareNews() {
    Share.share(
      '${news.title}\n\n${news.description}\n\nமுரசு - உங்கள் கிராமத்தின் குரல்',
      subject: news.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('செய்தி விவரம்'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareNews),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF6B85C), Color(0xFFFFC876)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.article, size: 80, color: Colors.white),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6B85C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppData.categoryLabels[widget.news.category] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF6B85C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meta info
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            news.author,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${news.date} ${news.time}',
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            news.village,
                            style: const TextStyle(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Content
                  Text(
                    news.fullContent,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Divider(height: 32),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleLike,
                          icon: Icon(
                            news.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text('${news.likes}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: news.isLiked
                                ? const Color(0xFF6366F1)
                                : const Color(0xFFF8FAFC),
                            foregroundColor: news.isLiked
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(L10n.t('comment_coming')),
                              ),
                            );
                          },
                          icon: const Icon(Icons.comment),
                          label: Text('${news.comments}'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _shareNews,
                          icon: const Icon(Icons.share),
                          label: const Text('பகிர்'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Related news
                  if (relatedNews.isNotEmpty) ...[
                    Text(
                      L10n.t('related_news'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...relatedNews.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: NewsCard(
                          news: item,
                          isGridView: false,
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => NewsDetailScreen(
                                  news: item,
                                  villageId: widget.villageId,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
