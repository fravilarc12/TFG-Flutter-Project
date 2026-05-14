import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/trips_repository.dart';

// --- PESTAÑA 4: GALERÍA DE FOTOS ---
class GalleryTab extends ConsumerWidget {
  final String tripId;
  const GalleryTab({required this.tripId});

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
        backgroundColor: AppColors.primary,
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

