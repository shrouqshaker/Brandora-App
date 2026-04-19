
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:winterproject/home/data.dart';
import 'core/services/firebase_options.dart';
import 'features/onboarding/presentation/screens/onboarding_main.dart';
import 'features/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MaterialsData()),
        ChangeNotifierProvider(create: (context) => ProductsData()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Brandora App',
        theme: ThemeData(
          primaryColor: const Color(0xFF3F51B5),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
        ),
        home: seenOnboarding ? const LoginScreen() : const OnboardingMain(),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart'; 
// import 'core/services/firebase_options.dart'; 

// import 'features/onboarding/presentation/screens/onboarding_main.dart';
// import 'features/auth/login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final prefs = await SharedPreferences.getInstance();
//   bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

//   runApp(MyApp(seenOnboarding: seenOnboarding));
// }

// class MyApp extends StatelessWidget {
//   final bool seenOnboarding;

//   const MyApp({super.key, required this.seenOnboarding});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Brandora App',
//       theme: ThemeData(
//         primarySwatch: Colors.indigo,
//       ),
//       home: seenOnboarding
//           ?  LoginScreen()
//           :  OnboardingMain(),
//     );
//   }
// }