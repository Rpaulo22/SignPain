import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_pain_admin/utils/app_exception.dart';
import 'package:sign_pain_admin/model/pain_descriptor_data.dart';
import 'package:emoji_regex/emoji_regex.dart';

class PainDescriptorViewModel extends ChangeNotifier {
  List<PainDescriptorData> _painDescriptors = [];
  List<PainDescriptorData> get painDescriptors => _painDescriptors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasFetched = false;

  
  Future<void> getPainDescriptors() async {
    if (_isLoading || _hasFetched) return;

    _isLoading = true;
    notifyListeners();

    var db = FirebaseFirestore.instance;
    List<PainDescriptorData> data = [];

    try {
      final querySnapshot = await db
          .collection("PainDescriptors")
          .get();
      // loop through results
      for (var docSnapshot in querySnapshot.docs) {
        var _data = docSnapshot.data(); 

        var id = docSnapshot.id;
        var descriptorName = _data['descriptorName'] as String;
        var associatedSymbol = _data['associatedSymbol'] as String;
        var description = _data['description'] as String;
        var videoURL = _data['videoURL'] as String;

        PainDescriptorData descriptorData = PainDescriptorData(id, descriptorName, associatedSymbol, description, videoURL);
        data.add(descriptorData);
      }
      _painDescriptors = data;
      _hasFetched = true;
    } 
    catch (_) {
      throw AppException("Erro a aceder base de dados\nTente novamente mais tarde");
    } 
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // given a name, an emoji (symbol) and description, add a new pain descriptor to the db
  // TODO also include the upload of the LGP video
  Future<void> createNewPainDescriptor(String name, String symbol, String description) async {
    _isLoading = true;
    notifyListeners();

    var db = FirebaseFirestore.instance;

    // pre processing and checks
    name = name.trim();
    description = description.trim();
    symbol = symbol.trim();

    if (!isEmoji(symbol)) { // given symbol is not a single emoji
      _isLoading = false;
      notifyListeners();
      throw AppException("Deverá incluir um símbolo (emoji) que represente visualmente a dor");
    }
    if (name.isEmpty || description.isEmpty) { // name or description is not given
      _isLoading = false;
      notifyListeners();
      throw AppException("Todos os campos têm de ser preenchidos para guardar na base de dados.");
    } 
    if (painDescriptors.any((element) => element.descriptorName.toUpperCase() == name.toUpperCase())) { // descriptor already exists
      _isLoading = false;
      notifyListeners();
      throw AppException("Este descritor já existe no sistema");
    }
    if (painDescriptors.any((element) => element.associatedSymbol == symbol)) { // symbol is already used in other existing descriptor
      _isLoading = false;
      notifyListeners();
      throw AppException("Este símbolo já está a ser usado por outro descritor");
    }

    final map = {
      "descriptorName": name,
      "associatedSymbol": symbol,
      "description": description,
      "videoURL": 'www.placeholder.com/placeholder.mp4' // placeholder link to video where it is being hosted
    };

    try {
      final docID = await db.collection("PainDescriptors").add(map); // add to firestore

      final data = PainDescriptorData(docID.id, name, symbol, description, 'www.placeholder.com/placeholder.mp4');

      painDescriptors.add(data); // add to local list
    }
    catch (e) {
      throw AppException("Erro a guardar descritor. Tente novamente\n${e.toString()}");
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // given a string, returns a boolean on whether it is a single emoji or not
  bool isEmoji(String text) {
    // .characters are the perceived characters, as emojis have more than 1 character and .length would return > 1 
    if (text.characters.length != 1) {
      return false;
    }

    final exactEmojiRegex = RegExp('^(${emojiRegex().pattern})\$');
    
    return exactEmojiRegex.hasMatch(text);
  }
}