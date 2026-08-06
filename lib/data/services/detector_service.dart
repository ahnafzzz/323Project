import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/config/env.dart';

class Prediction {
  final String label;
  final double confidence;

  Prediction({required this.label, required this.confidence});
}

class DetectorResponse {
  final bool success;
  final String? topLabel;
  final double? topConfidence;
  final List<Prediction> predictions;
  final String? error;

  DetectorResponse({
    required this.success,
    this.topLabel,
    this.topConfidence,
    this.predictions = const [],
    this.error,
  });
}

class DetectorService {
  final Dio _dio = Dio();

  Future<DetectorResponse> predict(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      Response response = await _dio.post(
        Env.detectorUrl,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        var data = response.data;
        List<Prediction> predictions = (data['predictions'] as List)
            .map((p) => Prediction(label: p['label'], confidence: p['confidence']))
            .toList();

        return DetectorResponse(
          success: true,
          topLabel: data['top_label'],
          topConfidence: data['top_confidence'],
          predictions: predictions,
        );
      } else {
        return DetectorResponse(
          success: false,
          error: response.data['message'] ?? "Unknown error from server",
        );
      }
    } catch (e) {
      return DetectorResponse(success: false, error: e.toString());
    }
  }
}
