import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => 'Search by title or user name';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final allPosts = snapshot.data!.docs.where((doc) {
          final title = doc['title']?.toString().toLowerCase() ?? '';
          final userName = doc['userName']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) ||
              userName.contains(query.toLowerCase());
        }).toList();

        if (allPosts.isEmpty) {
          return Center(child: Text("No results found."));
        }

        return ListView.builder(
          itemCount: allPosts.length,
          itemBuilder: (context, index) {
            final post = allPosts[index];
            final imageBase64 = post['imageUrl'];
            final image = (imageBase64 != null && imageBase64 != "")
                ? Image.memory(
                    base64Decode(imageBase64),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : SizedBox.shrink();

            return Card(
              margin: EdgeInsets.all(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'] ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      post['userName'] ?? '',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    if (post['description'] != null) Text(post['description']),
                    SizedBox(height: 8),
                    if (imageBase64 != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: image,
                      ),
                    SizedBox(height: 8),
                    Text(
                      post['timestamp'] != null
                          ? DateFormat(
                              'dd MMM yyyy - h:mm a',
                            ).format((post['timestamp'] as Timestamp).toDate())
                          : '',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
