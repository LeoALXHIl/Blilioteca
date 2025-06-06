import 'package:sapetshop/database/db_helper.dart';
import 'package:sapetshop/models/pet_model.dart';

class PetsController {
  //atributo -> é conexão com DB
  final PetShopDBHelper _dbHelper = PetShopDBHelper();


  Future<int> addPet(Pet pet) async {
    return await _dbHelper.insertPet(pet);
  }

  Future<List<Pet>> fetchPets() async {
    return await _dbHelper.getPets();
  }

  Future<Pet?> findPetbyId(int id) async {
    return await _dbHelper.getpetById(id);
  }

  Future<int> deletePet(Pet pet) async {
    return await _dbHelper.deletePet(pet);
  }

}