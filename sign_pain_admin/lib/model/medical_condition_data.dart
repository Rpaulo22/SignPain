class MedicalConditionData {
  // constructor
  MedicalConditionData(this.id, this.name, this.description, this.causes, this.commonDescriptors, this.uncommonDescriptors, this.treatment, this.bodyPartsAffected, this.side);

  String id;
  String name;
  String description;
  List<String> causes;
  List<String> commonDescriptors;
  List<String> uncommonDescriptors;
  String treatment;
  List<String> bodyPartsAffected;
  String side;

  // missing: videoURLs
}