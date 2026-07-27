class PainDescriptorData {
  String id; // id of the descriptor on the database
  String descriptorName; // name of the descriptor
  String associatedSymbol; // symbol (emoji) associated to the pain descriptor
  String description; // brief description of the descriptor
  String videoURL; // sign language video url which translates the description

  PainDescriptorData(this.id, this.descriptorName, this.associatedSymbol, this.description, this.videoURL);
}