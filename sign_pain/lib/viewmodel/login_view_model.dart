import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginViewModel {

  Future<void> loginUser(String userString, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userString,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Nenhum utilizador registado com e-mail fornecido.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Palavra-passe errada');
      }
    }
  }

  Future<void> createUser(String emailAddress, String phoneNumber, String password, String name) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      User? newUser = credential.user;
      if (newUser != null) {
        // saving the data from auth to firestore database
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(newUser.uid) // uses pre-established UID to bridge between auth and firestore
            .set({
          'phoneNumber': phoneNumber,
          'name': name,
          'email': emailAddress,
          'createdAt': DateTime.now()
          }
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception("A palavra-passe é demasiado fraca (mínimo 6 caracteres).");
      } else if (e.code == 'email-already-in-use') {
        throw Exception("Já existe uma conta com este e-mail.");
      } else if (e.code == 'invalid-email') {
        throw Exception("O formato do e-mail é inválido.");
      } else {
        throw Exception("Erro do Firebase: ${e.code} - ${e.message}");
      }
    } catch (e) {
      throw Exception("Erro inesperado: $e");
    }
  }
}