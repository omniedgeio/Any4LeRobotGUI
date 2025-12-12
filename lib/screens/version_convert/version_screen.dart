import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/process_manager.dart';

enum VersionConversion {
  v16ToV20('v1.6 → v2.0', 'v16_to_v20', Color(0xFF007AFF)),
  v20ToV21('v2.0 → v2.1', 'v20_to_v21', Color(0xFF5856D6)),
  v21ToV20('v2.1 → v2.0', 'v21_to_v20', Color(0xFFAF52DE)),
  v21ToV30('v2.1 → v3.0', 'v21_to_v30', Color(0xFF34C759)),
  v30ToV21('v3.0 → v2.1', 'v30_to_v21', Color(0xFFFF9500));

  final String displayName;
  final String scriptDir;
  final Color color;
  
  const VersionConversion(this.displayName, this.scriptDir, this.color);
}

class VersionScreen extends StatefulWidget {
  const VersionScreen({super.key});

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  VersionConversion? _selectedConversion;
  final TextEditingController _datasetPathController = TextEditingController();

  @override
  void dispose() {
    _datasetPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version Convert',
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Convert between LeRobot dataset versions',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),
            
            // Version Selection
            const Text(
              'SELECT VERSION PATH',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: VersionConversion.values.map((conversion) {
                final isSelected = _selectedConversion == conversion;
                return GestureDetector(
                  onTap: () => setState(() => _selectedConversion = conversion),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? conversion.color : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: conversion.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            CupertinoIcons.arrow_right_arrow_left,
                            color: conversion.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          conversion.displayName,
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? conversion.color : const Color(0xFF1C1C1E),
                          ),
                        ),
                        if (isSelected)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Icon(
                              CupertinoIcons.checkmark_circle_fill,
                              color: conversion.color,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            if (_selectedConversion != null) ...[
              // Dataset Path
              const Text(
                'DATASET',
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8E8E93),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          'Path',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 15,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      Expanded(
                        child: CupertinoTextField(
                          controller: _datasetPathController,
                          placeholder: 'Select dataset directory',
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          final result = await FilePicker.platform.getDirectoryPath();
                          if (result != null) _datasetPathController.text = result;
                        },
                        child: const Icon(CupertinoIcons.folder, color: Color(0xFF007AFF)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Start Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: _selectedConversion!.color,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: settings.isConfigured ? _startConversion : null,
                  child: const Text(
                    'Start Conversion',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (!settings.isConfigured) ...[
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Configure backend in Settings first',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 13,
                      color: const Color(0xFFFF9500),
                    ),
                  ),
                ),
              ],
            ] else
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.hand_draw,
                        size: 48,
                        color: const Color(0xFFC7C7CC),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select a version path above',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 15,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startConversion() {
    final settings = context.read<SettingsService>();
    final processManager = context.read<ProcessManager>();
    
    // Map to actual script filenames
    final scriptMap = {
      'v16_to_v20': 'convert_dataset_v16_to_v20.py',
      'v20_to_v21': 'convert_dataset_v20_to_v21.py',
      'v21_to_v20': 'convert_dataset_v21_to_v20.py',
      'v21_to_v30': 'convert_dataset_v21_to_v30.py',
      'v30_to_v21': 'convert_dataset_v30_to_v21.py',
    };
    
    final scriptName = scriptMap[_selectedConversion!.scriptDir]!;
    final scriptPath = settings.getScriptPath('ds_version_convert/${_selectedConversion!.scriptDir}/$scriptName');
    
    // Use venv Python if available
    final pythonPath = '${settings.effectiveRepoPath}/.venv/bin/python';
    
    processManager.startJob(
      name: _selectedConversion!.displayName,
      command: pythonPath,
      arguments: [scriptPath, '--dataset', _datasetPathController.text],
      workingDirectory: settings.effectiveRepoPath,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started ${_selectedConversion!.displayName}'),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
