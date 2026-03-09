import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Page 0: welcome, Page 1: goal, Page 2: call time, Page 3: sign in
  LearningGoal _selectedGoal = LearningGoal.business;
  int _callHour = 7;
  int _callMinute = 0;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  void _next() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    const uuid = Uuid();
    final name = _nameController.text.trim().isEmpty ? 'User' : _nameController.text.trim();
    final email = _emailController.text.trim().isEmpty ? 'user@example.com' : _emailController.text.trim();

    final profile = UserProfile(
      id: uuid.v4(),
      name: name,
      email: email,
      goal: _selectedGoal,
      callTimeHour: _callHour,
      callTimeMinute: _callMinute,
      streakCount: 0,
      totalCallMinutes: 0,
      totalCalls: 0,
      createdAt: DateTime.now(),
    );

    ref.read(userProfileProvider.notifier).setProfile(profile);

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('is_onboarded', true);
    await prefs.setBool('is_logged_in', true);
    ref.read(isOnboardedProvider.notifier).state = true;
    ref.read(isLoggedInProvider.notifier).state = true;

    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.gradientMain)),
          SafeArea(
            child: Column(
              children: [
                // Progress dots
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WelcomePage(),
                      _GoalPage(
                        selected: _selectedGoal,
                        onChanged: (g) => setState(() => _selectedGoal = g),
                      ),
                      _CallTimePage(
                        hour: _callHour,
                        minute: _callMinute,
                        onChanged: (h, m) => setState(() {
                          _callHour = h;
                          _callMinute = m;
                        }),
                      ),
                      _SignInPage(
                        nameController: _nameController,
                        emailController: _emailController,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          _currentPage == 3 ? 'Get Started' : 'Next',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (_currentPage > 0) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back', style: TextStyle(color: Colors.white70)),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Center(
              child: Text('RT', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Welcome to RingToku', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          Text(
            'Your AI English conversation partner that remembers you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.85), height: 1.6),
          ),
          const SizedBox(height: 32),
          _FeatureRow(icon: Icons.psychology, text: 'AI that remembers past conversations'),
          _FeatureRow(icon: Icons.call, text: 'Daily AI practice calls'),
          _FeatureRow(icon: Icons.auto_fix_high, text: 'Real-time grammar correction'),
          _FeatureRow(icon: Icons.bar_chart, text: 'Progress tracking & reports'),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final LearningGoal selected;
  final ValueChanged<LearningGoal> onChanged;
  const _GoalPage({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const goals = [
      (LearningGoal.business, '💼', 'Business English', 'Meetings, presentations,\nemail communication'),
      (LearningGoal.casual, '☕', 'Casual Conversation', 'Daily chat, travel,\nmaking friends'),
      (LearningGoal.travel, '✈️', 'Travel English', 'Airports, hotels,\nsightseeing'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What is your\nlearning goal?',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
          const SizedBox(height: 8),
          Text('We will personalize your AI tutor based on this.',
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 32),
          ...goals.map((g) => _GoalCard(
            goal: g.$1,
            emoji: g.$2,
            title: g.$3,
            subtitle: g.$4,
            isSelected: selected == g.$1,
            onTap: () => onChanged(g.$1),
          )),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final LearningGoal goal;
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  const _GoalCard({required this.goal, required this.emoji, required this.title, required this.subtitle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : Colors.white,
                  )),
                  Text(subtitle, style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.textSecondary : Colors.white60,
                  )),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _CallTimePage extends StatelessWidget {
  final int hour;
  final int minute;
  final void Function(int, int) onChanged;
  const _CallTimePage({required this.hour, required this.minute, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('When should we call?',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
          const SizedBox(height: 8),
          Text('We will send a daily reminder at this time.',
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TimeSelector(
                      value: hour,
                      max: 23,
                      label: 'Hour',
                      onChanged: (v) => onChanged(v, minute),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(':', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white)),
                    ),
                    _TimeSelector(
                      value: minute,
                      max: 59,
                      label: 'Minute',
                      onChanged: (v) => onChanged(hour, v),
                      step: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Daily call at ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recommended times:', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ('Morning', 7, 0),
              ('Lunch', 12, 0),
              ('Evening', 19, 0),
              ('Night', 22, 0),
            ].map((t) => ActionChip(
              label: Text(t.$1),
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              labelStyle: const TextStyle(color: Colors.white),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              onPressed: () => onChanged(t.$2, t.$3),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final int value;
  final int max;
  final String label;
  final ValueChanged<int> onChanged;
  final int step;
  const _TimeSelector({required this.value, required this.max, required this.label, required this.onChanged, this.step = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 32),
          onPressed: () => onChanged((value + step) % (max + 1)),
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300, color: Colors.white),
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
          onPressed: () => onChanged((value - step + max + 1) % (max + 1)),
        ),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

class _SignInPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  const _SignInPage({required this.nameController, required this.emailController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create your account',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white, height: 1.3)),
          const SizedBox(height: 8),
          Text('Your AI tutor will remember you forever.',
              style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.75))),
          const SizedBox(height: 32),
          _Field(controller: nameController, label: 'Your Name', hint: 'e.g. Yuki', icon: Icons.person),
          const SizedBox(height: 16),
          _Field(controller: emailController, label: 'Email', hint: 'yuki@example.com', icon: Icons.email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              ),
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              nameController.text = 'Demo User';
              emailController.text = 'demo@ringtoku.app';
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Text('G', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            label: const Text('Continue with Google'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  const _Field({required this.controller, required this.label, required this.hint, required this.icon, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: Colors.white60, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
