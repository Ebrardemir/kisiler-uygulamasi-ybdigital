import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisiler_uygulamasi/models/contact.dart';
import 'package:kisiler_uygulamasi/pages/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //async işlemler olduğu için kullanılıyo

  await Hive.initFlutter(); //hive i başlatma

  Hive.registerAdapter(ContactAdapter()); //adapteri kaydetmek için
  await Hive.openBox<Contact>(
    'contacts',
  ); //contacts adında box açtık , contact tipinde

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kişilerim",
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 202, 205, 248),
        scaffoldBackgroundColor: Colors.grey[100],

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 4,
          centerTitle: true,

          titleTextStyle: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
