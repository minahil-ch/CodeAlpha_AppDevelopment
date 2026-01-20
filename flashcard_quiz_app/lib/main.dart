import 'package:flutter/material.dart';

// Flashcard model to hold question and answer
class Flashcard {
  String question;
  String answer;

  Flashcard({required this.question, required this.answer});
}

void main() {
  runApp(const FlashcardQuizApp());
}

class FlashcardQuizApp extends StatelessWidget {
  const FlashcardQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Quiz App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const FlashcardQuizScreen(),
    );
  }
}

class FlashcardQuizScreen extends StatefulWidget {
  const FlashcardQuizScreen({super.key});

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  List<Flashcard> flashcards = [
    Flashcard(
        question: "What is the capital of France?",
        answer: "Paris"),
    Flashcard(
        question: "What is 2 + 2?",
        answer: "4"),
    Flashcard(
        question: "What is the largest planet in our solar system?",
        answer: "Jupiter"),
    Flashcard(
        question: "Who wrote Romeo and Juliet?",
        answer: "William Shakespeare"),
    Flashcard(
        question: "What is the chemical symbol for water?",
        answer: "H2O"),
  ];

  int currentIndex = 0;
  bool showAnswer = false;

  void _showAnswer() {
    setState(() {
      showAnswer = !showAnswer;
    });
  }

  void _nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        showAnswer = false;
      });
    }
  }

  void _previousCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showAnswer = false;
      });
    }
  }

  void _addFlashcard(Flashcard newCard) {
    setState(() {
      flashcards.add(newCard);
    });
  }

  void _editFlashcard(int index, Flashcard updatedCard) {
    setState(() {
      flashcards[index] = updatedCard;
    });
  }

  void _deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
      if (currentIndex >= flashcards.length && flashcards.isNotEmpty) {
        currentIndex = flashcards.length - 1;
      } else if (flashcards.isEmpty) {
        currentIndex = 0;
        showAnswer = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcard Quiz App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Flashcard Display
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            showAnswer ? "Answer:" : "Question:",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showAnswer 
                                ? flashcards.isNotEmpty ? flashcards[currentIndex].answer : "No flashcards available"
                                : flashcards.isNotEmpty ? flashcards[currentIndex].question : "No flashcards available",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: flashcards.isNotEmpty && currentIndex > 0 ? _previousCard : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Previous"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: flashcards.isNotEmpty ? _showAnswer : null,
                  icon: Icon(showAnswer ? Icons.visibility_off : Icons.visibility),
                  label: Text(showAnswer ? "Hide Answer" : "Show Answer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: flashcards.isNotEmpty && currentIndex < flashcards.length - 1 ? _nextCard : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Navigation Indicators
            if (flashcards.isNotEmpty)
              Text(
                "Card ${currentIndex + 1} of ${flashcards.length}",
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).hintColor,
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Management Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _openAddEditDialog(null);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: flashcards.isNotEmpty ? () {
                    _openAddEditDialog(currentIndex);
                  } : null,
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: flashcards.isNotEmpty ? () {
                    _confirmDeleteDialog();
                  } : null,
                  icon: const Icon(Icons.delete),
                  label: const Text("Delete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEditDialog(int? index) {
    final bool isEditing = index != null;
    final TextEditingController questionController = TextEditingController(
      text: isEditing ? flashcards[index!].question : "",
    );
    final TextEditingController answerController = TextEditingController(
      text: isEditing ? flashcards[index!].answer : "",
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditing ? "Edit Flashcard" : "Add New Flashcard"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: "Answer",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && 
                    answerController.text.isNotEmpty) {
                  
                  Flashcard newCard = Flashcard(
                    question: questionController.text.trim(),
                    answer: answerController.text.trim(),
                  );
                  
                  if (isEditing) {
                    _editFlashcard(index!, newCard);
                  } else {
                    _addFlashcard(newCard);
                  }
                  
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this flashcard?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteFlashcard(currentIndex);
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}