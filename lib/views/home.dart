import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/services/prefrences_services.dart';
import 'package:social_media_app/utils/color_utility.dart';
import 'package:social_media_app/views/posts.dart';
import 'package:social_media_app/views/profile.dart';
import 'package:social_media_app/widgets/custom_search_delegate.dart';
import 'package:social_media_app/widgets/custom_text_form_field.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isTabbed = false;

  int _selectedIndex = 0;

  String? name;
  String? email;

  final List<Widget> _pages = [Posts(), Profile()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void showAddPostSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? imageBase64;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await File(pickedFile.path).readAsBytes();
        imageBase64 = base64Encode(bytes);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              label: 'Post Title',
              hint: 'Enter Post Title',
              controller: titleController,
            ),
            CustomTextFormField(
              label: 'Description Title',
              hint: 'Enter Post Description',
              controller: descriptionController,
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: ColorUtility.hoverText),
              label: Text(
                'Add Image',
                style: TextStyle(color: ColorUtility.hoverText),
              ),
              onPressed: pickImage,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorUtility.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text('Add Post'),
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final userId = user.uid;
                      final userName =
                          user.displayName ?? user.email ?? "Unknown";

                      await FirebaseFirestore.instance.collection('posts').add({
                        'userId': userId,
                        'userName': userName,
                        'title': titleController.text,
                        'description': descriptionController.text,
                        'imageUrl': imageBase64 ?? "",
                        'timestamp': Timestamp.now(),
                        'likes': [],
                        'comments': [],
                      });

                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadUserData() async {
    setState(() {
      name = PreferencesServices.prefs?.getString('name') ?? '';
      email = PreferencesServices.prefs?.getString('email') ?? '';
    });
  }

  @override
  void initState() {
    loadUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorUtility.primary,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text('Home', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: PostSearchDelegate());
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    children: [
                      Text(
                        'Welcom, ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$name',
                        style: TextStyle(
                          color: ColorUtility.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  hoverColor: ColorUtility.hoverText,
                  onTap: () {
                    setState(() {
                      isTabbed = !isTabbed;
                    });
                    Navigator.pushNamed(context, '/profile');
                  },
                  leading: Icon(
                    Icons.person,
                    color: isTabbed ? ColorUtility.primary : Colors.grey,
                  ),
                  title: Text("Profile"),
                ),
                SizedBox(height: 10),
                ListTile(
                  hoverColor: Colors.indigo[100],
                  onTap: () {
                    setState(() {
                      isTabbed = !isTabbed;
                    });
                    Navigator.pushNamed(context, '/login');
                  },
                  leading: Icon(
                    Icons.logout,
                    color: isTabbed ? Colors.red : Colors.grey,
                  ),
                  title: Text("Logout"),
                ),
              ],
            ),
          ),
        ),

        body: _pages[_selectedIndex],
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          onPressed: () => showAddPostSheet(context),
          backgroundColor: ColorUtility.primary,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => _onItemTapped(0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list,
                      color: _selectedIndex == 0
                          ? ColorUtility.primary
                          : Colors.grey,
                    ),
                    Text(
                      'Posts',
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? ColorUtility.primary
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 48),
              GestureDetector(
                onTap: () => _onItemTapped(1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: _selectedIndex == 1
                          ? ColorUtility.primary
                          : Colors.grey,
                    ),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? ColorUtility.primary
                            : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
