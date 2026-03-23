import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_pain/model/medical_condition_data.dart';

class ConditionsViewModel {
  Future<List<MedicalConditionData>> getMedicalConditions() async{
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

        var name = nameMap['text'] as String;
        var description = descriptionMap['text'] as String;
        var causes = List<String>.from(causesMap['text'] ?? []);
        var treatment = treatmentMap['text'] as String;
        var commonDescriptors = List<String>.from(descriptorsMap['common'] ?? []);
        var uncommonDescriptors = List<String>.from(descriptorsMap['uncommon'] ?? []);

        MedicalConditionData medData = MedicalConditionData(id, name, description, causes, commonDescriptors, uncommonDescriptors, treatment, bodyPartsAffected);
        data.add(medData);
      }
    } catch(e) {
      rethrow;
    }

    return data;
  }
}