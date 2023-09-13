import 'package:flutter/material.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/models/order_attribute_value_widget.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/outlined_text.dart';
import 'package:possystem/components/style/text_divider.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/settings/currency_setting.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/order_screen.dart';
import 'package:possystem/constants/constant.dart';
import 'package:intl/intl.dart';
import '../cashier/order_details_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:possystem/components/style/circular_loading.dart';

//結帳的頁面
class OrderCashierProductList extends StatelessWidget {
  final List<OrderSelectedAttributeObject> attributes;
  final List<OrderProductTileData> products;
  //final OrderObjectTileData orderObjects;
  final int? id;
  final num totalPrice;
  final num productsPrice;
  final num attributePrice;
  final num? productCost;
  int count;

  /// 淨利，只需考慮總價和成本，不需考慮付額
  final num? income;

  /// 付額
  final num? paid;

  OrderCashierProductList({
    Key? key,
    required this.attributes,
    required this.products,
    //required this.orderObjects,
    required this.totalPrice,
    required this.productsPrice,
    this.productCost,
    this.income,
    this.paid,
    this.id,
    this.count = 1,
  })  : attributePrice = totalPrice - productsPrice,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final priceWidget = ExpansionTile(
      title: Text(
        S.orderCashierTotalPrice(totalPrice),
        style: const TextStyle(fontSize: 20),
      ),
      children: <Widget>[
        ListTile(
          title: Text(S.orderCashierProductTotalPriceLabel),
          trailing: Text(productsPrice.toCurrency()),
        ),
        // ListTile(
        //   title: Text(S.orderCashierAttributeTotalPrice),
        //   trailing: Text(attributePrice.toCurrency()),
        // ),
        // if (productCost != null)
        //   ListTile(
        //     title: Text(S.orderCashierProductTotalCostLabel),
        //     trailing: Text(productCost!.toCurrency()),
        //   ),
        if (income != null)
          ListTile(
            title: Text(S.orderCashierIncomeLabel),
            trailing: Text(income!.toCurrency()),
          ),
        if (paid != null)
          ListTile(
            title: Text(S.orderCashierPaidLabel),
            trailing: Text(paid!.toCurrency()),
          ),
      ],
    );

    // final attrWidget = attributes.isEmpty
    //     ? const SizedBox.shrink()
    //     : ExpansionTile(
    //         key: const Key('order_cashier_product_list.attributes'),
    //         title: Text(S.orderCashierAttributeInfoTitle),
    //         subtitle:
    //             Text(S.orderCashierAttributeTotalCount(attributes.length)),
    //         children: <Widget>[
    //           for (final attribute in attributes)
    //             ListTile(
    //               title: Text(attribute.name.toString()),
    //               subtitle: OrderAttributeValueWidget(
    //                 attribute.mode,
    //                 attribute.modeValue,
    //               ),
    //               trailing: OutlinedText(attribute.optionName.toString()),
    //             ),
    //         ],
    //       );

    return SingleChildScrollView(
      child: Column(children: [
        priceWidget,
        //attrWidget,
        TextDivider(label: S.orderCashierProductInfoTitle),
        HintText(S.orderCashierProductMetaCount(productCount)),
        //---testCode---
        ListTile(
          key: Key('order_cashier_product_list.${id}'),
          leading: orderBuildLeading(),
          title: buildTitle(context),
          //trailing:尾隨屬性
          // trailing: ElevatedButton(
          //   child: Text(S.orderCashierCheckout,style: const TextStyle(fontSize: 20)),
          //   onPressed:  ),
          //subtitle: subtitle,
          // onTap: () => Navigator.of(context).push(
          //   MaterialPageRoute(builder: (_) => _AnalysisOrderModal(order)),
          // ),
        ),
        //---testCode---
        //---原code---
        //for (final product in products) _ProductTile(product),
        //_ProductTile(productCount),
        // avoid calculator overlapping it
        //const SizedBox(height: 36),
      ]),
    );
  }

  int get productCount {
    return products.fold<int>(0, (v, p) => v + p.totalCount);
  }

  void incre() {
    count += 1;
    print("count == $count");
  }

  Widget orderBuildLeading() {
    incre();
    return Padding(
      padding: const EdgeInsets.only(top: kSpacing1),
      // child: Text(DateFormat.Hm(S.localeName).format(createdAt)),
    );
  }

  Widget buildTitle(BuildContext context) {
    int index = 0;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      //SingleChildScrollView:捲動單一元件，適用於動態載入，用以解決元件實際尺寸超出可用空間
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final product in products) ...[
          if (index++ > 0) const Text(MetaBlock.string),
          Stack(clipBehavior: Clip.none, children: [
            Text(product.productName),
          ]),
        ],
        const SizedBox(width: 8),
      ]),
    );
  }
}

class OrderProductTileData {
  final Iterable<String> ingredientNames;
  final String productName;
  //final OrderScreenState orderScreenState;
  final Product? product;
  final num totalPrice;
  final num? totalCost;
  final int totalCount;
  //int? get count => orderScreenState.orderCount;
  String? get ice => product?.ice;
  String? get size => product?.size;
  String? get sugar => product?.sugar;
  num? get newPrice => product?.newPrice;
  List<String>? get content => product?.content;
  OrderProductTileData({
    //required this.orderScreenState,
    required this.product,
    required this.productName,
    required this.ingredientNames,
    required this.totalPrice,
    required this.totalCount,
    this.totalCost,
    //required this.orderCount,
  });
}

///---test---
class OrderObjectTileData {
  //final Iterable<String> ingredientNames;
  final String productName;
  // //final OrderScreenState orderScreenState;
  // final Product? product;
  // final num totalPrice;
  // final num? totalCost;
  // final int totalCount;
  // //int? get count => orderScreenState.orderCount;
  // String? get ice => product?.ice;
  // String? get size => product?.size;
  // String? get sugar => product?.sugar;
  // num? get newPrice => product?.newPrice;
  // List<String>? get content => product?.content;
  OrderObjectTileData({
    //required this.orderScreenState,
    // required this.product,
    required this.productName,
    // required this.ingredientNames,
    // required this.totalPrice,
    // required this.totalCount,
    // this.totalCost,
    //required this.orderCount,
  });
}

///---test---
class _ProductTile extends StatelessWidget {
  final OrderProductTileData data;
  //final List<OrderProductTileData> products;
  const _ProductTile(this.data);
  @override
  Widget build(BuildContext context) {
    final texts = <String>[
      data.productName,
      S.orderCashierProductMetaPrice(data.totalPrice),
      S.orderCashierProductMetaCount(data.totalCount),
      S.orderCashierProductMetaSize(data.size ?? ''),
      S.orderCashierProductMetaSugar(data.sugar ?? ''),
      S.orderCashierProductMetaIce(data.ice ?? ''),
      S.orderCashierProductMetaContent(data.content?.join(',') ?? ''),
      if (data.totalCost != null)
        S.orderCashierProductMetaCost(data.totalCost!),
    ];
    return ExpansionTile(
      title: Text(
        "第一單",
        style: const TextStyle(fontSize: 20),
      ),

      subtitle: MetaBlock.withString(context, <String>[
        S.orderCashierProductMetaPrice(data.totalPrice),
        S.orderCashierProductMetaCount(data.totalCount),
        if (data.totalCost != null)
          S.orderCashierProductMetaCost(data.totalCost!),
      ]),
      //標題左側圖標
      //leading: data.product?.avator,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      childrenPadding: const EdgeInsets.all(8.0),
      children: [
        Wrap(
          spacing: 4,
          children: [
            for (final text in texts) Text(text),
          ],
        )
      ],
    );
  }
}




//原code
// class _ProductTile extends StatelessWidget {
//   final OrderProductTileData data;

//   const _ProductTile(this.data);

//   @override
//   Widget build(BuildContext context) {
//     final texts = <String>[
//       S.orderCashierProductMetaPrice(data.totalPrice),
//       S.orderCashierProductMetaCount(data.totalCount),
//       if (data.totalCost != null)
//         S.orderCashierProductMetaCost(data.totalCost!),
//       if (data.product != null)
//         S.orderCashierProductMetaCatalog(data.product!.catalog.name),
//       if (data.ingredientNames.isNotEmpty) S.orderCashierProductMetaIngredient,
//     ];
        //ExpansionTile: 展開閉合
//     return ExpansionTile(
//       title: Text(data.productName,style: const TextStyle(fontSize: 20),),
      
//       subtitle: MetaBlock.withString(context, <String>[ 
//         S.orderCashierProductMetaPrice(data.totalPrice),
//         S.orderCashierProductMetaCount(data.totalCount),
//         S.orderCashierProductMetaSize(data.size??''),
//         S.orderCashierProductMetaSugar(data.sugar??''),
//         S.orderCashierProductMetaIce(data.ice??''),
//         S.orderCashierProductMetaContent(data.content?.join(',')??''),
        
//         if (data.totalCost != null)
//           S.orderCashierProductMetaCost(data.totalCost!),
        
//       ]),
//       //標題左側圖標
//       leading: data.product?.avator,
//       expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
//       childrenPadding: const EdgeInsets.all(8.0),
//       children: [
//         for (final text in texts)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8),
//             child: Text(text),
//           ),
//         Wrap(spacing: 4, runSpacing: 4, children: [
//           for (final ingredient in data.ingredientNames)
//             OutlinedText(ingredient),
//         ]),
//       ],
//     );
//   }
// }