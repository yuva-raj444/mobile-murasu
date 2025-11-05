class NewsItem {
  final int id;
  final String title;
  final String description;
  final String fullContent;
  final String category;
  final String author;
  final String date;
  final String time;
  int likes;
  int comments;
  int shares;
  final String village;
  bool isLiked;

  NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fullContent,
    required this.category,
    required this.author,
    required this.date,
    required this.time,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.village,
    this.isLiked = false,
  });
}

class VillageData {
  final String district;
  final String taluk;
  final String village;

  VillageData({
    required this.district,
    required this.taluk,
    required this.village,
  });

  Map<String, dynamic> toJson() => {
    'district': district,
    'taluk': taluk,
    'village': village,
  };

  factory VillageData.fromJson(Map<String, dynamic> json) => VillageData(
    district: json['district'],
    taluk: json['taluk'],
    village: json['village'],
  );
}
