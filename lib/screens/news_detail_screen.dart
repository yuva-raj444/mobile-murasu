import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/news_item.dart';
import '../utils/app_data.dart';
import '../utils/storage_service.dart';
import '../widgets/news_card.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late NewsItem news;

  @override
  void initState() {
    super.initState();
    news = widget.news;
    _loadLikedStatus();
  }

  Future<void> _loadLikedStatus() async {
    final isLiked = await StorageService.isNewsLiked(news.id);
    setState(() {
      news.isLiked = isLiked;
    });
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
            news.isLiked
                ? 'விருப்பம் சேர்க்கப்பட்டது'
                : 'விருப்பம் நீக்கப்பட்டது',
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
    final relatedNews = AppData.getSampleNews()
        .where((item) => item.category == news.category && item.id != news.id)
        .take(3)
        .toList();

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
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppData.categoryLabels[news.category] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6366F1),
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
                              const SnackBar(
                                content: Text('கருத்து அம்சம் விரைவில் வரும்!'),
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
                    const Text(
                      'தொடர்புடைய செய்திகள்',
                      style: TextStyle(
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
                                builder: (_) => NewsDetailScreen(news: item),
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
