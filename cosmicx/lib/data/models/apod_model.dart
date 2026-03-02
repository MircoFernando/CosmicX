class ApodModel {
  final String title;
  final String url;
  final String explanation;
  final String date;

  ApodModel({
    required this.title,
    required this.url,
    required this.explanation,
    required this.date,
  });

  // Factory constructor to create an ApodModel from JSON
  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      title: json['title'] ?? 'Cosmic Mystery',
      url: json['url'] ?? '',
      explanation: json['explanation'] ?? 'No data available.',
      date: json['date'] ?? '',
    );
  }

  // Convert to JSON for local storage (Offline Mode)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'explanation': explanation,
      'date': date,
    };
  }
}
