import 'dart:io';

import 'package:flutter/material.dart';

import 'platform.dart';

abstract class PlatformBackgroundManager {
 factory PlatformBackgroundManager() {
  if (Platform.isAndroid) {
    return PlatformBackgroundManagerMobile();
  }
  return PlatformBackgroundManagerDesktop();
 } 

 Future<void> enableBackgroundExecution(BuildContext context);
}