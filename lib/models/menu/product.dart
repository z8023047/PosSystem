import 'dart:math';

import 'package:possystem/services/storage.dart';

import '../model.dart';
import '../objects/menu_object.dart';
import '../repository.dart';
import '../repository/menu.dart';
import 'catalog.dart';
import 'product_ingredient.dart';

//產品本身的instance及他的屬性值
class Product extends Model<ProductObject>
    with
        ModelStorage<ProductObject>,
        ModelOrderable<ProductObject>,
        ModelSearchable<ProductObject>,
        ModelImage<ProductObject>,
        Repository<ProductIngredient>,
        RepositoryStorage<ProductIngredient> {

  /// Connect to parent object
  late final Catalog catalog;

  /// Help to calculate daily earn
  num cost;
  //int count;
  /// Money show to customer/order
  num price;
  num newPrice=0;
  String size = '';
  String sugar = '';
  String ice = '';
  List<String>? content ;
  

  Product.copy(Product original) :
    catalog = original.catalog,
    cost = original.cost,
    price = original.price,
    newPrice = original.newPrice,
    size = original.size,
    sugar = original.sugar,
    ice = original.ice,
    content = original.content,
    createdAt = original.createdAt,
        super(original.id, original.status) {
    name = original.name;
    index = original.index;
    imagePath = original.imagePath;
  

    //if (original.ingredients != null) replaceItems(original.ingredients);
  }
  

  /// The time added to catalog
  final DateTime createdAt;

  /// The time it has been selected in searching
  DateTime? searchedAt;

  @override
  final Stores storageStore = Stores.menu;

  @override
  final RepositoryStorageType repoType = RepositoryStorageType.repoModel;
  //加東西的時候這裡也要加，這裡是暫存的地方
  Product({
    String? id,
    ModelStatus? status,
    String name = 'product',
    int index = 1,
    this.cost = 0,
    this.price = 0,
    String? imagePath,
    DateTime? createdAt,
    this.searchedAt,
    Map<String, ProductIngredient>? ingredients,
  })  : createdAt = createdAt ?? DateTime.now(),
        super(id, status) {
    this.name = name;
    this.index = index;
    this.imagePath = imagePath;

    if (ingredients != null) replaceItems(ingredients);
  }

  factory Product.fromObject(ProductObject object) {
    final ingredients = object.ingredients.map((e) {
      try {
        return ProductIngredient.fromObject(e);
      } catch (e) {
        // not finding ingredient
        return null;
      }
    }).where((e) => e != null);

    if (!object.ingredients.every((object) => object.isLatest)) {
      Menu.instance.versionChanged = true;
    }

    return Product(
      id: object.id,
      name: object.name!,
      index: object.index!,
      price: object.price!,
      cost: object.cost!,
      imagePath: object.imagePath,
      createdAt: object.createdAt,
      searchedAt: object.searchedAt,
      ingredients: {
        for (var ingredient in ingredients) ingredient!.id: ingredient
      },
    )..prepareItem();
  }

  factory Product.fromRow(
    Product? ori,
    List<String> row, {
    required int index,
  }) {
    //Parse:文字化的數字變成真正能提供運算的數字，但如果轉換失敗，會跳exception
    final price = num.parse(row[2]);
    final cost = num.parse(row[3]);
    //final sugar = num.parse(row[4]).toString();
    final status = ori == null
        ? ModelStatus.staged
        : (price == ori.price && cost == ori.cost //&& sugar == ori.sugar
            ? ModelStatus.normal
            : ModelStatus.updated);

    return Product(
      id: ori?.id,
      name: row[1],
      index: index,
      price: price,
      cost: cost,
      status: status,
    );
  }

  @override
  String get prefix => '${catalog.prefix}.products.$id';

  @override
  Catalog get repository => catalog;

  @override
  set repository(Repository repo) => catalog = repo as Catalog;

  @override
  ProductIngredient buildItem(String id, Map<String, Object?> value) {
    throw UnimplementedError();
  }

  int getItemsSimilarity(String pattern) {
    var maxScore = 0;
    for (final ingredient in items) {
      maxScore = max(ingredient.getSimilarity(pattern), maxScore);
      for (final quantity in ingredient.items) {
        maxScore = max(quantity.getSimilarity(pattern), maxScore);
      }
    }
    return maxScore;
  }

  bool hasIngredient(String id) {
    return items.any((item) => item.ingredient.id == id);
  }

  @override
  void notifyItems() {
    notifyListeners();
    catalog.notifyItem();
  }

  Future<void> searched() {
    return update(ProductObject(searchedAt: DateTime.now()), event: 'search');
  }

  @override
  ProductObject toObject() => ProductObject(
        id: id,
        name: name,
        index: index,
        price: price,
        cost: cost,
        createdAt: createdAt,
        imagePath: imagePath,
        ingredients: items.map((e) => e.toObject()).toList(),
      );
}
