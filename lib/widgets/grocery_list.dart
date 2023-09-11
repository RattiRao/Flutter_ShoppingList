import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  void onAddButtonPressed() async {
    final newItem = await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return const NewItemScreen();
      }),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grocery List'),
        actions: [
          IconButton(
            onPressed: onAddButtonPressed,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
          itemCount: groceryItems.length,
          itemBuilder: (context, index) {
            final grocery = groceryItems[index];
            return ListTile(
              title: Text(grocery.name),
              leading: Container(
                width: 25,
                height: 25,
                color: grocery.category.color,
              ),
              trailing: Text(
                grocery.quantity.toString(),
              ),
            );
          }),
    );
  }
}
