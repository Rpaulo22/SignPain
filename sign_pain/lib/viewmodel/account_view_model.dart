import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain/utils/app_exception.dart';

class AccountViewModel extends ChangeNotifier{
  
  var isSmsCodeSent = false; // switch for the ui to react to the sms verification
  var requestPassword = false; // switch for the ui to react to email/password login
  String? verificationID; // verification code for the sms verification
  String? errorMessage;
  bool isLoading = false;

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

  // Given a string, determines whether user is trying to login using email or phone number, and verifies validity of request
  Future<void> verifyUserString(String userString) async {
    isLoading = true;
    notifyListeners();
    userString = userString.trim();

    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );

    final RegExp numericRegExp = RegExp(r'^[0-9]+$');
  
    if (emailRegExp.hasMatch(userString)) { // is email
      isLoading = false;
      requestPassword = true;
      notifyListeners();
      return;
    }
    else if (numericRegExp.hasMatch(userString)) { // is phone number
      if (userString[0] == '9' || userString.length == 9) { // not a valid portuguese phone number
        loginUserWithPhoneAuth(userString); // try verification of phone number
        return;
      }
    }
    isLoading = false;
    notifyListeners();
    throw AppException("E-mail ou nº de telemóvel inválido");
  }

  // Given an email and a password, attempts to login the user into the app (through Firebase)
  Future<void> loginUser(String emailAdress, String password) async {
    // allows the app to display loading circle
    isLoading = true;
    notifyListeners();

    // sanitize arguments
    if (emailAdress.isEmpty) { // email must be given
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique e-mail");
    }
    if (password.isEmpty) { // password must be given
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique palavra-passe");
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAdress,
        password: password
      );

      // lets screen know that loading is done
      isLoading = false;
      notifyListeners();

    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
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
        case 'network-request-failed':
          throw AppException('Erro de rede. Verifique o seu acesso à internet.');
        default: 
          throw AppException('Erro no login (Erro do Firebase): ${e.code} - ${e.message}');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw AppException('Erro no login. Tente novamente mais tarde.\n(${e.toString()})');
    }
  }

  // Given a new user's information (email, phone number, password and name), attempts to create a new account
  // and asks for verification of phone number. If it is verified, it then logs in user
  Future<void> createUser(String emailAddress, String phoneNumber, String password, String name) async {
    var hasNumber = true;

    // allows the app to display loading circle
    isLoading = true;
    notifyListeners();

    // sanitize arguments
    if (emailAddress.isEmpty) { // email must be given
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique e-mail");
    }
    if (name.isEmpty) { // name must be given
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique o seu nome");
    }
    if (phoneNumber.isNotEmpty && (phoneNumber.length != 9 || phoneNumber[0] != '9')) { // phone number must be a valid potential portuguese phone number
      isLoading = false;
      notifyListeners();
      throw AppException("Por favor indique um nº de telemóvel português válido");
    }
    if (phoneNumber.isEmpty) { // phone number is optional
      isLoading = false;
      notifyListeners();
      hasNumber = false;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      User? newUser = credential.user;

      Map<String,dynamic> userMap = {
        'name': name,
        'email': emailAddress,
        'createdAt': DateTime.now(),
        'phoneVerified': false
      };

      if (hasNumber) userMap['phoneNumber'] = phoneNumber; 

      if (newUser != null) {
        // saving the data from auth to firestore database
        await FirebaseFirestore.instance
          .collection('Users')
          .doc(newUser.uid) // uses pre-established UID to bridge between auth and firestore
          .set(userMap);
      }

      if (hasNumber) { // if the user inserted their phone number, verify it and link it to account
        String fullNumber = "+351$phoneNumber";

        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: fullNumber,
          verificationCompleted: (PhoneAuthCredential cred) async {
            // Auto-resolution (Android only)
            await credential.user!.linkWithCredential(cred);
            isLoading = false;
            notifyListeners();
          },
          verificationFailed: (e) {
            errorMessage = 'Erro no SMS: ${e.message}';
            isLoading = false;
            notifyListeners();
          },
          codeSent: (String verificationId, int? resendToken) {
            verificationID = verificationId; 
            
            isSmsCodeSent = true;

            isLoading = false;
            notifyListeners();
          },
          codeAutoRetrievalTimeout: (id) => verificationID = id,
        );
      }
      else {
        isLoading = false;
        notifyListeners();
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
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
        case 'network-request-failed':
          throw AppException('Erro de rede. Verifique o seu acesso à internet.');
        default: 
          throw AppException("Erro do Firebase: ${e.code} - ${e.message}");
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
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

  // Given an SMS transmitted 6-digit code, verifies if phone number is valid
  Future<void> verifySMSCode(String smsCode) async {
    isLoading = true;
    notifyListeners();

    if (verificationID == null) {
      isLoading = false;
      notifyListeners();
      throw AppException('ID nulo.');
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      isLoading = false;
      notifyListeners();
      throw AppException('Erro crítico: Utilizador não criado.');
    }
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID!,
        smsCode: smsCode,
      );

      // link the account with the previously given number
      await currentUser.linkWithCredential(credential);

      // update firebase to let it know that phone has been verified
      await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
        'phoneVerified': true,
      });

      isLoading = false;
      isSmsCodeSent = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      throw AppException('Código incorreto ou expirado, ${e.toString()}');
    }
  }

  // Given a phone number, attemps to login through SMS authentication
  Future<void> loginUserWithPhoneAuth(String phoneNumber) async {
    isLoading = true;
    notifyListeners();

    String fullNumber = "+351$phoneNumber";

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-login (Android only)
        await FirebaseAuth.instance.signInWithCredential(credential);

        isLoading = false;
        notifyListeners();
      },
      verificationFailed: (e) {
        errorMessage = 'Erro no SMS: ${e.message}';
        isLoading = false;
        notifyListeners();
      },
      codeSent: (String verificationId, int? resendToken) {
        verificationID = verificationId;
        isSmsCodeSent = true;
        isLoading = false;
        notifyListeners(); 
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationID = verificationId;
      },
    );
  }

  // Given an SMS 6-digit verification code, verifies user and attempts to login
  Future<void> verifySMSAndLogin(String smsCode) async {
    isLoading = true;
    notifyListeners();

    if (verificationID == null) { 
      isLoading = false;
      notifyListeners();
      throw AppException('ID de verificação nulo.');
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID!,
        smsCode: smsCode.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      isSmsCodeSent = false;
      isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        isLoading = false;
        notifyListeners();
        throw AppException('Código inserido está incorreto.');
      } else if (e.code == 'user-not-found' || e.code == 'user-disabled') {
        isLoading = false;
        notifyListeners();
        throw AppException('Conta não existe ou foi desativada.');
      }
      isLoading = false;
      notifyListeners();
      throw AppException('Erro no login: ${e.message}');
    }
  }
}