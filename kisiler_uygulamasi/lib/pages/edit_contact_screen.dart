import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';

class EditContactScreen extends StatefulWidget {
  final int index; // düzenlenecek kaydın indexi

  const EditContactScreen({super.key, required this.index});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<Contact>('contacts');
    final contact = box.getAt(widget.index);

    nameController = TextEditingController(text: contact?.name ?? '');
    surnameController = TextEditingController(text: contact?.surname ?? '');
    phoneController = TextEditingController(text: contact?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Box<Contact> contactBox = Hive.box<Contact>('contacts');

    return Scaffold(
      appBar: AppBar(title: const Text("Kişiyi Düzenle")),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Ad"),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Ad boş olamaz" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: surnameController,
                  decoration: const InputDecoration(labelText: "Soyad"),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Telefon"),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    services.FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    services.LengthLimitingTextInputFormatter(11),
                  ],
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Telefon boş olamaz";
                    }
                    if (!RegExp(r'^\d{11}$').hasMatch(val)) {
                      return "Telefon 11 haneli olmalı";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final updated = Contact(
                        name: nameController.text.trim(),
                        surname: surnameController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                      );
                      contactBox.putAt(widget.index, updated); //güncelleme işkemi
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text(
                    "Güncelle",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
