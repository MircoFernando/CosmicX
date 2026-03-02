import 'package:flutter/material.dart';
import '../data/repositories/nasa_repository.dart';
import '../data/models/apod_model.dart';
import '../data/repositories/user_repository.dart'; // <--- 1. ADDED IMPORT
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NasaRepository _nasaRepository = NasaRepository();

  // <--- 2. ADDED MISSING VARIABLES --->
  final UserRepository _userRepo = UserRepository();
  int _totalXp = 0;

  late Future<ApodModel> _apodFuture;

  @override
  void initState() {
    super.initState();
    _apodFuture = _nasaRepository.fetchApod();
    _loadXp(); // 3. Make sure to call this!
  }

  Future<void> _loadXp() async {
    final xp = await _userRepo.getUserScore();
    setState(() {
      _totalXp = xp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("COSMIC QUEST", style: theme.textTheme.headlineSmall),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primaryColor),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: theme.primaryColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  "$_totalXp XP", // Now this variable exists!
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello Cadet!",
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              "Ready to explore the universe?",
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            Text(
              "ASTRONOMY PICTURE OF THE DAY",
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            FutureBuilder<ApodModel>(
              future: _apodFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Graceful error handling
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi_off, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Offline: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  final apod = snapshot.data!;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          apod.url,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apod.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                apod.explanation,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),

            const SizedBox(height: 24),

            _buildNavCard(
              context,
              title: "Take a Quest!",
              subtitle: "Explore the Multiverse",
              icon: Icons.sports_esports,
              color: theme.primaryColor,
              onTap: () async {
                // Wait for quiz to finish, then reload points
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
                _loadXp();
              },
            ),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              title: "Space Now",
              subtitle: "Live Rover & Solar Data",
              icon: Icons.satellite_alt,
              color: Colors.purpleAccent,
              onTap: () {
                // Navigate to Explore Tab
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
