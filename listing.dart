import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _updateQuantity(String productId, int currentQuantity, int change) async {
    int newQuantity = currentQuantity + change;
    if (newQuantity > 0) {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'quantity': newQuantity});
    }
  }

  Future<void> _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser?.displayName ?? 'My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // You should have a splash/login screen to navigate to
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellerId', isEqualTo: _currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('You have not posted any products yet.'));
          }

          return ListView(padding: const EdgeInsets.all(8), children: [
            ...snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Image.network(data['imageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(data['productName']),
                  subtitle: Text('Rs.${data['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(document.id)),
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateQuantity(document.id, data['quantity'], -1)),
                      Text('${data['quantity']}', style: const TextStyle(fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => _updateQuantity(document.id, data['quantity'], 1)),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            const Text('Most sold products', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),

          ]);
        },
      ),
    );
  }
}
