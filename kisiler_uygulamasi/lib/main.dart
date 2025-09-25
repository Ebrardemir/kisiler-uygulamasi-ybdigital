import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

class Person {
  Person({required this.id, required this.name, this.phone = ''});
  final int id;
  String name;
  String phone;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
  };

  static Person fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Kişiler',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const PeoplePage(),
    );
  }
}

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Person> _people = <Person>[];

  String _query = '';
  int _nextId = 1;

  static const String _prefsKey = 'people_v1';

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString == null || jsonString.isEmpty) {
      setState(() {
        _people.addAll(<Person>[
          Person(id: 1, name: 'Ahmet Yılmaz', phone: '555-111-2233'),
          Person(id: 2, name: 'Ayşe Demir', phone: '555-333-4455'),
          Person(id: 3, name: 'Mehmet Kaya', phone: '555-666-7788'),
        ]);
        _nextId = 4;
      });
      await _savePeople();
      return;
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      final List<Person> loaded = decoded
          .map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _people
          ..clear()
          ..addAll(loaded);
        _nextId = (_people.map((p) => p.id).fold<int>(0, (max, id) => id > max ? id : max)) + 1;
      });
    } catch (_) {
      // If parsing fails, keep current list
    }
  }

  Future<void> _savePeople() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _people.map((p) => p.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(data));
  }

  List<Person> get _filteredPeople {
    if (_query.trim().isEmpty) return _people;
    final q = _query.toLowerCase();
    return _people.where((p) => p.name.toLowerCase().contains(q) || p.phone.toLowerCase().contains(q)).toList();
  }

  void _openPersonDialog({Person? person}) async {
    final nameController = TextEditingController(text: person?.name ?? '');
    final phoneController = TextEditingController(text: person?.phone ?? '');

    final result = await showDialog<Person>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(person == null ? 'Kişi Ekle' : 'Kişiyi Düzenle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefon'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isEmpty) return;
                if (person == null) {
                  Navigator.of(context).pop(Person(id: _nextId, name: name, phone: phone));
                } else {
                  final updated = Person(id: person.id, name: name, phone: phone);
                  Navigator.of(context).pop(updated);
                }
              },
              child: Text(person == null ? 'Ekle' : 'Kaydet'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() {
      final existingIndex = _people.indexWhere((p) => p.id == result.id);
      if (existingIndex == -1) {
        _people.add(result);
        _nextId += 1;
      } else {
        _people[existingIndex] = result;
      }
    });
    await _savePeople();
  }

  Future<void> _deletePerson(Person person) async {
    setState(() {
      _people.removeWhere((p) => p.id == person.id);
    });
    await _savePeople();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kişiler'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Ara (isim veya telefon)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredPeople.isEmpty
                ? const Center(child: Text('Kayıt bulunamadı'))
                : ListView.separated(
                    itemCount: _filteredPeople.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final person = _filteredPeople[index];
                      return ListTile(
                        title: Text(person.name),
                        subtitle: person.phone.isEmpty ? null : Text(person.phone),
                        leading: CircleAvatar(
                          child: Text(person.name.isNotEmpty ? person.name[0] : '?'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openPersonDialog(person: person),
                              tooltip: 'Düzenle',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deletePerson(person),
                              tooltip: 'Sil',
                            ),
                          ],
                        ),
                        onTap: () => _openPersonDialog(person: person),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPersonDialog(),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Kişi Ekle'),
      ),
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
