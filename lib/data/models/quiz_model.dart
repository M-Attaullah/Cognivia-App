class QuizModel {
  final String id;
  final String title;
  final String description;
  final List<QuestionModel> questions;
  final int timeLimit; // in seconds per question
  final int totalScore;
  final String category;
  final String difficulty;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.timeLimit = 10, // 10 seconds per question
    this.totalScore = 0,
    required this.category,
    required this.difficulty,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'questions': questions.map((q) => q.toJson()).toList(),
      'timeLimit': timeLimit,
      'totalScore': totalScore,
      'category': category,
      'difficulty': difficulty,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      timeLimit: json['timeLimit'] as int? ?? 10,
      totalScore: json['totalScore'] as int? ?? 0,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }
}

class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class QuizResultModel {
  final String id;
  final String userId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpent; // in seconds
  final DateTime completedAt;
  final List<UserAnswerModel> userAnswers;

  QuizResultModel({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeSpent,
    required this.completedAt,
    required this.userAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'timeSpent': timeSpent,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'userAnswers': userAnswers.map((a) => a.toJson()).toList(),
    };
  }

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      quizId: json['quizId'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      timeSpent: json['timeSpent'] as int,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        json['completedAt'] as int,
      ),
      userAnswers: (json['userAnswers'] as List)
          .map((a) => UserAnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  double get percentage => (correctAnswers / totalQuestions) * 100;
}

class UserAnswerModel {
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final int timeSpent; // in seconds for this question

  UserAnswerModel({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.timeSpent,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswerIndex': selectedAnswerIndex,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
    };
  }

  factory UserAnswerModel.fromJson(Map<String, dynamic> json) {
    return UserAnswerModel(
      questionId: json['questionId'] as String,
      selectedAnswerIndex: json['selectedAnswerIndex'] as int,
      isCorrect: json['isCorrect'] as bool,
      timeSpent: json['timeSpent'] as int,
    );
  }
}
