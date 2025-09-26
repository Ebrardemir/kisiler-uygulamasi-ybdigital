import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kisiler_uygulamasi/models/contact.dart';

class ContactSearchDelegate extends SearchDelegate<Contact?> {
  final Box<Contact> contactBox;

  ContactSearchDelegate(this.contactBox);

  @override
  String get searchFieldLabel => "Kişi ara...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ""),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //filtrekeeme
    final results = contactBox.values
        .where(
          (c) =>
              (c.name?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              (c.surname?.toLowerCase().contains(query.toLowerCase()) ??
                  false) ||
              (c.phoneNumber?.contains(query) ?? false),
        )
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text("Sonuç bulunamadı"));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(
              contact.name[0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text("${contact.name} ${contact.surname}"),
          subtitle: Text(contact.phoneNumber),
          onTap: () => close(context, contact),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
