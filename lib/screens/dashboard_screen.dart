import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/widgets/artisan_card.dart';
import 'package:skillpay/services/jobs_service.dart';
import 'package:skillpay/services/categories_service.dart';
import 'package:skillpay/services/artisans_service.dart';
import 'package:skillpay/models/job_model.dart';
import 'package:skillpay/models/artisan_model.dart';
import 'package:skillpay/screens/notifications_screen.dart';
import 'package:skillpay/screens/artisans_screen.dart';
import 'package:skillpay/screens/hire_artisan_screen.dart';
import 'package:skillpay/services/auth_service.dart';
import 'package:skillpay/screens/history_screen.dart';
import 'package:skillpay/screens/history_job_details_screen.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final JobsService _jobsService = JobsService();
  final CategoriesService _categoriesService = CategoriesService();
  final ArtisansService _artisansService = ArtisansService();
  final AuthService _authService = AuthService();

  late Future<List<JobModel>> _jobsFuture;
  late Future<Map<String, dynamic>?> _userProfileFuture;
  late Future<List<CategoryItemModel>> _categoriesFuture;
  late Future<List<ArtisanModel>> _artisansFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _userProfileFuture = _fetchUserProfile();
  }

  void _refreshData() {
    setState(() {
      _jobsFuture = _jobsService.fetchCustomerJobs();
      _categoriesFuture = _categoriesService.fetchCategories();
      _artisansFuture = _artisansService.fetchTopArtisans();
    });
  }

  Future<Map<String, dynamic>?> _fetchUserProfile() async {
    return _authService.fetchUserProfile();
  }

  void _navigateToHire(ArtisanModel artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HireArtisanScreen(
          artisanData: {
            'id': artisan.id,
            'name': artisan.fullName,
            'profession': artisan.profession,
            'rating': artisan.rating,
            'jobsCompleted': artisan.jobsCompleted,
            'imagePath': artisan.profilePhoto ?? 'assets/images/avatar_james.png',
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          _refreshData();
          await Future.wait([_jobsFuture, _categoriesFuture, _artisansFuture]);
        },
        child: CustomScrollView(
          slivers: [
            // Black Header Sliver
            SliverToBoxAdapter(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  left: 24,
                  right: 24,
                  bottom: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User area & Bell
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FutureBuilder<Map<String, dynamic>?>(
                          future: _userProfileFuture,
                          initialData: () {
                            final u = Supabase.instance.client.auth.currentUser;
                            return {
                              'id': u?.id ?? '',
                              'full_name': u?.userMetadata?['full_name'] ?? 'User',
                              'email': u?.email,
                            };
                          }(),
                          builder: (context, snapshot) {
                            String firstName = 'User';
                            if (snapshot.hasData && snapshot.data != null) {
                              final fullName = snapshot.data!['full_name'] as String?;
                              if (fullName != null && fullName.isNotEmpty) {
                                firstName = fullName.split(' ').first;
                              }
                            }

                            return Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE0E0E0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hi $firstName,',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'What do you want to do today?',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: const Color(0xFFB0B0B0),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        // Notification bell
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(22),
                          child: Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                              ),
                              Positioned(
                                top: 10,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Search Bar
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArtisansScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Search for worker...',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFB0B0B0),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.search_rounded,
                              color: Color(0xFFB0B0B0),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Below Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Categories Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Categories',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Categories
                    FutureBuilder<List<CategoryItemModel>>(
                      future: _categoriesFuture,
                      initialData: _categoriesService.getCachedCategories(),
                      builder: (context, snapshot) {
                        final categories = snapshot.data ?? [];
                        if (categories.isEmpty) {
                          return const SizedBox(height: 100);
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ArtisansScreen(
                                          initialCategoryId: cat.id,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: _CategoryItem(cat.image, cat.name),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFF0F0F0), thickness: 8),
                    const SizedBox(height: 24),

                    // Top Artisans Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Top Artisans',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ArtisansScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              child: Text(
                                'View all',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Dynamic Top Artisans
                    FutureBuilder<List<ArtisanModel>>(
                      future: _artisansFuture,
                      initialData: _artisansService.getCachedTopArtisans(),
                      builder: (context, snapshot) {
                        final artisans = snapshot.data ?? [];
                        if (snapshot.connectionState == ConnectionState.waiting && artisans.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }

                        if (artisans.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text(
                              'No artisans available at the moment.',
                              style: GoogleFonts.outfit(color: AppColors.textMedium),
                            ),
                          );
                        }

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: artisans.map((artisan) {
                              return ArtisanCard(
                                id: artisan.id,
                                imagePath: artisan.profilePhoto,
                                name: artisan.fullName,
                                profession: artisan.profession,
                                jobsCompleted: artisan.jobsCompleted,
                                rating: artisan.rating,
                                onTap: () => _navigateToHire(artisan),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFF0F0F0), thickness: 8),
                    const SizedBox(height: 24),

                    // History Section Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'History',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const HistoryScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                              child: Text(
                                'View all',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Dynamic Jobs History Data
                    FutureBuilder<List<JobModel>>(
                      future: _jobsFuture,
                      initialData: _jobsService.getCachedCustomerJobs(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                        }

                        final jobs = snapshot.data ?? [];

                        if (jobs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                            child: Text(
                              'No jobs history found.',
                              style: GoogleFonts.outfit(color: AppColors.textMedium, fontSize: 14),
                            ),
                          );
                        }

                        // Take top 3 for dashboard
                        final previewJobs = jobs.take(3).toList();

                        return Column(
                          children: previewJobs.map((job) {
                            final String displayArtisan = job.artisanName != null && job.artisanName!.isNotEmpty
                                ? job.artisanName!
                                : (job.artisanId != null ? 'Assigned' : 'Searching');

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HistoryJobDetailsScreen(job: job),
                                  ),
                                );
                              },
                              child: _buildHistoryItem(
                                id: job.id.split('-').first.toUpperCase(),
                                artisan: displayArtisan,
                                trade: job.category,
                                status: job.status.capitalize(),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 80), // Padding for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String id,
    required String artisan,
    required String trade,
    required String status,
  }) {
    final isCompleted = status.toLowerCase() == 'completed';
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.work_outline_rounded,
                    color: AppColors.textDark, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOB-$id',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$artisan  |  $trade',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFE8F5E9)  // Light green
                      : const Color(0xFFFFF3E0), // Light orange
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String? imagePath;
  final String title;

  const _CategoryItem(this.imagePath, this.title);

  Widget _buildIcon() {
    final img = imagePath;
    if (img != null && (img.startsWith('http://') || img.startsWith('https://'))) {
      return Image.network(
        img,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.handyman_rounded, size: 36, color: AppColors.primary),
      );
    } else if (img != null && img.startsWith('assets/')) {
      return Image.asset(
        img,
        width: 44,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.handyman_rounded, size: 36, color: AppColors.primary),
      );
    }
    return const Icon(Icons.handyman_rounded, size: 36, color: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: _buildIcon(),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
