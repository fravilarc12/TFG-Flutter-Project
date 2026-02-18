import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/trip.dart';

part 'trips_repository.g.dart';

class TripsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- GESTIÓN DE VIAJES ---
  Stream<List<Trip>> watchTrips() {
    return _firestore.collection('trips').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
    });
  }

  Future<void> addTrip(Trip trip) async {
    await _firestore.collection('trips').add(trip.toFirestore());
  }

  Future<void> deleteTrip(String tripId) async {
    await _firestore.collection('trips').doc(tripId).delete();
  }

  // --- GESTIÓN DE EQUIPAJE (CHECKLIST) ---
  Stream<List<Map<String, dynamic>>> watchChecklist(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('checklist')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

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

  // --- GESTIÓN DE GASTOS ---
  Stream<List<Map<String, dynamic>>> watchExpenses(String tripId) {
    return _firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> addExpense(String tripId, String title, double amount) async {
    await _firestore
        .collection('trips')
        .doc(tripId)
        .collection('expenses')
        .add({
      'title': title,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
    });
  }
}

// --- PROVIDERS (LOS "CABLES" QUE CONECTAN TODO) ---

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

@riverpod
Stream<List<Map<String, dynamic>>> expensesStream(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchExpenses(tripId);
}
