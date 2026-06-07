import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/manager_provider.dart';
import '../../../models/review.dart';

class ManagerReviewsScreen extends StatefulWidget {
  const ManagerReviewsScreen({super.key});

  @override
  State<ManagerReviewsScreen> createState() => _ManagerReviewsScreenState();
}

class _ManagerReviewsScreenState extends State<ManagerReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ManagerProvider>(context, listen: false).loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ManagerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = provider.reviewSummary;

        if (summary == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined,
                    size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('Failed to load reviews',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => provider.loadReviews(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadReviews(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCard(summary),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'All Reviews',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${summary.totalReviews}',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (summary.reviews.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.reviews_outlined,
                            size: 60, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('No reviews yet',
                            style: GoogleFonts.poppins(
                                color: Colors.grey.shade500, fontSize: 16)),
                      ],
                    ),
                  ),
                )
              else
                ...summary.reviews
                    .map((review) => _buildReviewCard(review))
                    .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(ReviewSummary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade700, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Rating',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      summary.averageRating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 4),
                      child: Text(
                        '/ 5',
                        style: GoogleFonts.poppins(
                            fontSize: 18, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildStarRow(summary.averageRating, size: 22),
                const SizedBox(height: 6),
                Text(
                  '${summary.totalReviews} ${summary.totalReviews == 1 ? 'review' : 'reviews'}',
                  style:
                      GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _buildRatingBreakdown(summary),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown(ReviewSummary summary) {
    // Count reviews per star
    final counts = List.filled(5, 0);
    for (final r in summary.reviews) {
      final idx = (r.rating - 1).clamp(0, 4);
      counts[idx]++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(5, (i) {
        final star = 5 - i;
        final count = counts[star - 1];
        final fraction =
            summary.totalReviews > 0 ? count / summary.totalReviews : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text('$star',
                  style:
                      GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 10, color: Colors.white70),
              const SizedBox(width: 6),
              SizedBox(
                width: 60,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    backgroundColor: Colors.white24,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text('$count',
                  style:
                      GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    review.customerName.isNotEmpty
                        ? review.customerName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        _formatDate(review.createdAt),
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                _buildStarRow(review.rating.toDouble(), size: 16),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                review.comment,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey.shade700, height: 1.5),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _ratingColor(review.rating).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _ratingLabel(review.rating),
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _ratingColor(review.rating)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (i < rating) {
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }
      }),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 5:
        return '⭐ Excellent';
      case 4:
        return '😊 Good';
      case 3:
        return '😐 Average';
      case 2:
        return '😞 Poor';
      default:
        return '😡 Terrible';
    }
  }

  Color _ratingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.deepOrange;
      default:
        return Colors.red;
    }
  }
}
