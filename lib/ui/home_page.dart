import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_arduino_playground/ui/widgets/header_bar.dart';
import 'package:flutter_arduino_playground/ui/widgets/main_workspace.dart';

class LeftPanelRatioNotifier extends Notifier<double> {
  @override
  double build() => 0.5;

  void updateRatio(double ratio) {
    state = ratio;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          HeaderBar(),
          Expanded(child: MainWorkspace()),
        ],
      ),
    );
  }
}
