import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/utils/app_exception.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';


class FormViewModel extends ChangeNotifier {

  List<PainFormData> _painRecords = [];
  List<PainFormData> get painRecords => _painRecords;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Given a pain form entry (and the user currently logged in), saves it to firebase
  Future<bool> savePainForm(PainFormData formData) async {

    var db = FirebaseFirestore.instance;
    
    String frequency = painFrequencyToString(formData.frequency);
    
    final formEntry = <String, dynamic>{
      "userID": formData.userID, 
      "painIntensity": formData.painLevel,
      "descriptors": formData.descriptors.toList(),
      "bodyParts": formData.bodyParts,
      "date": formData.date,
      "frequency": frequency
    };

    final userEntries = db
      .collection('Users')
      .doc(formData.userID)
      .collection('userEntries'); // form entries subcollection

    try {
      // attempt to upload
      await userEntries.add(formEntry);

      return true;
      
    } catch (e) {
      return false;
    }
  }

  Future<void> getUserPainData(String userID) async {
    _isLoading = true;
    notifyListeners();

    var db = FirebaseFirestore.instance;
    List<PainFormData> data = [];

    try {
      final userEntries = await db
          .collection("Users")
          .doc(userID)
          .collection('userEntries')
          .orderBy('date', descending: true)
          .get();

      // loop through results
      for (var entry in userEntries.docs) {
        var _data = entry.data();
        
        var id = entry.id;
        var date = (_data['date'] as Timestamp).toDate();
        DateTime? updatedDate = (_data['updatedDate'] as Timestamp?)?.toDate();
        var descriptors = Set<String>.from(_data['descriptors'] ?? []);
        var painLevel = _data['painIntensity'] as int;
        var bodyParts = List<String>.from(_data['bodyParts'] ?? []);
        var frequencyString = _data['frequency'];

        PainFrequency frequency = PainFrequency.none;

        if (frequencyString != null) {
          frequencyString = frequencyString as String;
          switch (frequencyString) {
            case "continuous": 
              frequency = PainFrequency.continuous;
              break;
            case "intermittent": 
              frequency = PainFrequency.intermittent;
              break;
            case "spontaneous": 
              frequency = PainFrequency.spontaneous;
              break;
            case "none": default:
          }
        }

        PainFormData painForm = PainFormData.fromForm(userID, descriptors, painLevel, date, bodyParts, frequency, id, updatedDate);
        data.add(painForm);
      }
    _painRecords = data;

    } catch(e) {
      rethrow;
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePainForm(String entryID) async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    if (userID == null) return;

    final index = painRecords.indexWhere((entry) => entry.docID == entryID);
    final entryBackup = painRecords[index];

    // OPTIMISTIC UPDATE: Remove it from the local list instantly
    painRecords.removeAt(index);
    notifyListeners();

    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(userID)
        .collection('userEntries')
        .doc(entryID)
        .delete();
    } catch (e) {
      // If Firebase fails (e.g., no internet), put it back and show an error
      painRecords.insert(index, entryBackup);
      notifyListeners();
      throw AppException("Erro ao apagar o registo. Verifique a sua ligação.");
    } 
  }

  Future<void> updatePainForm(PainFormData formData) async {
    var db = FirebaseFirestore.instance;

    String frequency = painFrequencyToString(formData.frequency);
    
    final formEntry = <String, dynamic>{
      "userID": formData.userID, 
      "painIntensity": formData.painLevel,
      "descriptors": formData.descriptors.toList(),
      "bodyParts": formData.bodyParts,
      "date": formData.date,
      "updatedDate": DateTime.now(),
      "frequency": frequency
    };

    try {
      final userEntries = db
        .collection('Users')
        .doc(formData.userID)
        .collection('userEntries'); // form entries subcollection

      await userEntries.doc(formData.docID).update(formEntry);
    }
    catch (e) {
      throw AppException("Erro a editar formulário. Tente novamente");
    }
  }
}