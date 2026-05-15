import 'package:flutter/material.dart';

class DemoState {
  static String? overrideRole; // "SELLER" or "BUYER"
  static bool isDemoMode = false;
  static String? activeEscrowId;
  
  static final ValueNotifier<bool> demoNotifier = ValueNotifier<bool>(false);

  static void activateDemo(String role) {
    overrideRole = role;
    isDemoMode = true;
    demoNotifier.value = true;
  }
}
