class PainFormData {
  String userID = "user1"; 
  int? painLevel;
  Set<String> descriptors = {};
  DateTime? date;
  
  PainFormData(this.userID, this.descriptors, this.painLevel, this.date);

  // helper to check if the form is complete
  bool get isComplete => painLevel != null && descriptors.isNotEmpty;
}