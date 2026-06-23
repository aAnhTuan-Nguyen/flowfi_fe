import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FlowFi Typography System
/// All styles use Inter font, mapped from the DESIGN.md spec
abstract final class AppTextStyles {
  // ─── Display ─────────────────────────────────────────────────
  /// Primary balance / large hero numbers — 48sp, w700
  static TextStyle displayLg({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.96,
        height: 56 / 48,
        color: color,
      );

  // ─── Headline ─────────────────────────────────────────────────
  /// Page-level headers — 32sp, w700
  static TextStyle headlineLg({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.32,
        height: 40 / 32,
        color: color,
      );

  /// Section headers / app bar — 24sp, w700
  static TextStyle headlineLgMobile({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        color: color,
      );

  /// Card titles / dialog headers — 24sp, w600
  static TextStyle headlineMd({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: color,
      );

  // ─── Body ─────────────────────────────────────────────────────
  /// Primary body text — 18sp, w400
  static TextStyle bodyLg({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: color,
      );

  /// Secondary body text — 16sp, w400
  static TextStyle bodyMd({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color,
      );

  // ─── Label ────────────────────────────────────────────────────
  /// Interactive labels / buttons — 14sp, w500
  static TextStyle labelMd({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.14,
        height: 20 / 14,
        color: color,
      );

  /// Meta / timestamp / section caps — 12sp, w600
  static TextStyle labelSm({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: color,
      );

  /// Semibold body variant — 16sp, w600
  static TextStyle bodySemibold({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
        color: color,
      );

  /// Bold numeric — 18sp, w700
  static TextStyle numericBold({Color? color}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 28 / 18,
        color: color,
      );
}
