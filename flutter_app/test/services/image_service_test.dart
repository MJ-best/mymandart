import 'package:flutter_test/flutter_test.dart';
import 'package:mandarart_journey/services/image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageService', () {
    group('getPixelRatioForPreset', () {
      test('returns 3.0 for portrait preset', () {
        final ratio = ImageService.getPixelRatioForPreset(WallpaperPreset.portrait);
        expect(ratio, 3.0);
      });

      test('returns 3.0 for landscape preset', () {
        final ratio = ImageService.getPixelRatioForPreset(WallpaperPreset.landscape);
        expect(ratio, 3.0);
      });

      test('returns 4.0 for square preset', () {
        final ratio = ImageService.getPixelRatioForPreset(WallpaperPreset.square);
        expect(ratio, 4.0);
      });
    });

    group('getTargetSizeForPreset', () {
      test('returns portrait size for portrait preset', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.portrait);
        expect(size, isNotNull);
        expect(size!.width, 1080);
        expect(size.height, 1920);
      });

      test('returns landscape size for landscape preset', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.landscape);
        expect(size, isNotNull);
        expect(size!.width, 1920);
        expect(size.height, 1080);
      });

      test('returns square size for square preset', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.square);
        expect(size, isNotNull);
        expect(size!.width, 2048);
        expect(size.height, 2048);
      });
    });

    group('getFileNameForPreset', () {
      test('returns correct filename for portrait preset', () {
        final filename = ImageService.getFileNameForPreset(WallpaperPreset.portrait);
        expect(filename, 'mandalart_portrait.png');
      });

      test('returns correct filename for landscape preset', () {
        final filename = ImageService.getFileNameForPreset(WallpaperPreset.landscape);
        expect(filename, 'mandalart_landscape.png');
      });

      test('returns correct filename for square preset', () {
        final filename = ImageService.getFileNameForPreset(WallpaperPreset.square);
        expect(filename, 'mandalart_square.png');
      });
    });

    group('getPresetLabel', () {
      test('returns Korean label for portrait preset', () {
        final label = ImageService.getPresetLabel(WallpaperPreset.portrait);
        expect(label, '세로모드 (1080×1920)');
      });

      test('returns Korean label with dimensions for landscape preset', () {
        final label = ImageService.getPresetLabel(WallpaperPreset.landscape);
        expect(label, '가로모드 (1920×1080)');
        expect(label.contains('1920'), true);
        expect(label.contains('1080'), true);
      });

      test('returns Korean label with dimensions for square preset', () {
        final label = ImageService.getPresetLabel(WallpaperPreset.square);
        expect(label, '정사각형 만다라트만 (2048×2048)');
        expect(label.contains('2048'), true);
      });
    });

    group('WallpaperPreset enum', () {
      test('has exactly 3 values', () {
        expect(WallpaperPreset.values.length, 3);
      });

      test('contains all expected preset types', () {
        expect(WallpaperPreset.values.contains(WallpaperPreset.portrait), true);
        expect(WallpaperPreset.values.contains(WallpaperPreset.landscape), true);
        expect(WallpaperPreset.values.contains(WallpaperPreset.square), true);
      });
    });

    group('preset consistency', () {
      test('all presets have pixel ratio defined', () {
        for (final preset in WallpaperPreset.values) {
          final ratio = ImageService.getPixelRatioForPreset(preset);
          expect(ratio, greaterThan(0));
        }
      });

      test('all presets have filename defined', () {
        for (final preset in WallpaperPreset.values) {
          final filename = ImageService.getFileNameForPreset(preset);
          expect(filename, isNotEmpty);
          expect(filename.endsWith('.png'), true);
        }
      });

      test('all presets have label defined', () {
        for (final preset in WallpaperPreset.values) {
          final label = ImageService.getPresetLabel(preset);
          expect(label, isNotEmpty);
        }
      });

      test('all presets have target size', () {
        for (final preset in WallpaperPreset.values) {
          final size = ImageService.getTargetSizeForPreset(preset);
          expect(size, isNotNull);
          expect(size!.width, greaterThan(0));
          expect(size.height, greaterThan(0));
        }
      });
    });

    group('size validation', () {
      test('portrait size is portrait orientation', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.portrait);
        expect(size!.height, greaterThan(size.width));
      });

      test('landscape size is landscape orientation', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.landscape);
        expect(size!.width, greaterThan(size.height));
      });

      test('square size has equal dimensions', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.square);
        expect(size!.width, equals(size.height));
      });

      test('portrait size has correct aspect ratio', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.portrait);
        final aspectRatio = size!.width / size.height;
        // 9:16 aspect ratio
        expect(aspectRatio, closeTo(0.5625, 0.01));
      });
    });

    group('pixel ratio validation', () {
      test('all pixel ratios are reasonable values', () {
        for (final preset in WallpaperPreset.values) {
          final ratio = ImageService.getPixelRatioForPreset(preset);
          expect(ratio, greaterThanOrEqualTo(1.0));
          expect(ratio, lessThanOrEqualTo(10.0));
        }
      });

      test('square preset has highest pixel ratio', () {
        final portraitRatio = ImageService.getPixelRatioForPreset(WallpaperPreset.portrait);
        final landscapeRatio = ImageService.getPixelRatioForPreset(WallpaperPreset.landscape);
        final squareRatio = ImageService.getPixelRatioForPreset(WallpaperPreset.square);

        expect(squareRatio, greaterThanOrEqualTo(portraitRatio));
        expect(squareRatio, greaterThanOrEqualTo(landscapeRatio));
      });
    });

    group('filename validation', () {
      test('all filenames are unique', () {
        final filenames = WallpaperPreset.values
            .map((preset) => ImageService.getFileNameForPreset(preset))
            .toList();
        final uniqueFilenames = filenames.toSet();
        expect(filenames.length, uniqueFilenames.length);
      });

      test('all filenames contain "mandalart"', () {
        for (final preset in WallpaperPreset.values) {
          final filename = ImageService.getFileNameForPreset(preset);
          expect(filename.toLowerCase().contains('mandalart'), true);
        }
      });

      test('filenames have no spaces', () {
        for (final preset in WallpaperPreset.values) {
          final filename = ImageService.getFileNameForPreset(preset);
          expect(filename.contains(' '), false);
        }
      });
    });

    group('label validation', () {
      test('all labels contain Korean text', () {
        for (final preset in WallpaperPreset.values) {
          final label = ImageService.getPresetLabel(preset);
          // Check if label contains Korean characters (Hangul range)
          final hasKorean = label.runes.any((rune) =>
            (rune >= 0xAC00 && rune <= 0xD7A3) || // Hangul syllables
            (rune >= 0x1100 && rune <= 0x11FF) || // Hangul Jamo
            (rune >= 0x3130 && rune <= 0x318F)    // Hangul Compatibility Jamo
          );
          expect(hasKorean, true, reason: 'Label "$label" should contain Korean text');
        }
      });

      test('sized presets include dimensions in label', () {
        final portraitLabel = ImageService.getPresetLabel(WallpaperPreset.portrait);
        final landscapeLabel = ImageService.getPresetLabel(WallpaperPreset.landscape);
        final squareLabel = ImageService.getPresetLabel(WallpaperPreset.square);

        expect(portraitLabel.contains('1080'), true);
        expect(portraitLabel.contains('1920'), true);
        expect(landscapeLabel.contains('1920'), true);
        expect(landscapeLabel.contains('1080'), true);
        expect(squareLabel.contains('2048'), true);
      });
    });
  });
}
