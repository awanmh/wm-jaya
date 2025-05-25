// scripts/codegen_loader.dart
import 'dart:io';
import 'dart:developer' as developer;
import 'package:process_run/shell.dart'; // Mengimpor pustaka yang benar untuk Shell

void main(List<String> arguments) async {
  final shell = Shell(); // Sekarang Shell sudah terdefinisi

  // Check if build_runner is installed
  final buildRunnerCheck = await shell.run('dart pub get build_runner');
  if (buildRunnerCheck.isEmpty) {
    developer.log('🚨 Error: build_runner not installed!\nInstall it first using:\n  dart pub add build_runner --dev', name: 'codegen_loader');
    exit(1);
  }

  // Run code generation with conflict resolution
  developer.log('🔄 Running code generation...', name: 'codegen_loader');
  try {
    await shell.run('dart run build_runner build --delete-conflicting-outputs');
    developer.log('✅ Code generation completed successfully!', name: 'codegen_loader');
  } catch (e) {
    developer.log('''❌ Code generation failed!\nCommon solutions:\n1. Delete existing generated files:\n   dart run build_runner clean\n2. Check for syntax errors in your models\n3. Ensure all required annotations are added''', name: 'codegen_loader');
    exit(1);
  }
}
