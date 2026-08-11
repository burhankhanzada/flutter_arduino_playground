import 'package:flutter_riverpod/flutter_riverpod.dart';

final debugLogsProvider = NotifierProvider<DebugLogsNotifier, List<String>>(
  DebugLogsNotifier.new,
);

class DebugLogsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addLog(String log) {
    state = [...state, log];
  }

  void clear() {
    state = [];
  }
}

final serialLogsProvider = NotifierProvider<SerialLogsNotifier, List<String>>(
  SerialLogsNotifier.new,
);

class SerialLogsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addLog(String log) {
    state = [...state, log];
  }

  void clear() {
    state = [];
  }
}

final spiceLogsProvider = NotifierProvider<SpiceLogsNotifier, List<String>>(
  SpiceLogsNotifier.new,
);

class SpiceLogsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];

  void addLog(String log) {
    state = [...state, log];
  }

  void clear() {
    state = [];
  }
}

final verticalPanelRatioProvider = NotifierProvider<VerticalPanelRatioNotifier, double>(
  VerticalPanelRatioNotifier.new,
);

class VerticalPanelRatioNotifier extends Notifier<double> {
  double _savedRatio = 0.6;

  @override
  double build() => 0.6;

  void updateRatio(double ratio) {
    state = ratio;
    if (ratio < 0.95) {
      _savedRatio = ratio;
    }
  }

  void toggleCollapse() {
    if (state >= 0.95) {
      state = _savedRatio;
    } else {
      _savedRatio = state;
      state = 1.0;
    }
  }
}
