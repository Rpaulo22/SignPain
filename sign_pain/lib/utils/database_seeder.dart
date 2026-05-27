import 'package:cloud_firestore/cloud_firestore.dart';

// list of conditions to be added to firebase
final List<Map<String, dynamic>> initialConditions = [
  {
    "id": "cervicalgia",
    "name": { 
      "text" :"Cervicalgia (Dor no pescoço)",
      "videoURL": "www.example.com"
    },
    "description": {
      "text": "Dor persistente no pescoço",
      "videoURL": "www.example.com"
    },
    "causes": {
      "text": ["Stress" ,"Má postura", "Contraturas", "Movimentos bruscos", "Desgaste da coluna cervical", "Alterações nos discos intervertebrais"],
      "videoURL": "www.example.com"
    },
    "painDescriptors": {
      "common": ["Moedeira", "Tensão", "Localizada", "Mecânica", "Difusa"],
      "uncommon": ["Irradiada", "Latejante", "Aguda", "Ardor", "Intermitente"]
    },
    "treatment": {
      "text": "O tratamento mais comum baseia-se em fisioterapia, exercícios e aplicação de calor, enquanto opções menos frequentes incluem infiltrações, acupuntura ou cirurgia em casos graves e persistentes",
      "videoURL": "www.example.com"
    },
    "bodyPartsAffected": ["neck"]
  },
  {
    "id": "lombalgia",
    "name": { 
      "text" :"Lombalgia",
      "videoURL": "www.example.com"
    },
    "description": {
      "text": "Dor ou desconforto persistente na zona inferior das costas",
      "videoURL": "www.example.com"
    },
    "causes": {
      "text": ["Desgaste ou esforço dos tecidos da coluna ao longo do tempo", "Lesões nos discos intervertebrais"],
      "videoURL": "www.example.com"
    },
    "painDescriptors": {
      "common": ["Moedeira", "Tensão", "Cansaço", "Aguda", "Rigidez", "Peso"],
      "uncommon": ["Choque", "Formigueiro", "Ardor"]
    },
    "treatment": {
      "text": "É aconselhado atividade física, mantendo as atividades do dia-a-dia quanto a dor permita. Caso não seja eficaz, anti-inflamatórios não esteróides. Em último caso, poderá usar opióides ou até ser submitido a cirurgia, dependendo da causa subjacente",
      "videoURL": "www.example.com"
    },
    "bodyPartsAffected": ["lowerBack"]
  },
];


// upload medical conditions (defined above) to firebase (only run once for newly added conditions)
Future<void> uploadMedicalConditions() async {
  final db = FirebaseFirestore.instance;
  final batch = db.batch();


  for (var condition in initialConditions) {
    
    final docRef = db.collection('MedicalConditions').doc(condition['id']);
    
    batch.set(docRef, condition);
  }

  try {
    await batch.commit();
  } catch (e) {
    print("Error while uploading: $e");
  }
}