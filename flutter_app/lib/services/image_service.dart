import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:mandarart_journey/utils/web_downloader.dart'
    if (dart.library.io) 'package:mandarart_journey/utils/web_downloader_mobile.dart';

enum WallpaperPreset { original, iphone, ipad }

class ImageService {
  static double getPixelRatioForPreset(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.original:
        return 3.0;
      case WallpaperPreset.iphone:
        return 4.0;
      case WallpaperPreset.ipad:
        return 4.0;
    }
  }

  static ui.Size? getTargetSizeForPreset(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.original:
        return null;
      case WallpaperPreset.iphone:
        return const ui.Size(1290, 2796);
      case WallpaperPreset.ipad:
        return const ui.Size(2048, 2732);
    }
  }

  static String getFileNameForPreset(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.original:
        return 'mandalart.png';
      case WallpaperPreset.iphone:
        return 'mandalart_iphone.png';
      case WallpaperPreset.ipad:
        return 'mandalart_ipad.png';
    }
  }

  static String getPresetLabel(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.original:
        return '현재 화면 크기로 저장';
      case WallpaperPreset.iphone:
        return '아이폰 배경화면 (1290×2796)';
      case WallpaperPreset.ipad:
        return '아이패드 배경화면 (2048×2732)';
    }
  }

  static Future<Uint8List?> captureWithPreset(
    ScreenshotController controller,
    WallpaperPreset preset,
  ) async {
    final pixelRatio = getPixelRatioForPreset(preset);
    final bytes = await controller.capture(pixelRatio: pixelRatio);
    if (bytes == null) {
      return null;
    }

    final target = getTargetSizeForPreset(preset);
    if (target == null) {
      return bytes;
    }

    return resizeImage(bytes, target);
  }

  static Future<Uint8List> resizeImage(Uint8List bytes, ui.Size size) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..isAntiAlias = true;
    final src = ui.Rect.fromLTWH(
      0,
      0,
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    );
    final dst = ui.Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(frame.image, src, dst, paint);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static Future<void> saveToGallery(Uint8List imageBytes) async {
    await Gal.putImageBytes(imageBytes);
  }

  static void downloadWeb(Uint8List imageBytes, String fileName) {
    if (kIsWeb) {
      downloadImageWeb(imageBytes, fileName: fileName);
    }
  }
}
