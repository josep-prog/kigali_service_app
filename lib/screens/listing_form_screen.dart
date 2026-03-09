import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers.dart';
import '../models.dart';
import '../ui_helpers.dart';

/// Unified form for creating and editing listings.
/// Pass [listing] to edit an existing listing; leave null to create a new one.
class ListingFormScreen extends StatefulWidget {
  final ListingModel? listing;
  final double? initialLat;
  final double? initialLng;

  const ListingFormScreen({
    super.key,
    this.listing,
    this.initialLat,
    this.initialLng,
  });

  bool get isEditing => listing != null;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  final _mapController = MapController();
  late String _category;
  late double _previewLat;
  late double _previewLng;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameController = TextEditingController(text: l?.name ?? '');
    _descController = TextEditingController(text: l?.description ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _phoneController = TextEditingController(text: l?.phoneNumber ?? '');
    _category = l?.category ?? 'Hospital';

    _previewLat = l?.latitude ?? widget.initialLat ?? -1.9441;
    _previewLng = l?.longitude ?? widget.initialLng ?? 30.0619;
    _latController =
        TextEditingController(text: _previewLat.toStringAsFixed(6));
    _lngController =
        TextEditingController(text: _previewLng.toStringAsFixed(6));
    _latController.addListener(_updateMapPreview);
    _lngController.addListener(_updateMapPreview);
  }

  void _updateMapPreview() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat != null && lng != null) {
      setState(() {
        _previewLat = lat;
        _previewLng = lng;
      });
      _mapController.move(LatLng(lat, lng), 15.0);
    }
  }

  @override
  void dispose() {
    _latController.removeListener(_updateMapPreview);
    _lngController.removeListener(_updateMapPreview);
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid coordinates', style: GoogleFonts.dmSans()),
          backgroundColor: kTerra,
        ),
      );
      return;
    }

    final provider = context.read<ListingsProvider>();

    if (widget.isEditing) {
      // Update existing listing
      await provider.updateListing(widget.listing!.id!, {
        'name': _nameController.text,
        'category': _category,
        'description': _descController.text,
        'address': _addressController.text,
        'phoneNumber': _phoneController.text,
        'latitude': lat,
        'longitude': lng,
      });
    } else {
      // Create new listing
      final listing = ListingModel(
        name: _nameController.text,
        category: _category,
        description: _descController.text,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        latitude: lat,
        longitude: lng,
        createdBy: context.read<AuthProvider>().currentUser!.uid,
        createdAt: DateTime.now(),
      );
      await provider.createListing(listing);
    }

    if (context.mounted) Navigator.pop(context, widget.isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.isEditing ? 'Edit Place' : 'Add Place')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.storefront_rounded),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              dropdownColor: kSurface2,
              style: GoogleFonts.dmSans(color: kCream),
              items: [
                'Hospital',
                'Police Station',
                'Library',
                'Restaurant',
                'Café',
                'Park',
                'Tourist Attraction',
              ]
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            Icon(kCategoryIcon(c),
                                size: 16, color: kCategoryColor(c)),
                            const SizedBox(width: 8),
                            Text(c),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 3,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Icons.location_on_rounded),
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      prefixIcon: Icon(Icons.my_location_rounded),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      prefixIcon: Icon(Icons.explore_rounded),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Location Preview',
                style: GoogleFonts.dmSans(fontSize: 12, color: kMuted)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 180,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_previewLat, _previewLng),
                    initialZoom: 15,
                    interactionOptions:
                        const InteractionOptions(flags: InteractiveFlag.none),
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
                          point: LatLng(_previewLat, _previewLng),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on,
                              color: kTerra, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            kGradientButton(
              widget.isEditing ? 'Update Listing' : 'Add Listing',
              _submit,
              icon: widget.isEditing ? Icons.save : Icons.add_location,
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      ),
    );
  }
}
