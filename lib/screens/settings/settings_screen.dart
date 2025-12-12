import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              'Settings',
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
              'Configure application preferences',
              style: TextStyle(
                fontFamily: '.SF Pro Text',
                fontSize: 15,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),
            
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: settings.isConfigured 
                    ? const Color(0xFF34C759).withValues(alpha: 0.12)
                    : const Color(0xFFFF9500).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    settings.isConfigured 
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.exclamationmark_triangle_fill,
                    color: settings.isConfigured 
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF9500),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.isConfigured ? 'Ready to use' : 'Setup required',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: settings.isConfigured 
                                ? const Color(0xFF34C759)
                                : const Color(0xFFFF9500),
                          ),
                        ),
                        Text(
                          settings.usingBundledBackend 
                              ? 'Using bundled backend'
                              : (settings.isConfigured ? 'Using custom backend' : 'Configure backend path below'),
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 13,
                            color: settings.isConfigured 
                                ? const Color(0xFF34C759).withValues(alpha: 0.8)
                                : const Color(0xFFFF9500).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Python Configuration
            const Text(
              'PYTHON',
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
              child: _SettingsRow(
                label: 'Python Path',
                value: settings.pythonPath,
                onTap: () => _showTextDialog(
                  context,
                  'Python Path',
                  settings.pythonPath,
                  (value) => settings.setPythonPath(value),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Backend Configuration
            const Text(
              'BACKEND',
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
                  _SettingsRow(
                    label: 'Bundled Backend',
                    value: settings.bundledBackendPath.isNotEmpty 
                        ? settings.bundledBackendPath.split('/').last
                        : 'Not found',
                    valueColor: settings.bundledBackendPath.isNotEmpty 
                        ? const Color(0xFF34C759)
                        : const Color(0xFFFF3B30),
                    showChevron: false,
                  ),
                  const Divider(height: 1, indent: 16),
                  _SettingsRow(
                    label: 'Custom Path',
                    value: settings.repoPath.isNotEmpty 
                        ? settings.repoPath.split('/').last
                        : 'Not set',
                    onTap: () async {
                      final result = await FilePicker.platform.getDirectoryPath();
                      if (result != null) settings.setRepoPath(result);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Hugging Face
            const Text(
              'HUGGING FACE',
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
                  _SettingsRow(
                    label: 'Default Repo ID',
                    value: settings.hfRepoId.isNotEmpty ? settings.hfRepoId : 'Not set',
                    onTap: () => _showTextDialog(
                      context,
                      'Hugging Face Repo ID',
                      settings.hfRepoId,
                      (value) => settings.setHfRepoId(value),
                    ),
                  ),
                  const Divider(height: 1, indent: 16),
                  _SettingsRow(
                    label: 'Output Directory',
                    value: settings.defaultOutputDir.isNotEmpty 
                        ? settings.defaultOutputDir.split('/').last
                        : 'Not set',
                    onTap: () async {
                      final result = await FilePicker.platform.getDirectoryPath();
                      if (result != null) settings.setDefaultOutputDir(result);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // About
            const Text(
              'ABOUT',
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
                  _SettingsRow(
                    label: 'Version',
                    value: '1.0.0',
                    showChevron: false,
                  ),
                  const Divider(height: 1, indent: 16),
                  _SettingsRow(
                    label: 'GitHub Repository',
                    value: 'Tavish9/any4lerobot',
                    onTap: () {
                      Clipboard.setData(const ClipboardData(
                        text: 'https://github.com/Tavish9/any4lerobot',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('URL copied to clipboard'),
                          backgroundColor: const Color(0xFF34C759),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 15,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: '.SF Pro Text',
                  fontSize: 15,
                  color: valueColor ?? const Color(0xFF8E8E93),
                ),
              ),
              if (showChevron && onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: Color(0xFFC7C7CC),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
