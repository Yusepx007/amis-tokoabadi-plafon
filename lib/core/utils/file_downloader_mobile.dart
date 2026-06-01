import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> downloadFile(String csvContent, String filename) async {
  // Gunakan temporary directory agar tidak membutuhkan permission write storage pada Android/iOS
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/$filename');
  await tempFile.writeAsString('\uFEFF$csvContent');

  if (Platform.isAndroid || Platform.isIOS) {
    // Di HP, cara paling aman dan premium adalah memicu Share Sheet sistem.
    // Pengguna bisa langsung membuka file, menyimpannya ke folder mana pun, atau langsung membagikannya ke WhatsApp/Telegram.
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      subject: 'Laporan Keuangan Toko Abadi Plafon',
    );
  } else {
    // Untuk platform Desktop (Windows/macOS/Linux):
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final destFile = File('${downloadsDir.path}/$filename');
        await destFile.writeAsString('\uFEFF$csvContent');
        final url = Uri.file(destFile.path);
        if (await canLaunchUrl(url)) {
          await launchUrl(url);
          return;
        }
      }
    } catch (_) {
      // Abaikan jika terjadi error dan gunakan fallback di bawah
    }

    final url = Uri.file(tempFile.path);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
