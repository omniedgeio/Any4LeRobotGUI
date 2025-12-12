import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/process_manager.dart';

enum ConversionType {
  openxToLerobot('OpenX → LeRobot', 'openx2lerobot/openx_rlds.py', CupertinoIcons.doc_on_doc, Color(0xFF007AFF)),
  agibotToLerobot('AgiBot → LeRobot', 'agibot2lerobot/agibot_to_lerobot.py', CupertinoIcons.device_phone_portrait, Color(0xFF5856D6)),
  robomindToLerobot('RoboMIND → LeRobot', 'robomind2lerobot/robomind_to_lerobot.py', CupertinoIcons.lightbulb, Color(0xFFFF9500)),
  liberoToLerobot('LIBERO → LeRobot', 'libero2lerobot/libero_to_lerobot.py', CupertinoIcons.book, Color(0xFF34C759)),
  lerobotToRlds('LeRobot → RLDS', 'lerobot2rlds/lerobot_to_rlds.py', CupertinoIcons.arrow_right_arrow_left, Color(0xFFFF2D55));

  final String displayName;
  final String scriptPath;
  final IconData icon;
  final Color color;
  
  const ConversionType(this.displayName, this.scriptPath, this.icon, this.color);
  
  String get scriptName => scriptPath.split('/').last;
}

class ConversionScreen extends StatefulWidget {
  const ConversionScreen({super.key});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  ConversionType _selectedType = ConversionType.openxToLerobot;
  final TextEditingController _inputDirController = TextEditingController();
  final TextEditingController _outputDirController = TextEditingController();
  final TextEditingController _repoIdController = TextEditingController();
  bool _useVideos = true;
  bool _pushToHub = false;

  @override
  void dispose() {
    _inputDirController.dispose();
    _outputDirController.dispose();
    _repoIdController.dispose();
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
              'Data Conversion',
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
              'Convert datasets between formats',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),
            
            // Conversion Type Selection
            const Text(
              'CONVERSION TYPE',
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
              child: Column(
                children: ConversionType.values.map((type) {
                  final isLast = type == ConversionType.values.last;
                  final isSelected = _selectedType == type;
                  return Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _selectedType = type),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: type.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(type.icon, color: type.color, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    type.displayName,
                                    style: const TextStyle(
                                      fontFamily: '.SF Pro Text',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    CupertinoIcons.checkmark,
                                    size: 18,
                                    color: Color(0xFF007AFF),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, indent: 60),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Configuration
            const Text(
              'CONFIGURATION',
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
              child: Column(
                children: [
                  _InputRow(
                    label: 'Input Directory',
                    controller: _inputDirController,
                    placeholder: 'Select source directory',
                    onBrowse: () async {
                      final result = await FilePicker.platform.getDirectoryPath();
                      if (result != null) _inputDirController.text = result;
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _InputRow(
                    label: 'Output Directory',
                    controller: _outputDirController,
                    placeholder: 'Select output directory',
                    onBrowse: () async {
                      final result = await FilePicker.platform.getDirectoryPath();
                      if (result != null) _outputDirController.text = result;
                    },
                  ),
                  const Divider(height: 1, indent: 16),
                  _TextInputRow(
                    label: 'Repo ID',
                    controller: _repoIdController,
                    placeholder: 'username/dataset_name',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Options
            const Text(
              'OPTIONS',
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
              child: Column(
                children: [
                  _ToggleRow(
                    label: 'Use Videos',
                    subtitle: 'Encode frames as video files',
                    value: _useVideos,
                    onChanged: (v) => setState(() => _useVideos = v),
                  ),
                  const Divider(height: 1, indent: 16),
                  _ToggleRow(
                    label: 'Push to Hub',
                    subtitle: 'Upload to Hugging Face after conversion',
                    value: _pushToHub,
                    onChanged: (v) => setState(() => _pushToHub = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Start Button
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: settings.isConfigured ? _startConversion : null,
                borderRadius: BorderRadius.circular(12),
                child: const Text(
                  'Start Conversion',
                  style: TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }

  void _startConversion() {
    final settings = context.read<SettingsService>();
    final processManager = context.read<ProcessManager>();
    
    final scriptPath = settings.getScriptPath(_selectedType.scriptPath);
    
    // Use venv Python if available
    final pythonPath = '${settings.effectiveRepoPath}/.venv/bin/python';
    
    final args = <String>[
      scriptPath,
      '--raw-dir', _inputDirController.text,
      '--local-dir', _outputDirController.text,
      '--repo-id', _repoIdController.text,
    ];
    
    if (_useVideos) args.add('--use-videos');
    if (_pushToHub) args.add('--push-to-hub');
    
    processManager.startJob(
      name: _selectedType.displayName,
      command: pythonPath,
      arguments: args,
      workingDirectory: settings.effectiveRepoPath,
    );
    
    _showSuccessSnackbar('Started ${_selectedType.displayName}');
  }
  
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;
  final VoidCallback onBrowse;

  const _InputRow({
    required this.label,
    required this.controller,
    required this.placeholder,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(8),
              ),
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onBrowse,
            child: const Icon(
              CupertinoIcons.folder,
              color: Color(0xFF007AFF),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextInputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String placeholder;

  const _TextInputRow({
    required this.label,
    required this.controller,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(8),
              ),
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }
}
