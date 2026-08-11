import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_arduino_playground/constants.dart';
import 'package:flutter_arduino_playground/models/component_model.dart';

final componentRegistryProvider = FutureProvider<List<ComponentModel>>((
  ref,
) async {
  return standardComponents;
});
