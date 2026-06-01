import 'package:flutter/material.dart';

class AppColors {
  // Primary colors (dari Design System AMIS)
  static const Color primary = Color(0xFF1B4F72);     // Navy - warna utama
  static const Color primaryLight = Color(0xFF2E86C1); // Biru - secondary
  static const Color primaryDark = Color(0xFF154360);  // Navy gelap

  // Status colors
  static const Color success = Color(0xFF27500A);      // Hijau - stok Aman
  static const Color successLight = Color(0xFFD5F5E3); // Hijau muda background
  static const Color warning = Color(0xFF633806);      // Amber - stok Menipis
  static const Color warningLight = Color(0xFFFEF9E7); // Kuning muda background
  static const Color danger = Color(0xFF791F1F);       // Merah - stok Habis
  static const Color dangerLight = Color(0xFFFDEDEC);  // Merah muda background

  // Neutral colors
  static const Color background = Color(0xFFF4F6F9);  // Background abu muda
  static const Color surface = Color(0xFFFFFFFF);     // Card putih
  static const Color textPrimary = Color(0xFF1A1A2E); // Teks utama
  static const Color textSecondary = Color(0xFF6B7280); // Teks sekunder
  static const Color textHint = Color(0xFFB0B7C3);    // Placeholder
  static const Color divider = Color(0xFFE5E7EB);     // Garis pemisah
  static const Color border = Color(0xFFD1D5DB);      // Border input

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B4F72), Color(0xFF2E86C1)],
  );

  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4F72), Color(0xFF154360)],
  );

  // Category colors (untuk avatar produk)
  static const Color pvcColor = Color(0xFF3498DB);
  static const Color plafonColor = Color(0xFF9B59B6);
  static const Color wallpanelColor = Color(0xFF27AE60);

  // WhatsApp & Instagram
  static const Color whatsapp = Color(0xFF25D366);
  static const Color instagram = Color(0xFFE1306C);

  // Chart colors
  static final List<Color> chartColors = [
    const Color(0xFF1B4F72),
    const Color(0xFF2E86C1),
    const Color(0xFF3498DB),
    const Color(0xFF85C1E9),
    const Color(0xFFAED6F1),
    const Color(0xFFD6EAF8),
    const Color(0xFF1A5276),
  ];
}
