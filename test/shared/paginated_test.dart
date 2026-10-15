import 'package:flutter_test/flutter_test.dart';
import 'package:tanker_app/shared/models/paginated.dart';
import 'package:tanker_app/shared/utils/json_read.dart';

void main() {
  int idOf(Map<String, dynamic> row) => JsonRead.asInt(row['id']);

  test('reads the list shape every panel endpoint returns', () {
    final page = Paginated<int>.fromJson({
      'items': [
        {'id': 1},
        {'id': 2},
      ],
      'meta': {
        'current_page': 1,
        'last_page': 3,
        'per_page': 20,
        'total': 45,
        'has_more': true,
      },
    }, idOf);

    expect(page.items, [1, 2]);
    expect(page.lastPage, 3);
    expect(page.total, 45);
    expect(page.hasMore, isTrue);
    expect(page.nextPage, 2);
  });

  test('survives a response with no meta', () {
    final page = Paginated<int>.fromJson({'items': []}, idOf);

    expect(page.isEmpty, isTrue);
    expect(page.hasMore, isFalse);
    expect(page.currentPage, 1);
  });

  test('merge appends the next page and takes its meta', () {
    final first = Paginated<int>.fromJson({
      'items': [
        {'id': 1},
      ],
      'meta': {'current_page': 1, 'last_page': 2, 'has_more': true, 'total': 2},
    }, idOf);

    final second = Paginated<int>.fromJson({
      'items': [
        {'id': 2},
      ],
      'meta': {'current_page': 2, 'last_page': 2, 'has_more': false, 'total': 2},
    }, idOf);

    final merged = first.merge(second);

    expect(merged.items, [1, 2]);
    expect(merged.currentPage, 2);
    expect(merged.hasMore, isFalse);
  });
}
