import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/utils/color_utility.dart';
import 'package:social_media_app/widgets/custom_text_form_field.dart';

class Posts extends StatelessWidget {
  const Posts({super.key});

  void toggleLike(DocumentSnapshot post) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final postRef = post.reference;

    List likes = post['likes'] ?? [];

    if (likes.contains(userId)) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId]),
      });
    } else {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  void showCommentSheet(BuildContext context, DocumentSnapshot post) {
    final commentController = TextEditingController();
    final comments = post['comments'] as List<dynamic>? ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Comments",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            ...comments.map(
              (c) => ListTile(
                leading: Icon(Icons.comment),
                title: Text(c['userName'] ?? 'User'),
                subtitle: Text(c['comment']),
                trailing: Text(
                  c['timestamp'] != null
                      ? DateFormat(
                          'dd MMM - h:mm a',
                        ).format((c['timestamp'] as Timestamp).toDate())
                      : '',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
            CustomTextFormField(
              label: 'Comment',
              hint: 'Write a comment..',
              controller: commentController,
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null &&
                      commentController.text.trim().isNotEmpty) {
                    await post.reference.update({
                      'comments': FieldValue.arrayUnion([
                        {
                          'userId': user.uid,
                          'userName': user.displayName ?? user.email,
                          'comment': commentController.text.trim(),
                          'timestamp': Timestamp.now(),
                        },
                      ]),
                    });
                    commentController.clear();
                    Navigator.pop(context);
                  }
                },
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: ColorUtility.primary),
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
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
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ColorUtility.primary.withOpacity(
                            0.8,
                          ),
                          child: Text(
                            post['userName'] != null &&
                                    post['userName'].toString().isNotEmpty
                                ? post['userName'][0].toUpperCase()
                                : '?',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['userName'] ?? 'Anonymous',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              post['timestamp'] != null
                                  ? DateFormat('dd MMM yyyy - h:mm a').format(
                                      (post['timestamp'] as Timestamp).toDate(),
                                    )
                                  : '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 8),
                    if (post['title'] != null)
                      Text(
                        post['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (post['description'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(post['description']),
                      ),
                    if (imageBase64 != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: image,
                      ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            (post['likes'] as List).contains(
                                  FirebaseAuth.instance.currentUser!.uid,
                                )
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 20,
                            color: Colors.blue,
                          ),
                          onPressed: () => toggleLike(post),
                        ),

                        SizedBox(width: 2),
                        Text('${(post['likes'] as List?)?.length ?? 0}'),
                        SizedBox(width: 16),
                        TextButton.icon(
                          icon: Icon(Icons.comment_outlined),
                          label: Text("Comment"),
                          onPressed: () {
                            showCommentSheet(context, post);
                          },
                        ),

                        SizedBox(width: 2),
                        Text('${(post['comments'] as List?)?.length ?? 0}'),
                      ],
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
}
