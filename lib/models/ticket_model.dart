import 'package:flutter/material.dart';

class Ticket {
  final String id;
  final String title;
  final String description;
  final String priority;
  String status;
  final String date;
  final int commentCount;
  final String? assignedTo;
  final String? assignedAt;
  final String? completedAt;
  final String reporter;
  final List<String> comments;
  final double? rating;
  final String? ratingComment;
  final DateTime deadline;
  final bool isOverdue;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.date,
    this.commentCount = 0,
    this.assignedTo,
    this.assignedAt,
    this.completedAt,
    required this.reporter,
    this.comments = const [],
    this.rating,
    this.ratingComment,
    required this.deadline,
    required this.isOverdue,
  });

  String get slaStatus {
    if (isOverdue) return 'Overdue';
    final daysUntil = deadline.difference(DateTime.now()).inDays;
    if (daysUntil <= 1) return 'Urgent';
    if (daysUntil <= 3) return 'Warning';
    return 'On Track';
  }

  Color get slaColor {
    if (isOverdue) return Colors.red;
    final daysUntil = deadline.difference(DateTime.now()).inDays;
    if (daysUntil <= 1) return Colors.red;
    if (daysUntil <= 3) return Colors.orange;
    return Colors.green;
  }

  Ticket copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    String? status,
    String? date,
    int? commentCount,
    String? assignedTo,
    String? assignedAt,
    String? completedAt,
    String? reporter,
    List<String>? comments,
    double? rating,
    String? ratingComment,
    DateTime? deadline,
    bool? isOverdue,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      date: date ?? this.date,
      commentCount: commentCount ?? this.commentCount,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedAt: assignedAt ?? this.assignedAt,
      completedAt: completedAt ?? this.completedAt,
      reporter: reporter ?? this.reporter,
      comments: comments ?? this.comments,
      rating: rating ?? this.rating,
      ratingComment: ratingComment ?? this.ratingComment,
      deadline: deadline ?? this.deadline,
      isOverdue: isOverdue ?? this.isOverdue,
    );
  }
}
