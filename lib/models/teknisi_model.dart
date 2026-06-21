import 'package:flutter/material.dart';

class Teknisi {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final int activeTickets;
  final List<String> skills;
  final String division;

  Teknisi({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.activeTickets,
    required this.skills,
    required this.division,
  });

  String get workloadStatus {
    if (activeTickets <= 2) return 'Ringan';
    if (activeTickets <= 4) return 'Sedang';
    return 'Overload';
  }

  Color get workloadColor {
    if (activeTickets <= 2) return Colors.green;
    if (activeTickets <= 4) return Colors.orange;
    return Colors.red;
  }

  Teknisi copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    int? activeTickets,
    List<String>? skills,
    String? division,
  }) {
    return Teknisi(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      activeTickets: activeTickets ?? this.activeTickets,
      skills: skills ?? this.skills,
      division: division ?? this.division,
    );
  }
}
