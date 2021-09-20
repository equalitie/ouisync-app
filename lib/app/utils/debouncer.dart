import 'dart:async';

import 'package:flutter/foundation.dart';

class Debouncer {
  Debouncer({
    required this.milliseconds
    });

  final int milliseconds;

  VoidCallback? action;
  Timer? _timer;  
  
  run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }    
    
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
} 