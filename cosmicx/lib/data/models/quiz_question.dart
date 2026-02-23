enum ApiType { apod, mars }

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String answer;
  final ApiType type;
  final String apiRef;
  final String? roverName;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.type,
    required this.apiRef,
    this.roverName,
  });

  factory QuizQuestion.fromFirestore(Map<String, dynamic> data, String id) {
    // Helper to safely parse the type string
    ApiType parseType(String? typeStr) {
      if (typeStr?.toLowerCase() == 'mars') return ApiType.mars;
      return ApiType.apod; // Default to APOD if missing
    }

    return QuizQuestion(
      id: id,
      question: data['question'] ?? 'Unknown Mission',
      options: List<String>.from(data['options'] ?? []),
      answer: data['answer'] ?? '',
      type: parseType(data['type']),
      apiRef: data['apiRef'] ?? '',
      roverName: data['roverName'],
    );
  }
}
