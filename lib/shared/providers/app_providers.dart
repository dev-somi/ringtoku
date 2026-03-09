import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/app_models.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize with override');
});

final isOnboardedProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('is_onboarded') ?? false;
});

final isLoggedInProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('is_logged_in') ?? false;
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile?>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfile?> {
  UserProfileNotifier() : super(null);

  void setProfile(UserProfile profile) => state = profile;

  void updateGoal(LearningGoal goal) {
    if (state != null) state = state!.copyWith(goal: goal);
  }

  void updateCallTime(int hour, int minute) {
    if (state != null) {
      state = state!.copyWith(callTimeHour: hour, callTimeMinute: minute);
    }
  }

  void incrementStreak() {
    if (state != null) {
      state = state!.copyWith(streakCount: state!.streakCount + 1);
    }
  }
}

final callStatusProvider =
    StateProvider<CallStatus>((ref) => CallStatus.idle);

final currentCallProvider =
    StateNotifierProvider<CallNotifier, CallSession?>((ref) {
  return CallNotifier();
});

class CallNotifier extends StateNotifier<CallSession?> {
  CallNotifier() : super(null);
  final _uuid = const Uuid();

  void startCall() {
    state = CallSession(
      id: _uuid.v4(),
      startedAt: DateTime.now(),
      durationSeconds: 0,
      transcript: '',
      summary: '',
      grammarErrors: [],
    );
  }

  void endCall(List<GrammarError> errors, String summary) {
    if (state != null) {
      final now = DateTime.now();
      state = CallSession(
        id: state!.id,
        startedAt: state!.startedAt,
        endedAt: now,
        durationSeconds: now.difference(state!.startedAt).inSeconds,
        transcript: state!.transcript,
        summary: summary,
        grammarErrors: errors,
      );
    }
  }

  void clear() => state = null;
}

final callHistoryProvider =
    StateNotifierProvider<CallHistoryNotifier, List<CallSession>>((ref) {
  return CallHistoryNotifier();
});

class CallHistoryNotifier extends StateNotifier<List<CallSession>> {
  CallHistoryNotifier() : super(_mockCallHistory());
  void addCall(CallSession session) => state = [session, ...state];
}

final memoryItemsProvider =
    StateNotifierProvider<MemoryNotifier, List<MemoryItem>>((ref) {
  return MemoryNotifier();
});

class MemoryNotifier extends StateNotifier<List<MemoryItem>> {
  MemoryNotifier() : super(_mockMemories());
  void deleteMemory(String id) =>
      state = state.where((m) => m.id != id).toList();
  void addMemory(MemoryItem item) => state = [item, ...state];
}

final weeklyStatsProvider = Provider<WeeklyStats>((ref) {
  return const WeeklyStats(
    callsThisWeek: 5,
    minutesThisWeek: 62,
    totalErrors: 12,
    errorsByType: {
      'Article': 4,
      'Tense': 3,
      'Preposition': 3,
      'Word Order': 2,
    },
    dailyMinutes: [0, 12, 15, 0, 10, 13, 12],
  );
});

final subtitleProvider = StateProvider<String>((ref) => '');

// ─── Mock Data ────────────────────────────────────────────────────────────────

List<CallSession> _mockCallHistory() {
  const uuid = Uuid();
  final now = DateTime.now();
  return [
    CallSession(
      id: uuid.v4(),
      startedAt: now.subtract(const Duration(days: 1, hours: 2)),
      endedAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 48)),
      durationSeconds: 720,
      transcript:
          'Good morning! How are you today?\nI am fine, thank you. I went to a meeting yesterday...',
      summary:
          'Discussed work meetings and weekend plans. User mentioned enjoying hiking.',
      grammarErrors: [
        GrammarError(
          id: uuid.v4(),
          originalText: 'I goed to the meeting',
          correctedText: 'I went to the meeting',
          errorType: 'Tense',
          explanation:
              '"go" is an irregular verb. Past tense is "went", not "goed".',
          occurredAt: now.subtract(const Duration(days: 1, hours: 2)),
        ),
        GrammarError(
          id: uuid.v4(),
          originalText: 'She dont like it',
          correctedText: 'She does not like it',
          errorType: 'Subject-Verb Agreement',
          explanation:
              'With third-person singular (she/he/it), use "does not" not "do not".',
          occurredAt:
              now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
        ),
      ],
    ),
    CallSession(
      id: uuid.v4(),
      startedAt: now.subtract(const Duration(days: 2, hours: 3)),
      endedAt: now.subtract(const Duration(days: 2, hours: 2, minutes: 45)),
      durationSeconds: 900,
      transcript:
          'Hi! How was your weekend?\nIt was great! I went hiking in the mountains...',
      summary:
          'Talked about hiking experiences and introduced pet cat Leon.',
      grammarErrors: [
        GrammarError(
          id: uuid.v4(),
          originalText: 'The mountain is very height',
          correctedText: 'The mountain is very high',
          errorType: 'Vocabulary',
          explanation:
              'Use the adjective "high" to describe altitude, not the noun "height".',
          occurredAt: now.subtract(const Duration(days: 2, hours: 3)),
        ),
      ],
    ),
    CallSession(
      id: uuid.v4(),
      startedAt: now.subtract(const Duration(days: 4, hours: 1)),
      endedAt: now.subtract(const Duration(days: 4, minutes: 47)),
      durationSeconds: 780,
      transcript:
          'Hello! Ready to practice today?\nYes! I want to talk about my work...',
      summary: 'Practiced business English phrases for presentations.',
      grammarErrors: [
        GrammarError(
          id: uuid.v4(),
          originalText: 'I am boring in the meeting',
          correctedText: 'I am bored in the meeting',
          errorType: 'Adjective',
          explanation:
              '"Bored" describes how you feel. "Boring" describes the thing that causes boredom.',
          occurredAt: now.subtract(const Duration(days: 4, hours: 1)),
        ),
        GrammarError(
          id: uuid.v4(),
          originalText: 'We discussed about the project',
          correctedText: 'We discussed the project',
          errorType: 'Preposition',
          explanation:
              '"Discuss" does not take "about". Say "discuss something".',
          occurredAt: now.subtract(const Duration(days: 4, minutes: 55)),
        ),
      ],
    ),
  ];
}

List<MemoryItem> _mockMemories() {
  const uuid = Uuid();
  final now = DateTime.now();
  return [
    MemoryItem(
      id: uuid.v4(),
      content: 'Has a cat named Leon',
      category: 'Personal',
      sourceCallId: 'call-2',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    MemoryItem(
      id: uuid.v4(),
      content: 'Works in a tech company, has meetings with English speakers',
      category: 'Work',
      sourceCallId: 'call-3',
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    MemoryItem(
      id: uuid.v4(),
      content: 'Enjoys hiking on weekends, went to mountains recently',
      category: 'Hobbies',
      sourceCallId: 'call-2',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    MemoryItem(
      id: uuid.v4(),
      content: 'Goal: improve business English for overseas conferences',
      category: 'Learning Goal',
      sourceCallId: 'call-3',
      createdAt: now.subtract(const Duration(days: 4)),
    ),
    MemoryItem(
      id: uuid.v4(),
      content: 'Frequently confuses tense forms (go/went)',
      category: 'Grammar Pattern',
      sourceCallId: 'call-1',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}
