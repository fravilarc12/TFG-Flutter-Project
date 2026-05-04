import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Mis Viajes',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF005D90),
        elevation: 0,
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

          return RepaintBoundary(
            child: ListView.builder(
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

                // Confirmación antes de borrar
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text('¿Estás seguro de que quieres eliminar el viaje a ${trip.destination}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },

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
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14005D90),
                        offset: Offset(0, 12),
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => context.push('/trip/${trip.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF191C1D),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Color(0xFF707881)),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${trip.startDate.day}/${trip.startDate.month}/${trip.startDate.year} - ${trip.endDate.day}/${trip.endDate.month}/${trip.endDate.year}",
                                    style: const TextStyle(
                                      color: Color(0xFF707881),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.location_on,
                                      size: 16, color: Color(0xFF005D90)),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.destination,
                                    style: const TextStyle(
                                      color: Color(0xFF005D90),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: "https://maps.googleapis.com/maps/api/staticmap?center=${Uri.encodeComponent(trip.destination)}&zoom=11&size=450x225&maptype=terrain&key=AIzaSyBMTvXaq-cb3w4qLCRe_BkmVwA5B4ah4Qc",
                            height: 160,
                            fit: BoxFit.cover,
                            memCacheWidth: 450,
                            memCacheHeight: 225,
                            placeholder: (context, url) => Container(
                              height: 160,
                              color: Colors.grey.shade100,
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) =>
                                Container(
                              height: 160,
                              color: Colors.grey.shade200,
                              child: const Center(
                                  child: Icon(Icons.map,
                                      color: Colors.grey, size: 40)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0x33005D90),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTripDialog(context, ref),
          backgroundColor: const Color(0xFF005D90),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Nuevo Viaje',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Ventana emergente para añadir viajes
  void _showAddTripDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final destinationController = TextEditingController();
    DateTimeRange selectedDateRange = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(days: 7)),
    );

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para que el diálogo se redibuje al elegir fecha
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text('Planear Nuevo Viaje',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF005D90))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Color(0xFF191C1D)),
                      decoration: const InputDecoration(
                        labelText: 'Nombre del viaje',
                        labelStyle: TextStyle(color: Color(0xFF707881)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: destinationController,
                      style: const TextStyle(color: Color(0xFF191C1D)),
                      decoration: const InputDecoration(
                        labelText: 'Destino',
                        labelStyle: TextStyle(color: Color(0xFF707881)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // BOTÓN PARA ELEGIR RANGO DE FECHAS
                    ListTile(
                      title: const Text("Fechas del viaje:"),
                      subtitle: Text(
                        "Del ${selectedDateRange.start.day}/${selectedDateRange.start.month}/${selectedDateRange.start.year} al ${selectedDateRange.end.day}/${selectedDateRange.end.month}/${selectedDateRange.end.year}",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      leading: const Icon(Icons.date_range,
                          color: Color(0xFF005D90)),
                      onTap: () async {
                        // Abre el calendario de rangos oficial de Android/iOS
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          initialDateRange: selectedDateRange,
                          firstDate: DateTime.now(), // No dejar elegir pasadas
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF005D90),
                                  onPrimary: Colors.white,
                                  onSurface: Color(0xFF191C1D),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => selectedDateRange = picked);
                        }
                      },
                    ),
                  ],
                ),
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
                        startDate: selectedDateRange.start,
                        endDate: selectedDateRange.end,
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
