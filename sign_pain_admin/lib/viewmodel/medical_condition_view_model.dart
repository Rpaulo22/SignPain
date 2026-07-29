import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_pain_admin/utils/app_exception.dart';
import 'package:sign_pain_admin/model/medical_condition_data.dart';

class MedicalConditionViewModel extends ChangeNotifier {
  List<MedicalConditionData> _medicalConditions = [];
  List<MedicalConditionData> get medicalConditions => _medicalConditions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;

  Future<void> getMedicalConditions() async {
    if (_isLoading || _hasFetched) return;

    _isLoading = true;
    notifyListeners();

    var db = FirebaseFirestore.instance;
    List<MedicalConditionData> data = [];

    try {
      final querySnapshot = await db
          .collection("MedicalConditions")
          .get();
      // loop through results
      for (var docSnapshot in querySnapshot.docs) {
        var _data = docSnapshot.data(); 

        var id = docSnapshot.id;
        var nameMap = _data['name'] as Map<String, dynamic>;
        var descriptionMap = _data['description'] as Map<String, dynamic>;
        var causesMap = _data['causes'] as Map<String, dynamic>;
        var treatmentMap = _data['treatment'] as Map<String, dynamic>;
        var descriptorsMap = _data['painDescriptors'] as Map<String, dynamic>;
        var bodyPartsAffected = List<String>.from(_data['bodyPartsAffected'] ?? []);

        var name = nameMap['text'] as String;
        var description = descriptionMap['text'] as String;
        var causes = causesMap['text'] as String;
        var treatment = treatmentMap['text'] as String;
        var commonDescriptors = List<String>.from(descriptorsMap['common'] ?? []);
        var uncommonDescriptors = List<String>.from(descriptorsMap['uncommon'] ?? []);

        MedicalConditionData medData = MedicalConditionData(id, name, description, causes, commonDescriptors, uncommonDescriptors, treatment, bodyPartsAffected);
        data.add(medData);
      }
      _medicalConditions = data;
      _hasFetched = true;
    } 
    catch (_) {
      throw AppException("Erro a aceder base de dados\nTente novamente mais tarde");
    } 
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // given the parameters, creates a new medical condition in the database
  // TODO also include the upload of the LGP videos
  Future<void> createNewMedicalCondition(
    String name, 
    String description, 
    String causes, 
    List<String> commonDescriptors, 
    List<String> uncommonDescriptors, 
    String treatment,
    List<String> bodyParts) async {
    _isLoading = true;
    notifyListeners();

    var db = FirebaseFirestore.instance;

    // pre processing and checks
    name = name.trim();
    description = description.trim();

    if (name.isEmpty || description.isEmpty || causes.isEmpty || commonDescriptors.isEmpty || uncommonDescriptors.isEmpty || treatment.isEmpty || bodyParts.isEmpty) { // parameters are not given
      _isLoading = false;
      notifyListeners();
      throw AppException("Todos os campos têm de ser preenchidos para guardar na base de dados.");
    } 
    if (medicalConditions.any((element) => element.name.toUpperCase() == name.toUpperCase())) { // condition already exists
      _isLoading = false;
      notifyListeners();
      throw AppException("Esta condição já existe no sistema");
    }

    final map = {
      "name": { 
        "text" : name,
        "videoURL": "www.example.com"
      },
      "description": {
        "text": description,
        "videoURL": "www.example.com"
      },
      "causes": {
        "text": causes,
        "videoURL": "www.example.com"
      },
      "painDescriptors": {
        "common": commonDescriptors,
        "uncommon": uncommonDescriptors
      },
      "treatment": {
        "text": treatment,
        "videoURL": "www.example.com"
      },
      "bodyPartsAffected": bodyParts
    };

    try {
      final doc = await db.collection("MedicalConditions").add(map); // add to firestore

      final data = MedicalConditionData(doc.id, name, description, causes, commonDescriptors, uncommonDescriptors, treatment, bodyParts);

      medicalConditions.add(data); // add to local list
    }
    catch (e) {
      throw AppException("Erro a guardar condição. Tente novamente\n${e.toString()}");
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }


}