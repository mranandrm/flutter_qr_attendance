import 'package:flutter/material.dart';
import 'package:carousel_images/carousel_images.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../services/Auth.dart';
import 'ScannerScreen.dart';
import 'auth/LoginScreen.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<String> listImages = [
    'assets/carousel/q1.jpeg',
    'assets/carousel/q2.jpeg',
    'assets/carousel/q3.jpeg',
  ];

  final storage = new FlutterSecureStorage();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    readToken();
  }

  void readToken() async {
    dynamic token = await this.storage.read(key: 'token');

    if (token != null) {
      String tokenString = token as String;
      Provider.of<Auth>(context, listen: false).tryToken(token: tokenString);
      print("read token");
      print(tokenString);
    } else {
      print("Token is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Home'),
            Tab(text: 'QR Scanner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Home Tab
          CarouselImages(
            scaleFactor: 0.6,
            listImages: listImages,
            height: 300.0,
            borderRadius: 30.0,
            cachedNetworkImage: true,
            verticalAlignment: Alignment.topCenter,
            onTap: (index) {
              print('Tapped on page $index');
            },
          ),
          // QR Scanner Tab
          ScannerScreen(title: 'QR Scanner'),
        ],
      ),
      drawer: Drawer(
        child: Consumer<Auth>(
          builder: (context, auth, child) {
            if (!auth.authenticated) {
              return ListView(
                children: [
                  ListTile(
                    title: Text('Login'),
                    leading: Icon(Icons.login),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen(title: 'Login Screen')),
                      );
                    },
                  ),
                ],
              );
            } else {
              String avatar = auth.user?.avatar as String;
              String name = auth.user?.name as String;
              String email = auth.user?.email as String;

              return ListView(
                children: [
                  DrawerHeader(
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                          radius: 30,
                        ),
                        SizedBox(height: 10,),
                        Text(
                          name,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10,),
                        Text(
                          email,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    title: Text('Logout'),
                    leading: Icon(Icons.logout),
                    onTap: () {
                      Provider.of<Auth>(context, listen: false).logout();
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}