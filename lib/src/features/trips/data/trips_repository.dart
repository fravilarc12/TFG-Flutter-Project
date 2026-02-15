import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/trip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'trips_repository.g.dart';

class TripsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Trip>> watchTrips() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Trip.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> addTrip(Trip trip) async {
    await _firestore.collection('trips').add(trip.toMap());
  }

  // ¡MIRA AQUÍ!: Ahora está dentro de la clase y reconoce _firestore
  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }

  // Escucha los objetos del equipaje de un viaje específico
  Stream<List<Map<String, dynamic>>> watchChecklist(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('checklist')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

// Añade un objeto a la maleta
  Future<void> addChecklistItem(String tripId, String item) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('checklist')
        .add({
      'title': item,
      'isChecked': false,
    });
  }

// Marca/Desmarca un objeto
  Future<void> toggleChecklistItem(
      String tripId, String itemId, bool isChecked) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('checklist')
        .doc(itemId)
        .update({
      'isChecked': isChecked,
    });
  }
}

@riverpod
TripsRepository tripsRepository(Ref ref) {
  return TripsRepository();
}

@riverpod
Stream<List<Trip>> tripsStream(Ref ref) {
  return ref.watch(tripsRepositoryProvider).watchTrips();
}

@riverpod
Stream<List<Map<String, dynamic>>> checklistStream(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchChecklist(tripId);
}
