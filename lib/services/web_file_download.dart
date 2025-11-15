// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
// ignore: unused_import
import 'dart:html' as html;

/// Download a file on web platform
void downloadFileOnWeb(String content, String filename, String mimeType) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
