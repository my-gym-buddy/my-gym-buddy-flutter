import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/models/exercise.dart';
import 'package:gym_buddy_app/screens/exercises/add_exercise_screen.dart';
import 'mocks/mock_database_helper.dart';


void main() {
  group('AddExerciseScreen', () {
    late MockDatabaseHelper mockDatabaseHelper;

    setUp(() {
      // Create an instance of our mock
      mockDatabaseHelper = MockDatabaseHelper();
      // Replace the real DatabaseHelper with our mock
      DatabaseHelper.instance = mockDatabaseHelper;
    });

    testWidgets('can edit existing exercise', (WidgetTester tester) async {
      final existingExercise = Exercise(
        name: 'Existing Exercise',
        description: 'Existing Description',
        category: 'strength',
        difficulty: 'intermediate',
        images: [],
        videoURL: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AddExerciseScreen(exercise: existingExercise),
        ),
      );

      // Verify existing exercise data is displayed
      expect(find.text('Existing Exercise'), findsOneWidget);
      expect(find.text('Existing Description'), findsOneWidget);
    });
  });
} 