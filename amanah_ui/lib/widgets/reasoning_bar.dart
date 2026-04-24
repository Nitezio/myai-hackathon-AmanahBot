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
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isAnalyzing ? Colors.blueAccent : Colors.greenAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: isAnalyzing 
                  ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)
                  : const Icon(Icons.psychology_outlined, size: 16, color: Colors.greenAccent),
              ),
              const SizedBox(width: 10),
              Text(
                isAnalyzing ? "AGENT ACTIVE" : "AGENT VERDICT",
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.5,
                  color: isAnalyzing ? Colors.blueAccent : Colors.greenAccent
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            reasoning,
            style: const TextStyle(
              fontFamily: 'monospace', 
              color: Colors.white70, 
              fontSize: 13,
              height: 1.4
            ),
          ),
        ],
      ),
    );
  }
}
