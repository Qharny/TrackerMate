import 'package:flutter/material.dart';

class ItemsScreen extends StatelessWidget {
  ItemsScreen({super.key});

  // Sample list of items
  final List<String> _items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(_items[index]),
            subtitle: const Text('Last seen: Location XYZ'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to item details or perform an action
            },
          ),
        );
      },
    );
  }
}
