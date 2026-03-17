import 'package:custom_floating_navigation_bar/custom_floating_navigation_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floating Navigation Bar Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleScreen(),
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _PageContent(title: 'Home 🏠', color: Color(0xFFFFF3E0)),
    const _PageContent(title: 'Chat 💬', color: Color(0xFFE8F5E9)),
    const _PageContent(title: 'Call 📞', color: Color(0xFFE3F2FD)),
    const _PageContent(title: 'More ⚙️', color: Color(0xFFF3E5F5)),
  ];

  void _onTap(int index) {
    // Index 2 = floating button action
    if (index == 2) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Floating Button Tapped! 🎉'),
          content: const Text('Yahan apna custom action add karo.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Floating Nav Bar Example'),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomFloatingNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,

        // ── Floating Button ──
        floatingPosition: FloatingPosition.center,
        onFloatingTap: (_) => _onTap(2),
        floatingWidget: const _FloatingButton(),
        floatingSize: 64,
        floatingLift: 30,

        // ── Styling ──
        leftRadius: 27,
        rightRadius: 27,
        topRadius: 27,
        bottomRadius: 0,
        barHeight: 64,
        notchRadius: 40,
        centerGapWidth: 80,

        // ── Nav Items ──
        items: [
          NavItem(
            index: 0,
            label: 'Home',
            outlineIcon: const Icon(
              Icons.home_outlined,
              color: Color(0xff60646C),
            ),
            filledIcon: const Icon(
              Icons.home,
              color: Color(0xff3A3333),
            ),
          ),
          NavItem(
            index: 1,
            label: 'Chat',
            outlineIcon: const Icon(
              Icons.chat_bubble_outline,
              color: Color(0xff60646C),
            ),
            filledIcon: const Icon(
              Icons.chat_bubble,
              color: Color(0xff3A3333),
            ),
            showBadge: true,
            badgeText: '3',
          ),
          NavItem(
            index: 3,
            label: 'Call',
            outlineIcon: const Icon(
              Icons.call_outlined,
              color: Color(0xff60646C),
            ),
            filledIcon: const Icon(
              Icons.call,
              color: Color(0xff3A3333),
            ),
          ),
          NavItem(
            index: 4,
            label: 'More',
            outlineIcon: const Icon(
              Icons.more_horiz,
              color: Color(0xff60646C),
            ),
            filledIcon: const Icon(
              Icons.more_horiz,
              color: Color(0xff3A3333),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Floating Button Widget ─────────────────────────────────────
class _FloatingButton extends StatelessWidget {
  const _FloatingButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF4A90E2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B61FF).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

// ── Page Content ───────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  final String title;
  final Color color;

  const _PageContent({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
