
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// MAIN APPLICATION
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firestore Update',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// HOME PAGE
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore Update Application'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: 'Products'),
              Tab(icon: Icon(Icons.book), text: 'Books'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductPage(),
            BookPage(),
          ],
        ),
      ),
    );
  }
}

// QUESTION 1: PRODUCT UPDATE
class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();

  DocumentReference? productRef;
  String message = '';
  bool found = false;

  Future<void> searchProduct() async {
    String name = nameController.text.trim();

    if (name.isEmpty) {
      setState(() => message = 'Please enter product name');
      return;
    }

    try {
      var result = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        setState(() {
          productRef = null;
          found = false;
          quantityController.clear();
          priceController.clear();
          message = 'Product not found';
        });
        return;
      }

      var doc = result.docs.first;
      var data = doc.data();

      setState(() {
        productRef = doc.reference;
        found = true;
        nameController.text = data['name'].toString();
        quantityController.text = data['quantity'].toString();
        priceController.text = data['price'].toString();
        message = 'Product found successfully!';
      });
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  Future<void> updateProduct() async {
    if (productRef == null) {
      setState(() => message = 'Please search product first');
      return;
    }

    num? quantity = num.tryParse(quantityController.text);
    num? price = num.tryParse(priceController.text);

    if (quantity == null || price == null ||
        quantity < 0 || price < 0) {
      setState(() => message = 'Enter valid quantity and price');
      return;
    }

    try {
      await productRef!.update({
        'quantity': quantity,
        'price': price,
      });

      setState(() {
        message = 'Product updated successfully!';
      });
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            'Update Product Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Enter Product Name',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: searchProduct,
            child: const Text('Search'),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'New Quantity',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'New Price',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: updateProduct,
            child: const Text('Update'),
          ),

          const SizedBox(height: 20),

          Text(
            message,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (found) ...[
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Name: ${nameController.text}'),
                    Text('Quantity: ${quantityController.text}'),
                    Text('Price: ₹${priceController.text}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// QUESTION 2: BOOK UPDATE
class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final titleController = TextEditingController();
  final copiesController = TextEditingController();

  DocumentReference? bookRef;
  String author = '';
  String message = '';
  bool found = false;

  Future<void> searchBook() async {
    String title = titleController.text.trim();

    if (title.isEmpty) {
      setState(() => message = 'Please enter book title');
      return;
    }

    try {
      var result = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        setState(() {
          bookRef = null;
          found = false;
          author = '';
          copiesController.clear();
          message = 'Book not found';
        });
        return;
      }

      var doc = result.docs.first;
      var data = doc.data();

      setState(() {
        bookRef = doc.reference;
        found = true;
        titleController.text = data['title'].toString();
        author = data['author'].toString();
        copiesController.text = data['copies'].toString();
        message = 'Book found successfully!';
      });
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  Future<void> updateBook() async {
    if (bookRef == null) {
      setState(() => message = 'Please search book first');
      return;
    }

    int? copies = int.tryParse(copiesController.text);

    if (copies == null || copies < 0) {
      setState(() => message = 'Enter valid number of copies');
      return;
    }

    try {
      await bookRef!.update({
        'copies': copies,
      });

      setState(() {
        message = 'Book copies updated successfully!';
      });
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    copiesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            'Update Book Copies',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Enter Book Title',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: searchBook,
            child: const Text('Search'),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: copiesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Updated Number of Copies',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: updateBook,
            child: const Text('Update'),
          ),

          const SizedBox(height: 20),

          Text(
            message,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (found) ...[
            const SizedBox(height: 15),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Title: ${titleController.text}'),
                    Text('Author: $author'),
                    Text('Copies Available: ${copiesController.text}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
