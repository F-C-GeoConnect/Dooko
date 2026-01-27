import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled1/login.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({super.key});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  final _supabase = Supabase.instance.client;
  late final Stream<List<Map<String, dynamic>>> _productsStream;

  // REMOVED _currentUser from here to prevent it from being stale.

  @override
  void initState() {
    super.initState();
    // Get the current user within initState to ensure it's up-to-date.
    final currentUser = _supabase.auth.currentUser;
    _productsStream = _supabase
        .from('products')
        .stream(primaryKey: ['id']) // The primary key of your table
        .eq('sellerID', currentUser?.id ?? '') // Use the fresh user ID here.
        .order('created_at', ascending: false); // Show newest products first
  }

  Future<void> _updateQuantity(int productId, int currentQuantity, int change) async {
    int newQuantity = currentQuantity + change;
    if (newQuantity > 0) {
      await _supabase
          .from('products')
          .update({'quantity': newQuantity})
          .eq('id', productId);
      // No need to call setState, the stream will handle the update
    }
  }

  Future<void> _deleteProduct(int productId) async {
    await _supabase.from('products').delete().eq('id', productId);
    // No need to call setState, the stream will handle the update
  }

  @override
  Widget build(BuildContext context) {
    // Also get the fresh user object here for UI elements like the AppBar.
    final currentUser = _supabase.auth.currentUser;
    final sellerName = currentUser?.userMetadata?['full_name'] as String? ?? 'My Listings';

    return Scaffold(
      appBar: AppBar(
        title: Text(sellerName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
              // Navigate to the login screen after signing out
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      // Use a StreamBuilder to listen for real-time changes
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }
          final products = snapshot.data ?? []; // Use an empty list if data is null
          if (products.isEmpty) {
            return const Center(
                child: Text('You have not posted any products yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: product['imageUrl'] != null
                      ? Image.network(product['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : const SizedBox(width: 50, height: 50, child: Icon(Icons.image_not_supported)),
                  title: Text(product['productName'] ?? 'No Name'),
                  subtitle: Text('Rs.${product['price'] ?? 0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(product['id'])),
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => _updateQuantity(product['id'], product['quantity'], -1)),
                      Text('${product['quantity']}', style: const TextStyle(fontSize: 16)),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => _updateQuantity(product['id'], product['quantity'], 1)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
