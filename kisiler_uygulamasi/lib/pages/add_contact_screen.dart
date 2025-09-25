import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/contact.dart';
import 'package:flutter/services.dart' as services;

class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Box<Contact> contactBox = Hive.box<Contact>('contacts');

    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Kişi Ekle")),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Center(
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
                      services.FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9]'),
                      ), // sadece rakam
                      services.LengthLimitingTextInputFormatter(
                        11,
                      ), // en fazla 11
                    ],
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Telefon boş olamaz";
                      if (!RegExp(r'^\d{11}$').hasMatch(val))
                        return "Telefon 11 haneli olmalı";
                      return null;
                    },
                  ),

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newContact = Contact(
                          name: nameController.text,
                          surname: surnameController.text,
                          phoneNumber: phoneController.text,
                        );
                        contactBox.add(
                          newContact,
                        ); // kutuya ekleme mecbur yaptım, düzeltilebilir
                        Navigator.pop(context); // geri dönme işlemi
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text(
                      "Kaydet",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
