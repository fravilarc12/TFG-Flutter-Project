import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/trips_repository.dart';
import '../../domain/trip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vigilamos los cambios en la base de datos
    final tripsAsync = ref.watch(tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Viajes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0066CC),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: tripsAsync.when(
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Text('No tienes viajes planeados. ¡Dale al +!'),
            );
          }

          return ListView.builder(
            itemCount: trips.length,
            padding: const EdgeInsets.only(top: 10),
            itemBuilder: (context, index) {
              final trip = trips[index];

              return Dismissible(
                // 1. La clave es vital para que Flutter sepa qué elemento borra
                key: Key(trip.id ?? index.toString()),

                // 2. Dirección del deslizamiento (de derecha a izquierda)
                direction: DismissDirection.endToStart,

                // 3. Fondo rojo que aparece al deslizar
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // 4. Acción al terminar de deslizar
                onDismissed: (direction) {
                  final idParaBorrar = trip.id;

                  if (idParaBorrar != null) {
                    // 2. Borramos usando el ID seguro
                    ref.read(tripsRepositoryProvider).deleteTrip(idParaBorrar);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viaje a ${trip.destination} eliminado'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  } else {
                    // Si no hay ID, avisamos del error en lugar de cerrar la app
                    debugPrint(
                        'Error: El viaje no tiene un ID válido para borrar.');
                  }
                },

                // 5. Tu tarjeta de viaje actual
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    onTap: () =>
                        context.push('/trip/${trip.id}'), // <--- NAVEGACIÓN
                    leading: const Icon(
                      Icons.flight_takeoff,
                      color: Color(0xFF0066CC),
                    ), // Solo un leading al principio
                    title: Text(
                      trip.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${trip.destination} • ${trip.date.day}/${trip.date.month}/${trip.date.year}",
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTripDialog(context, ref),
        backgroundColor: const Color(0xFF0066CC),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Viaje', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // Ventana emergente para añadir viajes
  void _showAddTripDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final destinationController = TextEditingController();
    DateTime selectedDate = DateTime.now(); // Fecha por defecto

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para que el diálogo se redibuje al elegir fecha
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Planear Nuevo Viaje'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del viaje'),
                  ),
                  TextField(
                    controller: destinationController,
                    decoration: const InputDecoration(labelText: 'Destino'),
                  ),
                  const SizedBox(height: 20),

                  // BOTÓN PARA ELEGIR FECHA
                  ListTile(
                    title: const Text("Fecha del viaje:"),
                    subtitle: Text(
                      "Seleccionado: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    leading: const Icon(Icons.calendar_today,
                        color: Color(0xFF0066CC)),
                    onTap: () async {
                      // Abre el calendario oficial de Android/iOS
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now(), // No dejar elegir fechas pasadas
                        lastDate: DateTime(2030),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        destinationController.text.isNotEmpty) {
                      final nuevoViaje = Trip(
                        title: titleController.text,
                        destination: destinationController.text,
                        date: selectedDate, // Guardamos la fecha elegida
                      );

                      await ref
                          .read(tripsRepositoryProvider)
                          .addTrip(nuevoViaje);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
