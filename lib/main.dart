import 'package:flutter/material.dart';
import 'package:gym_buddy_app/database_helper.dart';
import 'package:gym_buddy_app/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.openLocalDatabase(newDatabase: false);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gym Buddy',
        theme: ThemeData(
          fontFamily: 'Montserrat',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Home());
  }
}
