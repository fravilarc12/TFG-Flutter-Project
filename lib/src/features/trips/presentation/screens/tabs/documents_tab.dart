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
import '../../../../../core/constants/app_colors.dart';
import '../../../data/trips_repository.dart';
import '../../../domain/trip.dart';

// --- PESTAÑA 5: DOCUMENTOS ---
class DocumentsTab extends ConsumerWidget {
  final String tripId;
  const DocumentsTab({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentsStreamProvider(tripId));

    return Scaffold(
      body: docsAsync.when(
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
                child: Text("No hay documentos subidos",
                    style: TextStyle(color: Colors.grey, fontSize: 16)));
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
                    backgroundColor:
                        isPdf ? Colors.red.shade100 : Colors.blue.shade100,
                    child: Icon(isPdf ? Icons.picture_as_pdf : Icons.image,
                        color: isPdf ? Colors.red : Colors.blue),
                  ),
                  title: Text(doc['name'] ?? 'Documento sin nombre',
                      overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      "${(doc['size'] / 1024 / 1024).toStringAsFixed(2)} MB",
                      style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar documento'),
                          content: const Text(
                              '¿Estás seguro de que quieres eliminarlo?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar')),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref
                                    .read(tripsRepositoryProvider)
                                    .deleteDocument(
                                        tripId, doc['id'], doc['storagePath']);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Documento eliminado')));
                              },
                              child: const Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () async {
                    final url = Uri.parse(doc['url']);
                    try {
                      final launched = await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                      if (!launched && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No hay app disponible para abrir esto')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('No se pudo procesar el enlace')));
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
        backgroundColor: AppColors.primary,
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
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subiendo documento...')));
            }
            try {
              await ref
                  .read(tripsRepositoryProvider)
                  .uploadDocument(tripId, file, extension, name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Documento subido con éxito')));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Error: ${e.toString().replaceAll("Exception: ", "")}')));
              }
            }
          }
        },
        icon: const Icon(Icons.upload_file),
        label: const Text('Subir Archivo',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

