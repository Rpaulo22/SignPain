import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:sign_pain/model/medical_condition_data.dart';
import 'package:sign_pain/utils/app_exception.dart';

class ConditionsViewModel extends ChangeNotifier{
  List<MedicalConditionData> _medicalConditions = [];
  List<MedicalConditionData> get medicalConditions => _medicalConditions;

  List<String> _userMedicalConditions = [];
  List<String> get userMedicalConditions => _userMedicalConditions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;

  Future<void> getMedicalConditionsInfo(String userID) async {
    if (_isLoading || _hasFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      await getMedicalConditions();
      await getUserMedicalData(userID);
      _hasFetched = true;
    } 
    catch (_) {
      rethrow;
    } 
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMedicalConditions() async {
    var db = FirebaseFirestore.instance;
    List<MedicalConditionData> data = [];

    try {
      final querySnapshot = await db
          .collection("MedicalConditions")
          .get();
      // loop through results
      for (var docSnapshot in querySnapshot.docs) {
        var _data = docSnapshot.data(); 
        
        var id = _data['id'] as String;
        var nameMap = _data['name'] as Map<String, dynamic>;
        var descriptionMap = _data['description'] as Map<String, dynamic>;
        var causesMap = _data['causes'] as Map<String, dynamic>;
        var treatmentMap = _data['treatment'] as Map<String, dynamic>;
        var descriptorsMap = _data['painDescriptors'] as Map<String, dynamic>;
        var bodyPartsAffected = List<String>.from(_data['bodyPartsAffected'] ?? []) ;
        var side = _data['side'] as String;

        var name = nameMap['text'] as String;
        var description = descriptionMap['text'] as String;
        var causes = List<String>.from(causesMap['text'] ?? []);
        var treatment = treatmentMap['text'] as String;
        var commonDescriptors = List<String>.from(descriptorsMap['common'] ?? []);
        var uncommonDescriptors = List<String>.from(descriptorsMap['uncommon'] ?? []);

        MedicalConditionData medData = MedicalConditionData(id, name, description, causes, commonDescriptors, uncommonDescriptors, treatment, bodyPartsAffected, side);
        data.add(medData);
      }
    } catch(e) {
      throw AppException("Erro a carregar informação médica. Por favor tente novamente mais tarde");
    }

    _medicalConditions = data;
  }

  Future<void> getUserMedicalData(String userID) async {
    var db = FirebaseFirestore.instance;

    try {
      final userSnapshot = await db
          .collection("Users")
          .doc(userID)
          .get();

      var data = userSnapshot.data(); 

      _userMedicalConditions = List<String>.from(data?['medicalConditions'] ?? []);
    } catch(e) {
      throw AppException("Erro a carregar informação médica. Por favor tente novamente mais tarde");
    }
  }

  Future<void> addCondition(String condition) async {
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) return;

    // OPTIMISTIC UPDATE: Add it to the local list instantly
    userMedicalConditions.add(condition);
    notifyListeners();
    
    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .set({'medicalConditions': userMedicalConditions}, SetOptions(merge: true)); // updates the users info correctly even if it does not have the list
    } catch (e) {
      // If Firebase fails (e.g., no internet), take it back and notify UI
      userMedicalConditions.removeWhere((entry) => entry == condition);
      notifyListeners();
      throw AppException("Erro ao adicionar condição médica. Verifique a sua ligação.");
    } 
  }

  Future<void> removeCondition(String condition) async {
    String? userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) return;

    // OPTIMISTIC UPDATE: Remove it from the local list instantly
    userMedicalConditions.remove(condition);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .set({'medicalConditions': userMedicalConditions}, SetOptions(merge: true)); // updates the users info correctly even if it does not have the list
    } catch (e) {
      // If Firebase fails (e.g., no internet), put it back and show an error
      userMedicalConditions.add(condition);
      notifyListeners();
      throw AppException("Erro ao remover condição médica. Verifique a sua ligação.");
    } 
  }
}