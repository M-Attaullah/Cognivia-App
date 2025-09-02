import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quiz_model.dart';

class QuizService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get quiz questions
  Future<List<QuestionModel>> getQuizQuestions(int limit) async {
    try {
      final snapshot = await _database
          .child('questions')
          .limitToFirst(limit)
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<QuestionModel> questions = [];

        data.forEach((key, value) {
          final questionMap = Map<String, dynamic>.from(value as Map);
          questionMap['id'] = key;
          questions.add(QuestionModel.fromJson(questionMap));
        });

        return questions;
      }

      // Return sample questions if no data exists
      return _getSampleQuestions();
    } catch (e) {
      throw Exception('Failed to get quiz questions: $e');
    }
  }

  // Save quiz result
  Future<void> saveQuizResult(QuizResultModel result) async {
    try {
      if (currentUserId == null) throw Exception('User not logged in');

      await _database
          .child('quizResults')
          .child(currentUserId!)
          .push()
          .set(result.toJson());
    } catch (e) {
      throw Exception('Failed to save quiz result: $e');
    }
  }

  // Get user's quiz history
  Future<List<QuizResultModel>> getQuizHistory(String userId) async {
    try {
      final snapshot = await _database
          .child('quizResults')
          .child(userId)
          .orderByChild('completedAt')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        final List<QuizResultModel> results = [];

        data.forEach((key, value) {
          final resultMap = Map<String, dynamic>.from(value as Map);
          resultMap['id'] = key;
          results.add(QuizResultModel.fromJson(resultMap));
        });

        // Sort by completed date (newest first)
        results.sort((a, b) => b.completedAt.compareTo(a.completedAt));
        return results;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to get quiz history: $e');
    }
  }

  // Get sample questions for testing
  List<QuestionModel> _getSampleQuestions() {
    final allQuestions = [
      QuestionModel(
        id: '1',
        question: 'Capital of France?',
        options: ['Paris', 'London', 'Rome', 'Berlin'],
        correctAnswerIndex: 0, // Paris
        explanation: 'Paris is the capital and most populous city of France.',
      ),
      QuestionModel(
        id: '2',
        question: '5 + 3 = ?',
        options: ['5', '8', '6', '7'],
        correctAnswerIndex: 1, // 8
        explanation: 'Simple arithmetic: 5 + 3 equals 8.',
      ),
      QuestionModel(
        id: '3',
        question: 'Which planet is known as the Red Planet?',
        options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
        correctAnswerIndex: 1, // Mars
        explanation:
            'Mars is called the Red Planet due to its reddish appearance.',
      ),
      QuestionModel(
        id: '4',
        question: 'What is the largest ocean on Earth?',
        options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
        correctAnswerIndex: 3, // Pacific
        explanation: 'The Pacific Ocean is the largest ocean on Earth.',
      ),
      QuestionModel(
        id: '5',
        question: 'Who wrote "Romeo and Juliet"?',
        options: [
          'Charles Dickens',
          'William Shakespeare',
          'Mark Twain',
          'Jane Austen',
        ],
        correctAnswerIndex: 1, // William Shakespeare
        explanation:
            'Romeo and Juliet is a tragedy written by William Shakespeare.',
      ),
      QuestionModel(
        id: '6',
        question: 'What is the chemical symbol for gold?',
        options: ['Go', 'Gd', 'Au', 'Ag'],
        correctAnswerIndex: 2, // Au
        explanation:
            'Au is the chemical symbol for gold, from the Latin word "aurum".',
      ),
      QuestionModel(
        id: '7',
        question: 'Which country is famous for the Taj Mahal?',
        options: ['Pakistan', 'India', 'Bangladesh', 'Nepal'],
        correctAnswerIndex: 1, // India
        explanation: 'The Taj Mahal is located in Agra, India.',
      ),
      QuestionModel(
        id: '8',
        question: 'How many continents are there?',
        options: ['5', '6', '7', '8'],
        correctAnswerIndex: 2, // 7
        explanation:
            'There are 7 continents: Asia, Africa, North America, South America, Antarctica, Europe, and Australia.',
      ),
      QuestionModel(
        id: '9',
        question: 'What is the fastest land animal?',
        options: ['Lion', 'Cheetah', 'Leopard', 'Tiger'],
        correctAnswerIndex: 1, // Cheetah
        explanation:
            'The cheetah is the fastest land animal, capable of speeds up to 70 mph.',
      ),
      QuestionModel(
        id: '10',
        question: 'Which programming language is known for web development?',
        options: ['Python', 'JavaScript', 'C++', 'Java'],
        correctAnswerIndex: 1, // JavaScript
        explanation:
            'JavaScript is widely used for web development, both frontend and backend.',
      ),
    ];

    // Shuffle and return 5 random questions
    allQuestions.shuffle();
    return allQuestions.take(5).toList();
  }
}
