import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_pain/app_exception.dart';

class AccountViewModel {
  // Given a user ID, obtains the corresponding user's name in Firebase
  Future<String> getUserName(String userID) async {
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

  // Given a userString (email or phone number) and a password, attempts to login the user into the app (through Firebase)
  Future<void> loginUser(String userString, String password) async {
    // sanitize arguments
    if (userString.isEmpty) { // email or phone number must be given
      throw AppException("Por favor indique e-mail ou nº de telemóvel");
    }
    if (password.isEmpty) { // password must be given
      throw AppException("Por favor indique palavra-passe");
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: userString,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw AppException('Nenhum utilizador registado com e-mail fornecido.');
        case 'wrong-password':
          throw AppException('Palavra-passe errada.');
        case 'user-disabled':
          throw AppException('Utilizador foi invalidado.');
        case 'invalid-argument':
          throw AppException('O formato do e-mail ou nº de telemóvel ou palavra-passe são inválidos.');
        case 'invalid-email':
          throw AppException("O formato do e-mail é inválido.");
        case 'invalid-password':
          throw AppException("O formato da palavra-passe é inválido.");
        case 'invalid-phone-number':
          throw AppException('O formato do nº de telemóvel é inválido.');
        case 'invalid-credential':
          throw AppException('Nenhum utilizador encontrado ou palavra-passe incorreta.');
        default: 
          throw AppException('Erro no login (Erro do Firebase): ${e.code} - ${e.message}');
      }
    } catch (e) {
      throw AppException('Erro no login. Tente novamente mais tarde.\n(${e.toString()})');
    }
  }

  // Given a new user's information (email, phone number, password and name), attempts to create a new account and login the user (through Firebase)
  Future<void> createUser(String emailAddress, String phoneNumber, String password, String name) async {
    // sanitize arguments
    if (emailAddress.isEmpty) { // email must be given
      throw AppException("Por favor indique e-mail");
    }
    if (password.isEmpty) { // password must be given
      throw AppException("Por favor indique palavra-passe");
    }
    if (phoneNumber.isEmpty) { // phone number must be given
      throw AppException("Por favor indique nº de telemóvel");
    }
    if (name.isEmpty) { // name must be given
      throw AppException("Por favor indique o seu nome");
    }
    if (phoneNumber.length != 9 || phoneNumber[0] != '9') { // phone number must be a valid potential portuguese phone number
      throw AppException("Por favor indique um nº de telemóvel português válido");
    }

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
      switch (e.code) {
        case 'user-disabled':
          throw AppException('Utilizador foi invalidado.');
        case 'phone-number-already-exists':
          throw AppException('Nº de telemóvel já utilizado.');
        case 'weak-password':
          throw AppException("A palavra-passe é demasiado fraca (mínimo 6 caracteres).");
        case 'email-already-in-use':
          throw AppException("Já existe uma conta com este e-mail.");
        case 'invalid-email':
          throw AppException("O formato do e-mail é inválido.");
        case 'invalid-argument':
          throw AppException('E-mail ou nº de telemóvel ou palavra-passe inválidas.');
        default: 
          throw AppException("Erro do Firebase: ${e.code} - ${e.message}");
      }
    } catch (e) {
      throw AppException("Erro a criar conta. Tente novamente mais tarde - $e");
    }
  }

  // Signs out current user of the app
  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw AppException('Erro a terminar sessão. Por favor tente mais tarde - $e');
    }
  }
}