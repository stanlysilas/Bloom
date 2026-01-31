class BackgroundModel {
  final String name;
  final String url;

  BackgroundModel({required this.name, required this.url});

  factory BackgroundModel.fromJson(Map<String, dynamic> json) {
    return BackgroundModel(
      name: json['name'] ?? 'Untitled',
      url: json['url'] ?? '',
    );
  }
}
