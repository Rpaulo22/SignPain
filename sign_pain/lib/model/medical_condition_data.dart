class MedicalConditionData {
  // constructor
  MedicalConditionData(this.id, this.name, this.description, this.causes, this.commonDescriptors, this.uncommonDescriptors, this.treatment, this.bodyPartsAffected);

  String id;
  String name;
  String description;
  List<String> causes;
  List<String> commonDescriptors;
  List<String> uncommonDescriptors;
  String treatment;
  List<String> bodyPartsAffected;
}