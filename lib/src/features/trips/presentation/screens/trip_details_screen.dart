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
import '../../domain/trip.dart';
import '../../../../core/constants/app_colors.dart';
import 'tabs/route_tab.dart';
import 'tabs/checklist_tab.dart';
import 'tabs/expenses_tab.dart';
import 'tabs/documents_tab.dart';
import 'tabs/gallery_tab.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String tripId;
  const TripDetailsScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripAsync = ref.watch(tripsStreamProvider.select((async) {
      return async.whenData((trips) => trips.firstWhere(
            (t) => t.id == tripId,
            orElse: () => throw Exception('Viaje no encontrado'),
          ));
    }));

    return tripAsync.when(
      data: (trip) {
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 200.0,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(trip.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              "https://maps.googleapis.com/maps/api/staticmap?center=${Uri.encodeComponent(trip.destination)}&zoom=11&size=500x250&maptype=terrain&key=${dotenv.env['GOOGLE_MAPS_API_KEY']}",
                          fit: BoxFit.cover,
                          memCacheWidth: 500,
                          memCacheHeight: 250,
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
                      labelColor: AppColors.primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppColors.primary,
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
                  RouteTab(destination: trip.destination, tripId: tripId),
                  ChecklistTab(tripId: tripId),
                  ExpensesTab(tripId: tripId, trip: trip),
                  DocumentsTab(tripId: tripId),
                  GalleryTab(tripId: tripId),
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
