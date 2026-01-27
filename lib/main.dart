import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:untitled1/add.dart';
import 'package:untitled1/homepage.dart';
import 'package:untitled1/listing.dart';
import 'package:untitled1/login.dart';
import 'package:untitled1/map.dart';
import 'package:untitled1/profile.dart';
import 'package:untitled1/sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // URL and Anon Key should be replaced with your actual Supabase credentials
  await Supabase.initialize(
    url: ' https://www.pornhub.com/ ',
    // IMPORTANT: Please verify this key from your Supabase dashboard
    anonKey: 'vai yesh ma key halna parch github policy ale share garna milne  ',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DOOKO App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A9141),
        ),
        useMaterial3: true,
      ),
      // Set the AuthGate as the home screen
      home: const AuthGate(),
    );
  }
}

// This widget acts as a gate, showing the correct page based on auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // While waiting for the auth state, show a loading indicator.
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          // If there is a valid session, the user is logged in.
          return const MainPage();
        } else {
          // If there is no session, the user is not logged in.
          return const LoginScreen();
        }
      },
    );
  }
}

/* ===================== MAIN PAGE ===================== */

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(title: 'Home'),
    ListingPage(),
    AddPage(),
    MapPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Listing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
