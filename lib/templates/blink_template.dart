import 'package:flutter_arduino_playground/templates/project_template.dart';

final blinkTemplate = ProjectTemplate(
  name: 'Blink',
  cppCode: '''void setup() {
  Serial.begin(9600);
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
CIRCUIT "Blink"

PARTS
  uno "Arduino Uno" AT -310.0 -230.0
  led1 "LED" AT -150.0 -330.0 PROPERTIES {Color: "Red"}

WIRES
  led1:anode TO uno:13 COLOR red
  led1:cathode TO uno:GND_1 COLOR black
''',
);
