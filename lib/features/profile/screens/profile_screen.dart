import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api_client.dart';
import '../../../core/colors.dart';
import '../../../core/storage.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _developerMode = false;
  bool _sandboxMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() {
    final prefs = ref.read(prefsProvider);
    _notificationsEnabled = prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
    _developerMode = prefs.getBool(StorageKeys.developerMode) ?? false;
    _sandboxMode = prefs.getBool(StorageKeys.sandboxMode) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => context.push('/achievements'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // Avatar and name
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: MultandoColors.brandRed,
                  child: Text(
                    user?.fullName.isNotEmpty == true
                        ? user!.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: MultandoColors.surface900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: MultandoColors.surface500,
                  ),
                ),
                if (user?.createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Member since ${DateFormat('MMMM y').format(user!.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: MultandoColors.surface400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatCard(
                  label: 'Reports',
                  value: '${user?.reportsCount ?? 0}',
                  icon: Icons.description,
                  color: MultandoColors.brandRed,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Verified',
                  value: '${user?.verifiedReportsCount ?? 0}',
                  icon: Icons.verified,
                  color: MultandoColors.success,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Reputation',
                  value: (user?.reputationScore ?? 0).toStringAsFixed(0),
                  icon: Icons.star,
                  color: MultandoColors.accentGold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: MultandoColors.surface400,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Language
          _SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // Language picker would go here
            },
          ),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined, color: MultandoColors.surface600),
            title: const Text('Notifications'),
            value: _notificationsEnabled,
            activeColor: MultandoColors.brandRed,
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              ref.read(prefsProvider).setBool(StorageKeys.notificationsEnabled, v);
            },
          ),

          // Developer mode
          SwitchListTile(
            secondary: const Icon(Icons.code, color: MultandoColors.surface600),
            title: const Text('Developer Mode'),
            value: _developerMode,
            activeColor: MultandoColors.brandRed,
            onChanged: (v) {
              setState(() => _developerMode = v);
              ref.read(prefsProvider).setBool(StorageKeys.developerMode, v);
            },
          ),

          // Sandbox mode (only visible in developer mode)
          if (_developerMode)
            SwitchListTile(
              secondary: const Icon(Icons.science, color: MultandoColors.accentGold),
              title: const Text('Sandbox Mode'),
              subtitle: const Text('Connect to sandbox API for testing'),
              value: _sandboxMode,
              activeColor: MultandoColors.accentGold,
              onChanged: (v) async {
                setState(() => _sandboxMode = v);
                await ref.read(apiClientProvider.notifier).toggleSandbox(v);
              },
            ),

          const Divider(indent: 16, endIndent: 16),

          // About
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),

          const SizedBox(height: 24),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout, color: MultandoColors.danger),
              label: const Text(
                'Log Out',
                style: TextStyle(color: MultandoColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: MultandoColors.danger,
                side: const BorderSide(color: MultandoColors.danger),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
      bottomNavigationBar: const MultandoBottomNavBar(currentIndex: 4),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: MultandoColors.danger,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: MultandoColors.surface500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: MultandoColors.surface600),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right, color: MultandoColors.surface400),
      onTap: onTap,
    );
  }
}
