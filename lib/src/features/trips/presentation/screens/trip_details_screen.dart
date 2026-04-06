import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import '../../data/trips_repository.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsStreamProvider);

    return tripsAsync.when(
      data: (trips) {
        final trip = trips.firstWhere(
          (t) => t.id == tripId,
          orElse: () => throw Exception('Viaje no encontrado'),
        );

        return DefaultTabController(
          length: 5,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: const Color(0xFF005D90),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(trip.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: "https://maps.googleapis.com/maps/api/staticmap?center=${Uri.encodeComponent(trip.destination)}&zoom=11&size=800x400&maptype=terrain&key=AIzaSyBMTvXaq-cb3w4qLCRe_BkmVwA5B4ah4Qc",
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          memCacheHeight: 400,
                        ),
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
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: Color(0xFF005D90),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Color(0xFF005D90),
                      tabs: [
                        Tab(icon: Icon(Icons.map), text: 'Ruta'),
                        Tab(icon: Icon(Icons.checklist), text: 'Equipaje'),
                        Tab(icon: Icon(Icons.payments), text: 'Gastos'),
                        Tab(icon: Icon(Icons.description), text: 'Docs'),
                        Tab(icon: Icon(Icons.photo_library), text: 'Galería'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ],
              body: TabBarView(
                children: [
                  _RouteTab(destination: trip.destination, tripId: tripId),
                  _ChecklistTab(tripId: tripId),
                  _ExpensesTab(tripId: tripId),
                  _DocumentsTab(tripId: tripId),
                  _GalleryTab(tripId: tripId),
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

// --- PESTAÑA 1: RUTA CON FLUTTER MAP (OPENSTREETMAP) ---
class _RouteTab extends ConsumerStatefulWidget {
  final String destination;
  final String tripId;
  const _RouteTab({required this.destination, required this.tripId});

  @override
  ConsumerState<_RouteTab> createState() => _RouteTabState();
}

class _RouteTabState extends ConsumerState<_RouteTab>
    with AutomaticKeepAliveClientMixin {
  LatLng? _location;
  bool _loading = true;
  final MapController _mapController = MapController();

  @override
  bool get wantKeepAlive => true;

  Future<List<LatLng>> _safeGeocode(String address) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=AIzaSyBMTvXaq-cb3w4qLCRe_BkmVwA5B4ah4Qc');
      final request = await HttpClient().getUrl(url);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body);
      if (data['status'] == 'OK' &&
          data['results'] != null &&
          (data['results'] as List).isNotEmpty) {
        final loc = data['results'][0]['geometry']['location'];
        return [
          LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble())
        ];
      }
    } catch (_) {}
    return [];
  }

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  Future<void> _getCoordinates() async {
    try {
      if (mounted) setState(() => _loading = true);
      final locations = await _safeGeocode(widget.destination);
      if (locations.isNotEmpty) {
        if (mounted) {
          setState(() {
            _location = locations.first;
            _errorMessage = null;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "No se pudieron obtener las coordenadas para: ${widget.destination}. Verifica tu API Key de Google.";
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error en geocodificación: $e";
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getCoordinates,
                child: const Text("Reintentar búsqueda de destino"),
              ),
            ],
          ),
        ),
      );
    }

    if (_location == null) {
      return const Center(child: Text("Ubicación no encontrada"));
    }

    final itineraryAsync = ref.watch(itineraryStreamProvider(widget.tripId));

    return itineraryAsync.when(
      data: (points) {
        List<Marker> markers = [];
        for (var point in points) {
          if (point['latitude'] == null || point['longitude'] == null) continue;
          final lat = (point['latitude'] as num).toDouble();
          final lng = (point['longitude'] as num).toDouble();
          final pos = LatLng(lat, lng);

          markers.add(
            Marker(
              point: pos,
              width: 45,
              height: 45,
              child: GestureDetector(
                onTap: () => _showPointDetails(context, point),
                child:
                    const Icon(Icons.location_on, color: Colors.red, size: 45),
              ),
            ),
          );
        }

        return Stack(
          children: [
            RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _location!,
                  initialZoom: 15,
                  onLongPress: (tapPosition, point) =>
                      _showQuickAddDialog(context, point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fravilarc.travel_planner',
                  ),
                  CurrentLocationLayer(
                    alignPositionOnUpdate: AlignOnUpdate.never,
                    alignDirectionOnUpdate: AlignOnUpdate.never,
                  ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
            // BOTÓN MI UBICACIÓN
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () async {
                  final permission = await Geolocator.checkPermission();
                  if (permission == LocationPermission.denied) {
                    await Geolocator.requestPermission();
                  }
                  final pos = await Geolocator.getCurrentPosition();
                  _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Color(0xFF005D90)),
              ),
            ),
            Positioned(
              bottom: 24.0,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: () => _showSearchAddressDialog(context),
                  label: const Text('Añadir Lugar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  icon: const Icon(Icons.add_location_alt),
                  backgroundColor: const Color(0xFF005D90),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Error al cargar el itinerario:\n$e",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text(
                "Esto suele ocurrir si hay un problema con la configuración de Google Play Services o Firebase.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPointDetails(BuildContext context, Map<String, dynamic> point) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              point['title'] ?? 'Lugar sin nombre',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005D90),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.directions_walk),
              label: const Text("Cómo llegar andando"),
              onPressed: () async {
                final lat = point['latitude'];
                final lng = point['longitude'];
                final url = Uri.parse(
                    'google.navigation:q=$lat,$lng&mode=w'); // w = walking
                
                // Fallback para iOS/Web
                final fallbackUrl = Uri.parse(
                    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking');

                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else if (await canLaunchUrl(fallbackUrl)) {
                  await launchUrl(fallbackUrl);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No se pudo abrir el mapa")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              icon: const Icon(Icons.delete_outline),
              label: const Text("Eliminar punto"),
              onPressed: () {
                Navigator.pop(context);
                _confirmDeletePoint(context, point['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePoint(BuildContext context, String pointId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar punto?"),
        content: const Text("Esta acción quitará el lugar de tu itinerario."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(tripsRepositoryProvider)
                  .deleteItineraryPoint(widget.tripId, pointId);
              Navigator.pop(context);
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context, LatLng pos) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Añadir marcador aquí"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: "Nombre del sitio"),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                final title = titleController.text.trim();
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 400));
                ref.read(tripsRepositoryProvider).addItineraryPoint(
                    widget.tripId, title, pos.latitude, pos.longitude);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _showSearchAddressDialog(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    bool isSearching = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Buscar Dirección"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        hintText: "Ej. Mi Hotel",
                        labelText: "Nombre del Lugar"),
                    autofocus: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                        hintText: "Ej. Times Square, NY",
                        labelText: "Dirección real a buscar"),
                  ),
                  if (isSearching) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSearching ? null : () => Navigator.pop(context),
                  child: const Text("Cancelar",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005D90),
                      foregroundColor: Colors.white),
                  onPressed: isSearching
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty) return;
                          setStateDialog(() => isSearching = true);
                          try {
                            final locations = await _safeGeocode(
                                addressController.text.trim());
                            if (locations.isNotEmpty) {
                              final title = titleController.text.trim();
                              final lat = locations.first.latitude;
                              final lng = locations.first.longitude;
                              if (context.mounted) Navigator.pop(context);
                              await Future.delayed(
                                  const Duration(milliseconds: 400));
                              ref
                                  .read(tripsRepositoryProvider)
                                  .addItineraryPoint(
                                      widget.tripId, title, lat, lng);
                            } else {
                              setStateDialog(() => isSearching = false);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Dirección no encontrada o error de red")));
                              }
                            }
                          } catch (e) {
                            setStateDialog(() => isSearching = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Error al procesar la dirección")));
                            }
                          }
                        },
                  child: const Text("Buscar y Añadir"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// --- PESTAÑA 2: LISTA DE EQUIPAJE ---
class _ChecklistTab extends ConsumerStatefulWidget {
  final String tripId;
  const _ChecklistTab({required this.tripId});

  @override
  ConsumerState<_ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends ConsumerState<_ChecklistTab> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'Ropa';

  final List<String> _categories = [
    'Ropa',
    'Electrónica',
    'Aseo',
    'Documentos',
    'Otros'
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checklistAsync = ref.watch(checklistStreamProvider(widget.tripId));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Color(0xFF191C1D)),
                      decoration: InputDecoration(
                        hintText: "Ej: Pasaporte, Cargador...",
                        hintStyle: const TextStyle(color: Color(0xFF707881)),
                        filled: true,
                        fillColor: const Color(0xFFE7E8E9),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0x33005D90), width: 2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF005D90), Color(0xFF0077B6)]),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          ref
                              .read(tripsRepositoryProvider)
                              .addChecklistItem(widget.tripId, _controller.text, _selectedCategory);
                          _controller.clear();
                          FocusScope.of(context).unfocus();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                        selectedColor: const Color(0xFF005D90).withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF005D90)
                                : Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: checklistAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Text("Tu maleta está vacía"));
              }

              // Agrupar por categoría
              final Map<String, List<dynamic>> groupedItems = {};
              for (var cat in _categories) {
                groupedItems[cat] = [];
              }
              for (var item in items) {
                final cat = item['category'] ?? 'Otros';
                if (groupedItems.containsKey(cat)) {
                  groupedItems[cat]!.add(item);
                } else {
                  groupedItems['Otros']!.add(item);
                }
              }

              return ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final catItems = groupedItems[cat]!;
                  if (catItems.isEmpty) return const SizedBox.shrink();

                  return ExpansionTile(
                    initiallyExpanded: true,
                    title: Text(
                      cat,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005D90)),
                    ),
                    children: catItems.map((item) {
                      return Dismissible(
                        key: Key(item['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) {
                          ref.read(tripsRepositoryProvider).deleteChecklistItem(widget.tripId, item['id']);
                        },
                        child: CheckboxListTile(
                          title: Text(item['title'], style: TextStyle(decoration: item['isChecked'] ? TextDecoration.lineThrough : null)),
                          value: item['isChecked'],
                          onChanged: (val) => ref
                              .read(tripsRepositoryProvider)
                              .toggleChecklistItem(widget.tripId, item['id'], val!),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: $e",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- PESTAÑA 3: CONTROL DE GASTOS ---
class _ExpensesTab extends ConsumerStatefulWidget {
  final String tripId;
  const _ExpensesTab({required this.tripId});

  @override
  ConsumerState<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends ConsumerState<_ExpensesTab> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  String _selectedCategory = 'Otros';

  final List<String> _categories = [
    'Transporte',
    'Alojamiento',
    'Comida',
    'Ocio',
    'Otros'
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Transporte':
        return Icons.directions_bus;
      case 'Alojamiento':
        return Icons.hotel;
      case 'Comida':
        return Icons.restaurant;
      case 'Ocio':
        return Icons.local_activity;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesStreamProvider(widget.tripId));

    return Column(
      children: [
        expensesAsync.when(
          data: (expenses) {
            final total = expenses.fold<double>(
                0, (sum, item) => sum + (item['amount'] ?? 0));
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF005D90), Color(0xFF0077B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x33005D90),
                      offset: Offset(0, 8),
                      blurRadius: 24)
                ],
              ),
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
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: titleController,
                          style: const TextStyle(color: Color(0xFF191C1D)),
                          decoration: InputDecoration(
                            hintText: "Concepto",
                            hintStyle:
                                const TextStyle(color: Color(0xFF707881)),
                            filled: true,
                            fillColor: const Color(0xFFE7E8E9),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ))),
                  const SizedBox(width: 10),
                  SizedBox(
                      width: 90,
                      child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          style: const TextStyle(color: Color(0xFF191C1D)),
                          decoration: InputDecoration(
                            hintText: "€",
                            hintStyle:
                                const TextStyle(color: Color(0xFF707881)),
                            filled: true,
                            fillColor: const Color(0xFFE7E8E9),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none),
                          ))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategory = val);
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005D90),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Añadir"),
                    onPressed: () {
                      final amount = double.tryParse(
                          amountController.text.replaceAll(',', '.'));
                      if (titleController.text.isNotEmpty && amount != null) {
                        ref.read(tripsRepositoryProvider).addExpense(
                            widget.tripId,
                            titleController.text,
                            amount,
                            _selectedCategory);
                        titleController.clear();
                        amountController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: expensesAsync.when(
            data: (expenses) => ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final ex = expenses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0x33005D90),
                    child: Icon(_getCategoryIcon(ex['category'] ?? 'Otros'),
                        color: const Color(0xFF005D90)),
                  ),
                  title: Text(ex['title']),
                  subtitle: Text(ex['category'] ?? 'Otros'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("-${ex['amount']} €",
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                        onPressed: () {
                          ref
                              .read(tripsRepositoryProvider)
                              .deleteExpense(widget.tripId, ex['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Error: $e",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- PESTAÑA 4: GALERÍA DE FOTOS ---
class _GalleryTab extends ConsumerWidget {
  final String tripId;
  const _GalleryTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryStreamProvider(tripId));

    return Scaffold(
      body: galleryAsync.when(
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
                child: Text("No hay fotos en la galería",
                    style: TextStyle(color: Colors.grey, fontSize: 16)));
          }
          return GridView.builder(
            padding: const EdgeInsets.only(
                left: 8.0, right: 8.0, top: 8.0, bottom: 80.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog.fullscreen(
                      backgroundColor: Colors.black,
                      child: _FullScreenImageViewer(
                        photo: photo,
                        tripId: tripId,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: photo['url'],
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                    memCacheHeight: 400,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.grey),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error: $e",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF005D90),
        foregroundColor: Colors.white,
        onPressed: () async {
          final ImageSource? source = await showModalBottomSheet<ImageSource>(
            context: context,
            builder: (BuildContext context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Tomar foto con la cámara'),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Seleccionar de la galería'),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ],
                ),
              );
            },
          );

          if (source != null && context.mounted) {
            _pickAndUploadImage(context, ref, source);
          }
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Subir foto',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _pickAndUploadImage(
      BuildContext context, WidgetRef ref, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 50, // <--- Más reducción para Androids limitados
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (image != null) {
      // Damos un respiro de medio segundo para que Android restaure la vista tras la cámara
      // y ejecute la recolección de basura (GC) sin bloquear el hilo principal (evita Signal 3).
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subiendo foto...')),
          );
        }
        await ref
            .read(tripsRepositoryProvider)
            .uploadPhoto(tripId, File(image.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Foto subida correctamente!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
          );
        }
      }
    }
  }
}

// --- VISOR DE FOTOS A PANTALLA COMPLETA ---
class _FullScreenImageViewer extends ConsumerWidget {
  final Map<String, dynamic> photo;
  final String tripId;

  const _FullScreenImageViewer({required this.photo, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Preparando imagen para compartir...')),
                );
                final file =
                    await DefaultCacheManager().getSingleFile(photo['url']);
                await Share.shareXFiles([XFile(file.path)],
                    text: 'Mira esta foto de mi viaje');
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No se pudo compartir la imagen.')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar foto'),
                  content: const Text(
                      '¿Estás seguro de que quieres eliminar esta foto?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(
                            context); // Cierra el mensaje de confirmación

                        // No cerramos la foto entera inmediatamente para evitar que
                        // el usuario toque otra foto en la cuadrícula al mismo tiempo
                        // que Firebase llama al hilo principal para borrar en la nube.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Eliminando foto de la nube...')),
                        );

                        try {
                          await ref.read(tripsRepositoryProvider).deletePhoto(
                              tripId, photo['id'], photo['storagePath']);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Foto eliminada correctamente')),
                            );
                            Navigator.pop(
                                context); // AHORA SÍ cerramos la pantalla completa
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Error al eliminar la foto')),
                            );
                          }
                        }
                      },
                      child: const Text('Eliminar',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            photo['url'],
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const CircularProgressIndicator();
            },
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// --- PESTAÑA 5: DOCUMENTOS ---
class _DocumentsTab extends ConsumerWidget {
  final String tripId;
  const _DocumentsTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsStreamProvider(tripId));

    return Scaffold(
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(child: Text("No hay documentos subidos", style: TextStyle(color: Colors.grey, fontSize: 16)));
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80, top: 8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final isPdf = doc['type'] == 'pdf';
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPdf ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Icon(isPdf ? Icons.picture_as_pdf : Icons.image, color: isPdf ? Colors.red : Colors.blue),
                  ),
                  title: Text(doc['name'] ?? 'Documento sin nombre', overflow: TextOverflow.ellipsis),
                  subtitle: Text("${(doc['size'] / 1024 / 1024).toStringAsFixed(2)} MB", style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar documento'),
                          content: const Text('¿Estás seguro de que quieres eliminarlo?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref.read(tripsRepositoryProvider).deleteDocument(tripId, doc['id'], doc['storagePath']);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento eliminado')));
                              },
                              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () async {
                    final url = Uri.parse(doc['url']);
                    try {
                      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay app disponible para abrir esto')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo procesar el enlace')));
                      }
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Error: $e",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF005D90),
        foregroundColor: Colors.white,
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          );

          if (result != null && result.files.single.path != null) {
            final file = File(result.files.single.path!);
            final extension = result.files.single.extension ?? 'unknown';
            final name = result.files.single.name;
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subiendo documento...')));
            }
            try {
              await ref.read(tripsRepositoryProvider).uploadDocument(tripId, file, extension, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Documento subido con éxito')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}')));
              }
            }
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Subir Archivo', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
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
