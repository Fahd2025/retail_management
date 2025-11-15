/// Stub for web file download (used on non-web platforms)
void downloadFileOnWeb(String content, String filename, String mimeType) {
  throw UnsupportedError('Web file download is only supported on web platform');
}
