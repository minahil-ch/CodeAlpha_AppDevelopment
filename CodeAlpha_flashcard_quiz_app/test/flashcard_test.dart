import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart'; // Direct path to main.dart

void main() {
  group('Flashcard Quiz App Tests', () {
    testWidgets('App builds successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const FlashcardQuizApp());
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Flashcard Quiz App'), findsOneWidget);
    });

    testWidgets('Initial flashcard is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const FlashcardQuizApp());
      
      expect(find.text('What is the capital of France?'), findsOneWidget);
    });

    testWidgets('Show Answer button toggles answer visibility', (WidgetTester tester) async {
      await tester.pumpWidget(const FlashcardQuizApp());
      
      // Initially shows question
      expect(find.text('What is the capital of France?'), findsOneWidget);
      expect(find.text('Paris'), findsNothing);
      
      // Tap Show Answer button
      await tester.tap(find.text('Show Answer'));
      await tester.pump();
      
      // Now shows answer
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Question:'), findsNothing);
      expect(find.text('Answer:'), findsOneWidget);
    });

    testWidgets('Navigation buttons work', (WidgetTester tester) async {
      await tester.pumpWidget(const FlashcardQuizApp());
      
      // Check initial card
      expect(find.text('What is the capital of France?'), findsOneWidget);
      
      // Tap Next button
      await tester.tap(find.text('Next'));
      await tester.pump();
      
      // Check second card
      expect(find.text('What is 2 + 2?'), findsOneWidget);
      
      // Tap Previous button
      await tester.tap(find.text('Previous'));
      await tester.pump();
      
      // Back to first card
      expect(find.text('What is the capital of France?'), findsOneWidget);
    });

    testWidgets('Card counter updates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const FlashcardQuizApp());
      
      expect(find.text('Card 1 of 5'), findsOneWidget);
      
      // Go to next card
      await tester.tap(find.text('Next'));
      await tester.pump();
      
      expect(find.text('Card 2 of 5'), findsOneWidget);
    });
  });
}