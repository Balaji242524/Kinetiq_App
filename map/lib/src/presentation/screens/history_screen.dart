import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/pose_provider.dart';
import 'pose_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose History'),
      ),
      body: Consumer<PoseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.history.isEmpty) {
            return const Center(
              child: Text('No history found. Press the camera button to start.'),
            );
          }
          return ListView.builder(
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final pose = provider.history[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.file(
                      File(pose.localImagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                  title: Text(
                    DateFormat.yMMMd().add_jms().format(pose.timestamp),
                  ),
                  subtitle: Text('Tap to view pose'),
                  trailing: IconButton( 
                    icon: const Icon(Icons.code),
                    onPressed: () => _showKeypointsDialog(context, pose.keypointsJson),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoseDetailScreen(poseData: pose),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showImageSourceDialog(context);
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                context.read<PoseProvider>().processImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
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

  void _showKeypointsDialog(BuildContext context, String jsonString) {
    const jsonEncoder = JsonEncoder.withIndent('  ');
    final prettyJson = jsonEncoder.convert(jsonDecode(jsonString));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keypoints JSON'),
        content: SingleChildScrollView(
          child: Text(prettyJson),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}