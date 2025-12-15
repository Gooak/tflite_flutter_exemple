import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// TFLite 모델을 로드하고 이미지 분류를 수행하는 헬퍼 클래스입니다.
class Classifier {
  Interpreter? _interpreter;
  List<String>? _labels;

  static const String _modelFile = 'assets/mobilenet_v4.tflite';
  static const String _labelsFile = 'assets/labels_v4.txt';

  Classifier() {
    _loadModel();
    _loadLabels();
  }

  /// TFLite 모델 파일을 메모리로 로드합니다.
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        _modelFile,
        options: InterpreterOptions()..threads = 4,
      );
      print('Model loaded successfully');
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  /// 분류 결과 매핑을 위한 라벨 파일을 로드합니다.
  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString(_labelsFile);
      _labels = labelData.split('\n');
      print('Labels loaded successfully');
    } catch (e) {
      print('Error loading labels: $e');
    }
  }

  /// 이미지를 입력받아 모델 추론을 실행하고 확률이 높은 상위 3개 결과를 반환합니다.
  Future<Map<String, double>?> predict(File imageFile) async {
    if (_interpreter == null || _labels == null) {
      print('Interpreter or labels not loaded');
      return null;
    }

    // 1. 이미지 전처리 (Preprocess image)
    // 파일을 바이트로 읽어서 이미지 객체로 변환합니다.
    var image = img.decodeImage(imageFile.readAsBytesSync());
    if (image == null) return null;

    // MobileNet V1 모델은 224x224 크기의 입력을 기대합니다.
    var resizedImage = img.copyResize(image, width: 224, height: 224);

    // 입력 텐서 생성 (Provide input tensor)
    // 형태: [1, 224, 224, 3] (배치 크기, 높이, 너비, 채널)
    // 타입: float32
    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          var pixel = resizedImage.getPixel(x, y);
          // 정규화 (Normalization): ImageNet 표준 (mean, std)
          // (pixel / 255.0 - mean) / std
          return [
            ((pixel.r / 255.0) - 0.485) / 0.229,
            ((pixel.g / 255.0) - 0.456) / 0.224,
            ((pixel.b / 255.0) - 0.406) / 0.225,
          ];
        }),
      ),
    );

    // 출력 텐서 생성 (Output tensor)
    // 출력 텐서 생성 (Output tensor)
    // 형태: [1, 1000] (MobileNetV4는 보통 1000개 클래스)
    var outputBuffer = List.filled(1 * 1000, 0.0).reshape([1, 1000]);

    // 2. 추론 실행 (Run inference)
    _interpreter!.run(input, outputBuffer);

    // 3. 결과 처리 (Process output)
    var output = outputBuffer[0] as List<double>;

    // 라벨과 점수를 매핑합니다.
    Map<String, double> labeledResults = {};
    for (int i = 0; i < output.length; i++) {
      if (i < _labels!.length) {
        labeledResults[_labels![i]] = output[i];
      }
    }

    // 점수가 높은 순서대로 정렬합니다.
    var sortedKeys = labeledResults.keys.toList(growable: false)
      ..sort((k1, k2) => labeledResults[k2]!.compareTo(labeledResults[k1]!));

    // 상위 3개 결과만 추출하여 반환합니다.
    Map<String, double> topResults = {};
    for (var key in sortedKeys.take(3)) {
      topResults[key] = labeledResults[key]!;
    }

    return topResults;
  }
}
