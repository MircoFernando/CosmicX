import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/repositories/nasa_repository.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final NasaRepository _repository = NasaRepository();
  late TabController _tabController;

  // Futures for our data
  late Future<List<Map<String, dynamic>>> _asteroidsFuture;
  late Future<List<Map<String, dynamic>>> _galleryFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize the data fetches
    _asteroidsFuture = _repository.fetchAsteroids();
    _galleryFuture = _repository.fetchEarthGallery();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EXPLORE',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          indicatorWeight: 3,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.radar), text: "ASTEROIDS"),
            Tab(icon: Icon(Icons.satellite_alt), text: "GALLERY"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAsteroidTab(theme), _buildGalleryTab(theme)],
      ),
    );
  }

  // --- TAB 1: ASTEROID WATCH ---
  Widget _buildAsteroidTab(ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _asteroidsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.satellite_outlined,
                  size: 80,
                  color: theme.primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  "Connection Lost",
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Unable to reach NASA servers",
                  style: GoogleFonts.inter(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 80,
                  color: Colors.green.withOpacity(0.6),
                ),
                const SizedBox(height: 20),
                Text(
                  "All Clear",
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "No near-Earth objects detected today",
                  style: GoogleFonts.inter(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final asteroids = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: asteroids.length,
          itemBuilder: (context, index) {
            final asteroid = asteroids[index];
            final name = asteroid['name'];
            final isHazardous = asteroid['is_potentially_hazardous_asteroid'];

            // Safe parsing for nested JSON data
            final diameter =
                asteroid['estimated_diameter']['meters']['estimated_diameter_max'];
            final velocity =
                asteroid['close_approach_data'][0]['relative_velocity']['kilometers_per_hour'];

            final sizeStr = "${diameter.toStringAsFixed(1)}m";
            final speedStr =
                "${(double.parse(velocity) / 1000).toStringAsFixed(1)}k km/h";

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: isHazardous
                    ? LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.15),
                          Colors.red.withOpacity(0.05),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          theme.primaryColor.withOpacity(0.08),
                          theme.primaryColor.withOpacity(0.02),
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHazardous
                      ? Colors.red.withOpacity(0.6)
                      : theme.primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isHazardous
                          ? [
                              Colors.red.withOpacity(0.4),
                              Colors.red.withOpacity(0.2),
                            ]
                          : [
                              theme.primaryColor.withOpacity(0.3),
                              theme.primaryColor.withOpacity(0.1),
                            ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isHazardous
                            ? Colors.red.withOpacity(0.2)
                            : theme.primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.blur_circular,
                    color: isHazardous ? Colors.red : theme.primaryColor,
                    size: 28,
                  ),
                ),
                title: Text(
                  name,
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lens_blur,
                        size: 15,
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(sizeStr, style: GoogleFonts.inter(fontSize: 13)),
                      const SizedBox(width: 18),
                      Icon(
                        Icons.flash_on,
                        size: 15,
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(speedStr, style: GoogleFonts.inter(fontSize: 13)),
                    ],
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isHazardous
                        ? Colors.red.withOpacity(0.25)
                        : Colors.green.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHazardous ? Icons.warning_amber_rounded : Icons.verified,
                    color: isHazardous ? Colors.red : Colors.green,
                    size: 22,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAB 2: EARTH GALLERY ---
  Widget _buildGalleryTab(ThemeData theme) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _galleryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final images = snapshot.data ?? [];

        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  "No Images Available",
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final item = images[index];

            // Helper to format date safely
            String dateStr = item['date'] ?? '';
            if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);

            return Container(
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Image
                    Positioned.fill(
                      child: Image.network(
                        item['image'],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.cardColor,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Gradient Overlay for Text Readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.85),
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item['title'],
                              style: GoogleFonts.orbitron(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: theme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateStr,
                                  style: GoogleFonts.inter(
                                    color: theme.primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item['description'],
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Page Indicator
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor.withOpacity(0.9),
                              theme.primaryColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Text(
                          '${index + 1} / ${images.length}',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
