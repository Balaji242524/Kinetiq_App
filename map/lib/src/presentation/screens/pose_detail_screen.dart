import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/pose_data_model.dart';
import '../widgets/pose_painter.dart';

class PoseDetailScreen extends StatefulWidget {
  final PoseData poseData;

  const PoseDetailScreen({super.key, required this.poseData});

  @override
  State<PoseDetailScreen> createState() => _PoseDetailScreenState();
}

class _PoseDetailScreenState extends State<PoseDetailScreen> {
  ui.Image? _image;
  List<Map<String, dynamic>>? _keypoints;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final imageBytes = await File(widget.poseData.localImagePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    
    final keypointsData = jsonDecode(widget.poseData.keypointsJson);
    final keypointsList = (keypointsData['keypoints'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();

    setState(() {
      _image = frame.image;
      _keypoints = keypointsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pose Details'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: (_image == null || _keypoints == null)
            ? const CircularProgressIndicator() 
            : FittedBox( 
                child: SizedBox(
                  width: _image!.width.toDouble(),
                  height: _image!.height.toDouble(),
                  child: CustomPaint(
                    painter: PosePainter(
                      image: _image!,
                      keypoints: _keypoints!,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}