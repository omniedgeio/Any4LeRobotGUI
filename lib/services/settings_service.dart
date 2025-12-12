import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

class SettingsService extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Python path
  String _pythonPath = 'python3';
  String get pythonPath => _pythonPath;
  
  // Any4LeRobot repo path
  String _repoPath = '';
  String get repoPath => _repoPath;
  
  // Default output directory
  String _defaultOutputDir = '';
  String get defaultOutputDir => _defaultOutputDir;
  
  // Hugging Face repo ID
  String _hfRepoId = '';
  String get hfRepoId => _hfRepoId;
  
  // Bundled backend path (auto-detected)
  String _bundledBackendPath = '';
  String get bundledBackendPath => _bundledBackendPath;
  
  // Effective repo path (use bundled if custom not set)
  String get effectiveRepoPath => _repoPath.isNotEmpty ? _repoPath : _bundledBackendPath;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _pythonPath = _prefs.getString('pythonPath') ?? 'python3';
    _repoPath = _prefs.getString('repoPath') ?? '';
    _defaultOutputDir = _prefs.getString('defaultOutputDir') ?? '';
    _hfRepoId = _prefs.getString('hfRepoId') ?? '';
    
    // Auto-detect bundled backend
    await _detectBundledBackend();
  }
  
  Future<void> _detectBundledBackend() async {
    // Try to find the backend directory relative to the executable
    final execDir = File(Platform.resolvedExecutable).parent.path;
    
    // In debug mode, the app runs from the project directory
    // Check common locations
    final possiblePaths = [
      p.join(Directory.current.path, 'backend'),
      p.join(execDir, '..', '..', '..', '..', '..', 'backend'),
      p.join(execDir, 'backend'),
    ];
    
    for (final path in possiblePaths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        final canonicalPath = await dir.resolveSymbolicLinks();
        _bundledBackendPath = canonicalPath;
        debugPrint('Found bundled backend at: $_bundledBackendPath');
        notifyListeners();
        return;
      }
    }
    
    debugPrint('Bundled backend not found in common paths');
  }
  
  Future<void> setPythonPath(String path) async {
    _pythonPath = path;
    await _prefs.setString('pythonPath', path);
    notifyListeners();
  }
  
  Future<void> setRepoPath(String path) async {
    _repoPath = path;
    await _prefs.setString('repoPath', path);
    notifyListeners();
  }
  
  Future<void> setDefaultOutputDir(String path) async {
    _defaultOutputDir = path;
    await _prefs.setString('defaultOutputDir', path);
    notifyListeners();
  }
  
  Future<void> setHfRepoId(String id) async {
    _hfRepoId = id;
    await _prefs.setString('hfRepoId', id);
    notifyListeners();
  }
  
  bool get isConfigured => effectiveRepoPath.isNotEmpty;
  
  bool get usingBundledBackend => _repoPath.isEmpty && _bundledBackendPath.isNotEmpty;
  
  // Get the full path to a script in the backend
  String getScriptPath(String relativePath) {
    return p.join(effectiveRepoPath, relativePath);
  }
}
