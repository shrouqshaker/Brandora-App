import 'package:flutter/material.dart';

class OnboardingStep2 extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip; 

  const OnboardingStep2({
    super.key, 
    required this.onNext, 
    required this.onBack, 
    required this.onSkip, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        title: const Text(
          'Brandora',
          style: TextStyle(
            color: Colors.black, 
            fontWeight: FontWeight.bold, 
            fontSize: 18
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: onSkip, 
            child: const Text(
              "SKIP", 
              style: TextStyle(
                color: Color(0xFF3F51B5), 
                fontWeight: FontWeight.bold
              ),
            ),
          )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/second.png', 
                            fit: BoxFit.contain
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Manage Products Smarter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26, 
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFF111827)
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Use AI to generate captions, suggest prices, and track your inventory effortlessly.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16, 
                          color: Color(0xFF6B7280), 
                          height: 1.5
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildInactiveDot(),
                          const SizedBox(width: 8),
                          Container(
                            width: 24, 
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F51B5), 
                              borderRadius: BorderRadius.circular(4)
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildInactiveDot(),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next', 
                                style: TextStyle(color: Colors.white, fontSize: 18)
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: onBack,
                        child: const Text(
                          'Back', 
                          style: TextStyle(color: Color(0xFF3F51B5), fontSize: 16)
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInactiveDot() {
    return Container(
      width: 8, 
      height: 8, 
      decoration: const BoxDecoration(
        color: Color(0xFFD1D5DB), 
        shape: BoxShape.circle
      )
    );
  }
}