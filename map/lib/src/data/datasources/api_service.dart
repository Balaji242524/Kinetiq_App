import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/logger.dart';

class ApiService {
  final String _baseUrl = 'http://10.229.24.235:5000'; 

  Future<String?> getKeypointsFromImage(File image) async {
    final uri = Uri.parse('$_baseUrl/process_image');
    AppLogger.log('Sending image to Python backend at $uri');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file', 
          image.path,
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        AppLogger.log('Successfully received keypoints from backend.');
        return response.body;
      } else {
        AppLogger.log(
          'Backend Error: Failed to get keypoints. Status: ${response.statusCode}',
          error: response.body,
        );
        return null;
      }
    } catch (e, s) {
      AppLogger.log('Network Error: Failed to connect to backend', error: e, stackTrace: s);
      return null;
    }
  }
}