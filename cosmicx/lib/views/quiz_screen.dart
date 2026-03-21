import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/repositories/quiz_repository.dart';
import '../data/models/quiz_question.dart';
import '../data/repositories/user_repository.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    this.repository,
    this.userRepository,
    this.flutterTts,
  });

  final QuizRepository? repository;
  final UserRepository? userRepository;
  final FlutterTts? flutterTts;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late final QuizRepository _repository;
  late final UserRepository _userRepo;
  late final FlutterTts _flutterTts;

  List<QuizQuestion> _questions = [];

  int _currentIndex = 0;
  int _sessionScore = 0;
  bool _isLoadingQuiz = true;
  bool _isLoadingContent = true;
  bool _answered = false;
  String? _selectedAnswer;
  ApiContent? _currentApiContent;
  String? _errorMessage;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? QuizRepository();
    _userRepo = widget.userRepository ?? UserRepository();
    _flutterTts = widget.flutterTts ?? FlutterTts();
    _initTts();
    _loadQuiz();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // 0.5 is normal speed

    // Updates UI when speaking starts/stops
    _flutterTts.setStartHandler(() {
      setState(() => _isSpeaking = true);
    });

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setCancelHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((message) {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _speakQuestion() async {
    if (_questions.isEmpty) return;

    // If already speaking, stop it.
    if (_isSpeaking) {
      await _flutterTts.stop();
      return;
    }

    final q = _questions[_currentIndex];
    // Read the Question AND the Options
    String textToRead = "${q.question}... Is it... ${q.options.join(', or ')}?";

    await _flutterTts.speak(textToRead);
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

    await _flutterTts.stop();

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
    _flutterTts.stop(); // Stop TTS when an answer is selected
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emoji_events_rounded,
                color: Theme.of(context).primaryColor,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "MISSION ACCOMPLISHED",
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            _buildScoreRow(
              "Mission XP:",
              "+$_sessionScore",
              Colors.greenAccent,
            ),
            const Divider(),
            _buildScoreRow(
              "Total Career XP:",
              "$totalCareerScore",
              Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_done_rounded,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  "Progress saved",
                  style: GoogleFonts.inter(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: Text(
                "RETURN TO BASE",
                style: GoogleFonts.orbitron(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
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
            style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showHint() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber.withOpacity(0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Mission Intel",
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          _currentApiContent?.hint ?? "Decrypting...",
          style: GoogleFonts.inter(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Copy That",
              style: GoogleFonts.orbitron(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      return Scaffold(
        body: Center(
          child: Text("No quests available.", style: GoogleFonts.inter()),
        ),
      );
    if (_errorMessage != null)
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage!,
            style: GoogleFonts.inter(color: Colors.red),
          ),
        ),
      );

    final currentQ = _questions[_currentIndex];
    // FIX 2: Use .answer
    final bool isCorrect = _selectedAnswer == currentQ.answer;

    final AppBar appBar;
    if (Platform.isIOS) {
      appBar = AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Quest ${_currentIndex + 1}/${_questions.length}",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.amber.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.amber,
              ),
              onPressed: _showHint,
            ),
          ),
        ],
      );
    } else if (Platform.isAndroid) {
      appBar = AppBar(
        title: Text(
          "Quest ${_currentIndex + 1}/${_questions.length}",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.3),
                  Colors.amber.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.tips_and_updates_rounded,
                color: Colors.amber,
              ),
              onPressed: _showHint,
            ),
          ),
        ],
      );
    } else {
      appBar = AppBar(
        title: Text(
          "Quest ${_currentIndex + 1}/${_questions.length}",
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _isLoadingContent
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.network(
                            _currentApiContent?.imageUrl ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (c, e, s) => Container(
                              color: theme.cardColor,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey[400],
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor.withOpacity(0.9),
                                    theme.primaryColor.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.radar,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'LIVE DATA',
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      currentQ.question,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                    color: _isSpeaking ? Colors.greenAccent : Colors.white,
                  ),
                  onPressed: _speakQuestion,
                ),
              ],
            ),
          ),

          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCorrect
                        ? [
                            Colors.green.withOpacity(0.3),
                            Colors.green.withOpacity(0.1),
                          ]
                        : [
                            Colors.red.withOpacity(0.3),
                            Colors.red.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.6)
                        : Colors.red.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCorrect ? Icons.verified_rounded : Icons.cancel_rounded,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isCorrect ? "CORRECT! +20 XP" : "INCORRECT",
                      style: GoogleFonts.orbitron(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1,
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

                  return GestureDetector(
                    onTap: () => _checkAnswer(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _answered
                              ? (isOptionCorrect
                                    ? [
                                        Colors.green.shade600,
                                        Colors.green.shade700,
                                      ]
                                    : [
                                        Colors.red.shade700,
                                        Colors.red.shade800,
                                      ])
                              : [
                                  theme.primaryColor,
                                  theme.primaryColor.withOpacity(0.9),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _answered
                              ? (isOptionCorrect
                                    ? Colors.greenAccent
                                    : Colors.redAccent)
                              : theme.primaryColor,
                          width:
                              _answered && (isOptionCorrect || isOptionSelected)
                              ? 2.5
                              : 2,
                        ),
                        boxShadow:
                            _answered && (isOptionCorrect || isOptionSelected)
                            ? [
                                BoxShadow(
                                  color: isOptionCorrect
                                      ? Colors.green.withOpacity(0.5)
                                      : Colors.red.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          option,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex < _questions.length - 1
                            ? "NEXT MISSION"
                            : "FINISH QUEST",
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
