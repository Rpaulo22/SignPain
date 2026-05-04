import 'package:cloud_firestore/cloud_firestore.dart';

class AccountViewModel {

  Future<String> getUserName(String userID) async { // obtain user's name from user's ID
    var db = FirebaseFirestore.instance;

    try {
      final userInfo = await db
        .collection('Users')
        .doc(userID)
        .get();
      
      if (userInfo.exists && userInfo.data() != null) {
        final data = userInfo.data() as Map<String, dynamic>;
      
        return data['name'] as String? ?? 'Utilizador';
      }
      return "Utilizador";

    } catch (e) { // could not retrieve user info
      return "Utilizador";
    }
  }
}