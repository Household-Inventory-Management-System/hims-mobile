import 'package:firebase_database/firebase_database.dart';

class FirebaseDataService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    await _dbRef.child('users/$userId').set(data);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final snapshot = await _dbRef.child('users/$userId').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await _dbRef.child('users/$userId').update(data);
  }

  Future<void> deleteUserData(String userId) async {
    await _dbRef.child('users/$userId').remove();
  }
}
