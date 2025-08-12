import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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

  bool _isPaintingVisible = true;

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

    if (mounted) {
      setState(() {
        _image = frame.image;
        _keypoints = keypointsList;
      });
    }
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
            onPressed: () {
              Clipboard.setData(ClipboardData(text: prettyJson));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Keypoints copied to clipboard!')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(widget.poseData.timestamp)),
        actions: [
          IconButton(
            icon: Icon(_isPaintingVisible ? Icons.visibility_off : Icons.visibility),
            tooltip: 'Toggle Pose Overlay',
            onPressed: () {
              setState(() {
                _isPaintingVisible = !_isPaintingVisible;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy_all_rounded),
            tooltip: 'View & Copy Keypoints',
            onPressed: () {
              _showKeypointsDialog(context, widget.poseData.keypointsJson);
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: (_image == null || _keypoints == null)
            ? const CircularProgressIndicator()
            : Hero(
                tag: widget.poseData.localImagePath,
                child: FittedBox(
                  child: SizedBox(
                    width: _image!.width.toDouble(),
                    height: _image!.height.toDouble(),
                    child: CustomPaint(
                      painter: PosePainter(
                        image: _image!,
                        keypoints: _isPaintingVisible ? _keypoints! : [],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}