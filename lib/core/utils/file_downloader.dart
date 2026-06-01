import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart'
    if (dart.library.io) 'file_downloader_mobile.dart';

Future<void> saveAndDownloadFile(String csvContent, String filename) async {
  await downloadFile(csvContent, filename);
}
