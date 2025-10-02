import 'dart:html' as html;
import 'dart:typed_data';

void downloadImageWeb(Uint8List image) {
  final blob = html.Blob([image]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'mandalart.png')
    ..click();
  html.Url.revokeObjectUrl(url);
}
