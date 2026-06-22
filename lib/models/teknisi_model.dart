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
  final String? workloadStatusOverride;

  Teknisi({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.activeTickets,
    required this.skills,
    required this.division,
    this.workloadStatusOverride,
  });

  String get workloadStatus {
    if (workloadStatusOverride != null) return workloadStatusOverride!;
    if (activeTickets <= 2) return 'Ringan';
    if (activeTickets <= 4) return 'Sedang';
    return 'Overload';
  }

  Color get workloadColor {
    final status = workloadStatus;
    if (status == 'Ringan') return Colors.green;
    if (status == 'Sedang') return Colors.orange;
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
    String? workloadStatusOverride,
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
      workloadStatusOverride:
          workloadStatusOverride ?? this.workloadStatusOverride,
    );
  }
}
