import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'dart:io';

const defaultDevices = [
  Device.phone,
  Device.iphone11,
  Device.tabletPortrait,
];

Future<void> setupGoldenTests() async {
  await loadAppFonts();
}

WidgetWrapper materialWrapper({ThemeData? theme}) {
  return (Widget child) => MaterialApp(
        theme: theme ?? ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: child,
      );
}

bool get isGoldenTestsSupported {
  // We skip golden tests on non-Linux platforms to avoid flaky font rendering in CI.
  return Platform.isLinux;
}
