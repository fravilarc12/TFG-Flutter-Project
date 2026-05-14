import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_planner_app/src/features/trips/domain/trip.dart';

void main() {
  group('Trip Model Unit Tests', () {
    test('toFirestore genera un mapa correcto con todos los campos', () {
      // 1. Arrange: Preparamos los datos
      final fechaInicio = DateTime(2025, 5, 1);
      final fechaFin = DateTime(2025, 5, 15);

      final trip = Trip(
        id: '12345',
        title: 'Viaje a Tokio',
        destination: 'Japón',
        startDate: fechaInicio,
        endDate: fechaFin,
        budget: 2000.0,
      );

      // 2. Act: Ejecutamos el método que queremos probar
      final map = trip.toFirestore();

      // 3. Assert: Comprobamos que el resultado es el esperado
      expect(map['title'], 'Viaje a Tokio');
      expect(map['destination'], 'Japón');
      expect(map['budget'], 2000.0);

      // Firestore guarda las fechas como Timestamp
      expect(map['startDate'], isA<Timestamp>());
      expect((map['startDate'] as Timestamp).toDate(), fechaInicio);

      expect(map['endDate'], isA<Timestamp>());
      expect((map['endDate'] as Timestamp).toDate(), fechaFin);
    });

    test('toFirestore no incluye el presupuesto si es nulo', () {
      final tripSinPresupuesto = Trip(
        title: 'Escapada',
        destination: 'Pueblo',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        budget: null, // Presupuesto nulo
      );

      final map = tripSinPresupuesto.toFirestore();

      expect(map.containsKey('budget'), isFalse);
    });
  });
}
