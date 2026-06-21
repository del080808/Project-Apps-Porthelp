enum UserRole { pelapor, teknisi, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? company;
  final String? specialization;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.company,
    this.specialization,
  });
}