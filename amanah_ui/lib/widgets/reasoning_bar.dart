import 'package:flutter/material.dart';

class ReasoningBar extends StatelessWidget {
  final String reasoning;
  final bool isAnalyzing;

  const ReasoningBar({super.key, required this.reasoning, this.isAnalyzing = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAnalyzing ? Colors.blueAccent : Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, size: 16, color: isAnalyzing ? Colors.blueAccent : Colors.greenAccent),
              const SizedBox(width: 8),
              const Text("SECURE AGENT LOG", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const Spacer(),
              if (isAnalyzing) const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            reasoning,
            style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 13),
          ),
        ],
      ),
    );
  }
}