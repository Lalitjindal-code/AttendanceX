import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

int initCount = 0;
int disposeCount = 0;

void main() {
  testWidgets('SliverToBoxAdapter lifecycle test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 1000)),
              SliverToBoxAdapter(child: LifecycleTestWidget()),
              SliverToBoxAdapter(child: SizedBox(height: 1000)),
            ],
          ),
        ),
      ),
    );

    print('Initial initCount: $initCount, disposeCount: $disposeCount');

    // Scroll down by 2000 pixels
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    print(
        'After scroll down initCount: $initCount, disposeCount: $disposeCount');

    // Scroll back up
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 2000));
    await tester.pumpAndSettle();

    print('After scroll up initCount: $initCount, disposeCount: $disposeCount');
  });
}

class LifecycleTestWidget extends StatefulWidget {
  const LifecycleTestWidget({super.key});
  @override
  State<LifecycleTestWidget> createState() => _LifecycleTestWidgetState();
}

class _LifecycleTestWidgetState extends State<LifecycleTestWidget> {
  @override
  void initState() {
    super.initState();
    initCount++;
  }

  @override
  void dispose() {
    disposeCount++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 100, child: Text('Test'));
  }
}
