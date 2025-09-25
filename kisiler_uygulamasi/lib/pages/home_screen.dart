import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kisiler_uygulamasi/models/contact.dart';
import 'package:kisiler_uygulamasi/pages/add_contact_screen.dart';
import 'package:kisiler_uygulamasi/pages/edit_contact_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final Box<Contact> contactBox = Hive.box<Contact>('contacts');

    return Scaffold(
      appBar: AppBar(title: Text("Kişilerim")),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
        child: ValueListenableBuilder(
          valueListenable: contactBox.listenable(),
          builder: (context, Box<Contact> contacts, _) {
            // Arama filtresi: index-map oluştur
            final List<(int, Contact)> items = [
              for (int i = 0; i < contacts.length; i++)
                if (contacts.getAt(i) != null) (i, contacts.getAt(i)!)
            ];

            final String q = _query.trim().toLowerCase();
            final List<(int, Contact)> filtered = q.isEmpty
                ? items
                : items.where((pair) {
                    final contact = pair.$2;
                    return contact.name.toLowerCase().contains(q) ||
                        ((contact.surname ?? '').toLowerCase().contains(q)) ||
                        contact.phoneNumber.toLowerCase().contains(q);
                  }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  contacts.values.isEmpty ? "Kayıtlı kişi yok" : "Sonuç bulunamadı",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: filtered.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Arama çubuğu
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Ara: ad, soyad, telefon',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    );
                  }

                  final (origIndex, contact) = filtered[index - 1];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          "${contact.name} ${(contact.surname ?? '')}".trim(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          contact.phoneNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero, 
                              constraints:
                                  const BoxConstraints(), 

                              icon: Icon(
                                Icons.edit,
                                color: const Color.fromARGB(255, 185, 75, 249),
                                size: 24,
                              ),
                              onPressed: () async {
                                final nameController = TextEditingController(text: contact.name);
                                final surnameController = TextEditingController(text: contact.surname ?? '');
                                final phoneController = TextEditingController(text: contact.phoneNumber);

                                await showDialog<void>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Kişiyi Düzenle'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: const InputDecoration(labelText: 'Ad'),
                                              textInputAction: TextInputAction.next,
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: surnameController,
                                              decoration: const InputDecoration(labelText: 'Soyad (opsiyonel)'),
                                              textInputAction: TextInputAction.next,
                                            ),
                                            const SizedBox(height: 8),
                                            TextField(
                                              controller: phoneController,
                                              decoration: const InputDecoration(labelText: 'Telefon'),
                                              keyboardType: TextInputType.phone,
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Vazgeç'),
                                        ),
                                        FilledButton(
                                          onPressed: () async {
                                            final String newName = nameController.text.trim();
                                            final String newSurname = surnameController.text.trim();
                                            final String newPhone = phoneController.text.trim();
                                            if (newName.isEmpty || newPhone.isEmpty) {
                                              return;
                                            }
                                             final updated = Contact(
                                               name: newName,
                                               surname: newSurname,
                                               phoneNumber: newPhone,
                                             );
                                            await contactBox.putAt(origIndex, updated);
                                            if (context.mounted) Navigator.pop(context);
                                          },
                                          child: const Text('Kaydet'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 2),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),

                              icon: Icon(
                                Icons.delete,
                                color: const Color.fromARGB(255, 66, 4, 117),
                                size: 24,
                              ),
                              onPressed: () {
                                contactBox.deleteAt(origIndex); 
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurpleAccent, Color.fromARGB(255, 66, 8, 100)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddContactScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
