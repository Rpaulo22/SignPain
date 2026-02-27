class PainFormData {
  int? painLevel;
  List<String> painTypes = [];
  String? notes;
  
  // helper to check if the form is complete
  bool get isComplete => painLevel != null && painTypes.isNotEmpty;
}