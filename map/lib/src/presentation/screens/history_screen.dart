import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pose_provider.dart';
import '../../data/models/pose_data_model.dart';
import 'pose_detail_screen.dart'; 
import '../widgets/shimmer_loading_card.dart'; 

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis History'),
      ),
      body: Consumer<PoseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.history.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: 5, 
              itemBuilder: (context, index) => const ShimmerLoadingCard(),
            );
          }
          if (provider.history.isEmpty) {
            return const Center(
              child: Text('No sessions yet. Start your first analysis.'),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.history.length,
              itemBuilder: (context, index) {
                final pose = provider.history[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildHistoryCard(context, pose),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceDialog(context),
        child: const Icon(Icons.add_chart),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PoseData pose) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PoseDetailScreen(poseData: pose),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Hero(
                tag: pose.localImagePath,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(pose.localImagePath),
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported, size: 30)
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(pose.timestamp),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.jm().format(pose.timestamp),
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Analysis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('From Camera'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<PoseProvider>().processImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('From Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<PoseProvider>().processImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}