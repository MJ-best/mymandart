import 'dart:typed_data';

void downloadImageWeb(Uint8List image) {
  // This should not be called on mobile.
  throw UnimplementedError('Web download is not supported on this platform.');
}
