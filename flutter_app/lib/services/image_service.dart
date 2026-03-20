import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:mandarart_journey/utils/web_downloader.dart'
    if (dart.library.io) 'package:mandarart_journey/utils/web_downloader_mobile.dart';

enum WallpaperPreset { portrait, landscape, square }

class ImageService {
  static double getPixelRatioForPreset(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.portrait:
        return 3.0;
      case WallpaperPreset.landscape:
        return 3.0;
      case WallpaperPreset.square:
        return 4.0;
    }
  }

  static ui.Size? getTargetSizeForPreset(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.portrait:
        return const ui.Size(1080, 1920); // 세로모드 (9:16)
      case WallpaperPreset.landscape:
        return const ui.Size(1920, 1080); // 가로모드 (16:9)
      case WallpaperPreset.square:
        return const ui.Size(2048, 2048); // 정사각형
    }
  }

  static String getFileNameForPreset(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.portrait:
        return 'mandalart_portrait.png';
      case WallpaperPreset.landscape:
        return 'mandalart_landscape.png';
      case WallpaperPreset.square:
        return 'mandalart_square.png';
    }
  }

  static String getPresetLabel(WallpaperPreset preset) {
    switch (preset) {
      case WallpaperPreset.portrait:
        return '세로모드 (1080×1920)';
      case WallpaperPreset.landscape:
        return '가로모드 (1920×1080)';
      case WallpaperPreset.square:
        return '정사각형 만다라트만 (2048×2048)';
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
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
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
