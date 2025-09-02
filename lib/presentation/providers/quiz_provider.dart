import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/models/quiz_model.dart';
import '../../data/services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService;

  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  bool _isQuizActive = false;
  String? _errorMessage;
  List<QuizResultModel> _quizHistory = [];
  List<UserAnswerModel> _userAnswers = [];
  int _quizStartTime = 0;

  // Timer related
  int _timeRemaining = 10;
  bool _isTimerRunning = false;
  Timer? _timer;

  QuizProvider({QuizService? quizService})
    : _quizService = quizService ?? QuizService();

  // Getters
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isQuizActive => _isQuizActive;
  String? get errorMessage => _errorMessage;
  List<QuizResultModel> get quizHistory => _quizHistory;
  int get timeRemaining => _timeRemaining;
  bool get isTimerRunning => _isTimerRunning;

  QuestionModel? get currentQuestion =>
      _questions.isNotEmpty && _currentQuestionIndex < _questions.length
      ? _questions[_currentQuestionIndex]
      : null;

  bool get isQuizCompleted => !_isQuizActive && _questions.isNotEmpty;

  // Submit answer (alias for answerQuestion for UI consistency)
  void submitAnswer(int selectedOptionIndex) {
    answerQuestion(selectedOptionIndex);
  }

  // Start new quiz
  Future<void> startQuiz({int questionLimit = 5}) async {
    try {
      _setLoading(true);
      _clearError();

      final questions = await _quizService.getQuizQuestions(questionLimit);

      if (questions.isNotEmpty) {
        _questions = questions;
        _currentQuestionIndex = 0;
        _score = 0;
        _isQuizActive = true;
        _timeRemaining = 10;
        _userAnswers = [];
        _quizStartTime = DateTime.now().millisecondsSinceEpoch;
        _setLoading(false);
        _startTimer();
      } else {
        _setError('No questions available');
        _setLoading(false);
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Answer current question
  void answerQuestion(int selectedOptionIndex) {
    if (!_isQuizActive || currentQuestion == null) return;

    _stopTimer();

    // Record user answer
    final timeSpentOnQuestion = 10 - _timeRemaining;
    final isCorrect =
        selectedOptionIndex == currentQuestion!.correctAnswerIndex;

    _userAnswers.add(
      UserAnswerModel(
        questionId: currentQuestion!.id,
        selectedAnswerIndex: selectedOptionIndex,
        isCorrect: isCorrect,
        timeSpent: timeSpentOnQuestion,
      ),
    );

    // Check if answer is correct
    if (isCorrect) {
      _score++;
    }

    // Move to next question or end quiz
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _timeRemaining = 10;
      _startTimer();
    } else {
      _endQuiz();
    }

    notifyListeners();
  }

  // Handle timer timeout
  void _onTimerTimeout() {
    if (!_isQuizActive) return;

    // Record timeout as wrong answer
    if (currentQuestion != null) {
      _userAnswers.add(
        UserAnswerModel(
          questionId: currentQuestion!.id,
          selectedAnswerIndex: -1, // -1 indicates timeout
          isCorrect: false,
          timeSpent: 10, // Full time elapsed
        ),
      );
    }

    // Move to next question or end quiz (no score increase)
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _timeRemaining = 10;
      _startTimer();
    } else {
      _endQuiz();
    }

    notifyListeners();
  }

  // End current quiz
  void _endQuiz() async {
    _isQuizActive = false;
    _stopTimer();

    // Calculate total time spent
    final totalTimeSpent =
        (DateTime.now().millisecondsSinceEpoch - _quizStartTime) ~/ 1000;

    // Save quiz result to Firebase
    try {
      final result = QuizResultModel(
        id: '', // Will be set by Firebase
        userId: _quizService.currentUserId ?? '',
        quizId: 'general-quiz', // Default quiz ID
        score: _score,
        totalQuestions: _questions.length,
        correctAnswers: _score,
        timeSpent: totalTimeSpent,
        completedAt: DateTime.now(),
        userAnswers: _userAnswers,
      );

      await _quizService.saveQuizResult(result);

      // Add to local history for immediate UI update
      _quizHistory.insert(0, result);
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
      // Continue with quiz completion even if saving fails
    }

    notifyListeners();
  }

  // Load quiz history
  Future<void> loadQuizHistory(String userId) async {
    try {
      _setLoading(true);
      final history = await _quizService.getQuizHistory(userId);
      _quizHistory = history;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }

  // Timer methods
  void _startTimer() {
    _isTimerRunning = true;
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _onTimerTimeout();
      }
    });

    notifyListeners();
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Reset quiz state
  void resetQuiz() {
    _questions.clear();
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizActive = false;
    _timeRemaining = 10;
    _userAnswers = [];
    _quizStartTime = 0;
    _stopTimer();
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
