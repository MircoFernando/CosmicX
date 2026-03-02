import 'package:flutter/material.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz_question.dart';
import '../data/repositories/user_repository.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository _repository = QuizRepository();
  final UserRepository _userRepo = UserRepository();

  List<QuizQuestion> _questions = [];

  int _currentIndex = 0;
  int _sessionScore = 0;
  bool _isLoadingQuiz = true;
  bool _isLoadingContent = true;
  bool _answered = false;
  String? _selectedAnswer;
  ApiContent? _currentApiContent;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final questions = await _repository.fetchQuestions();

      if (questions.isEmpty) {
        setState(() {
          _errorMessage =
              "Database is empty! Add documents to 'questions' collection.";
          _isLoadingQuiz = false;
        });
        return;
      }

      setState(() {
        _questions = questions;
        _isLoadingQuiz = false;
      });

      _loadCurrentQuestionContent();
    } catch (e) {
      setState(() {
        _isLoadingQuiz = false;
        _errorMessage = "Error loading quiz: $e";
      });
    }
  }

  Future<void> _loadCurrentQuestionContent() async {
    setState(() {
      _isLoadingContent = true;
      _currentApiContent = null;
    });

    final currentQ = _questions[_currentIndex];
    final content = await _repository.fetchLiveContent(currentQ);

    if (mounted) {
      setState(() {
        _currentApiContent = content;
        _isLoadingContent = false;
      });
    }
  }

  void _checkAnswer(String answer) {
    if (_answered) return;

    // FIX 1: Use .answer (matches your Model)
    final isCorrect = answer == _questions[_currentIndex].answer;

    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (isCorrect) {
        _sessionScore += 20;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
      _loadCurrentQuestionContent();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final newTotalScore = await _userRepo.updateUserScore(_sessionScore);

    if (mounted) Navigator.pop(context);
    if (mounted) _showEndScreen(newTotalScore);
  }

  void _showEndScreen(int totalCareerScore) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0D17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00D4FF), width: 2),
        ),
        title: const Text(
          "MISSION ACCOMPLISHED",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.yellowAccent, size: 50),
            const SizedBox(height: 20),
            _buildScoreRow(
              "Mission XP:",
              "+$_sessionScore",
              Colors.greenAccent,
            ),
            const Divider(color: Colors.grey),
            _buildScoreRow(
              "Total Career XP:",
              "$totalCareerScore",
              const Color(0xFF00D4FF),
            ),
            const SizedBox(height: 20),
            const Text(
              "Database updated successfully.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D4FF),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text("RETURN TO BASE"),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mission Intel"),
        content: Text(_currentApiContent?.hint ?? "Decrypting..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Copy That"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoadingQuiz)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_questions.isEmpty)
      return const Scaffold(body: Center(child: Text("No quests available.")));
    if (_errorMessage != null)
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );

    final currentQ = _questions[_currentIndex];
    // FIX 2: Use .answer
    final bool isCorrect = _selectedAnswer == currentQ.answer;

    return Scaffold(
      appBar: AppBar(
        title: Text("Quest ${_currentIndex + 1}/${_questions.length}"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.lightbulb_outline,
              color: Colors.yellowAccent,
            ),
            onPressed: _showHint,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: _isLoadingContent
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _currentApiContent?.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              currentQ.question,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.error,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCorrect ? "CORRECT! +20 XP" : "WRONG ANSWER",
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 10),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  if (index >= currentQ.options.length) return const SizedBox();
                  final option = currentQ.options[index];
                  final bool isOptionCorrect = option == currentQ.answer;
                  final bool isOptionSelected = option == _selectedAnswer;

                  // --- COLOR LOGIC ---
                  Color cardColor = Colors.deepPurple;
                  Color borderColor = Colors.deepPurpleAccent;

                  if (_answered) {
                    if (isOptionCorrect) {
                      // Correct Answer: ALWAYS Green
                      cardColor = Colors.green.shade700;
                      borderColor = Colors.greenAccent;
                    } else if (isOptionSelected) {
                      // Selected Wrong Answer: Bright Red
                      cardColor = Colors.red.shade800;
                      borderColor = Colors.redAccent;
                    } else {
                      // Unselected Wrong Answers
                      cardColor = Colors.red;
                      borderColor = Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () => _checkAnswer(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: borderColor,
                          width:
                              _answered && (isOptionCorrect || isOptionSelected)
                              ? 3
                              : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? "NEXT MISSION"
                      : "FINISH DEBRIEF",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
