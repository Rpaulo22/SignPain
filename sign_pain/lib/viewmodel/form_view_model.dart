import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_pain/model/pain_form_data.dart';


class FormViewModel {
  
  // function which saves pain form date in firebase (firestore)
  Future<bool> saveDailyForm(PainFormData formData) async {
    var db = FirebaseFirestore.instance;
    // TODO check if userValid()
    final formEntry = <String, dynamic>{
      "userID": formData.userID, 
      "painIntensity": formData.painLevel,
      "descriptors": formData.descriptors.toList(),
      "date": formData.date
    };

    try {
      // attempt to upload
      await db.collection("FormEntry").add(formEntry);
      
      // successful
      print("Form submitted successfully!");
      return true;
      
    } catch (e) {
      // goes wrong 
      print("Error adding document: $e");
      return false;
    }
  }

  Future<List<PainFormData>> getUserPainData(String userID) async {
    var db = FirebaseFirestore.instance;
    List<PainFormData> data = [];

    try {
      final querySnapshot = await db
          .collection("FormEntry")
          .where("userID", isEqualTo: userID)
          .get();
      // loop through results
      for (var docSnapshot in querySnapshot.docs) {
        var _data = docSnapshot.data(); 
        
        var date = (_data['date'] as Timestamp).toDate();
        var descriptors = Set<String>.from(_data['descriptors'] ?? []);
        var painLevel = _data['painIntensity'] as int;
        
        PainFormData painForm = PainFormData(userID, descriptors, painLevel, date);
        data.add(painForm);
      }
    } catch(e) {
      rethrow;
    }
    return data;
  }
}