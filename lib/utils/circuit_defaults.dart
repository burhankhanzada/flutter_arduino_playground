class ProjectTemplate {
  final String name;
  final String cppCode;
  final String diagramCode;

  ProjectTemplate({
    required this.name,
    required this.cppCode,
    required this.diagramCode,
  });
}

class CircuitDefaults {
  static List<ProjectTemplate> getTemplates() {
    return [
      ProjectTemplate(
        name: 'Blink',
        cppCode: '''void setup() {
  pinMode(2, OUTPUT);
  pinMode(4, OUTPUT);
}

void loop() {
  Serial.println("Hello World");
  digitalWrite(2, HIGH);
  digitalWrite(4, LOW);
  delay(500);
  
  digitalWrite(2, LOW);
  digitalWrite(4, HIGH);
  delay(500);
}
''',
        diagramCode: '''
Circuit(
  parts: [
    Part(type: 'Arduino Uno', id: 'uno', x: -150.0, y: -50.0),
    Part(type: 'LED', id: 'led1', x: 70.0, y: -180.0),
    Part(type: 'LED', id: 'led2', x: 160.0, y: -180.0),
  ],
  wires: [
    Wire(from: 'led2:cathode', to: 'uno:2', color: 'green'),
    Wire(from: 'led1:cathode', to: 'uno:4', color: 'red'),
    Wire(from: 'led2:anode', to: 'uno:GND_1', color: 'black'),
    Wire(from: 'led1:anode', to: 'uno:GND_1', color: 'black'),
  ]
)
''',
      ),
    ];
  }

  static ProjectTemplate getBlinkExample() {
    return getTemplates().firstWhere((t) => t.name == 'Blink');
  }
}
