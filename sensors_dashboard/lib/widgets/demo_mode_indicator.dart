import 'package:flutter/material.dart';
import '../core/utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
class DemoModeIndicator extends StatelessWidget {
  const DemoModeIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Aplikacja działa w trybie demonstracyjnym z użyciem wygenerowanych danych. Połączenie z MongoDB jest wyłączone.',
      preferBelow: true,
      showDuration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        color: Colors.amber[700]?.withAlphaFromOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white,
      ),      child: Container(        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.amber.withAlphaFromOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.amber,
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              'Demo',
              style: GoogleFonts.inter(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Colors.amber[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
