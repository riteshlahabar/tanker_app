/// Search + active/inactive filter shared by the four master-data lists
/// (Tanker/Driver/Customer/Spot) — all four list endpoints read the same
/// `search` and `status` query params via `RespondsWithList`.
class EntityListFilter {
  const EntityListFilter({this.search, this.status});

  final String? search;
  final bool? status;

  EntityListFilter copyWith({String? search, bool? status, bool clearStatus = false}) =>
      EntityListFilter(
        search: search ?? this.search,
        status: clearStatus ? null : (status ?? this.status),
      );
}
