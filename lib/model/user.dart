import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final String id;
  final String nickname;
  final String email;
  final String photoUrl;

  User({
    required this.id,
    required this.nickname,
    required this.email,
    required this.photoUrl,
  });
  factory User.fromDoccument(DocumentSnapshot doc) {
    return User(
      id: doc.id,
      nickname: doc['name'],
      email: doc['email'],
      photoUrl: doc['image'],
    );
  }
}

// List<User> listUser = [
//   User(
//       id: '1',
//       nickname: 'meomoe',
//       email: 'meo1@gmail.com',
//       photoUrl:
//           'https://pdp.edu.vn/wp-content/uploads/2021/05/hinh-anh-anime-co-trang.jpg',
//       createdAt: '22/2/2021'),
//   User(
//       id: '2',
//       nickname: 'meomoe 2',
//       email: 'meo2@gmail.com',
//       photoUrl:
//           'https://pdp.edu.vn/wp-content/uploads/2021/05/hinh-anh-anime-co-trang.jpg',
//       createdAt: '22/2/2021'),
//   User(
//       id: '3',
//       nickname: 'meomoe 3',
//       email: 'meo3@gmail.com',
//       photoUrl:
//           'https://pdp.edu.vn/wp-content/uploads/2021/05/hinh-anh-anime-co-trang.jpg',
//       createdAt: '22/2/2021'),
//   User(
//       id: '4',
//       nickname: 'meomoe 4',
//       email: 'meo4@gmail.com',
//       photoUrl:
//           'https://pdp.edu.vn/wp-content/uploads/2021/05/hinh-anh-anime-co-trang.jpg',
//       createdAt: '22/2/2021'),
//   User(
//       id: '5',
//       nickname: 'meomoe 5',
//       email: 'meo5@gmail.com',
//       photoUrl:
//           'https://pdp.edu.vn/wp-content/uploads/2021/05/hinh-anh-anime-co-trang.jpg',
//       createdAt: '22/2/2021'),
// ];
