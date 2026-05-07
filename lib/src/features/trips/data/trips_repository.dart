import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/trip.dart';

part 'trips_repository.g.dart';

class TripsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _userTrips {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _firestore.collection('users').doc(userId).collection('trips');
  }

  Stream<List<Trip>> watchTrips() {
    try {
      return _userTrips.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) => Trip.fromFirestore(doc)).toList();
      });
    } catch (e) {
      debugPrint('Error en watchTrips: $e');
      return Stream.error(e);
    }
  }

  Future<void> addTrip(Trip trip) async {
    await _userTrips.add(trip.toFirestore());
  }

  Future<void> deleteTrip(String tripId) async {
    await _userTrips.doc(tripId).delete();
  }

  Future<void> updateTripBudget(String tripId, double budget) async {
    await _userTrips.doc(tripId).update({'budget': budget});
  }

  Stream<List<Map<String, dynamic>>> watchChecklist(String tripId) {
    try {
      return _userTrips.doc(tripId).collection('checklist').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList());
    } catch (e) {
      debugPrint('Error en watchChecklist: $e');
      return Stream.error(e);
    }
  }

  Future<void> addChecklistItem(
      String tripId, String item, String category) async {
    await _userTrips.doc(tripId).collection('checklist').add({
      'title': item,
      'isChecked': false,
      'category': category,
    });
  }

  Future<void> deleteChecklistItem(String tripId, String itemId) async {
    await _userTrips.doc(tripId).collection('checklist').doc(itemId).delete();
  }

  Future<void> toggleChecklistItem(
      String tripId, String itemId, bool isChecked) async {
    await _userTrips.doc(tripId).collection('checklist').doc(itemId).update({
      'isChecked': isChecked,
    });
  }

  Stream<List<Map<String, dynamic>>> watchExpenses(String tripId) {
    try {
      return _userTrips
          .doc(tripId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList());
    } catch (e) {
      debugPrint('Error en watchExpenses: $e');
      return Stream.error(e);
    }
  }

  Future<void> addExpense(
      String tripId, String title, double amount, String category) async {
    await _userTrips.doc(tripId).collection('expenses').add({
      'title': title,
      'amount': amount,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    await _userTrips.doc(tripId).collection('expenses').doc(expenseId).delete();
  }

  Stream<List<Map<String, dynamic>>> watchItinerary(String tripId) {
    try {
      return _userTrips
          .doc(tripId)
          .collection('itinerary')
          .snapshots()
          .map((snapshot) {
        final list =
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
        list.sort((a, b) {
          final ta = a['timestamp'] as Timestamp?;
          final tb = b['timestamp'] as Timestamp?;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return ta.toDate().compareTo(tb.toDate());
        });
        return list;
      });
    } catch (e) {
      debugPrint('Error en watchItinerary: $e');
      return Stream.error(e);
    }
  }

  Future<void> addItineraryPoint(
      String tripId, String title, double lat, double lng) async {
    await _userTrips.doc(tripId).collection('itinerary').add({
      'title': title,
      'latitude': lat,
      'longitude': lng,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteItineraryPoint(String tripId, String pointId) async {
    await _userTrips.doc(tripId).collection('itinerary').doc(pointId).delete();
  }

  Stream<List<Map<String, dynamic>>> watchGallery(String tripId) {
    try {
      return _userTrips
          .doc(tripId)
          .collection('gallery')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList());
    } catch (e) {
      debugPrint('Error en watchGallery: $e');
      return Stream.error(e);
    }
  }

  Future<void> uploadPhoto(String tripId, File file) async {
    final int sizeInBytes = await file.length();
    if (sizeInBytes > 5 * 1024 * 1024) {
      throw Exception('La imagen supera el límite de 5 MB.');
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String storagePath = 'users/$userId/trips/$tripId/gallery/$fileName';

    final Reference ref = _storage.ref().child(storagePath);
    await ref.putFile(file);
    final String downloadUrl = await ref.getDownloadURL();

    await _userTrips.doc(tripId).collection('gallery').add({
      'url': downloadUrl,
      'name': fileName,
      'storagePath': storagePath,
      'size': sizeInBytes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePhoto(
      String tripId, String photoId, String storagePath) async {
    await _storage.ref().child(storagePath).delete();
    await _userTrips.doc(tripId).collection('gallery').doc(photoId).delete();
  }

  Stream<List<Map<String, dynamic>>> watchDocuments(String tripId) {
    try {
      return _userTrips
          .doc(tripId)
          .collection('documents')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList());
    } catch (e) {
      debugPrint('Error en watchDocuments: $e');
      return Stream.error(e);
    }
  }

  Future<void> uploadDocument(
      String tripId, File file, String type, String originalName) async {
    final int sizeInBytes = await file.length();
    if (sizeInBytes > 10 * 1024 * 1024) {
      throw Exception('El documento supera el límite de 10 MB.');
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');

    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}_$originalName';
    final String storagePath =
        'users/$userId/trips/$tripId/documents/$fileName';

    final Reference ref = _storage.ref().child(storagePath);
    await ref.putFile(file);
    final String downloadUrl = await ref.getDownloadURL();

    await _userTrips.doc(tripId).collection('documents').add({
      'url': downloadUrl,
      'name': originalName,
      'type': type,
      'storagePath': storagePath,
      'size': sizeInBytes,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteDocument(
      String tripId, String docId, String storagePath) async {
    await _storage.ref().child(storagePath).delete();
    await _userTrips.doc(tripId).collection('documents').doc(docId).delete();
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

@riverpod
Stream<List<Map<String, dynamic>>> expensesStream(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchExpenses(tripId);
}

@riverpod
Stream<List<Map<String, dynamic>>> itineraryStream(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchItinerary(tripId);
}

@riverpod
Stream<List<Map<String, dynamic>>> galleryStream(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchGallery(tripId);
}

@riverpod
Stream<List<Map<String, dynamic>>> documentsStream(Ref ref, String tripId) {
  return ref.watch(tripsRepositoryProvider).watchDocuments(tripId);
}
