import '../utils/json_read.dart';

/// Every paginated list the API returns has the same shape, so the app has one
/// parsing path and one "load more" rule rather than one per screen:
/// `{ items: [...], meta: { current_page, last_page, per_page, total, has_more } }`
class Paginated<T> {
  const Paginated({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMore,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMore;

  const Paginated.empty()
      : items = const [],
        currentPage = 1,
        lastPage = 1,
        perPage = 20,
        total = 0,
        hasMore = false;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> row) parse,
  ) {
    final meta = JsonRead.asMap(json['meta']);

    return Paginated<T>(
      items: JsonRead.asMapList(json['items']).map(parse).toList(growable: false),
      currentPage: JsonRead.asInt(meta['current_page'], fallback: 1),
      lastPage: JsonRead.asInt(meta['last_page'], fallback: 1),
      perPage: JsonRead.asInt(meta['per_page'], fallback: 20),
      total: JsonRead.asInt(meta['total']),
      hasMore: JsonRead.asBool(meta['has_more']),
    );
  }

  bool get isEmpty => items.isEmpty;

  int get nextPage => currentPage + 1;

  /// Appends the next page onto what is already on screen.
  Paginated<T> merge(Paginated<T> next) => Paginated<T>(
        items: [...items, ...next.items],
        currentPage: next.currentPage,
        lastPage: next.lastPage,
        perPage: next.perPage,
        total: next.total,
        hasMore: next.hasMore,
      );
}
