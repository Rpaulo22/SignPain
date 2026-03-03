class PainFormData {
  int? painLevel;
  Set<String> descriptors = {};
  String? notes;
  
  // helper to check if the form is complete
  bool get isComplete => painLevel != null && descriptors.isNotEmpty;
}