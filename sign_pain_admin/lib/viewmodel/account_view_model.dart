import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain_admin/app_exception.dart';

class AccountViewModel extends ChangeNotifier {

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? errorMessage;

  Future<void> loginAdmin(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .get();

      final isUserAdmin = userDoc.data()?['isAdmin'] == true; // if user is an admin, isAdmin == true

      if (!isUserAdmin) {
        await FirebaseAuth.instance.signOut(); // sign out non-admin user
        _isLoading = false;
        notifyListeners();
        throw AppException("Utilizador admin inválido");
      }
    }
    catch (e) {
      _isLoading = false;
      notifyListeners();
      throw AppException("Erro a entrar na plataforma admin. Tente novamente");
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw AppException('Erro a terminar sessão. Por favor tente mais tarde - $e');
    }
  }
}