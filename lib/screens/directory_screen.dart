import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers.dart';
import '../models.dart';
import '../ui_helpers.dart';
import 'listing_detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  late final Stream<List<ListingModel>> _baseStream;

  static const categories = [
    'All',
    'Hospital',
    'Police Station',
    'Library',
    'Restaurant',
    'Café',
    'Park',
    'Tourist Attraction',
  ];

  @override
  void initState() {
    super.initState();
    _baseStream = context.read<ListingsProvider>().listingsStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                color: kSurface,
                border: Border(bottom: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [kGreen, kGreenLight],
                      ),
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: kGreen.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_city_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KIGALI GUIDE',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: kCream,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Text(
                        'Services & Places Directory',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: kMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    context.read<ListingsProvider>().setSearchQuery(v),
              ),
            ),
            Consumer<ListingsProvider>(
              builder: (context, provider, _) {
                final selected = provider.selectedCategory;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selected,
                        isExpanded: true,
                        dropdownColor: kSurface2,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded,
                            color: kMuted),
                        onChanged: (v) => provider.setCategory(v!),
                        selectedItemBuilder: (_) => categories.map((cat) {
                          final isAll = cat == 'All';
                          final color = isAll ? kMuted : kCategoryColor(cat);
                          final icon =
                              isAll ? Icons.apps_rounded : kCategoryIcon(cat);
                          return Row(
                            children: [
                              Icon(icon, size: 16, color: color),
                              const SizedBox(width: 10),
                              Text(
                                cat,
                                style: GoogleFonts.dmSans(
                                  color: kCream,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        items: categories.map((cat) {
                          final isAll = cat == 'All';
                          final color = isAll ? kMuted : kCategoryColor(cat);
                          final icon =
                              isAll ? Icons.apps_rounded : kCategoryIcon(cat);
                          final isSelected = selected == cat;
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(icon, size: 16, color: color),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  cat,
                                  style: GoogleFonts.dmSans(
                                    color: isSelected ? color : kCream,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                if (isSelected) const Spacer(),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Consumer<ListingsProvider>(
                builder: (context, provider, _) {
                  return StreamBuilder<List<ListingModel>>(
                    stream: _baseStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListView(
                          padding: const EdgeInsets.all(16),
                          children: List.generate(6, (_) => kShimmerCard()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: kTerra, size: 56),
                              const SizedBox(height: 16),
                              Text('Error: ${snapshot.error}',
                                  style: GoogleFonts.dmSans(color: kMuted)),
                            ],
                          ),
                        );
                      }

                      var listings = snapshot.data ?? [];
                      if (provider.searchQuery.isNotEmpty) {
                        listings = listings
                            .where((l) => l.name
                                .toLowerCase()
                                .contains(provider.searchQuery.toLowerCase()))
                            .toList();
                      }
                      if (provider.selectedCategory != 'All') {
                        listings = listings
                            .where((l) =>
                                l.category == provider.selectedCategory)
                            .toList();
                      }

                      if (listings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  color: kMuted, size: 64),
                              const SizedBox(height: 16),
                              Text('No listings found',
                                  style: GoogleFonts.dmSans(
                                      fontSize: 15, color: kMuted)),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filter',
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: kMuted.withValues(alpha: 0.7)),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: listings.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10, top: 4),
                              child: Text(
                                '${listings.length} ${listings.length == 1 ? 'place' : 'places'} found',
                                style:
                                    GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                              ),
                            );
                          }
                          final listing = listings[index - 1];
                          return _ListingCard(listing: listing)
                              .animate(delay: ((index - 1) * 50).ms)
                              .fadeIn(duration: 350.ms)
                              .slideX(begin: 0.05);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ListingDetailScreen(listing: listing)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              kCategoryBadge(listing.category),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            listing.name,
                            style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kCream),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: kCategoryColor(listing.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            listing.category,
                            style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: kCategoryColor(listing.category),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: kTerra, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            listing.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.phone, color: kGreenLight, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          listing.phoneNumber,
                          style:
                              GoogleFonts.dmSans(fontSize: 12, color: kMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: kTerra, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
