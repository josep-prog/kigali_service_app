import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers.dart';
import '../models.dart';
import '../ui_helpers.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  bool _pickingLocation = false;
  late final Stream<List<ListingModel>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = context.read<ListingsProvider>().listingsStream;
  }

  List<Marker> _buildMarkers(List<ListingModel> listings) {
    return listings.map((listing) {
      final color = kCategoryColor(listing.category);
      return Marker(
        point: LatLng(listing.latitude, listing.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: kSurface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        kCategoryBadge(listing.category),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(listing.name,
                                  style: GoogleFonts.playfairDisplay(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: kCream)),
                              Text(listing.category,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 12, color: kGreenLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: kTerra, size: 15),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(listing.address,
                              style: GoogleFonts.dmSans(
                                  fontSize: 13, color: kMuted)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: kGreenLight, size: 15),
                        const SizedBox(width: 6),
                        Text(listing.phoneNumber,
                            style: GoogleFonts.dmSans(
                                fontSize: 13, color: kMuted)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    kGradientButton(
                      'View Details',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ListingDetailScreen(listing: listing)),
                        );
                      },
                      icon: Icons.arrow_forward,
                    ),
                  ],
                ),
              ),
            );
          },
          child: Icon(Icons.location_on, color: color, size: 40),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map View')),
      body: Stack(
        children: [
          StreamBuilder<List<ListingModel>>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: kGreenLight),
                      const SizedBox(height: 16),
                      Text('Loading map...', style: GoogleFonts.dmSans(color: kMuted)),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: kTerra, size: 56),
                      const SizedBox(height: 16),
                      Text('Error: ${snapshot.error}', style: GoogleFonts.dmSans(color: kMuted)),
                    ],
                  ),
                );
              }

              final listings = snapshot.data ?? [];

              return FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(-1.9441, 30.0619),
                  initialZoom: 12,
                  onTap: _pickingLocation
                      ? (_, point) {
                          setState(() => _pickingLocation = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingFormScreen(
                                initialLat: point.latitude,
                                initialLng: point.longitude,
                              ),
                            ),
                          );
                        }
                      : null,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.kigali_city_services',
                  ),
                  MarkerLayer(markers: _buildMarkers(listings)),
                ],
              );
            },
          ),

          if (_pickingLocation)
            Positioned(
              top: 16,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tap anywhere on the map to place your listing',
                        style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _pickingLocation = false),
                      child: const Text('✕', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 96,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'map_fab',
              onPressed: () => setState(() => _pickingLocation = true),
              backgroundColor: kGreen,
              child: const Icon(Icons.add_location_alt, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
