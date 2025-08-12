class PoseData {
  final int? id;
  final DateTime timestamp;
  final String keypointsJson;
  final String localImagePath;
  final String? cloudImageUrl;

  PoseData({
    this.id,
    required this.timestamp,
    required this.keypointsJson,
    required this.localImagePath,
    this.cloudImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'keypoints_json': keypointsJson,
      'image_path': cloudImageUrl ?? localImagePath,
    };
  }

  factory PoseData.fromMap(Map<String, dynamic> map) {
    return PoseData(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      keypointsJson: map['keypoints_json'],
      localImagePath: map['image_path'],
      cloudImageUrl: (map['image_path'] as String).startsWith('http')
          ? map['image_path']
          : null,
    );
  }
}