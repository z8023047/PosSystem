import 'dart:math';

import 'package:flutter/material.dart';
import 'package:possystem/helpers/logger.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/order/order_attribute_option.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart_ingredients.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/settings/currency_setting.dart';

import 'cashier.dart';
import 'seller.dart';
import 'stock.dart';
import 'package:group_button/group_button.dart';
//訂單的物件庫，購物車
class Cart extends ChangeNotifier {
  static Cart instance = Cart();

  final List<OrderProduct> products = [];

  final Map<String, String> attributes = {};

  ValueNotifier<num?> currentPaid = ValueNotifier(null);

  bool isHistoryMode = false;

  bool get isEmpty => products.isEmpty;

  /// check if selected products are same
  bool get isSameProducts {
    final selected = this.selected;
    if (selected.isEmpty) return false;

    final firstId = selected.first.id;
    return selected.every((e) => e.id == firstId);
  }

  num get productsPrice {
    return products.fold(0, (value, product) => value + product.newPrice);
  }

  num get productsCost {
    return products.fold(0, (value, product) => value + product.cost);
  }

  // String get productsIce {
  //   return products.fold(0 as String, (value, product) => value + product.ice);
  // }

  Iterable<OrderProduct> get selected =>
      products.where((product) => product.isSelected);

  Iterable<OrderAttributeOption> get selectedAttributeOptions sync* {
    for (var attr in OrderAttributes.instance.itemList) {
      final optionId = attributes[attr.id];
      final option =
          optionId == null ? attr.defaultOption : attr.getItem(optionId);

      if (option != null) {
        yield option;
      }
    }
  }

  int get totalCount {
    return products.fold(0, (value, product) => value + product.count);
  }

  num get totalPrice {
    var total = productsPrice;

    for (var option in selectedAttributeOptions) {
      total = option.calculatePrice(total);
    }

    return max(total.toCurrencyNum(), 0);
  }

  OrderProduct add(Product product) {
    final orderProduct = OrderProduct(product, isSelected: true);
    products.add(orderProduct);
    print('222');
    _selectedChanged();

    return orderProduct;
  }
  // OrderProduct showAlertDialog(Product product) {
  //   var context;
  //   return  showDialog(
  //     context: context,
  //     builder: (context){
  //       return  AlertDialog(
  //         title: Text("title"),
  //         content: Text("content info"),
  //         actions: <Widget>[
  //           TextButton(
  //           child: Text("取消"),
  //           onPressed: () => Navigator.of(context).pop(), // 关闭对话框
  //         ),
  //         TextButton(
  //           child: Text("删除"),
  //           onPressed: () {
  //             //关闭对话框并返回true
  //             Navigator.of(context).pop(true);
  //           },
  //         ),
  //         ],
  //       );
  //     }
  //     );
  // }

  void clear() {
    products.clear();
    attributes.clear();
    isHistoryMode = false;
    currentPaid.dispose();
    currentPaid = ValueNotifier(null);
    _selectedChanged();
  }

  @override
  void dispose() {
    products.clear();
    attributes.clear();
    super.dispose();
  }

  /// Drop the stashed order
  Future<bool> drop(int lastCount) async {
    Log.ger('start', 'order_cart_drop');
    final order = await Seller.instance.drop(lastCount);
    if (order == null) return false;

    replaceByObject(order);
    Log.ger('done', 'order_cart_drop');

    return true;
  }

  /// Paid to the order
  Future<CashierUpdateStatus?> checkout() async {
    if (totalCount == 0) {
      clear();
      return null;
    }

    final price = totalPrice;
    final paid = currentPaid.value ?? price;
    Log.ger(isHistoryMode ? 'history' : 'normal', 'order_paid');
    if (paid < price) throw const PaidException('insufficient_amount');

    Log.ger('verified', 'order_paid');
    // if history mode update data
    final result = isHistoryMode
    //修改歷史訂單
        ? await _finishHistoryMode(paid, price)
    //正常點單
        : await _finishNormalMode(paid, price);

    clear();
    return result;
  }

  Future<bool> popHistory() async {
    Log.ger('start', 'order_cart_pop');
    final order = await Seller.instance.getTodayLast();
    if (order == null) return false;

    replaceByObject(order);
    Log.ger('done', 'order_cart_pop');

    isHistoryMode = true;

    return true;
  }

  void rebind() {
    // remove not exist product
    products.removeWhere((product) {
      return Menu.instance.items
          .every((catalog) => !catalog.hasItem(product.id));
    });
    // remove non exist attribute
    attributes.entries.toList().forEach((entry) {
      final attr = OrderAttributes.instance.getItem(entry.key);
      if (attr == null || !attr.hasItem(entry.value)) {
        attributes.remove(entry.key);
      }
    });
    // rebind product ingredient/quantity
    for (var product in products) {
      product.rebind();
    }
  }

  void removeSelected() {
    products.removeWhere((e) => e.isSelected);
    _selectedChanged();
  }
  // void removeSelected_test(Product product) {
  //   //products.removeWhere((e) => e.isSelected);
  //   products.removeAt(product.index);

  //   _selectedChanged();
  // }

  @visibleForTesting
  void replaceAll({
    List<OrderProduct>? products,
    Map<String, String>? attributes,
  }) {
    if (products != null) {
      this.products
        ..clear()
        ..addAll(products);
    }
    if (attributes != null) {
      this.attributes
        ..clear()
        ..addAll(attributes);
    }
  }

  void replaceByObject(OrderObject object) {
    products
      ..clear()
      ..addAll(object.parseToProduct());
    attributes
      ..clear()
      ..addAll(object.parseToAttrId());
    currentPaid.value = object.paid;
    _selectedChanged();
  }

  /// Stash order to DB
  ///
  /// Return false if not storable
  /// Rate limit = 5
  Future<bool> stash() async {
    if (isEmpty) return true;

    Log.ger('start', 'order_cart_stash');
    // disallow before stash, so need minus 1
    final length = await Seller.instance.getStashCount();
    if (length > 4) return false;

    final data = await toObject();
    await Seller.instance.stash(data);

    clear();
    Log.ger('done', 'order_cart_stash');

    return true;
  }

  void drinkSize(Product product) {
    print(product.size);
    print(product.price);
    if (product.size == '大杯') {
      product.newPrice = product.price + 5;
      print("-------------------");
      print(product.newPrice);
    } else if (product.size == '小杯') {
      product.newPrice = product.price;

      print(product.newPrice);
    }
  }

  void toggleAll(bool? checked, {OrderProduct? except}) {
    // except only acceptable when specify checked
    assert(checked != null || except == null);
    //
    // final catalogs = Menu.instance.notEmptyItems;
    // final product1 =
    //     Product(
    //       index: 1,
    //       name: "object6666test.name",
    //       price: 50,
    //       cost: 40,
    //       ice: "object.ice",
    //       imagePath: "_image",
    //     );

    //    catalogs[0].addItem(product1);

    for (var product in products) {
      //toggleSelected:通過設置toggleSelection 屬性true 或false 來決定是否取消選擇選定的數據點/系列，或者在再次與其交互時保持選中狀態
      product.toggleSelected(identical(product, except) ? !checked! : checked);
    }
  }

  Future<OrderObject> toObject({
    num? paid,
    OrderObject? object,
  }) async {
    for (final item in OrderAttributes.instance.notEmptyItems) {
      if (!attributes.containsKey(item.id)) {
        final option = item.defaultOption;
        if (option != null) {
          attributes[item.id] = option.id;
        }
      }
    }

    return OrderObject(
      id: object?.id,
      paid: paid,
      createdAt: object?.createdAt,
      attributes: attributes.entries
          .map((e) => OrderSelectedAttributeObject.fromId(e.key, e.value))
          .where((e) => e.isNotEmpty),
      totalPrice: totalPrice,
      totalCount: totalCount,
      productsPrice: productsPrice,
      products: products.map<OrderProductObject>((e) => e.toObject()),
    );
  }

  void updateSelectedCount(int? count) {
    if (count == null) return;

    for (var e in selected) {
      e.count = count;
    }
    notifyListeners();
  }
  //   void incrementNum(Product product) {
  //   product.count++;
  //   //setState();
  // }

  // void deIncrementNum(Product product) {
  //   if (product.count != 0) {
  //     product.count--;
  //     //setState();
  //   }
  // }

  void updateSelectedDiscount(int? discount) {
    if (discount == null) return;

    for (var e in selected) {
      final price = e.singlePrice * discount / 100;
      e.singlePrice = price.toCurrencyNum();
    }
    notifyListeners();
  }

  void updateSelectedPrice(num? price) {
    if (price == null) return;

    for (var e in selected) {
      e.singlePrice = price;
    }
    notifyListeners();
  }

  Future<CashierUpdateStatus> _finishHistoryMode(num paid, num price) async {
    final oldData = await Seller.instance.getTodayLast();
    final data = await toObject(paid: paid, object: oldData);

    await Seller.instance.update(data);
    Log.ger('history done', 'order_paid');

    await Stock.instance.order(data, oldData: oldData);
    final cashierResult = await Cashier.instance.paid(
      paid,
      price,
      oldPrice: oldData?.totalPrice ?? 0,
    );

    return cashierResult;
  }

  Future<CashierUpdateStatus> _finishNormalMode(num paid, num price) async {
    final data = await toObject(paid: paid);

    await Seller.instance.push(data);
    Log.ger('normal done', 'order_paid');

    await Stock.instance.order(data);
    final cashierResult = await Cashier.instance.paid(paid, price);

    return cashierResult;
  }

  // Future<CashierUpdateStatus> _finishStashMode(num paid, num price) async {
  //   final stashedOrders = [];
  //   final data = toObject();
  //   await Cart.instance.stashedOrders.push(data);

  //   final cashierResult = await Cashier.instance.paid(paid, price);

  //   return cashierResult;
  // }




  void _selectedChanged() {
    notifyListeners();
    CartIngredients.instance.notifyListeners();
  }
  // print("product.content ===== ${product.content}");
  // print("product.newPrice == ${product.newPrice}");

  void drinkContent(Product product) {
  
    switch ((product.content).toString()) {
      case '[珍珠]':
        product.newPrice += 5;

        break;
      case '[椰果]':
        product.newPrice += 10;

        break;
      case '[仙草凍]':
        product.newPrice += 5;

        break;
      case '[咖啡凍]':
        product.newPrice += 10;

        break;
      case '[寒天]':
        product.newPrice += 20;
        break;
      case '[愛玉]':
        product.newPrice += 15;
        break;
      case '[芋圓]':
        product.newPrice += 5;
        break;
      case '[冰淇淋]':
        product.newPrice = product.newPrice + 5;
        break;
    }
  }

  void contentEmpty(Product product) {
    product.content = null;
  }

  //  void increment() {
  //   count += 1;
  //   notifyListeners();
  //   Cart.instance.notifyListeners();
  // }
  showAlertDialog(Product product, BuildContext context) {
    final _buttons = [
      "珍珠",
      "椰果",
      "仙草凍",
      "咖啡凍",
      "寒天",
      "愛玉",
      "芋圓",
      "冰淇淋",
    ];
    product.size = '大杯';
    product.sugar = '半糖';
    product.ice = '正常冰';
    if (product.size == '大杯') {
      drinkSize(product);
    }
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 79, 64, 119),
              title: Text(product.name),
              content: Container(
                  width: 450,
                  height: 600,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        Text(
                          "尺寸:",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 139, 184, 35)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                DropdownButton<String>(
                                    dropdownColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    value: product.size,
                                    style: const TextStyle(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    items: <String>['大杯', '小杯']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      );
                                    }).toList(),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                    iconSize: 20,
                                    underline: SizedBox(),
                                    onChanged: (String? sizeValue) {
                                      setState(() {
                                        product.size = sizeValue!;
                                        drinkSize(product);
                                        print("product.size ==${product.size}");
                                      });
                                    })
                              ]),
                        ),
                        Text(
                          "甜度:",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 139, 184, 35)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton<String>(
                                dropdownColor:
                                    Color.fromARGB(255, 255, 255, 255),
                                value: product.sugar,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                items: <String>[
                                  '多糖',
                                  '少糖',
                                  '半糖',
                                  '微糖',
                                  '無糖'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  );
                                }).toList(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                iconSize: 20,
                                underline: SizedBox(),
                                onChanged: (String? sugarValue) {
                                  setState(() {
                                    product.sugar = sugarValue!;
                                    print("product.sugar == ${product.sugar}");
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "冰量:",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 139, 184, 35)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButton<String>(
                                dropdownColor:
                                    Color.fromARGB(255, 255, 255, 255),
                                value: product.ice,
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                                items: <String>[
                                  '正常冰',
                                  '多冰',
                                  '少冰',
                                  '微冰',
                                  '去冰'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  );
                                }).toList(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                                iconSize: 20,
                                underline: SizedBox(),
                                onChanged: (String? iceValue) {
                                  setState(() {
                                    product.ice = iceValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "加料:",
                          style: TextStyle(
                              fontSize: 20,
                              color: Color.fromARGB(255, 139, 184, 35)),
                        ),
                        SizedBox(
                          width: 0,
                        ),
                        GroupButton(
                          spacing: 5,
                          isRadio: false,
                          direction: Axis.horizontal,

                          onSelected: (index, isSelected) => {
                            if (isSelected == true )
                              {
                                //(product.content ??= []).add(_buttons[index]),
                                ((product.content ??= [])).add(_buttons[index]),
                                print("product.content == ${(product.content)}"),
                              }
                            else
                              {
                                (product.content)?.remove(_buttons[index]),
                                print("product.content == ${(product.content)}"),
                              },
                            print(
                                '$index button is ${isSelected ? 'selected' : 'unselected'}')
                          },

                          buttons: _buttons,

                          //selectedButtons: [],

                          selectedTextStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.red,
                          ),
                          unselectedTextStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),

                          selectedColor: Colors.white,
                          unselectedColor: Colors.grey[300],
                          selectedBorderColor: Colors.red,
                          unselectedBorderColor: Colors.grey[500],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ])),
              actions: [
                ElevatedButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                      drinkContent(product);
                      add(Product.copy(product));
                      //add(product);
                      print('111');
                      contentEmpty(product);
                    }),
                ElevatedButton(
                    child: Text("Cancel"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            );
          }));
        });
  }
}

class PaidException implements Exception {
  final String cause;

  const PaidException(this.cause);
}
