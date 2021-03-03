import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:sqflite/sqflite.dart';

class Category {
  int ID;
  String name, image;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnMainCategoryId: ID,
      columnCategoryName: name,
      columnCategoryImage: image
    };
    return map;
  }

  Category();

  Category.fromMap(Map<String, dynamic> map) {
    ID = map[columnMainCategoryId];
    name = map[columnCategoryName];
    image = map[columnCategoryImage];
  }
}

class CategoryProvider {
  Future<Category> getCategoryById(Database db, int id) async {
    var maps = await db.query(tableCategoryName,
        columns: [
          columnMainCategoryId,
          columnCategoryName,
          columnCategoryImage
        ],
        where: '$columnMainCategoryId=?',
        whereArgs: [id]);
    if (maps.length > 0) return Category.fromMap(maps.first);
    return null;
  }

  Future<List<Category>> getCategories(Database db) async {
    var maps = await db.query(tableCategoryName,
        columns: [
          columnMainCategoryId,
          columnCategoryName,
          columnCategoryImage
        ]);
    if (maps.length > 0) return maps.map((category) => Category.fromMap(category)).toList();
    return null;
  }

}

class CategoryList extends StateNotifier<List<Category>>{
  CategoryList(List<Category> state):super(state ?? []);

  void addAll(List<Category> category){
    state.addAll(category);
  }

  void add(Category category){
    state = [
      ...state,
      category,
    ];
  }
}
