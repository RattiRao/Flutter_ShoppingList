import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  var _isDeleting = false;
  String? _errorMsg;

  void _loadShoppingList() async {
    setState(() {
      _errorMsg = null;
      _isLoading = true;
    });
    final url = Uri.https(
      'flutter-shopping-bbf7d-default-rtdb.firebaseio.com',
      'shopping_list.json',
    );

    try {
      final response = await http.get(url);
      //Handle error
      if (response.statusCode > 400) {
        setState(() {
          _isLoading = false;
          _errorMsg = 'Unable to fetch data. Please try again.';
          return;
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> tempList = [];

      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        final groceryItem = GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        );

        tempList.add(groceryItem);
      }

      setState(() {
        _groceryItems = tempList;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Something went wrong!. Please try again later.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  void onAddButtonPressed() async {
    final groceryItem = await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return const NewItemScreen();
      }),
    );

    if (groceryItem != null) {
      setState(() {
        _groceryItems.add(groceryItem);
      });
    }
  }

  void _removeItem(GroceryItem item) async {
    final url = Uri.https(
      'flutter-shopping-bbf7d-default-rtdb.firebaseio.com',
      'shopping_list/${item.id}.json',
    );
    final index = _groceryItems.indexWhere((element) => element.id == item.id);
    setState(() {
      _groceryItems.remove(item);
      _isDeleting = true;
    });

    final response = await http.delete(url);
    setState(() {
      _isDeleting = false;
    });
    if (response.statusCode != 200) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No items added yet.'),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (_errorMsg != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMsg!),
            const SizedBox(
              height: 18,
            ),
            ElevatedButton(
              onPressed: _loadShoppingList,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 25,
                height: 25,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
              ),
            ),
          );
        },
      );
    }
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
      body: Stack(
        children: [
          content,
          if (_isDeleting)
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
