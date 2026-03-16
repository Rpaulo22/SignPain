import 'package:body_part_selector/body_part_selector.dart';

class PainFormData {
  String userID = "user1"; 
  int? painLevel; // self-reported pain level (on a scale of 0-10)
  Set<String> descriptors = {}; // adjectives which describe the felt pain
  DateTime? date; // date of the form's submission
  BodyParts bodyParts = BodyParts(); // body parts which the pain is inflicted
  
  PainFormData.fromForm(this.userID, this.descriptors, this.painLevel, this.date, this.bodyParts);
  PainFormData();

  // helper to check if the form is complete
  bool get isComplete => painLevel != null && descriptors.isNotEmpty;

}

extension BodyPartsMapper on BodyParts {

  // Transforms a BodyParts object into a List of strings
  List<String> toList() {
    return toJson()
    .entries // key-value pairs
    .where((entry) => entry.value == true) // keep only the selected ones
    .map((entry) => entry.key)
    .toList();
  }

  // Transforms a List of body part strings into a BodyParts object
  static BodyParts fromList(List<String> bodyParts) {
    Map<String, dynamic> bodyMap = BodyParts().toJson();

    for (String part in bodyParts) {
      if (bodyMap.containsKey(part)) { 
        bodyMap[part] = true;
      }
    }

    return BodyParts.fromJson(bodyMap);
  }

  // Transforms a BodyParts object into a List of strings in portuguese, for visualization on UI
  List<String> toPortugueseList() {
    List<String> parts = [];

    if (head) parts.add("Cabeça");
    if (neck) parts.add("Pescoço");
    if (leftShoulder) parts.add("Ombro Esquerdo");
    if (leftUpperArm) parts.add("Braço Esquerdo");
    if (leftElbow) parts.add("Cotovelo Esquerdo");
    if (leftLowerArm) parts.add("Antebraço Esquerdo");
    if (leftHand) parts.add("Mão Esquerda");
    if (rightShoulder) parts.add("Ombro Direito");
    if (rightUpperArm) parts.add("Braço Direito");
    if (rightElbow) parts.add("Cotovelo Direito");
    if (rightLowerArm) parts.add("Antebraço Direito");
    if (rightHand) parts.add("Mão Direita");
    if (upperBody) parts.add("Caixa Torácica");
    if (lowerBody) parts.add("Barriga/Dorsal");
    if (abdomen) parts.add("Anca");
    if (leftUpperLeg) parts.add("Coxa Esquerda");
    if (leftKnee) parts.add("Joelho Esquerdo");
    if (leftLowerLeg) parts.add("Perna Esquerda");
    if (leftFoot) parts.add("Pé Esquerdo");
    if (rightUpperLeg) parts.add("Coxa Direita");
    if (rightKnee) parts.add("Joelho Direito");
    if (rightLowerLeg) parts.add("Perna Direita");
    if (rightFoot) parts.add("Pé Direito");

    return parts;
  }
}