import 'package:flutter/material.dart';
import 'package:possystem/components/style/sliding_up_opener.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cart.dart';

import 'order_cashier_calculator.dart';
import 'order_cashier_product_list.dart';
import 'order_cashier_snapshot.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/components/meta_block.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:possystem/components/bottom_sheet_actions.dart';
import 'package:possystem/components/meta_block.dart';
import 'package:possystem/components/style/circular_loading.dart';
import 'package:possystem/components/style/hint_text.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/constants/icons.dart';
import 'package:possystem/models/objects/order_object.dart';
import 'package:possystem/models/repository/cashier.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:possystem/models/repository/stock.dart';
import 'package:possystem/translator.dart';
import 'package:possystem/ui/order/cashier/order_cashier_product_list.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// class AnalysisOrderList<T> extends StatefulWidget {
//   final Future<List<OrderObject>> Function(T, int) handleLoad;

//   const AnalysisOrderList({Key? key, required this.handleLoad})
//       : super(key: key);

//   @override
//   State<AnalysisOrderList<T>> createState() => AnalysisOrderListState<T>();
// }

// class AnalysisOrderListState<T> extends State<AnalysisOrderList<T>> {
//   late final RefreshController _scrollController;

//   final List<OrderObject> _data = [];
//   late T _params;
//   bool _isLoading = false;

//   num totalPrice = 0;
//   int totalCount = 0;

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading == true) {
//       return const CircularLoading();
//     } else if (_data.isEmpty) {
//       return HintText(S.analysisOrderListStatus('empty'));
//     }

//     return Column(
//       children: [
//         Center(
//           child: MetaBlock.withString(context, [
//             S.analysisOrderListMetaPrice(totalPrice),
//             S.analysisOrderListMetaCount(totalCount),
//           ]),
//         ),
//         Expanded(
//           //SmartRefresher:實現下拉刷新和上拉加載功能
//           child: SmartRefresher(
//             controller: _scrollController,
//             enablePullUp: true,
//             enablePullDown: true,
//             onRefresh: () => _handleRefresh(),
//             onLoading: () => _handleLoad(),
//             footer: _buildFooter(),
//             child: ListView.builder(
//               itemBuilder: (context, index) => _OrderTile(_data[index]),
//               itemCount: _data.length,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = RefreshController();
//   }

//   void reset(T params, {required num totalPrice, required int totalCount}) {
//     setState(() {
//       this.totalPrice = totalPrice;
//       this.totalCount = totalCount;
//       _params = params;
//       _data.clear();
//       _isLoading = true;
//       _handleLoad();
//     });
//   }

//   Widget _buildFooter() {
//     return CustomFooter(
//       height: 30,
//       builder: (BuildContext context, LoadStatus? mode) {
//         switch (mode) {
//           case LoadStatus.canLoading:
//             return Center(child: Text(S.analysisOrderListStatus('ready')));
//           case LoadStatus.loading:
//             return const CircularLoading();
//           case LoadStatus.noMore:
//             return Center(child: Text(S.analysisOrderListStatus('allLoaded')));
//           default:
//             return Container();
//         }
//       },
//     );
//   }

//   void _handleRefresh() async {
//     _data.clear();
//     await _handleLoad();
//     _scrollController.refreshCompleted(resetFooterState: true);
//   }

//   Future<void> _handleLoad() async {
//     final data = await widget.handleLoad(_params, _data.length);

//     _data.addAll(data);
//     data.isEmpty
//         ? _scrollController.loadNoData()
//         : _scrollController.loadComplete();

//     setState(() => _isLoading = false);
//   }
// }

// //點擊後跳出結帳後的畫面
// class _AnalysisOrderModal extends StatelessWidget {
//   final OrderObject order;

//   const _AnalysisOrderModal(this.order);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const PopButton(),
//         actions: [
//           // IconButton(
//           //   key: const Key('analysis.more'),
//           //   onPressed: () => _showActions(context),
//           //   enableFeedback: true,
//           //   icon: const Icon(KIcons.more),
//           // ),
//         ],
//       ),
//       body: Column(children: [
//         Padding(
//           padding: const EdgeInsets.all(4.0),
//           //child: HintText(_parseCreatedAt(order.createdAt)),
//         ),
//         Expanded(
//           child: OrderCashierProductList(
//             attributes: order.attributes.toList(),
//             products: order.products
//                 .map((product) => OrderProductTileData(
//                       product: Menu.instance.getProduct(product.productId),
//                       productName: product.productName,
//                       ingredientNames:
//                           product.ingredients.map((e) => e.quantityName == null
//                               ? S.orderProductIngredientDefaultName(e.name)
//                               : S.orderProductIngredientName(
//                                   e.name,
//                                   e.quantityName!,
//                                 )),
//                       totalCount: product.count,
//                       totalCost: product.totalCost,
//                       totalPrice: product.totalPrice,
//                     ))
//                 .toList(),
//             // orderObjects:
//             //     OrderObjectTileData(productName: order.paid.toString()),
//             productsPrice: order.productsPrice,
//             totalPrice: order.totalPrice,
//             productCost: order.cost,
//             income: order.income,
//             paid: order.paid,
//           ),
//         ),
//       ]),
//     );
//   }

//   // Future<void> _showActions(BuildContext context) async {
//   //   final form = GlobalKey<_WarningContextState>();
//   //   await BottomSheetActions.withDelete<_Action>(
//   //     context,
//   //     deleteCallback: () => showSnackbarWhenFailed(
//   //       Seller.instance.delete(order, form.currentState?.recoverOther ?? false),
//   //       context,
//   //       'analysis_delete_error',
//   //     ),
//   //     deleteValue: _Action.delete,
//   //     popAfterDeleted: true,
//   //     warningContent: _WarningContext(order, key: form),
//   //   );
//   // }
// }

// class _OrderTile extends StatelessWidget {
//   final OrderObject order;

//   const _OrderTile(this.order);

//   @override
//   Widget build(BuildContext context) {
//     final subtitle = MetaBlock.withString(context, [
//       //統計顯示的售價，付額，淨利
//       S.analysisOrderListItemMetaPrice(order.totalPrice),
//       S.analysisOrderListItemMetaPaid(order.paid!),
//       S.analysisOrderListItemMetaIncome(order.income),
//     ]);

//     return ListTile(
//       //唯一性
//       key: Key('analysis.order_list.${order.id}'),
//       //標題
//       //leading: buildLeading(),
//       //上面文字列
//       title: buildTitle(context),
//       //下面文字列
//       subtitle: subtitle,
//       // onTap: () => Navigator.of(context).push(
//       //   MaterialPageRoute(builder: (_) => _AnalysisOrderModal(order)),
//       // ),
//     );
//   }

//   //每單的時間
//   // Widget buildLeading() {
//   //   return Padding(
//   //     padding: const EdgeInsets.only(top: kSpacing1),
//   //     child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
//   //   );
//   // }
//   //每單的飲品名稱與數量
//   Widget buildTitle(BuildContext context) {
//     int index = 0;
//     final theme = Theme.of(context);
//     return SingleChildScrollView(
//       //SingleChildScrollView:捲動單一元件，適用於動態載入，用以解決元件實際尺寸超出可用空間
//       scrollDirection: Axis.horizontal,
//       child: Row(children: [
//         for (final product in order.products) ...[
//           if (index++ > 0) //const Text(MetaBlock.string),
//             Stack(clipBehavior: Clip.none, children: [
//               Text(product.productName),
//               if (product.count > 1)
//                 Positioned(
//                   top: 0,
//                   right: -8,
//                   child: DefaultTextStyle(
//                     style: theme.textTheme.labelSmall!.copyWith(
//                       color: theme.colorScheme.onError,
//                     ),
//                     child: IntrinsicWidth(
//                       child: Container(
//                         height: 16,
//                         clipBehavior: Clip.antiAlias,
//                         decoration: ShapeDecoration(
//                           color: theme.colorScheme.error,
//                           shape: const StadiumBorder(),
//                         ),
//                         padding: const EdgeInsets.symmetric(horizontal: 4),
//                         alignment: Alignment.center,
//                         child: Text(product.count.toString()),
//                       ),
//                     ),
//                   ),
//                 ),
//             ]),
//         ],
//         const SizedBox(width: 8),
//       ]),
//     );
//   }
// }

// class OrderCashierModal extends StatefulWidget {
//   const OrderCashierModal({Key? key}) : super(key: key);

//   @override
//   State<OrderCashierModal> createState() => _OrderCashierModalState();
// }

// class _OrderCashierModalState extends State<OrderCashierModal> {
//   final opener = GlobalKey<SlidingUpOpenerState>();
//   List<OrderObject>? _data ;

//   @override
//   void initState() {
//     super.initState();
//     _handleTest();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final totalPrice = Cart.instance.totalPrice;

//     final collapsed = OrderCashierSnapshot(totalPrice: totalPrice);

//     final panel = Container(
//       padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
//       margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
//       decoration: BoxDecoration(
//         color: theme.scaffoldBackgroundColor,
//         borderRadius: const BorderRadius.all(Radius.circular(18.0)),
//       ),
//       child: OrderCashierCalculator(
//         onSubmit: () => opener.currentState?.close(),
//         totalPrice: totalPrice,
//       ),
//     );

//     //final body = _OrderTile(_data[0]);

//     final body = OrderCashierProductList(
//       attributes: Cart.instance.selectedAttributeOptions
//           .map((e) => OrderSelectedAttributeObject.fromModel(e))
//           .toList(),
//       products: Cart.instance.products
//           .map((e) => OrderProductTileData(
//                 product: e.product,
//                 productName: e.name,
//                 ingredientNames: e.getIngredientNames(onlyQuantified: false),
//                 totalPrice: e.price,
//                 totalCount: e.count,
//               ))
//           .toList(),
//       //orderObjects: OrderObjectTileData(productName: _data[0].paid.toString()),
//       totalPrice: totalPrice,
//       productsPrice: Cart.instance.productsPrice,
//       productCost: Cart.instance.productsCost,
//     );

//     return SlidingUpOpener(
//       key: opener,
//       // 4 rows * 64 + 24 (insets) + 64 (collapse)
//       maxHeight: 408,
//       minHeight: 84,
//       heightOffset: 58,
//       renderPanelSheet: false,
//       body: body,
//       panel: panel,
//       collapsed: collapsed,
//     );
//   }

//   void _handleTest() async {
//     final data = await Seller.instance.getTodayLast();
//     print("data == $data");
//     if (data == null ) return;
//     (_data ??= []).add(data);
//   }
// }


class OrderCashierModal extends StatefulWidget {
  const OrderCashierModal({Key? key}) : super(key: key);

  @override
  State<OrderCashierModal> createState() => _OrderCashierModalState();
}

class _OrderCashierModalState extends State<OrderCashierModal> {
  final opener = GlobalKey<SlidingUpOpenerState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPrice = Cart.instance.totalPrice;

    final collapsed = OrderCashierSnapshot(totalPrice: totalPrice);

    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      margin: const EdgeInsets.fromLTRB(4.0, 0, 4.0, 16.0),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      child: OrderCashierCalculator(
        onSubmit: () => opener.currentState?.close(),
        totalPrice: totalPrice,
      ),
    );

    final body = OrderCashierProductList(
      attributes: Cart.instance.selectedAttributeOptions
          .map((e) => OrderSelectedAttributeObject.fromModel(e))
          .toList(),
      products: Cart.instance.products
          .map((e) => OrderProductTileData(
                product: e.product,
                productName: e.name,
                ingredientNames: e.getIngredientNames(onlyQuantified: false),
                totalPrice: e.price,
                totalCount: e.count,
              ))
          .toList(),
      totalPrice: totalPrice,
      productsPrice: Cart.instance.productsPrice,
      productCost: Cart.instance.productsCost,
    );

    return SlidingUpOpener(
      key: opener,
      // 4 rows * 64 + 24 (insets) + 64 (collapse)
      maxHeight: 408,
      minHeight: 84,
      heightOffset: 58,
      renderPanelSheet: false,
      body: body,
      panel: panel,
      collapsed: collapsed,
    );
  }
}

