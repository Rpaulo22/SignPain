import 'package:body_part_selector/body_part_selector.dart';

class PainFormData {
  String userID = "user1"; 
  int? painLevel; // self-reported pain level (on a scale of 0-10)
  Set<String> descriptors = {}; // adjectives which describe the felt pain
  DateTime? date; // date of the form's submission
  List<String> bodyParts = []; // body parts which the pain is inflicted on
  
  PainFormData.fromForm(this.userID, this.descriptors, this.painLevel, this.date, this.bodyParts);
  PainFormData();

  // helper to check if the form is complete
  bool get isComplete => painLevel != null && descriptors.isNotEmpty && bodyParts.isNotEmpty;

}

// functions to extend the functionalities of BodyParts package for SignPain
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

  // Transforms a BodyParts object into a List of strings in portuguese, for visualization in UI
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
  
  // maps english "code" body parts to corresponding portuguese translation
  static const Map<String, String> bodyTranslationsPT = {
    "head" : "Cabeça",
    "neck" : "Pescoço",
    "leftShoulder" : "Ombro Esquerdo",
    "leftUpperArm" : "Braço Esquerdo",
    "leftElbow" : "Cotovelo Esquerdo",
    "leftLowerArm" : "Antebraço Esquerdo",
    "leftHand" : "Mão Esquerda",
    "rightShoulder" : "Ombro Direito",
    "rightUpperArm" : "Braço Direito",
    "rightElbow" : "Cotovelo Direito",
    "rightLowerArm" : "Antebraço Direito",
    "rightHand" : "Mão Direita",
    "upperBody" : "Caixa Torácica",
    "lowerBody" : "Barriga/Dorsal",
    "abdomen" : "Anca",
    "leftUpperLeg" : "Coxa Esquerda",
    "leftKnee" : "Joelho Esquerdo",
    "leftLowerLeg" : "Perna Esquerda",
    "leftFoot" : "Pé Esquerdo",
    "rightUpperLeg" : "Coxa Direita",
    "rightKnee" : "Joelho Direito",
    "rightLowerLeg" : "Perna Direita",
    "rightFoot" : "Pé Direito"
  };

  // Given a list of body parts (which are in English), outputs a list with the portuguese translation
  static List<String> listToPortuguese(List<String> parts) {
    return parts.map((part) => bodyTranslationsPT[part] ?? part).toList();
  }
}