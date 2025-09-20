//crud işlemleri burada yapılacak

import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisiler_uygulamasi/models/contact.dart';

class ContactService {
  final Box<Contact> contactBox = Hive.box<Contact>('contacts'); //hivedeki oluşturduğumu< contacts adlıboxı açıp onu değişkene atadık böylece her fonksiyonda kullanabiliriz




  
}