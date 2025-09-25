//hive için modelimiz
import 'package:hive/hive.dart';
part 'contact.g.dart';

@HiveType(typeId: 1)
class Contact {
  @HiveField(1)
  String name;

  @HiveField(2)
  String? surname; // surname alanı zorunlu değil

  @HiveField(3)
  String phoneNumber;

  Contact({required this.name, this.surname, required this.phoneNumber});
}
