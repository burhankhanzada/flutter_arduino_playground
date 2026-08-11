import 'package:flutter_arduino_playground/templates/project_template.dart';
import 'package:flutter_arduino_playground/templates/blink_template.dart';
import 'package:flutter_arduino_playground/templates/breadboard_template.dart';
export 'package:flutter_arduino_playground/templates/project_template.dart';

class CircuitDefaults {
  static List<ProjectTemplate> getTemplates() {
    return [blinkTemplate, breadboardTemplate];
  }

  static ProjectTemplate getBlinkExample() {
    return getTemplates().firstWhere((t) => t.name == 'Blink');
  }
}
