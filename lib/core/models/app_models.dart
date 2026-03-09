import 'package:equatable/equatable.dart';

enum LearningGoal { business, casual, travel }
enum CallStatus { idle, connecting, active, ending, ended }

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final LearningGoal goal;
  final int callTimeHour;
  final int callTimeMinute;
  final int streakCount;
  final int totalCallMinutes;
  final int totalCalls;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.goal,
    required this.callTimeHour,
    required this.callTimeMinute,
    required this.streakCount,
    required this.totalCallMinutes,
    required this.totalCalls,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? name,
    LearningGoal? goal,
    int? callTimeHour,
    int? callTimeMinute,
    int? streakCount,
    int? totalCallMinutes,
    int? totalCalls,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      goal: goal ?? this.goal,
      callTimeHour: callTimeHour ?? this.callTimeHour,
      callTimeMinute: callTimeMinute ?? this.callTimeMinute,
      streakCount: streakCount ?? this.streakCount,
      totalCallMinutes: totalCallMinutes ?? this.totalCallMinutes,
      totalCalls: totalCalls ?? this.totalCalls,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, goal, streakCount];
}

class CallSession extends Equatable {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String transcript;
  final String summary;
  final List<GrammarError> grammarErrors;

  const CallSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.durationSeconds,
    required this.transcript,
    required this.summary,
    required this.grammarErrors,
  });

  @override
  List<Object?> get props => [id, startedAt, durationSeconds];
}

class GrammarError extends Equatable {
  final String id;
  final String originalText;
  final String correctedText;
  final String errorType;
  final String explanation;
  final DateTime occurredAt;

  const GrammarError({
    required this.id,
    required this.originalText,
    required this.correctedText,
    required this.errorType,
    required this.explanation,
    required this.occurredAt,
  });

  @override
  List<Object?> get props => [id, originalText, correctedText];
}

class MemoryItem extends Equatable {
  final String id;
  final String content;
  final String category;
  final String sourceCallId;
  final DateTime createdAt;

  const MemoryItem({
    required this.id,
    required this.content,
    required this.category,
    required this.sourceCallId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, content, category];
}

class WeeklyStats extends Equatable {
  final int callsThisWeek;
  final int minutesThisWeek;
  final int totalErrors;
  final Map<String, int> errorsByType;
  final List<int> dailyMinutes; // 7 days

  const WeeklyStats({
    required this.callsThisWeek,
    required this.minutesThisWeek,
    required this.totalErrors,
    required this.errorsByType,
    required this.dailyMinutes,
  });

  @override
  List<Object?> get props => [callsThisWeek, minutesThisWeek];
}
