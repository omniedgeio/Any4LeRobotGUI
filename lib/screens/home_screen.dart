import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/process_manager.dart';
import '../services/settings_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsService>();
    final processManager = context.watch<ProcessManager>();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Dashboard',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (!settings.isConfigured)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle,
                          color: Color(0xFFFF9500),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Configure in Settings',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFF9500),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: Color(0xFF34C759),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ready',
                          style: TextStyle(
                            fontFamily: '.SF Pro Text',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: CupertinoIcons.play_circle_fill,
                    iconColor: const Color(0xFF007AFF),
                    label: 'Running',
                    value: processManager.runningJobs.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: CupertinoIcons.checkmark_circle_fill,
                    iconColor: const Color(0xFF34C759),
                    label: 'Completed',
                    value: processManager.completedJobs.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: CupertinoIcons.folder_fill,
                    iconColor: const Color(0xFF5856D6),
                    label: 'Backend',
                    value: settings.usingBundledBackend ? 'Bundled' : (settings.isConfigured ? 'Custom' : 'None'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
              ),
            ),
            const SizedBox(height: 12),
            
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
                  _QuickActionRow(
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    iconColor: const Color(0xFF007AFF),
                    title: 'OpenX → LeRobot',
                    subtitle: 'Convert Open X-Embodiment datasets',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _QuickActionRow(
                    icon: CupertinoIcons.layers_alt_fill,
                    iconColor: const Color(0xFF5856D6),
                    title: 'Merge Datasets',
                    subtitle: 'Combine multiple LeRobot datasets',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 56),
                  _QuickActionRow(
                    icon: CupertinoIcons.arrow_2_squarepath,
                    iconColor: const Color(0xFF34C759),
                    title: 'Version Convert',
                    subtitle: 'Upgrade dataset version (v1.6 → v3.0)',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Recent Jobs
            Row(
              children: [
                const Text(
                  'Recent Jobs',
                  style: TextStyle(
                    fontFamily: '.SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                const Spacer(),
                if (processManager.jobs.isNotEmpty)
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: processManager.clearCompletedJobs,
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
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
              child: processManager.jobs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.tray,
                              size: 48,
                              color: const Color(0xFFC7C7CC),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No recent jobs',
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
                      children: processManager.jobs.map((job) {
                        final isLast = job == processManager.jobs.last;
                        return Column(
                          children: [
                            _JobRow(job: job),
                            if (!isLast) const Divider(height: 1, indent: 56),
                          ],
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontFamily: '.SF Pro Display',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: '.SF Pro Text',
              fontSize: 13,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: '.SF Pro Text',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
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
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Color(0xFFC7C7CC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  final Job job;

  const _JobRow({required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildStatusIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                  ),
                ),
                Text(
                  job.logs.isNotEmpty ? job.logs.last : 'Pending...',
                  style: const TextStyle(
                    fontFamily: '.SF Pro Text',
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (job.status == JobStatus.running)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                context.read<ProcessManager>().cancelJob(job.id);
              },
              child: const Icon(
                CupertinoIcons.stop_circle,
                color: Color(0xFFFF3B30),
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (job.status) {
      case JobStatus.pending:
        return const Icon(CupertinoIcons.clock, color: Color(0xFF8E8E93), size: 24);
      case JobStatus.running:
        return const CupertinoActivityIndicator(radius: 10);
      case JobStatus.completed:
        return const Icon(CupertinoIcons.checkmark_circle_fill, color: Color(0xFF34C759), size: 24);
      case JobStatus.failed:
        return const Icon(CupertinoIcons.xmark_circle_fill, color: Color(0xFFFF3B30), size: 24);
      case JobStatus.cancelled:
        return const Icon(CupertinoIcons.minus_circle_fill, color: Color(0xFFFF9500), size: 24);
    }
  }
}
