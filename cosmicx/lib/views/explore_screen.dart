import 'package:flutter/material.dart';
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
        title: Text("COSMIC MONITOR", style: theme.textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: theme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.public), text: "Asteroid Watch"),
            Tab(icon: Icon(Icons.photo_library), text: "Earth Gallery"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAsteroidTab(theme), // <--- This is the method you were missing
          _buildGalleryTab(theme),
        ],
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
            child: Text(
              "Radar Offline: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No near-earth objects detected today."),
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

            return Card(
              color: isHazardous
                  ? Colors.red.withOpacity(0.1)
                  : theme.cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isHazardous
                      ? Colors.red
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isHazardous
                      ? Colors.red
                      : theme.primaryColor.withOpacity(0.2),
                  child: Icon(
                    Icons.public_off,
                    color: isHazardous ? Colors.white : theme.primaryColor,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text("Size: $sizeStr  •  Speed: $speedStr"),
                trailing: isHazardous
                    ? const Icon(Icons.warning, color: Colors.red)
                    : const Icon(Icons.check_circle, color: Colors.green),
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
          return const Center(child: Text("No images found."));
        }

        return PageView.builder(
          itemCount: images.length,
          itemBuilder: (context, index) {
            final item = images[index];

            // Helper to format date safely
            String dateStr = item['date'] ?? '';
            if (dateStr.length > 10) dateStr = dateStr.substring(0, 10);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(item['image']),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Gradient Overlay for Text Readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.9),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dateStr,
                            style: TextStyle(color: theme.primaryColor),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
