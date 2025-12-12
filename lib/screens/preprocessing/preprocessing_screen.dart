import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';
import '../../services/process_manager.dart';

class PreprocessingScreen extends StatefulWidget {
  const PreprocessingScreen({super.key});

  @override
  State<PreprocessingScreen> createState() => _PreprocessingScreenState();
}

class _PreprocessingScreenState extends State<PreprocessingScreen> {
  int _selectedTab = 0;
  
  // Merger state
  final List<String> _sourceDirs = [];
  final TextEditingController _outputDirController = TextEditingController();
  int _stateMaxDim = 32;
  int _actionMaxDim = 32;
  int _fps = 20;
  bool _copyImages = false;

  @override
  void dispose() {
    _outputDirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Preprocessing',
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
              'Merge, filter, and sample datasets',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),
            
            // Segmented Control
            Container(
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedTab,
                onValueChanged: (value) => setState(() => _selectedTab = value ?? 0),
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Merge'),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Filter'),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Sample'),
                  ),
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Tab Content
            if (_selectedTab == 0) _buildMergeTab(),
            if (_selectedTab == 1) _buildPlaceholderTab('Filtering', CupertinoIcons.slider_horizontal_3),
            if (_selectedTab == 2) _buildPlaceholderTab('Sampling', CupertinoIcons.sparkles),
          ],
        ),
      ),
    );
  }

  Widget _buildMergeTab() {
    final settings = context.watch<SettingsService>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source Datasets
        Row(
          children: [
            const Text(
              'SOURCE DATASETS',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () async {
                final result = await FilePicker.platform.getDirectoryPath();
                if (result != null) {
                  setState(() => _sourceDirs.add(result));
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.add, size: 16),
                  const SizedBox(width: 4),
                  const Text('Add'),
                ],
              ),
            ),
          ],
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
          child: _sourceDirs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.folder_badge_plus,
                          size: 40,
                          color: const Color(0xFFC7C7CC),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No datasets added',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 15,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: _sourceDirs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final path = entry.value;
                    final isLast = index == _sourceDirs.length - 1;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.folder_fill,
                                color: Color(0xFF007AFF),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  path.split('/').last,
                                  style: const TextStyle(
                                    fontFamily: '.SF Pro Text',
                                    fontSize: 15,
                                    color: Color(0xFF1C1C1E),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              CupertinoButton(
                                padding: EdgeInsets.zero,
                                onPressed: () => setState(() => _sourceDirs.removeAt(index)),
                                child: const Icon(
                                  CupertinoIcons.minus_circle_fill,
                                  color: Color(0xFFFF3B30),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast) const Divider(height: 1, indent: 48),
                      ],
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 24),
        
        // Output Directory
        const Text(
          'OUTPUT',
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
                  width: 100,
                  child: Text(
                    'Directory',
                    style: TextStyle(
                      fontFamily: '.SF Pro Text',
                      fontSize: 15,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: _outputDirController,
                    placeholder: 'Select output directory',
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
                    if (result != null) _outputDirController.text = result;
                  },
                  child: const Icon(CupertinoIcons.folder, color: Color(0xFF007AFF)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Parameters
        const Text(
          'PARAMETERS',
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
              _StepperRow(
                label: 'State Max Dim',
                value: _stateMaxDim,
                onChanged: (v) => setState(() => _stateMaxDim = v),
              ),
              const Divider(height: 1, indent: 16),
              _StepperRow(
                label: 'Action Max Dim',
                value: _actionMaxDim,
                onChanged: (v) => setState(() => _actionMaxDim = v),
              ),
              const Divider(height: 1, indent: 16),
              _StepperRow(
                label: 'FPS',
                value: _fps,
                onChanged: (v) => setState(() => _fps = v),
              ),
              const Divider(height: 1, indent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Copy Images',
                        style: TextStyle(
                          fontFamily: '.SF Pro Text',
                          fontSize: 15,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _copyImages,
                      onChanged: (v) => setState(() => _copyImages = v),
                      activeTrackColor: const Color(0xFF34C759),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Start Button
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: settings.isConfigured && _sourceDirs.isNotEmpty ? _startMerge : null,
            borderRadius: BorderRadius.circular(12),
            child: const Text(
              'Start Merge',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Container(
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
            Icon(icon, size: 48, color: const Color(0xFFC7C7CC)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startMerge() {
    final settings = context.read<SettingsService>();
    final processManager = context.read<ProcessManager>();
    
    final scriptPath = settings.getScriptPath('dataset_merging/merge_lerobot_dataset.py');
    
    // Use venv Python if available
    final pythonPath = '${settings.effectiveRepoPath}/.venv/bin/python';
    
    final args = <String>[
      scriptPath,
      '--sources', ..._sourceDirs,
      '--output', _outputDirController.text,
      '--state_max_dim', _stateMaxDim.toString(),
      '--action_max_dim', _actionMaxDim.toString(),
      '--fps', _fps.toString(),
    ];
    
    if (_copyImages) args.add('--copy_images');
    
    processManager.startJob(
      name: 'Dataset Merge',
      command: pythonPath,
      arguments: args,
      workingDirectory: settings.effectiveRepoPath,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Started dataset merge'),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF1C1C1E),
              ),
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                child: Icon(
                  CupertinoIcons.minus_circle,
                  color: value > 1 ? const Color(0xFF007AFF) : const Color(0xFFC7C7CC),
                  size: 24,
                ),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onChanged(value + 1),
                child: const Icon(
                  CupertinoIcons.plus_circle,
                  color: Color(0xFF007AFF),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
