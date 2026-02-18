import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime date;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.date,
  });

  // 1. EL TRADUCTOR: De objeto Dart a Mapa de Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'destination': destination,
      'date':
          Timestamp.fromDate(date), // Firebase usa Timestamps para las fechas
    };
  }

  // 2. EL TRADUCTOR: De documento de Firebase a objeto Dart
  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dateValue = data['date'];

    // Lógica inteligente para la fecha
    DateTime parsedDate;
    if (dateValue is Timestamp) {
      parsedDate = dateValue.toDate();
    } else if (dateValue is String) {
      parsedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Trip(
      id: doc.id,
      title: data['title'] ?? '',
      destination: data['destination'] ?? '',
      date: parsedDate,
    );
  }
}
