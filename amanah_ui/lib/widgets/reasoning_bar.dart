import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReasoningBar extends StatelessWidget {
  final String reasoning;
  final bool isAnalyzing;

  const ReasoningBar({super.key, required this.reasoning, this.isAnalyzing = false});

  @override
  Widget build(BuildContext context) {
    final bool isError = reasoning.startsWith("ERROR");
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1B).withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAnalyzing 
            ? const Color(0xFF1D1D1B).withValues(alpha: 0.2) 
            : const Color(0xFF1D1D1B).withValues(alpha: 0.05)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security, 
                size: 16, 
                color: isError 
                  ? Colors.redAccent 
                  : (isAnalyzing ? const Color(0xFF1D1D1B) : const Color(0xFF10B981))
              ),
              const SizedBox(width: 8),
              Text(
                "SECURE AGENT LOG", 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.w900, 
                  letterSpacing: 1.2,
                  color: const Color(0xFF1D1D1B).withValues(alpha: 0.4),
                )
              ),
              const Spacer(),
              if (isAnalyzing) 
                SizedBox(
                  height: 12, 
                  width: 12, 
                  child: CircularProgressIndicator(
                    strokeWidth: 2, 
                    color: const Color(0xFF1D1D1B).withValues(alpha: 0.3)
                  )
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reasoning,
            style: GoogleFonts.robotoMono(
              color: isError ? Colors.redAccent : const Color(0xFF1D1D1B).withValues(alpha: 0.7),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}