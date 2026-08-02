import 'package:flutter/material.dart';

import 'package:flutter_arduino_playground/ui/widgets/main_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MainView());
  }
}
