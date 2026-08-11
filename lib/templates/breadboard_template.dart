import 'package:flutter_arduino_playground/templates/project_template.dart';

final breadboardTemplate = ProjectTemplate(
  name: 'Breadboard',
  cppCode: '''
void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  Serial.println("Hello World");
  digitalWrite(13, HIGH);
  delay(500);
  
  digitalWrite(13, LOW);
  delay(500);
}
''',
  diagramCode: '''
Circuit(
  parts: [
    Part(type: 'Breadboard Half', id: 'part1', x: -760.0, y: -230.0, rotation: 1.5707963267948966, properties: {'Color': 'Red'}),
    Part(type: 'LED', id: 'led1', x: -310.0, y: -190.0, properties: {'Color': 'Red'}),
    Part(type: 'Breadboard Half', id: 'part2', x: -90.0, y: -230.0),
    Part(type: 'LED', id: 'led2', x: 0.0, y: -250.0, properties: {'Color': 'Green'}),
    Part(type: 'Arduino Uno', id: 'uno', x: -500.0, y: -80.0),
  ],
  wires: [
    Wire(from: 'part1:sig_left_b_8', to: 'uno:GND_1', color: 'black'),
    Wire(from: 'part1:sig_left_b_7', to: 'uno:13', color: 'red'),
  ]
)
''',
);
