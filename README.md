# AI Plant Expert (식물 판별 앱)

TensorFlow Lite (TFLite) 모델을 활용하여 식물(및 사물) 사진을 판별하는 Flutter 애플리케이션 예제입니다.

## 📱 프로젝트 소개
이 프로젝트는 온디바이스 머신러닝을 활용하여 인터넷 연결 없이도 이미지를 분류할 수 있는 기능을 제공합니다.
기본적으로 `MobileNet V1` 모델을 사용하여 1000여 가지의 사물을 식별할 수 있으며, 추후 식물 전용 데이터셋으로 학습된 모델로 교체하여 "식물 전문가" 앱으로 발전시킬 수 있습니다.

## ✨ 주요 기능
- **이미지 선택**: 갤러리에서 사진을 선택하거나 카메라로 직접 촬영할 수 있습니다.
- **이미지 분류**: 선택된 이미지를 TFLite 모델(MobileNet V1)을 통해 분석합니다.
- **결과 표시**: 분석 결과 중 확신이 높은 상위 3개의 클래스와 정확도를 표시합니다.

## 🛠 기술 스택
- **Flutter**: UI 및 앱 개발 프레임워크
- **tflite_flutter**: TFLite 모델 실행을 위한 플러그인
- **image_picker**: 카메라 및 갤러리 접근
- **image**: 이미지 크기 조절 및 전처리

## 🚀 시작하기

### 1. 설치
프로젝트를 클론하고 의존성을 설치합니다.
```bash
flutter pub get
```

### 2. 모델 설정
이 예제에는 이미 `assets/` 폴더에 `MobileNet V1` 모델과 라벨 파일이 포함되어 있습니다.
- `assets/model.tflite`
- `assets/labels.txt`

### 3. 실행
iOS 시뮬레이터 또는 Android 에뮬레이터에서 실행합니다.
```bash
flutter run
```

## ⚠️ 참고사항
현재 포함된 모델은 일반적인 사물 인식용 `MobileNet V1`입니다. 
더 정확한 **식물 판별**을 위해서는 [TensorFlow Hub](https://tfhub.dev/)나 [Teachable Machine](https://teachablemachine.withgoogle.com/) 등을 통해 식물 데이터로 학습된 `.tflite` 모델을 구하여 `assets/` 폴더의 파일을 교체해야 합니다.

## 📂 프로젝트 구조
- `lib/main.dart`: UI 및 앱의 메인 로직
- `lib/classifier.dart`: TFLite 모델 로드 및 이미지 추론 담당 (한글 주석 포함)
- `assets/`: 머신러닝 모델 및 라벨 파일 저장소
