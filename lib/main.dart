import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';

/// 앱의 진입점(Entry point)입니다.
void main() {
  runApp(const MyApp());
}

/// 앱의 전반적인 테마와 홈 화면을 설정하는 최상위 위젯입니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Plant Expert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'AI Plant Expert'),
    );
  }
}

/// 메인 화면의 상태를 관리하고 UI를 구성하는 StatefulWidget입니다.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 이미지를 분류하는 헬퍼 클래스 인스턴스
  final Classifier _classifier = Classifier();
  // 이미지를 선택(카메라/갤러리)하는 객체
  final ImagePicker _picker = ImagePicker();

  File? _image; // 선택된 이미지 파일
  Map<String, double>? _results; // 분류 결과 (라벨: 점수)
  bool _loading = false; // 로딩 상태 표시

  /// 갤러리나 카메라에서 이미지를 선택하고 분류를 수행하는 함수입니다.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _results = null;
          _loading = true;
        });

        // 헬퍼 클래스를 통해 이미지 분류 실행
        final predictions = await _classifier.predict(_image!);

        // 결과 업데이트 및 로딩 종료
        setState(() {
          _results = predictions;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 이미지가 선택되었으면 이미지를, 아니면 아이콘을 표시
            if (_image != null)
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              )
            else
              Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            const SizedBox(height: 20),

            // 로딩 중이면 인디케이터, 결과가 있으면 결과 텍스트, 아무것도 없으면 안내 문구 표시
            if (_loading)
              const CircularProgressIndicator()
            else if (_results != null)
              Column(
                children: _results!.entries.map((entry) {
                  return Text(
                    '${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              )
            else
              const Text('사진을 선택하여 식물을 확인해보세요', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 40),

            // 이미지 선택 버튼 영역 (갤러리 / 카메라)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('카메라'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
