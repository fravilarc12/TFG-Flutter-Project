import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../data/trips_repository.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Vigilamos el stream de viajes para obtener los datos del viaje actual
    final tripsAsync = ref.watch(tripsStreamProvider);

    return tripsAsync.when(
      data: (trips) {
        // Buscamos el viaje que coincide con el ID que recibimos por la ruta
        final trip = trips.firstWhere(
          (t) => t.id == tripId,
          orElse: () => throw Exception('Viaje no encontrado'),
        );

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // Cabecera con imagen que se encoge al hacer scroll
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: const Color(0xFF0066CC),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(trip.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800",
                          fit: BoxFit.cover,
                        ),
                        // Degradado para que el título se lea bien sobre la imagen
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Pestañas fijas debajo de la imagen
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      labelColor: Color(0xFF0066CC),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF0066CC),
                      tabs: [
                        Tab(icon: Icon(Icons.map), text: 'Ruta'),
                        Tab(icon: Icon(Icons.checklist), text: 'Equipaje'),
                        Tab(icon: Icon(Icons.payments), text: 'Gastos'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ],
              body: TabBarView(
                children: [
                  _RouteTab(
                      destination: trip.destination), // Pestaña 1: Google Maps
                  _ChecklistTab(tripId: tripId), // Pestaña 2: Maleta Firebase
                  _ExpensesTab(tripId: tripId), // Pestaña 3: Presupuesto
                ],
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text("Error: $e"))),
    );
  }
}

// --- PESTAÑA 1: RUTA CON GOOGLE MAPS ---
class _RouteTab extends StatefulWidget {
  final String destination;
  const _RouteTab({required this.destination});

  @override
  State<_RouteTab> createState() => _RouteTabState();
}

class _RouteTabState extends State<_RouteTab> {
  LatLng? _location;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    try {
      // Geocoding: convierte el texto del destino en coordenadas
      List<Location> locations = await locationFromAddress(widget.destination);
      if (locations.isNotEmpty) {
        setState(() {
          _location =
              LatLng(locations.first.latitude, locations.first.longitude);
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_location == null)
      return const Center(child: Text("Ubicación no encontrada"));

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _location!, zoom: 16),
      // 🛑 IMPORTANTE: Dejamos esto vacío. Ni un solo Marker() dentro.
      markers: const {},
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
    );
  }
}

// --- PESTAÑA 2: LISTA DE EQUIPAJE ---
class _ChecklistTab extends ConsumerWidget {
  final String tripId;
  const _ChecklistTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checklistAsync = ref.watch(checklistStreamProvider(tripId));
    final controller = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Ej: Pasaporte, Cargador...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    ref
                        .read(tripsRepositoryProvider)
                        .addChecklistItem(tripId, controller.text);
                    controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: checklistAsync.when(
            data: (items) => ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return CheckboxListTile(
                  title: Text(item['title']),
                  value: item['isChecked'],
                  onChanged: (val) => ref
                      .read(tripsRepositoryProvider)
                      .toggleChecklistItem(tripId, item['id'], val!),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text("Error: $e"),
          ),
        ),
      ],
    );
  }
}

// --- PESTAÑA 3: CONTROL DE GASTOS ---
class _ExpensesTab extends ConsumerWidget {
  final String tripId;
  const _ExpensesTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesStreamProvider(tripId));
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    return Column(
      children: [
        expensesAsync.when(
          data: (expenses) {
            final total = expenses.fold<double>(
                0, (sum, item) => sum + (item['amount'] ?? 0));
            return Card(
              color: const Color(0xFF0066CC),
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Gastado:",
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text("${total.toStringAsFixed(2)} €",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: "Concepto"))),
              const SizedBox(width: 10),
              SizedBox(
                  width: 70,
                  child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: "€"))),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF0066CC)),
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (titleController.text.isNotEmpty && amount != null) {
                    ref
                        .read(tripsRepositoryProvider)
                        .addExpense(tripId, titleController.text, amount);
                    titleController.clear();
                    amountController.clear();
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: expensesAsync.when(
            data: (expenses) => ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final ex = expenses[index];
                return ListTile(
                  title: Text(ex['title']),
                  trailing: Text("-${ex['amount']} €",
                      style: const TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text("Error: $e"),
          ),
        ),
      ],
    );
  }
}

// --- DELEGADO PARA EL TABBAR FIJO ---
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
