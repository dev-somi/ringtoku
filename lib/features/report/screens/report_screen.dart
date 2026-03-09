import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class ReportScreen extends ConsumerWidget {
  final CallSession? session;
  const ReportScreen({super.key, this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(callHistoryProvider);
    final s = session ?? (history.isNotEmpty ? history.first : null);

    if (s == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Call Report')),
        body: const Center(child: Text('No report available')),
      );
    }

    final dur = Duration(seconds: s.durationSeconds);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.gradientMain),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Call Report',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        const Text('Session Summary',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            _MetaBadge(
                                icon: Icons.access_time,
                                text:
                                    '${dur.inMinutes}m ${dur.inSeconds % 60}s'),
                            _MetaBadge(
                                icon: Icons.error_outline,
                                text: '${s.grammarErrors.length} errors'),
                            _MetaBadge(
                                icon: Icons.calendar_today,
                                text: DateFormat('MMM d')
                                    .format(s.startedAt)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionCard(
                  title: 'Conversation Summary',
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.primary,
                  child: Text(
                    s.summary.isEmpty
                        ? 'Great conversation today! Keep it up.'
                        : s.summary,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6),
                  ),
                ),
                const SizedBox(height: 16),
                if (s.grammarErrors.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Grammar Errors (${s.grammarErrors.length})',
                    icon: Icons.auto_fix_high,
                    iconColor: AppColors.accent,
                    child: Column(
                      children: s.grammarErrors
                          .map((e) => _GrammarErrorTile(error: e))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Error Breakdown',
                    icon: Icons.bar_chart,
                    iconColor: AppColors.warning,
                    child: _ErrorBreakdown(errors: s.grammarErrors),
                  ),
                  const SizedBox(height: 16),
                ],
                _SectionCard(
                  title: 'Key Expressions Today',
                  icon: Icons.star_outline,
                  iconColor: AppColors.success,
                  child: const Column(
                    children: [
                      _ExpressionTile(
                        expression: 'That is a great point',
                        usage:
                            'Use in meetings to acknowledge others',
                      ),
                      _ExpressionTile(
                        expression: 'Could you elaborate on that?',
                        usage: 'Politely ask for more details',
                      ),
                      _ExpressionTile(
                        expression: 'I totally agree with you',
                        usage: 'Express strong agreement naturally',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.push('/call'),
                  icon: const Icon(Icons.replay),
                  label: const Text('Practice Again'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _SectionCard(
      {required this.title,
      required this.icon,
      required this.iconColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _GrammarErrorTile extends StatelessWidget {
  final GrammarError error;
  const _GrammarErrorTile({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(error.errorType,
                style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.close,
                  color: Color(0xFFDC2626), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error.originalText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFDC2626),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check,
                  color: Color(0xFF059669), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error.correctedText,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(error.explanation,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4)),
        ],
      ),
    );
  }
}

class _ErrorBreakdown extends StatelessWidget {
  final List<GrammarError> errors;
  const _ErrorBreakdown({required this.errors});

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final e in errors) {
      counts[e.errorType] = (counts[e.errorType] ?? 0) + 1;
    }
    final total = errors.length;
    const colors = [
      AppColors.danger,
      AppColors.accent,
      AppColors.warning,
      AppColors.primary,
      AppColors.success,
    ];
    return Column(
      children: counts.entries.toList().asMap().entries.map((entry) {
        final i = entry.key;
        final type = entry.value.key;
        final count = entry.value.value;
        final pct = total > 0 ? count / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(type,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
                  Text('$count',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      colors[i % colors.length]),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ExpressionTile extends StatelessWidget {
  final String expression;
  final String usage;
  const _ExpressionTile(
      {required this.expression, required this.usage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(expression,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success)),
          const SizedBox(height: 4),
          Text(usage,
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.success.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
