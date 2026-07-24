class UserData {
  String userID;
  String email;
  String fullName;
  String healthIdentifier;
  DateTime birthDate;

  UserData({required this.userID, required this.email, required this.fullName, required this.healthIdentifier, required this.birthDate});

  void update(String newName, String newHealthIdentifier, DateTime newBirthDate) {
    fullName = newName;
    healthIdentifier = newHealthIdentifier;
    birthDate = newBirthDate;
  }
}