import 'package:flutter/material.dart';

class AppWidgets {
  static void showSnack(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFF2A0A0A) : const Color(0xFF0A2A0A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
              color: isError ? const Color(0xFFEF5350) : const Color(0xFF66BB6A)),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Widget sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF607D9A),
        fontSize: 11,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static Widget alertBox(String type, String message) {
    final styles = {
      'success': (const Color(0xFF0A2A0A), const Color(0xFF66BB6A), const Color(0xFFA5D6A7), Icons.check_circle_outline),
      'error': (const Color(0xFF2A0A0A), const Color(0xFFEF5350), const Color(0xFFEF9A9A), Icons.error_outline),
      'info': (const Color(0xFF0A1A2A), const Color(0xFF4FC3F7), const Color(0xFF81D4FA), Icons.info_outline),
      'warn': (const Color(0xFF2A1A0A), const Color(0xFFFFA726), const Color(0xFFFFCC80), Icons.warning_amber_outlined),
    };
    final s = styles[type]!;
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: s.$1,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: s.$2, width: 3)),
      ),
      child: Row(
        children: [
          Icon(s.$4, color: s.$3, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: s.$3, fontSize: 13))),
        ],
      ),
    );
  }
}
