import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CompilerException implements Exception {
  final String message;
  CompilerException(this.message);
  @override
  String toString() => message;
}

class CompilerService {
  static Future<String> compile(String code) async {
    final tempDir = await getTemporaryDirectory();
    final buildDir = Directory('${tempDir.path}/arduino_build');
    
    if (!buildDir.existsSync()) {
      buildDir.createSync(recursive: true);
    }
    
    final sketchDir = Directory('${buildDir.path}/sketch');
    if (sketchDir.existsSync()) {
      sketchDir.deleteSync(recursive: true);
    }
    sketchDir.createSync(recursive: true);
    
    final sketchFile = File('${sketchDir.path}/sketch.ino');
    await sketchFile.writeAsString(code);

    final outDir = Directory('${buildDir.path}/out');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    try {
      final cliPath = await _findArduinoCli();
      if (cliPath == null) {
        throw CompilerException('arduino-cli not found. Please install arduino-cli and ensure it is in your PATH, or installed via Homebrew.');
      }

      final result = await Process.run(
        cliPath,
        [
          'compile',
          '--fqbn',
          'arduino:avr:uno',
          '--output-dir',
          outDir.path,
          sketchDir.path,
        ],
        environment: _buildEnvironment(),
      );

      if (result.exitCode != 0) {
        throw CompilerException('Compilation failed:\n${result.stderr}\n${result.stdout}');
      }

      final hexFile = File('${outDir.path}/sketch.ino.hex');
      if (!hexFile.existsSync()) {
        throw CompilerException('Compilation succeeded but HEX file was not generated.');
      }

      return await hexFile.readAsString();
    } on CompilerException {
      rethrow;
    } on ProcessException catch (e) {
      throw CompilerException(
        'Failed to execute arduino-cli (${e.executable}): ${e.message}\n'
        'Process error code: ${e.errorCode}\n'
        'If you are running on macOS, ensure App Sandbox is disabled and re-run "flutter clean".',
      );
    } catch (e) {
      throw CompilerException('An error occurred during compilation: $e');
    } finally {
      // Clean up
      if (sketchDir.existsSync()) {
        sketchDir.deleteSync(recursive: true);
      }
    }
  }

  static Map<String, String> _buildEnvironment() {
    final env = Map<String, String>.from(Platform.environment);
    final currentPath = env['PATH'] ?? '';
    final home = Platform.environment['HOME'] ?? '';
    final extraPaths = [
      '/opt/homebrew/bin',
      '/usr/local/bin',
      if (home.isNotEmpty) '$home/.local/bin',
      if (home.isNotEmpty) '$home/bin',
      '/usr/bin',
      '/bin',
    ];

    final existingParts = currentPath.split(':');
    final newParts = <String>[];
    for (final path in extraPaths) {
      if (!existingParts.contains(path)) {
        newParts.add(path);
      }
    }
    if (newParts.isNotEmpty) {
      env['PATH'] = '${newParts.join(':')}:$currentPath';
    }
    return env;
  }

  static Future<String?> _findArduinoCli() async {
    final env = _buildEnvironment();
    // 1. Try generic PATH
    try {
      final result = await Process.run(
        'which',
        ['arduino-cli'],
        environment: env,
      );
      if (result.exitCode == 0) {
        final path = result.stdout.toString().trim();
        if (path.isNotEmpty && File(path).existsSync()) {
          return path;
        }
      }
    } catch (_) {}

    // 2. Try common Homebrew and user binary paths
    final home = Platform.environment['HOME'] ?? '';
    final commonPaths = [
      '/opt/homebrew/bin/arduino-cli',
      '/usr/local/bin/arduino-cli',
      if (home.isNotEmpty) '$home/.local/bin/arduino-cli',
      if (home.isNotEmpty) '$home/bin/arduino-cli',
    ];

    for (final path in commonPaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }

    return null;
  }
}
