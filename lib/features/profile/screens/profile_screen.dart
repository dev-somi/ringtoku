import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final stats = ref.watch(weeklyStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.gradientMain),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Colors.white.withValues(alpha: 0.2),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2),
                        ),
                        child: Center(
                          child: Text(
                            profile?.name.isNotEmpty == true
                                ? profile!.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile?.name ?? 'User',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.email ?? '',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      // Stat row
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                        children: [
                          _HeaderStat(
                              value:
                                  '${profile?.streakCount ?? 5}',
                              label: 'Day Streak'),
                          _Divider(),
                          _HeaderStat(
                              value:
                                  '${profile?.totalCalls ?? stats.callsThisWeek}',
                              label: 'Total Calls'),
                          _Divider(),
                          _HeaderStat(
                              value:
                                  '${profile?.totalCallMinutes ?? stats.minutesThisWeek}m',
                              label: 'Practiced'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Learning goal section
                _SettingsSection(
                  title: 'Learning',
                  children: [
                    _GoalSelector(
                      profile: profile,
                      onChanged: (g) =>
                          ref.read(userProfileProvider.notifier).updateGoal(g),
                    ),
                    const _Divider2(),
                    _CallTimeRow(profile: profile, ref: ref),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats section
                _SettingsSection(
                  title: 'Your Statistics',
                  children: [
                    _StatRow(
                        label: 'Calls This Week',
                        value: '${stats.callsThisWeek}'),
                    const _Divider2(),
                    _StatRow(
                        label: 'Minutes This Week',
                        value: '${stats.minutesThisWeek}m'),
                    const _Divider2(),
                    _StatRow(
                        label: 'Grammar Errors Fixed',
                        value: '${stats.totalErrors}'),
                    const _Divider2(),
                    _StatRow(
                        label: 'Most Common Error',
                        value: stats.errorsByType.isNotEmpty
                            ? stats.errorsByType.entries
                                .reduce((a, b) =>
                                    a.value > b.value ? a : b)
                                .key
                            : 'None'),
                  ],
                ),
                const SizedBox(height: 16),

                // Notifications
                _SettingsSection(
                  title: 'Notifications',
                  children: [
                    _SwitchRow(
                      label: 'Daily Call Reminder',
                      subtitle: 'Get notified at your scheduled time',
                      icon: Icons.notifications_outlined,
                      value: true,
                      onChanged: (_) {},
                    ),
                    const _Divider2(),
                    _SwitchRow(
                      label: 'Weekly Report',
                      subtitle: 'Summary every Sunday',
                      icon: Icons.bar_chart,
                      value: true,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account
                _SettingsSection(
                  title: 'Account',
                  children: [
                    _ActionRow(
                      icon: Icons.help_outline,
                      label: 'Help & FAQ',
                      onTap: () {},
                    ),
                    const _Divider2(),
                    _ActionRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    const _Divider2(),
                    _ActionRow(
                      icon: Icons.logout,
                      label: 'Sign Out',
                      color: AppColors.danger,
                      onTap: () async {
                        final prefs =
                            ref.read(sharedPreferencesProvider);
                        await prefs.setBool('is_logged_in', false);
                        await prefs.setBool('is_onboarded', false);
                        ref.read(isLoggedInProvider.notifier).state =
                            false;
                        ref.read(isOnboardedProvider.notifier).state =
                            false;
                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'RingToku v1.0.0  ·  記録する、話す、身につく',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3));
  }
}

class _Divider2 extends StatelessWidget {
  const _Divider2();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.border);
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection(
      {required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _GoalSelector extends StatelessWidget {
  final UserProfile? profile;
  final ValueChanged<LearningGoal> onChanged;
  const _GoalSelector(
      {required this.profile, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const goals = [
      (LearningGoal.business, '💼', 'Business'),
      (LearningGoal.casual, '☕', 'Casual'),
      (LearningGoal.travel, '✈️', 'Travel'),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_outlined,
                  size: 18, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Learning Goal',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: goals
                .map((g) => Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(g.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: profile?.goal == g.$1
                                ? AppColors.primaryLight
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: profile?.goal == g.$1
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: profile?.goal == g.$1 ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(g.$2,
                                  style:
                                      const TextStyle(fontSize: 20)),
                              const SizedBox(height: 4),
                              Text(g.$3,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: profile?.goal == g.$1
                                          ? AppColors.primary
                                          : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CallTimeRow extends StatelessWidget {
  final UserProfile? profile;
  final WidgetRef ref;
  const _CallTimeRow({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    final h = (profile?.callTimeHour ?? 7).toString().padLeft(2, '0');
    final m =
        (profile?.callTimeMinute ?? 0).toString().padLeft(2, '0');
    return ListTile(
      leading: const Icon(Icons.alarm_outlined,
          color: AppColors.textSecondary, size: 20),
      title: const Text('Daily Call Time',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
      trailing: Text('$h:$m',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
      onTap: () => _showTimePicker(context),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: profile?.callTimeHour ?? 7,
          minute: profile?.callTimeMinute ?? 0),
    );
    if (result != null) {
      ref
          .read(userProfileProvider.notifier)
          .updateCallTime(result.hour, result.minute);
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow(
      {required this.label,
      required this.subtitle,
      required this.icon,
      required this.value,
      required this.onChanged});

  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<_SwitchRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(widget.icon,
          color: AppColors.textSecondary, size: 20),
      title: Text(widget.label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
      subtitle: Text(widget.subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      value: _value,
      activeThumbColor: AppColors.primary,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged(v);
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionRow(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
      title: Text(label,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: c)),
      trailing: color == null
          ? const Icon(Icons.chevron_right,
              color: AppColors.textSecondary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
