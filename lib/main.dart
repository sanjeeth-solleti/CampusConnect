import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import Firebase config
import 'registration_id.dart';
import 'optionspage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'College App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: '/', // Start at Registration Page
      routes: {
        '/': (context) => RegistrationIDPage(),
        '/dashboard':
            (context) =>
                OptionsPage(name: '', regId: '', branch: '', section: ''),
      },
    );
  }
}
