import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/app_models.dart';
import '../../../shared/providers/app_providers.dart';

class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key});
  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  Timer? _timer;
  Timer? _subtitleTimer;
  int _elapsedSeconds = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  CallStatus _status = CallStatus.connecting;

  final List<String> _mockConversation = [
    'AI: Hello! Great to talk to you again.',
    'AI: How has your day been going so far?',
    'You: It was pretty good. I had a busy morning...',
    'AI: I see! By the way, how is Leon doing? Your cat.',
    'You: Oh! Leon is doing great, thank you for remembering!',
    'AI: Of course! You mentioned he loves to play in the morning.',
    'You: Yes, he woke me up at 6am today haha.',
    'AI: Ha! That sounds like something Leon would do.',
    'You: Anyway, I wanted to practice my presentation.',
    'AI: Sure! Tell me about your presentation topic.',
  ];
  int _subtitleIndex = 0;
  String _currentSubtitle = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _startCall();
  }

  Future<void> _startCall() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _status = CallStatus.active);
    ref.read(currentCallProvider.notifier).startCall();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    _startSubtitles();
  }

  void _startSubtitles() {
    void showNext() {
      if (!mounted || _subtitleIndex >= _mockConversation.length) return;
      setState(
          () => _currentSubtitle = _mockConversation[_subtitleIndex++]);
      _subtitleTimer = Timer(
        Duration(
            milliseconds:
                2500 + _mockConversation[_subtitleIndex - 1].length * 40),
        showNext,
      );
    }

    _subtitleTimer = Timer(const Duration(milliseconds: 800), showNext);
  }

  Future<void> _endCall() async {
    setState(() => _status = CallStatus.ending);
    _timer?.cancel();
    _subtitleTimer?.cancel();

    const uuid = Uuid();
    final errors = [
      GrammarError(
        id: uuid.v4(),
        originalText: 'I goed to the meeting',
        correctedText: 'I went to the meeting',
        errorType: 'Tense',
        explanation:
            '"go" is an irregular verb. Past tense is "went", not "goed".',
        occurredAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      GrammarError(
        id: uuid.v4(),
        originalText: 'The presentation is very bored',
        correctedText: 'The presentation is very boring',
        errorType: 'Adjective',
        explanation:
            '"Boring" describes the thing. "Bored" describes how you feel.',
        occurredAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];

    ref.read(currentCallProvider.notifier).endCall(
          errors,
          'Talked about daily life, Leon the cat, and practiced presentation vocabulary.',
        );

    final session = ref.read(currentCallProvider);
    if (session != null) {
      ref.read(callHistoryProvider.notifier).addCall(session);
    }

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    context.pushReplacement('/report/new', extra: session);
  }

  String get _timeString {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _timer?.cancel();
    _subtitleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradientMain),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white, size: 28),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'AI English Tutor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _status == CallStatus.active
                            ? const Color(0xFF059669).withValues(alpha: 0.3)
                            : Colors.orange.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _status == CallStatus.active
                              ? const Color(0xFF059669)
                              : Colors.orange,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        _status == CallStatus.connecting
                            ? 'Connecting...'
                            : _status == CallStatus.ending
                                ? 'Ending...'
                                : 'Live',
                        style: TextStyle(
                          color: _status == CallStatus.active
                              ? const Color(0xFF6EE7B7)
                              : Colors.orange[200],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsing avatar
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_status == CallStatus.active)
                              ...List.generate(
                                3,
                                (i) => Container(
                                  width: 140 +
                                      i * 28.0 +
                                      _pulseController.value * 12,
                                  height: 140 +
                                      i * 28.0 +
                                      _pulseController.value * 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withValues(
                                        alpha: 0.04 - i * 0.01),
                                  ),
                                ),
                              ),
                            child!,
                          ],
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              Colors.white.withValues(alpha: 0.15),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 2),
                        ),
                        child: const Center(
                          child: Text('🤖',
                              style: TextStyle(fontSize: 52)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('RingToku AI',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Text(
                      _status == CallStatus.connecting
                          ? 'Connecting...'
                          : _timeString,
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 32),
                    if (_status == CallStatus.active)
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, _) =>
                            _WaveformWidget(animValue: _waveController.value),
                      ),
                    const SizedBox(height: 24),
                    if (_currentSubtitle.isNotEmpty)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey(_currentSubtitle),
                          margin:
                              const EdgeInsets.symmetric(horizontal: 32),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            _currentSubtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlButton(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          label: _isMuted ? 'Unmute' : 'Mute',
                          onTap: () =>
                              setState(() => _isMuted = !_isMuted),
                          isActive: _isMuted,
                        ),
                        _ControlButton(
                          icon: _isSpeakerOn
                              ? Icons.volume_up
                              : Icons.volume_off,
                          label: 'Speaker',
                          onTap: () => setState(
                              () => _isSpeakerOn = !_isSpeakerOn),
                          isActive: !_isSpeakerOn,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap:
                          _status == CallStatus.active ? _endCall : null,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFDC2626),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFDC2626)
                                  .withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.call_end,
                            color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('End Call',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveformWidget extends StatelessWidget {
  final double animValue;
  const _WaveformWidget({required this.animValue});

  @override
  Widget build(BuildContext context) {
    final random = Random(42);
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(24, (i) {
          final base = 0.2 + random.nextDouble() * 0.5;
          final wave =
              sin((i / 24 * 2 * pi) + animValue * 2 * pi) * 0.4 + 0.6;
          final height = 4.0 + base * wave * 36;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6 + wave * 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  const _ControlButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
