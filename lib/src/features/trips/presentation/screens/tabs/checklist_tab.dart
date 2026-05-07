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

// --- PESTAÑA 2: LISTA DE EQUIPAJE ---
class ChecklistTab extends ConsumerStatefulWidget {
  final String tripId;
  const ChecklistTab({required this.tripId});

  @override
  ConsumerState<ChecklistTab> createState() => ChecklistTabState();
}

class ChecklistTabState extends ConsumerState<ChecklistTab> {
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: "Ej: Pasaporte, Cargador...",
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.inputFill,
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
                          colors: [AppColors.primary, AppColors.primaryContainer]),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          ref.read(tripsRepositoryProvider).addChecklistItem(
                              widget.tripId,
                              _controller.text,
                              _selectedCategory);
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
                        selectedColor: AppColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
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
                          color: AppColors.primary),
                    ),
                    children: catItems.map((item) {
                      return Dismissible(
                        key: Key(item['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) {
                          ref
                              .read(tripsRepositoryProvider)
                              .deleteChecklistItem(widget.tripId, item['id']);
                        },
                        child: CheckboxListTile(
                          title: Text(item['title'],
                              style: TextStyle(
                                  decoration: item['isChecked']
                                      ? TextDecoration.lineThrough
                                      : null)),
                          value: item['isChecked'],
                          onChanged: (val) => ref
                              .read(tripsRepositoryProvider)
                              .toggleChecklistItem(
                                  widget.tripId, item['id'], val!),
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

