import 'package:flutter/material.dart';
import '../widgets/onboarding_step1.dart';
import '../widgets/onboarding_step2.dart';
import '../widgets/onboarding_step3.dart'; 

class OnboardingMain extends StatefulWidget {
  const OnboardingMain({super.key});

  @override
  State<OnboardingMain> createState() => _OnboardingMainState();
}

class _OnboardingMainState extends State<OnboardingMain> {
  final PageController _pageController = PageController();

  void _onSkip() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
    );
  }

  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onBack() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          children: [
            OnboardingStep1(onNext: _onNext, onSkip: _onSkip),
            OnboardingStep2(onNext: _onNext, onBack: _onBack, onSkip: _onSkip),
            OnboardingStep3(onBack: _onBack), 
          ],
        ),
      ),
    );
  }
}