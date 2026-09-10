// This file's entire job is to print a report to the terminal, so the
// avoid_print lint (meant for library/production code) doesn't apply here.
// ignore_for_file: avoid_print

import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final raw in rawBooks) {
    library.add(Book.fromJson(raw));
  }
  library.open();

  final books = library.items.whereType<Book>().toList();

  print('--- Level 4: Collections ---');
  print('All titles: ${library.allTitles.toList()}');
  print(
    'Books after 2010: ${library.booksAfter2010.map((b) => b.title).toList()}',
  );
  print('Average pages: ${library.averagePages.toStringAsFixed(1)}');
  print('Books per author: ${library.bookCountByAuthor}');
  print('Distinct authors: ${library.authorNames}');
  print('Genres present: ${library.genresPresent}');
  print('');
  print(library.report());

  print('');
  print('--- Level 3: Null Safety ---');
  print('Opened at: ${library.openedAt}');
  print('Country of "Clean Code": ${library.countryOf('Clean Code')}');
  print(
    'Country of "Design Patterns": ${library.countryOf('Design Patterns')}',
  );
  print(
    'Country of "Nonexistent Book": ${library.countryOf('Nonexistent Book')}',
  );

  print('');
  print('--- Level 5: Dart 3 ---');
  final stats = statsOf(books);
  print(
    'Stats: count=${stats.count}, avgPages=${stats.avgPages.toStringAsFixed(1)}',
  );

  final states = <ShelfState>[
    const Empty(),
    Ready(books),
    const Broken('shelf collapsed'),
  ];
  for (final state in states) {
    print(describe(state));
  }
}
