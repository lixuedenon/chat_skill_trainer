// lib/features/character_selection/character_controller.dart
import 'package:flutter/foundation.dart';
import '../../core/models/character_model.dart';
import '../../core/constants/character_data.dart';

class CharacterController extends ChangeNotifier {
  List<CharacterModel> _characters = [];
  CharacterModel? _selectedCharacter;
  bool _isLoading = false;

  List<CharacterModel> get characters => _characters;
  CharacterModel? get selectedCharacter => _selectedCharacter;
  bool get isLoading => _isLoading;

  CharacterController() {
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));
    _characters = CharacterData.allCharacters;

    _isLoading = false;
    notifyListeners();
  }

  void selectCharacter(CharacterModel character) {
    _selectedCharacter = character;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCharacter = null;
    notifyListeners();
  }
}