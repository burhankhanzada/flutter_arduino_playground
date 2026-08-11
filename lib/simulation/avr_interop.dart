import 'dart:typed_data';
import 'package:avr8_dart/avr8_dart.dart';

class AVRBridge {
  static const int clockHz = 16000000;

  static late CPU _cpu;
  static late AVRIOPort _portB;
  // ignore: unused_field
  static late AVRTimer _timer0;
  static late AVRUSART _usart0;

  /// Receives whatever the sketch writes to `Serial`.
  static void Function(String)? onSerialByte;

  static void loadHex(String hexString) {
    final program = Uint16List(0x4000); // 32KB flash is 16K x 16-bit
    _parseHex(hexString, program);
    _cpu = CPU(program);
    _timer0 = AVRTimer(_cpu, timer0Config);
    _portB = AVRIOPort(_cpu, portBConfig);

    // USART0 must be emulated even if nothing reads the output. Without it the
    // UDRE flag never sets, the Arduino core's 64-byte tx ring never drains,
    // and the fifth Serial.print blocks the sketch forever.
    _usart0 = AVRUSART(_cpu, usart0Config, clockHz);
    _usart0.onByteTransmit = (byte) {
      onSerialByte?.call(String.fromCharCode(byte));
    };
  }

  /// Advances the CPU by [cycles] *clock cycles* (not instructions -- an AVR
  /// instruction takes one to four of them). Pacing on cycles is what keeps
  /// `delay()` and `millis()` lined up with wall-clock time.
  static void runCycles(int cycles) {
    final target = _cpu.cycles + cycles;
    while (_cpu.cycles < target) {
      avrInstruction(_cpu);
      _cpu.tick();
    }
  }

  static bool getPin13State() {
    // Pin 13 is PB5
    return _portB.pinState(5) == PinState.High;
  }

  static void _parseHex(String hexString, Uint16List flash) {
    flash.fillRange(0, flash.length, 0);
    final lines = hexString.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line[0] != ':') continue;
      
      final type = line.substring(7, 9);
      if (type == '00') { // Data record
        final length = int.parse(line.substring(1, 3), radix: 16);
        final addr = int.parse(line.substring(3, 7), radix: 16);
        
        for (int i = 0; i < length; i += 2) {
          final lsb = int.parse(line.substring(9 + i * 2, 11 + i * 2), radix: 16);
          int msb = 0;
          if (i + 1 < length) {
            msb = int.parse(line.substring(11 + i * 2, 13 + i * 2), radix: 16);
          }
          flash[(addr + i) >> 1] = (msb << 8) | lsb;
        }
      }
    }
  }
}
