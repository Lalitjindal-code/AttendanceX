import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: TestScreen()));
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Container(height: 1000, color: Colors.red)),
          const SliverToBoxAdapter(child: LifecycleTestWidget()),
          SliverToBoxAdapter(
              child: Container(height: 1000, color: Colors.blue)),
        ],
      ),
    );
  }
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
    print("LifecycleTestWidget: initState");
  }

  @override
  void dispose() {
    print("LifecycleTestWidget: dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100, color: Colors.green, child: const Text('Test'));
  }
}
