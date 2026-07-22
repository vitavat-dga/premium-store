import 'package:flutter/material.dart';

const Color kBlack = Color(0xFF0A0A0A);
const Color kDarkBg = Color(0xFF111111);
const Color kDarkSurface = Color(0xFF1C1C1C);
const Color kDarkCard = Color(0xFF1E1E1E);
const Color kGold = Color(0xFFC9A84C);
const Color kGoldLight = Color(0xFFE8C96A);
const Color kGoldDark = Color(0xFF9B7E35);
const Color kTextPrimary = Color(0xFFF5F5F5);
const Color kTextSecondary = Color(0xFF9E9E9E);
const Color kTextMuted = Color(0xFF616161);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDarkBg,
    colorScheme: const ColorScheme.dark(
      primary: kGold,
      onPrimary: kBlack,
      secondary: kGoldLight,
      onSecondary: kBlack,
      surface: kDarkSurface,
      onSurface: kTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBlack,
      foregroundColor: kGold,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      iconTheme: IconThemeData(color: kGold),
    ),
    cardTheme: const CardThemeData(
      color: kDarkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBlack,
      selectedItemColor: kGold,
      unselectedItemColor: kTextMuted,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kDarkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kTextMuted),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kTextMuted),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kGold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: kTextSecondary),
      hintStyle: const TextStyle(color: kTextMuted),
      prefixIconColor: kGold,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGold,
        foregroundColor: kBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: kGold)),
    dividerTheme: const DividerThemeData(color: kDarkSurface),
    chipTheme: ChipThemeData(
      backgroundColor: kDarkSurface,
      selectedColor: kGold,
      labelStyle: const TextStyle(color: kTextPrimary),
      secondaryLabelStyle: const TextStyle(color: kBlack),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kTextMuted),
      ),
    ),
    iconTheme: const IconThemeData(color: kTextSecondary),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: kGold, foregroundColor: kBlack),
  );
}

Widget goldDivider() {
  return Container(
    height: 1,
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, kGold, Colors.transparent])),
  );
}

/// Format a THB price, e.g. 25000 → "฿25,000".
String formatThb(double price) {
  final str = price.toStringAsFixed(0);
  final result = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) result.write(',');
    result.write(str[i]);
    count++;
  }
  return '฿${result.toString().split('').reversed.join()}';
}
