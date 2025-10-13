import 'package:flutter_test/flutter_test.dart';
import 'package:mandarart_journey/services/image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageService', () {
    group('getPixelRatioForPreset', () {
      test('returns 3.0 for original preset', () {
        final ratio = ImageService.getPixelRatioForPreset(WallpaperPreset.original);
        expect(ratio, 3.0);
      });

      test('returns 4.0 for iPhone preset', () {
        final ratio = ImageService.getPixelRatioForPreset(WallpaperPreset.iphone);
        expect(ratio, 4.0);
      });

      test('returns 4.0 for iPad preset', () {
        final ratio = ImageService.getPixelRatioForPreset(WallpaperPreset.ipad);
        expect(ratio, 4.0);
      });
    });

    group('getTargetSizeForPreset', () {
      test('returns null for original preset', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.original);
        expect(size, isNull);
      });

      test('returns iPhone wallpaper size for iPhone preset', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.iphone);
        expect(size, isNotNull);
        expect(size!.width, 1290);
        expect(size.height, 2796);
      });

      test('returns iPad wallpaper size for iPad preset', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.ipad);
        expect(size, isNotNull);
        expect(size!.width, 2048);
        expect(size.height, 2732);
      });
    });

    group('getFileNameForPreset', () {
      test('returns correct filename for original preset', () {
        final filename = ImageService.getFileNameForPreset(WallpaperPreset.original);
        expect(filename, 'mandalart.png');
      });

      test('returns correct filename for iPhone preset', () {
        final filename = ImageService.getFileNameForPreset(WallpaperPreset.iphone);
        expect(filename, 'mandalart_iphone.png');
      });

      test('returns correct filename for iPad preset', () {
        final filename = ImageService.getFileNameForPreset(WallpaperPreset.ipad);
        expect(filename, 'mandalart_ipad.png');
      });
    });

    group('getPresetLabel', () {
      test('returns Korean label for original preset', () {
        final label = ImageService.getPresetLabel(WallpaperPreset.original);
        expect(label, '현재 화면 크기로 저장');
      });

      test('returns Korean label with dimensions for iPhone preset', () {
        final label = ImageService.getPresetLabel(WallpaperPreset.iphone);
        expect(label, '아이폰 배경화면 (1290×2796)');
        expect(label.contains('1290'), true);
        expect(label.contains('2796'), true);
      });

      test('returns Korean label with dimensions for iPad preset', () {
        final label = ImageService.getPresetLabel(WallpaperPreset.ipad);
        expect(label, '아이패드 배경화면 (2048×2732)');
        expect(label.contains('2048'), true);
        expect(label.contains('2732'), true);
      });
    });

    group('WallpaperPreset enum', () {
      test('has exactly 3 values', () {
        expect(WallpaperPreset.values.length, 3);
      });

      test('contains all expected preset types', () {
        expect(WallpaperPreset.values.contains(WallpaperPreset.original), true);
        expect(WallpaperPreset.values.contains(WallpaperPreset.iphone), true);
        expect(WallpaperPreset.values.contains(WallpaperPreset.ipad), true);
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

      test('all presets have target size or null', () {
        for (final preset in WallpaperPreset.values) {
          final size = ImageService.getTargetSizeForPreset(preset);
          if (preset == WallpaperPreset.original) {
            expect(size, isNull);
          } else {
            expect(size, isNotNull);
            expect(size!.width, greaterThan(0));
            expect(size.height, greaterThan(0));
          }
        }
      });
    });

    group('size validation', () {
      test('iPhone size is portrait orientation', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.iphone);
        expect(size!.height, greaterThan(size.width));
      });

      test('iPad size is portrait orientation', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.ipad);
        expect(size!.height, greaterThan(size.width));
      });

      test('iPhone size has correct aspect ratio', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.iphone);
        final aspectRatio = size!.width / size.height;
        // iPhone 15 Pro Max aspect ratio is approximately 0.461
        expect(aspectRatio, closeTo(0.461, 0.01));
      });

      test('iPad size has correct aspect ratio', () {
        final size = ImageService.getTargetSizeForPreset(WallpaperPreset.ipad);
        final aspectRatio = size!.width / size.height;
        // iPad Pro 12.9" aspect ratio is approximately 0.749
        expect(aspectRatio, closeTo(0.749, 0.01));
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

      test('higher quality presets have equal or higher pixel ratios', () {
        final originalRatio = ImageService.getPixelRatioForPreset(WallpaperPreset.original);
        final iphoneRatio = ImageService.getPixelRatioForPreset(WallpaperPreset.iphone);
        final ipadRatio = ImageService.getPixelRatioForPreset(WallpaperPreset.ipad);

        expect(iphoneRatio, greaterThanOrEqualTo(originalRatio));
        expect(ipadRatio, greaterThanOrEqualTo(originalRatio));
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
        final iphoneLabel = ImageService.getPresetLabel(WallpaperPreset.iphone);
        final ipadLabel = ImageService.getPresetLabel(WallpaperPreset.ipad);

        expect(iphoneLabel.contains('1290'), true);
        expect(iphoneLabel.contains('2796'), true);
        expect(ipadLabel.contains('2048'), true);
        expect(ipadLabel.contains('2732'), true);
      });
    });
  });
}
