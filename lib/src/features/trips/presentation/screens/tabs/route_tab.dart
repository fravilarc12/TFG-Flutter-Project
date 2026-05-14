import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/trips_repository.dart';

// --- PESTAÑA 1: RUTA CON FLUTTER MAP (OPENSTREETMAP) ---
class RouteTab extends ConsumerStatefulWidget {
  final String destination;
  final String tripId;
  const RouteTab({required this.destination, required this.tripId});

  @override
  ConsumerState<RouteTab> createState() => RouteTabState();
}

class RouteTabState extends ConsumerState<RouteTab> {
  LatLng? _location;
  bool _loading = true;
  final MapController _mapController = MapController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCoordinates();
  }

  @override
  void dispose() {
    // Liberar recursos si fuera necesario
    super.dispose();
  }

  Future<List<LatLng>> _safeGeocode(String address) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}');
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
            _errorMessage =
                "No se pudieron obtener las coordenadas para: ${widget.destination}.";
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
            FlutterMap(
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
                child: const Icon(Icons.my_location, color: AppColors.primary),
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
                  backgroundColor: AppColors.primary,
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
                backgroundColor: AppColors.primary,
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

  Future<List<String>> _getPlacePredictions(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}');
      final request = await HttpClient().getUrl(url);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body);
      if (data['status'] == 'OK' && data['predictions'] != null) {
        return (data['predictions'] as List)
            .map((p) => p['description'] as String)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  void _showSearchAddressDialog(BuildContext context) {
    final titleController = TextEditingController();
    final addressController = TextEditingController();
    bool isSearching = false;
    bool isSearchingLocations = false;
    List<String> _predictions = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Buscar Dirección"),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                            hintText: "Ej. Mi Hotel",
                            labelText: "Nombre del Lugar (Opcional)"),
                        autofocus: true,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                            hintText: "Ej. Times Square, NY",
                            labelText: "Dirección real a buscar"),
                        onChanged: (val) async {
                          if (val.trim().length > 2) {
                            setStateDialog(() => isSearchingLocations = true);
                            final predictions = await _getPlacePredictions(val);
                            setStateDialog(() {
                              _predictions = predictions;
                              isSearchingLocations = false;
                            });
                          } else {
                            setStateDialog(() {
                              _predictions = [];
                              isSearchingLocations = false;
                            });
                          }
                        },
                      ),
                      if (isSearchingLocations) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(),
                      ],
                      if (_predictions.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _predictions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.location_on_outlined,
                                    color: Colors.grey),
                                title: Text(_predictions[index],
                                    style: const TextStyle(fontSize: 14)),
                                onTap: () {
                                  addressController.text = _predictions[index];
                                  if (titleController.text.isEmpty) {
                                    titleController.text =
                                        _predictions[index].split(',').first;
                                  }
                                  setStateDialog(() {
                                    _predictions = [];
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                      if (isSearching) ...[
                        const SizedBox(height: 16),
                        const Center(child: CircularProgressIndicator()),
                      ]
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSearching ? null : () => Navigator.pop(context),
                  child: const Text("Cancelar",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  onPressed: isSearching
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty &&
                              addressController.text.trim().isNotEmpty) {
                            titleController.text =
                                addressController.text.trim().split(',').first;
                          }
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
