import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_pain/model/pain_form_data.dart';
import 'package:sign_pain/widgets/pain_frequency.dart';


class FormViewModel {
  
  // Given a pain form entry (and the user currently logged in), saves it to firebase
  Future<bool> saveDailyForm(PainFormData formData) async {

    var db = FirebaseFirestore.instance;
    
    String frequency = painFrequencyToString(formData.frequency);
    
    final formEntry = <String, dynamic>{
      "userID": formData.userID, 
      "painIntensity": formData.painLevel,
      "descriptors": formData.descriptors.toList(),
      "bodyParts": formData.bodyParts,
      "date": DateTime.now(),
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

  Future<List<PainFormData>> getUserPainData(String userID) async {
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
        
        var date = (_data['date'] as Timestamp).toDate();
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

        PainFormData painForm = PainFormData.fromForm(userID, descriptors, painLevel, date, bodyParts, frequency);
        data.add(painForm);
      }
    } catch(e) {
      rethrow;
    }

    return data;
  }
}