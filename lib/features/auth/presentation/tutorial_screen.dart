import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stutz/features/auth/application/auth_providers.dart';
import 'package:stutz/shared/widgets/app_action_buttons.dart';

class _TutorialPage {
  final String title;
  final String text;
  final IconData icon;

  const _TutorialPage({
    required this.title,
    required this.text,
    required this.icon,
  });
}

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleting = false;

  static const _pages = [
    _TutorialPage(
      title: "Fix vs. Variabel",
      text:
          "Stutz trennt automatisch deine Fixkosten vom Budget. So siehst du nur das Geld, das du wirklich ausgeben kannst.",
      icon: Icons.pie_chart_outline,
    ),
    _TutorialPage(
      title: "Monatlich & Jährlich",
      text:
          "Versicherungen zahlen wir oft jährlich. Stutz rechnet diese Kosten automatisch auf den Monat herunter.",
      icon: Icons.calendar_today,
    ),
    _TutorialPage(
      title: "Offline First",
      text:
          "Kein Netz? Kein Problem. Erfasse Ausgaben jederzeit offline. Wir synchronisieren, sobald du wieder online bist.",
      icon: Icons.cloud_off,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;

    setState(() => _isCompleting = true);
    try {
      await ref.read(onboardingControllerProvider.notifier).complete();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (_) {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          AppTextButton(
            label: "Überspringen",
            onPressed: _isCompleting ? null : _completeOnboarding,
            textStyle: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) =>
                    _buildPageContent(_pages[index]),
              ),
            ),

            // Navigation Dots & Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.teal
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppPrimaryButton(
                    label: _currentPage == _pages.length - 1
                        ? "Alles klar"
                        : "Weiter",
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(_TutorialPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(page.icon, size: 100, color: Colors.teal),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Text(
            page.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
