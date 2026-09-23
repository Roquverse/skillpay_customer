import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/services/artisans_service.dart';
import 'package:skillpay/services/categories_service.dart';
import 'package:skillpay/models/artisan_model.dart';
import 'package:skillpay/screens/hire_artisan_screen.dart';

class ArtisansScreen extends StatefulWidget {
  final String? initialCategoryId;

  const ArtisansScreen({super.key, this.initialCategoryId});

  @override
  State<ArtisansScreen> createState() => _ArtisansScreenState();
}

class _ArtisansScreenState extends State<ArtisansScreen> {
  final ArtisansService _artisansService = ArtisansService();
  final CategoriesService _categoriesService = CategoriesService();

  final TextEditingController _searchCtrl = TextEditingController();
  late Future<List<ArtisanModel>> _artisansFuture;
  late Future<List<CategoryItemModel>> _categoriesFuture;

  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _categoriesFuture = _categoriesService.fetchCategories();
    _fetchArtisans();
  }

  void _fetchArtisans() {
    setState(() {
      _artisansFuture = _artisansService.fetchArtisans(
        search: _searchCtrl.text,
        categoryId: _selectedCategoryId,
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Artisans',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: Color(0xFF9E9E9E), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onSubmitted: (_) => _fetchArtisans(),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search by artisan name or trade...',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF9E9E9E),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
                        ),
                      ),
                      if (_searchCtrl.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            _fetchArtisans();
                          },
                          child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                FutureBuilder<List<CategoryItemModel>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    final categories = snapshot.data ?? [];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip(
                            label: 'All',
                            isSelected: _selectedCategoryId == null,
                            onTap: () {
                              setState(() => _selectedCategoryId = null);
                              _fetchArtisans();
                            },
                          ),
                          ...categories.map((cat) {
                            return _buildChip(
                              label: cat.name,
                              isSelected: _selectedCategoryId == cat.id,
                              onTap: () {
                                setState(() {
                                  _selectedCategoryId =
                                      _selectedCategoryId == cat.id ? null : cat.id;
                                });
                                _fetchArtisans();
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Artisans List
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => _fetchArtisans(),
              child: FutureBuilder<List<ArtisanModel>>(
                future: _artisansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Unable to load artisans\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(color: AppColors.textMedium),
                      ),
                    );
                  }

                  final artisans = snapshot.data ?? [];

                  if (artisans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 56, color: Color(0xFFB0B0B0)),
                          const SizedBox(height: 12),
                          Text(
                            'No artisans found',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try selecting another category or clear your search',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: artisans.length,
                    itemBuilder: (context, index) {
                      final artisan = artisans[index];
                      return _buildArtisanRow(artisan);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  Widget _buildArtisanRow(ArtisanModel artisan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: _buildAvatar(artisan.profilePhoto),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            artisan.fullName,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (artisan.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, size: 16, color: Color(0xFF2E7D32)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artisan.profession,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _navigateToHire(artisan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Hire',
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          if (artisan.bio != null && artisan.bio!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              artisan.bio!,
              style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF616161), height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.work_outline_rounded, size: 15, color: AppColors.textMedium),
                  const SizedBox(width: 5),
                  Text(
                    '(${artisan.jobsCompleted}) Jobs completed',
                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.primaryDark),
                  const SizedBox(width: 4),
                  Text(
                    artisan.rating.toStringAsFixed(1),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? photo) {
    if (photo != null && (photo.startsWith('http://') || photo.startsWith('https://'))) {
      return Image.network(
        photo,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    } else if (photo != null && photo.startsWith('assets/')) {
      return Image.asset(
        photo,
        width: 46,
        height: 46,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 46,
      height: 46,
      color: const Color(0xFFE0E0E0),
      child: const Icon(Icons.person, color: Colors.white, size: 26),
    );
  }
}
