import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getUserByEmail(String email) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('user_mail', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      return null;
    }
  }

  Future<void> addFriend(String userId, String friendId) async {
    // Prevent adding oneself
    if (userId == friendId) {
      throw Exception("You cannot add yourself as a friend.");
    }

    await _firestore.collection('users').doc(userId).update({
      'friends': FieldValue.arrayUnion([friendId])
    });

    await _firestore.collection('users').doc(friendId).update({
      'friends': FieldValue.arrayUnion([userId])
    });
  }

  Future<List<DocumentSnapshot>> getFriendsData(List<dynamic> friendIds) async {
    if (friendIds.isEmpty) return [];

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendIds)
        .get();

    return snapshot.docs;
  }

  Future<void> initializeUser(String uid, String email, String nickname) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'nickname': nickname,
      'hydration': {
        'cups': 0,
        'streak': 0,
        'lastHydration': Timestamp.now(),
      },
      'friends': [],
    });
  }
}
