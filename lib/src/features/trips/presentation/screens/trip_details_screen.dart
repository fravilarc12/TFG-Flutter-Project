import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/trips_repository.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text("Planificación"),
                background: Image.network(
                  "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                const TabBar(
                  labelColor: Color(0xFF0066CC),
                  unselectedLabelColor: Colors.grey,
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
              const Center(child: Text('Mapa e Itinerario')),
              _ChecklistTab(tripId: tripId), // Nuestra nueva sección funcional
              const Center(child: Text('Control de Presupuesto')),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para la pestaña de Equipaje
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
                  decoration:
                      const InputDecoration(hintText: "Añadir a la maleta..."),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF0066CC)),
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

// Necesario para que el TabBar se quede fijo al hacer scroll
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
