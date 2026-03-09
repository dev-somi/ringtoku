import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryItemsProvider);

    final grouped = <String, List<MemoryItem>>{};
    for (final m in memories) {
      grouped.putIfAbsent(m.category, () => []).add(m);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.gradientMain),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.psychology,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('AI Memory',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                                Text(
                                    'What your AI remembers about you',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.memory,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${memories.length} memories stored',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (memories.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🧠', style: TextStyle(fontSize: 56)),
                    SizedBox(height: 16),
                    Text('No memories yet',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    SizedBox(height: 8),
                    Text('Start a call to build your AI memory!',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your AI references these memories to personalize every conversation.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary
                                    .withValues(alpha: 0.9),
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...grouped.entries.map(
                    (entry) => _CategorySection(
                      category: entry.key,
                      items: entry.value,
                      onDelete: (id) => ref
                          .read(memoryItemsProvider.notifier)
                          .deleteMemory(id),
                    ),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<MemoryItem> items;
  final void Function(String id) onDelete;
  const _CategorySection(
      {required this.category,
      required this.items,
      required this.onDelete});

  Color get _color {
    switch (category) {
      case 'Personal':
        return AppColors.primary;
      case 'Work':
        return AppColors.accent;
      case 'Hobbies':
        return AppColors.success;
      case 'Learning Goal':
        return AppColors.warning;
      case 'Grammar Pattern':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  String get _emoji {
    switch (category) {
      case 'Personal':
        return '👤';
      case 'Work':
        return '💼';
      case 'Hobbies':
        return '🎯';
      case 'Learning Goal':
        return '🚀';
      case 'Grammar Pattern':
        return '✏️';
      default:
        return '📌';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(category,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _color)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${items.length}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _color)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...items.map((item) => _MemoryCard(
              item: item,
              color: _color,
              onDelete: () => onDelete(item.id),
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryItem item;
  final Color color;
  final VoidCallback onDelete;
  const _MemoryCard(
      {required this.item,
      required this.color,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete Memory'),
                content: const Text(
                    'Remove this from your AI memory?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete',
                        style:
                            TextStyle(color: AppColors.danger)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.content,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    'Learned ${DateFormat('MMM d').format(item.createdAt)}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.swipe_left,
                size: 16,
                color: AppColors.textSecondary.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
