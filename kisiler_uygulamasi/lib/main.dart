import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisiler_uygulamasi/models/contact.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //async işlemler olduğu için kullanılıyo
  
  await Hive.initFlutter(); //hive i başlatma

  Hive.registerAdapter(ContactAdapter()); //adapteri kaydetmek için
  await Hive.openBox<Contact>('contacts'); //contacts adında box açtık , contact tipinde

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}