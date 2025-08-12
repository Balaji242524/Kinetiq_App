import 'package:flutter/material.dart';
import '../../data/models/pose_data_model.dart';
import '../../data/repositories/pose_repository.dart';
import '../../core/logger.dart';

class PoseProvider extends ChangeNotifier {
  final PoseRepository _repo = PoseRepository();
  
  bool _isLoading = false;
  List<PoseData> _history = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<PoseData> get history => _history;
  String? get errorMessage => _errorMessage;

  PoseProvider() {
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    _setLoading(true);
    try {
      _history = await _repo.getHistory();
      AppLogger.log('History fetched and state updated.');
    } catch (e, s) {
      AppLogger.log('Failed to fetch history', error: e, stackTrace: s);
      _errorMessage = "Failed to load history.";
    }
    _setLoading(false);
  }

  Future<void> captureAndProcessImage() async {
    _setLoading(true);
    _errorMessage = null;

    final success = await _repo.captureAndProcessImage();
    
    if (success) {
      await fetchHistory();
    } else {
      _errorMessage = "Failed to process image. Please try again.";
      AppLogger.log(_errorMessage!);
    }
    
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}