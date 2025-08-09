import 'dart:async';
import 'package:flutter/material.dart';

class UseDebounce {
  Timer? _debounceTimer;
  final Duration delay;

  UseDebounce({this.delay = const Duration(milliseconds: 500)});

  void run(VoidCallback action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  void cancel() {
    _debounceTimer?.cancel();
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}

class DebouncedTextController extends TextEditingController {
  final Duration delay;
  final void Function(String) onDebounced;
  Timer? _debounceTimer;

  DebouncedTextController({
    super.text,
    this.delay = const Duration(milliseconds: 500),
    required this.onDebounced,
  }) {
    addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      onDebounced(text);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    removeListener(_onTextChanged);
    super.dispose();
  }
}
