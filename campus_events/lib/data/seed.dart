import '../models/event_category.dart';
import '../models/item.dart';

const _first = [
  'Aigerim',
  'Dana',
  'Timur',
  'Madina',
  'Nursultan',
  'Alina',
  'Arman',
  'Zhanar',
  'Daniyar',
  'Kamila',
];
const _last = ['Omarov', 'Sadykova', 'Akhmetov', 'Nurlanova', 'Bekov'];

/// [n] distinct made-up attendee names.
List<String> _people(int n) => [
  for (var i = 0; i < n; i++)
    '${_first[i % _first.length]} ${_last[(i ~/ _first.length) % _last.length]}',
];

/// Twelve seed events with dates relative to today.
/// Mandatory cases: 60-char title (e2), at the limit (e3), past (e4),
/// mode on (e5, e10), no optional text (e6, e9, ...).
List<Item> buildSeed() {
  final now = DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Item(
      id: 'e1',
      title: 'Flutter Hackathon',
      category: EventCategory.tech,
      startsAt: at(3, 10),
      capacity: 40,
      location: 'Main Hall, Room 101',
      names: _people(12),
      description: 'Twelve hours, one app. Teams of up to four.',
    ),
    Item(
      id: 'e2',
      title: 'International Student Conference on Mobile and Web Computing',
      category: EventCategory.tech,
      startsAt: at(21, 9, 30),
      capacity: 150,
      location: 'Congress Center',
      names: _people(18),
      description: 'Talks, posters and a demo session.',
    ),
    Item(
      id: 'e3',
      title: 'Futsal Cup Qualifiers',
      category: EventCategory.sports,
      startsAt: at(5, 18),
      capacity: 10,
      location: 'Sports Hall B',
      names: _people(10),
      description: 'Ten players, two teams. The list is closed.',
    ),
    Item(
      id: 'e4',
      title: 'Welcome Week Concert',
      category: EventCategory.music,
      startsAt: at(-4, 19),
      capacity: 100,
      location: 'Open-air stage',
      names: _people(37),
      description: 'Student bands on the main square.',
    ),
    Item(
      id: 'e5',
      title: 'Career Q&A with Engineers',
      category: EventCategory.career,
      startsAt: at(2, 16),
      capacity: 80,
      location: 'https://meet.example.com/career-qa',
      online: true,
      names: _people(25),
      description: 'Ask anything about your first job in tech.',
    ),
    Item(
      id: 'e6',
      title: 'Open Mic Evening',
      category: EventCategory.music,
      startsAt: at(2, 20),
      capacity: 30,
      location: 'Student Cafe',
      names: _people(26),
    ),
    Item(
      id: 'e7',
      title: 'Watercolor Workshop',
      category: EventCategory.art,
      startsAt: at(7, 15),
      capacity: 20,
      location: 'Art Studio 3',
      names: _people(8),
      description: 'Bring nothing, we provide paper and paint.',
    ),
    Item(
      id: 'e8',
      title: 'Resume Clinic',
      category: EventCategory.career,
      startsAt: at(1, 14),
      capacity: 25,
      location: 'Library, Room 2',
      names: _people(6),
      description: 'Fifteen minutes of feedback per person.',
    ),
    Item(
      id: 'e9',
      title: 'Morning Run Club',
      category: EventCategory.sports,
      startsAt: at(1, 7, 30),
      capacity: 50,
      location: 'Stadium gate',
      names: _people(20),
    ),
    Item(
      id: 'e10',
      title: 'AI Study Group',
      category: EventCategory.tech,
      startsAt: at(4, 19),
      capacity: 60,
      location: 'https://meet.example.com/ai-study',
      online: true,
      names: _people(30),
      description: 'Weekly paper reading, this time on diffusion models.',
    ),
    Item(
      id: 'e11',
      title: 'Autumn Photo Walk',
      category: EventCategory.art,
      startsAt: at(9, 10),
      capacity: 15,
      location: 'Central Park, east entrance',
      names: _people(14),
      description: 'Phones are fine. One place left.',
    ),
    Item(
      id: 'e12',
      title: 'Jazz Under the Stars',
      category: EventCategory.music,
      startsAt: at(14, 21),
      capacity: 120,
      location: 'Rooftop Terrace',
      names: _people(40),
      description: 'A quartet and hot tea.',
      favourite: true,
    ),
  ];
}
