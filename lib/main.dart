import 'package:flutter/material.dart';
import 'package:smart_bins_flutter/page/bins.dart';
import 'package:smart_bins_flutter/page/notification.dart';
import 'package:smart_bins_flutter/page/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'api/firebase-api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/bins': (context) => const BinScreen(),
        '/route': (context) => const RouteScreen(),
        '/notification': (context) => const NotificationScreen()
      },
      home: const MyHomePage(title: 'Smart Bins'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const BinScreen(),
    const RouteScreen(),
    const NotificationScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
                appBar: AppBar(title: const Text("Error")),
                body: Center(child: Text("${snapshot.error}")));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              body: _widgetOptions.elementAt(_selectedIndex),
              bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  iconSize: 30,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.delete),
                      label: 'Bins',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.location_on),
                      label: 'Route',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.notifications),
                      label: 'Notification ',
                    ),
                  ]),
            );
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }));
  }
}
