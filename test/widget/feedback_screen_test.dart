import 'package:attendify/features/settings/screens/feedback_screen.dart';
import 'package:attendify/features/settings/services/feedback_service.dart';
import 'package:attendify/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class MockFeedbackService extends Mock implements FeedbackService {}

void main() {
  late MockFeedbackService mockFeedbackService;

  setUp(() async {
    mockFeedbackService = MockFeedbackService();
    SharedPreferences.setMockInitialValues({
      PreferencesService.keyHasShownFeedbackTutorial: true,
    });
    await PreferencesService.instance.initialize();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        feedbackServiceProvider.overrideWithValue(mockFeedbackService),
      ],
      child: MaterialApp(
        home: ShowCaseWidget(
          builder: (context) => const FeedbackScreen(),
        ),
      ),
    );
  }

  group('FeedbackScreen Widget Tests', () {
    testWidgets('renders all form fields correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Send Feedback'), findsWidgets);
      expect(find.text('Your Name (Optional)'), findsOneWidget);
      expect(find.text('Your Email (Optional)'), findsOneWidget);
      expect(find.text('Your Message *'), findsOneWidget);
    });

    testWidgets('shows validation error when message is empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final buttonFinder = find.byType(FilledButton);
      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle();
      
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your message'), findsOneWidget);
    });
  });
}
