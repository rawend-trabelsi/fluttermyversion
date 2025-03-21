
import 'package:flutter/material.dart';

class TechnicienEmploi {
  final int id;
  final String email;
  final String username;
  final String phone;
  final String jourRepos;
  final String heureDebut; // Horaire au format "HH:mm:ss"
  final String heureFin;   // Horaire au format "HH:mm:ss"

  TechnicienEmploi({
    required this.id,
    required this.email,
    required this.username,
    required this.phone,
    required this.jourRepos,
    required this.heureDebut,
    required this.heureFin,
  });

  // Convertir un JSON en objet TechnicienEmploi
  factory TechnicienEmploi.fromJson(Map<String, dynamic> json) {
    return TechnicienEmploi(
      id: json['id'],
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      jourRepos: json['jourRepos'],
      heureDebut: json['heureDebut'],  // Au format "HH:mm:ss"
      heureFin: json['heureFin'],      // Au format "HH:mm:ss"
    );
  }

  // Convertir un objet TechnicienEmploi en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'jourRepos': jourRepos,
      'heureDebut': heureDebut,  // Au format "HH:mm:ss"
      'heureFin': heureFin,      // Au format "HH:mm:ss"
    };
  }

  // Convertir un TimeOfDay en format "HH:mm:ss"
  static String formatTimeOfDay(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return "$hours:${minutes}:00"; // Ajout de secondes fixes à "00"
  }

  // Convertir un format "HH:mm:ss" en TimeOfDay
  static TimeOfDay parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    return TimeOfDay(hour: hours, minute: minutes);
  }
}
