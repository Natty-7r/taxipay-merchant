/// The API's paged list shape.
class Page<T> {
  Page({required this.content, required this.page, required this.totalElements, required this.last});

  final List<T> content;
  final int page;
  final int totalElements;
  final bool last;

  factory Page.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) item) => Page(
        content: (json['content'] as List).map((e) => item(e as Map<String, dynamic>)).toList(),
        page: json['page'] as int,
        totalElements: (json['totalElements'] as num).toInt(),
        last: json['last'] as bool,
      );
}
