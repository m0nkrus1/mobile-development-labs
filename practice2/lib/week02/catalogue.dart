import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title) {
    final matches = items.whereType<Book>().where((b) => b.title == title);
    return matches.isEmpty ? null : matches.first;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  late final DateTime openedAt;

  void open() => openedAt = DateTime.now();

  String? _cachedReport;

  String report() => _cachedReport ??= _buildReport();

  String _buildReport() {
    final display = buildDisplay();
    return display.join('\n');
  }

  Iterable<String> get allTitles => items.map((item) => item.title);

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((b) => b.year > 2010).toList();

  double get averagePages {
    final books = items.whereType<Book>().toList();
    if (books.isEmpty) return 0.0;
    return books.fold<int>(0, (sum, b) => sum + b.pages) / books.length;
  }

  Map<String, int> get bookCountByAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        {},
        (map, b) => map..update(b.author.name, (v) => v + 1, ifAbsent: () => 1),
      );

  Set<String> get authorNames =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> buildDisplay() {
    final books = items.whereType<Book>().toList();
    return [
      'CATALOGUE',
      for (final b in books) '${b.title} (${b.year})',
      ...authorNames,
      if (books.any((b) => b.pages == 0)) '(incomplete data)',
    ];
  }
}
