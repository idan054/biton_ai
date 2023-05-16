// import 'package:biton_ai/common/models/post/woo_post_model.dart';
// import 'package:flutter/material.dart';
// import '../../common/constants.dart';
// import '../../common/services/wooApi.dart';
//
// class WooPostsScreen extends StatefulWidget {
//   final int userId; // 1
//
//   const WooPostsScreen({Key? key, required this.userId}) : super(key: key);
//
//   @override
//   _WooPostsScreenState createState() => _WooPostsScreenState();
// }
//
// class _WooPostsScreenState extends State<WooPostsScreen> {
//   List<WooPostModel> _posts = [];
//   final _titleController = TextEditingController();
//   final _contentController = TextEditingController();
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _getPosts();
//   }
//
//   void _getPosts() async {
//     var posts = await WooApi.getPosts(userId: '${widget.userId}');
//     print('posts ${posts.length}');
//     _posts = posts;
//     setState(() {});
//   }
//
//   void _onSave(userId) async {
//     var postData = WooPostModel(
//       title: "my title",
//       content: "my content",
//       author: debugUid,
//       categories: [28],
//       id: 99,
//     );
//     final post = await WooApi.createPost(postData);
//     // Navigator.of(context).pop(post);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('New Post')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: ListView(
//           // crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: InputDecoration(hintText: 'Title'),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               controller: _contentController,
//               decoration: InputDecoration(hintText: 'Content'),
//               maxLines: null,
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _onSave(widget.userId),
//               child: Text('Save'),
//             ),
//             Text('${_posts.length}'),
//             ListView.builder(
//               shrinkWrap: true,
//               itemCount: _posts.length,
//               itemBuilder: (context, index) {
//                 final post = _posts[index];
//                 return ListTile(
//                   title: Text('title: ${post.title}'),
//                   // subtitle: Text(post.content),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
