import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String? id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double? budget;

  Trip({
    this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.budget,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'destination': destination,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      if (budget != null) 'budget': budget,
    };
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Compatibilidad hacia atrás: Si no existen las nuevas variables, intenta usar 'date' antigua
    final startDateValue = data['startDate'] ?? data['date'];
    final endDateValue = data['endDate'] ?? data['date'];

    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.tryParse(dateValue) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Trip(
      id: doc.id,
      title: data['title'] ?? '',
      destination: data['destination'] ?? '',
      startDate: parseDate(startDateValue),
      endDate: parseDate(endDateValue),
      budget:
          data['budget'] != null ? (data['budget'] as num).toDouble() : null,
    );
  }
}
