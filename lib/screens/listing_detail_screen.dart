import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models.dart';
import '../ui_helpers.dart';
import 'listing_form_screen.dart';

class ListingDetailScreen extends StatelessWidget {
  final ListingModel listing;
  final bool canEdit;

  const ListingDetailScreen({super.key, required this.listing, this.canEdit = false});

  Widget _circleButton(IconData icon, Color iconColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(fontSize: 14, color: kCream),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = kCategoryColor(listing.category);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _circleButton(Icons.arrow_back_rounded, Colors.white,
                  () => Navigator.pop(context)),
              const Spacer(),
              if (canEdit)
                _circleButton(Icons.edit_rounded, kGold, () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ListingFormScreen(listing: listing)),
                  );
                  if (updated == true && context.mounted) {
                    Navigator.pop(context);
                  }
                }),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Full-bleed map at top
          SizedBox(
            height: 320,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(listing.latitude, listing.longitude),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.kigali_city_services',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(listing.latitude, listing.longitude),
                      width: 44,
                      height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: categoryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.location_on,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable content card overlapping the map
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 284), // leaves top 36px of map peeking above card
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 284,
                  ),
                  decoration: const BoxDecoration(
                    color: kBg,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Name + category badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            kCategoryBadge(listing.category),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    listing.name,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: kCream,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      listing.category,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: categoryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kSurface2,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            listing.description,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: kCream, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Info rows
                        _infoRow(Icons.location_on_rounded, listing.address, kTerra),
                        const SizedBox(height: 12),
                        _infoRow(Icons.phone_rounded, listing.phoneNumber, kGreenLight),
                        const SizedBox(height: 28),

                        // Buttons
                        kGradientButton(
                          'Get Directions',
                          () async {
                            final url = Uri.parse(
                                'https://www.google.com/maps/dir/?api=1&destination=${listing.latitude},${listing.longitude}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: Icons.directions_rounded,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final url =
                                Uri.parse('tel:${listing.phoneNumber}');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: kTerra),
                            minimumSize: const Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.phone_rounded, color: kTerra),
                          label: Text('Call',
                              style: GoogleFonts.dmSans(
                                  color: kTerra,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
