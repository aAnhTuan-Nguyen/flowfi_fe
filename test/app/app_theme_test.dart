import 'package:flowfi_fe/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('buildAppTheme loads the FlowFi design typography', () {
    final theme = buildAppTheme();
    final plusJakartaSansFamily = GoogleFonts.plusJakartaSans().fontFamily;

    expect(theme.colorScheme.primary, const Color(0xFF628141));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFFF8F3));
    expect(theme.textTheme.bodyMedium?.fontSize, 16);
    expect(theme.textTheme.labelMedium?.fontSize, 14);
    expect(theme.textTheme.bodyMedium?.fontFamily, plusJakartaSansFamily);
  });
}
