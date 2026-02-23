import 'package:flutter/material.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz_question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository _repository = QuizRepository();
  List<QuizQuestion> _questions = [];

  // State variables
  int _currentIndex = 0;
  bool _isLoadingQuiz = true;
  bool _isLoadingContent = true;
  bool _answered = false;
  String? _selectedAnswer;
  ApiContent? _currentApiContent;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  String? _errorMessage;

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
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
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
      Navigator.pop(context);
    }
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
          // 1. Dynamic Image Area
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

          // 2. Question Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              currentQ.question,
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),

          // 3. Feedback Indicator (Shows only when answered)
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
                      isCorrect ? "CORRECT!" : "WRONG ANSWER",
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

          const SizedBox(height: 30),

          // 4. Answer Grid
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

                  Color cardColor = Colors.deepPurple; // Default Purple
                  Color borderColor = Colors.deepPurpleAccent;

                  if (_answered) {
                    if (isOptionCorrect) {
                      // Always show the correct answer in Green
                      cardColor = Colors.green.shade700;
                      borderColor = Colors.greenAccent;
                    } else {
                      // Everything else is Red
                      cardColor = Colors.red.shade800;
                      borderColor = Colors.redAccent;
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
                              : 1, // Make selected/correct borders thicker
                        ),
                        boxShadow: [
                          if (_answered && isOptionCorrect)
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                        ],
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

          // 5. Hint Section
          if (_currentApiContent?.hint != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.yellowAccent.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.yellowAccent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Mission Intel",
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentApiContent!.hint!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 6. Next Button
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
