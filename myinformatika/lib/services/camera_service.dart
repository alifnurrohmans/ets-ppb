import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  static final CameraService _instance = CameraService._internal();
  
  factory CameraService() {
    return _instance;
  }

  CameraService._internal();

  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isInitialized = false;

  /// Get camera controller
  CameraController get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize camera
  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      _controller = CameraController(
        _cameras[0], // Use first camera (usually back camera)
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _controller.initialize();
      _isInitialized = true;
      debugPrint('Camera initialized successfully');
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      rethrow;
    }
  }

  /// Switch to front or back camera
  Future<void> switchCamera() async {
    try {
      final lensDirection = _controller.description.lensDirection;
      CameraDescription newCamera;

      if (lensDirection == CameraLensDirection.back) {
        newCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras[0],
        );
      } else {
        newCamera = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras[0],
        );
      }

      await _controller.dispose();
      _controller = CameraController(newCamera, ResolutionPreset.high);
      await _controller.initialize();
      _isInitialized = true;
      debugPrint('Camera switched successfully');
    } catch (e) {
      debugPrint('Error switching camera: $e');
      rethrow;
    }
  }

  /// Take a picture
  Future<XFile?> takePicture() async {
    try {
      if (!_isInitialized || !_controller.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      if (_controller.value.isTakingPicture) {
        return null;
      }

      final image = await _controller.takePicture();
      debugPrint('Picture taken: ${image.path}');
      return image;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      rethrow;
    }
  }

  /// Start video recording
  Future<void> startVideoRecording() async {
    try {
      if (!_isInitialized || !_controller.value.isInitialized) {
        throw Exception('Camera is not initialized');
      }

      if (_controller.value.isRecordingVideo) {
        return;
      }

      await _controller.startVideoRecording();
      debugPrint('Video recording started');
    } catch (e) {
      debugPrint('Error starting video recording: $e');
      rethrow;
    }
  }

  /// Stop video recording
  Future<XFile?> stopVideoRecording() async {
    try {
      if (!_controller.value.isRecordingVideo) {
        return null;
      }

      final video = await _controller.stopVideoRecording();
      debugPrint('Video recording stopped: ${video.path}');
      return video;
    } catch (e) {
      debugPrint('Error stopping video recording: $e');
      rethrow;
    }
  }

  /// Dispose camera
  Future<void> dispose() async {
    try {
      if (_isInitialized) {
        await _controller.dispose();
        _isInitialized = false;
        debugPrint('Camera disposed');
      }
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }
}
