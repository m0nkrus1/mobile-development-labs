class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.website,
    required this.city,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as int,
    name: j['name'] as String,
    email: j['email'] as String,
    phone: j['phone'] as String? ?? '',
    website: j['website'] as String? ?? '',
    city: (j['address'] as Map<String, dynamic>?)?['city'] as String? ?? '',
  );

  final int id;
  final String name;
  final String email;
  final String phone;
  final String website;
  final String city;

  String get phoneDigits =>
      phone.split(RegExp(r'\s*x')).first.replaceAll(RegExp(r'[^0-9+]'), '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'website': website,
    'address': {'city': city},
  };
}
