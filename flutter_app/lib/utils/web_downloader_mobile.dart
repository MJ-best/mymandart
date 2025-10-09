import 'dart:typed_data';

void downloadImageWeb(Uint8List image, {String fileName = 'mandalart.png'}) {
  // This should not be called on mobile.
  throw UnimplementedError('Web download is not supported on this platform.');
}
