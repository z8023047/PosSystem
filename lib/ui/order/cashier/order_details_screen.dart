import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';
import 'order_cashier_check.dart';
import 'order_cashier_modal.dart';
import 'order_set_attribute_modal.dart';

import 'package:flutter/material.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/models/repository/seller.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

import '../../analysis/widgets/analysis_order_list.dart';
//import '../../analysis/widgets/calendar_wrapper.dart';
import '../cashier/order_cashier_calender.dart';
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

class AnalysisOrderList<T> extends StatefulWidget {
  final Future<List<OrderObject>> Function(T, int) handleLoad;

  const AnalysisOrderList({Key? key, required this.handleLoad})
      : super(key: key);

  @override
  State<AnalysisOrderList<T>> createState() => AnalysisOrderListState<T>();
}

class AnalysisOrderListState<T> extends State<AnalysisOrderList<T>> {
  late final RefreshController _scrollController;

  final List<OrderObject> _data = [];
  late T _params;
  bool _isLoading = false;

  num totalPrice = 0;
  int totalCount = 0;

  @override
  Widget build(BuildContext context) {
    if (_isLoading == true) {
      return const CircularLoading();
    } else if (_data.isEmpty) {
      return HintText(S.analysisOrderListStatus('empty'));
    }

    return Column(
      children: [
        Center(
          child: MetaBlock.withString(context, [
            S.analysisOrderListMetaPrice(123456),
            S.analysisOrderListMetaCount(totalCount),
          ]),
        ),
        Expanded(
          // child: ListView.builder(
          //   itemBuilder: (context, index) => _OrderTile(_data[index]),
          //   itemCount: _data.length,
          // ),
         // SmartRefresher:實現下拉刷新和上拉加載功能
          child: SmartRefresher(
            controller: _scrollController,
            enablePullUp: true,
            enablePullDown: true,
            onRefresh: () => _handleRefresh(),
            onLoading: () => _handleLoad(),
            footer: _buildFooter(),
            child: ListView.builder(
              itemBuilder: (context, index) => _OrderTile(_data[index]),
              itemCount: _data.length,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController = RefreshController();
  }

  void reset(T params, {required num totalPrice, required int totalCount}) {
    setState(() {
      this.totalPrice = totalPrice;
      this.totalCount = totalCount;
      _params = params;
      _data.clear();
      _isLoading = true;
      _handleLoad();
    });
  }

  Widget _buildFooter() {
    return CustomFooter(
      height: 30,
      builder: (BuildContext context, LoadStatus? mode) {
        switch (mode) {
          case LoadStatus.canLoading:
            return Center(child: Text(S.analysisOrderListStatus('ready')));
          case LoadStatus.loading:
            return const CircularLoading();
          case LoadStatus.noMore:
            return Center(child: Text(S.analysisOrderListStatus('allLoaded')));
          default:
            return Container();
        }
      },
    );
  }

  void _handleRefresh() async {
    _data.clear();
    await _handleLoad();
    _scrollController.refreshCompleted(resetFooterState: true);
  }

  Future<void> _handleLoad() async {
    final data = await widget.handleLoad(_params, _data.length);

    _data.addAll(data);
    data.isEmpty
        ? _scrollController.loadNoData()
        : _scrollController.loadComplete();

    setState(() => _isLoading = false);
  }
}

//點擊後跳出結帳後的畫面
class _AnalysisOrderModal extends StatelessWidget {
  final OrderObject order;

  const _AnalysisOrderModal(this.order);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          IconButton(
            key: const Key('analysis.more'),
            onPressed: () => _showActions(context),
            enableFeedback: true,
            icon: const Icon(KIcons.more),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: HintText(_parseCreatedAt(order.createdAt)),
        ),
        Expanded(
          child: OrderCashierProductList(
            attributes: order.attributes.toList(),
            products: order.products
                .map((product) => OrderProductTileData(
                      product: Menu.instance.getProduct(product.productId),
                      productName: product.productName,
                      ingredientNames:
                          product.ingredients.map((e) => e.quantityName == null
                              ? S.orderProductIngredientDefaultName(e.name)
                              : S.orderProductIngredientName(
                                  e.name,
                                  e.quantityName!,
                                )),
                      totalCount: product.count,
                      totalCost: product.totalCost,
                      totalPrice: product.totalPrice,
                    ))
                .toList(),
            //orderObjects: OrderObjectTileData(  productName: order.paid.toString()),
            productsPrice: order.productsPrice,
            totalPrice: order.totalPrice,
            productCost: order.cost,
            income: order.income,
            paid: order.paid,
          ),
        ),
      ]),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final form = GlobalKey<_WarningContextState>();
    await BottomSheetActions.withDelete<_Action>(
      context,
      deleteCallback: () => showSnackbarWhenFailed(
        Seller.instance.delete(order, form.currentState?.recoverOther ?? false),
        context,
        'analysis_delete_error',
      ),
      deleteValue: _Action.delete,
      popAfterDeleted: true,
      warningContent: _WarningContext(order, key: form),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderObject order;

  const _OrderTile(this.order);

  @override
  Widget build(BuildContext context) {
    final subtitle = MetaBlock.withString(context, [
      //統計顯示的售價，付額，淨利
      S.analysisOrderListItemMetaPrice(order.totalPrice),
      S.analysisOrderListItemMetaPaid(order.paid!),
      S.analysisOrderListItemMetaIncome(order.income),
    ]);

    return ListTile(
      //唯一性
      key: Key('analysis.order_list.${order.id}'),
      //標題
      leading: buildLeading(),
      //上面文字列
      title: buildTitle(context),
      //下面文字列
      subtitle: subtitle,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _AnalysisOrderModal(order)),
      ),
    );
  }

  //每單的時間
  Widget buildLeading() {
    return Padding(
      padding: const EdgeInsets.only(top: kSpacing1),
      child: Text(DateFormat.Hm(S.localeName).format(order.createdAt)),
    );
  }

  //每單的飲品名稱與數量
  Widget buildTitle(BuildContext context) {
    int index = 0;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      //SingleChildScrollView:捲動單一元件，適用於動態載入，用以解決元件實際尺寸超出可用空間
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        for (final product in order.products) ...[
          if (index++ > 0) const Text(MetaBlock.string),
          Stack(clipBehavior: Clip.none, children: [
            Text(product.productName),
            if (product.count > 1)
              Positioned(
                top: 0,
                right: -8,
                child: DefaultTextStyle(
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                  child: IntrinsicWidth(
                    child: Container(
                      height: 16,
                      clipBehavior: Clip.antiAlias,
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.error,
                        shape: const StadiumBorder(),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      child: Text(product.count.toString()),
                    ),
                  ),
                ),
              ),
          ]),
        ],
        const SizedBox(width: 8),
      ]),
    );
  }
}

class _WarningContext extends StatefulWidget {
  final OrderObject order;

  const _WarningContext(this.order, {Key? key}) : super(key: key);

  @override
  State<_WarningContext> createState() => _WarningContextState();
}

class _WarningContextState extends State<_WarningContext> {
  bool recoverOther = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('確定要刪除 ${_parseCreatedAt(widget.order.createdAt)} 的訂單嗎？'),
        const Text('\n此動作無法復原'),
        const Divider(height: 32),
        CheckboxListTile(
          key: const Key('analysis.tile_del_with_other'),
          autofocus: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: recoverOther,
          selected: recoverOther,
          onChanged: _onChanged,
          title: const Text('復原對應的庫存和收銀機資料'),
        ),
        if (recoverOther) ..._iterStockHint(context),
        if (recoverOther) ..._iterCashierHint(context),
      ]),
    );
  }

  Iterable<Widget> _iterStockHint(BuildContext context) sync* {
    final amounts = <String, num>{};
    widget.order.fillIngredient(amounts, add: true);

    for (final entry in amounts.entries) {
      final ing = Stock.instance.getItem(entry.key);
      if (ing != null && entry.value != 0) {
        final operator = entry.value > 0 ? '增加' : '減少';
        final v = entry.value > 0 ? entry.value : -entry.value;
        yield Text('${(ing.name)} 將$operator $v 單位');
      }
    }
  }

  Iterable<Widget> _iterCashierHint(BuildContext context) sync* {
    final amounts = <int, int>{};
    final status = Cashier.instance.smallChange(
      amounts,
      widget.order.totalPrice,
      add: false,
    );

    for (final entry in amounts.entries) {
      final e = Cashier.instance.at(entry.key);
      yield Text(
          '${e.unit} 元將減少 ${-entry.value} 個至 ${e.count + entry.value} 個');
    }

    String? errorText;
    switch (status) {
      case CashierUpdateStatus.notEnough:
        errorText = '收銀機將不夠錢換，不管了。';
        break;
      case CashierUpdateStatus.usingSmall:
        errorText = '收銀機要用小錢換才能滿足。';
        break;
      default:
        break;
    }
    if (errorText != null) {
      yield Text(
        errorText,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
  }

  void _onChanged(value) {
    setState(() {
      recoverOther = value ?? false;
    });
  }
}

enum _Action {
  delete,
}

String _parseCreatedAt(DateTime t) {
  return DateFormat.MMMEd(S.localeName).format(t) +
      MetaBlock.string +
      DateFormat.jms(S.localeName).format(t);
}

class OrderCheck extends StatelessWidget {
  final TutorialInTab?  tab;

  final orderList = GlobalKey<AnalysisOrderListState<_OrderListParams>>();

  OrderCheck({Key? key, this.tab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TutorialWrapper(
      startWhenReady: false,
      child: OrientationBuilder(
        key: const Key('analysis.builder'),
        builder: (_, orientation) => orientation == Orientation.portrait
            ? _buildPortrait()
            : _buildLandscape(),
      ),
    );
  }

  Widget _buildCalendar({required bool isPortrait}) {
    return Tutorial(
      id: 'analysis.calendar',
      title: '日曆格式',
      message: '上下滑動可以調整週期單位，如月或週。\n左右滑動可以調整日期起訖。',
      tab: tab,
      //spotlightBuilder: const SpotlightRectBuilder(),
      child: CalendarWrapper(
        //isPortrait: isPortrait,
        handleDaySelected: _handleDaySelected,
        searchCountInMonth: _searchCountInMonth,
      ),
    );
  }

  Widget _buildLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //Expanded(child: _buildCalendar(isPortrait: false)),
        //_buildCalendar(isPortrait: false),
        Expanded(child: _buildOrderList()),
      ],
    );
  }

  Widget _buildPortrait() {
    return Column(children: [
      _buildCalendar(isPortrait: true),
      Expanded(child: _buildOrderList()),
    ]);
  }

  Widget _buildOrderList() {
    return AnalysisOrderList<_OrderListParams>(
      key: orderList,
      handleLoad: (_OrderListParams params, int offset) =>
          Seller.instance.getOrderBetween(params.start, params.end, offset),
    );
  }

  void _handleDaySelected(DateTime day) async {
    final end = DateTime(day.year, day.month, day.day + 1);
    final start = DateTime(day.year, day.month, day.day);

    final result = await Seller.instance.getMetricBetween(start, end);
   
    orderList.currentState?.reset(
      _OrderListParams(start: start, end: end),
      totalPrice: result['totalPrice'] as num,
      totalCount: result['count'] as int,
    );
  }

  Future<Map<DateTime, int>> _searchCountInMonth(DateTime day) {
    // add/sub 7 days for first/last few days on next/last month
    final end = DateTime(day.year, day.month + 1).add(const Duration(days: 7));
    final start =
        DateTime(day.year, day.month).subtract(const Duration(days: 7));

    return Seller.instance.getCountBetween(start, end);
  }
}

class _OrderListParams {
  final DateTime start;
  final DateTime end;

  const _OrderListParams({required this.start, required this.end});
}

// class OrderDetailsScreen extends StatefulWidget {
//   const OrderDetailsScreen({Key? key}) : super(key: key);

//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }
// // SingleTickerProviderStateMixin用於實現滾動的動態效果
// class _OrderDetailsScreenState extends State<OrderDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   //選項卡控制器
//   late final TabController _controller;

//   late bool hasAttr;

//   @override
//   Widget build(BuildContext context) {
//     // tab widgets
//     PreferredSizeWidget? tabBar;
//     //更改成AnalysisOrderList()
//     Widget body = OrderCashierModal();

//     if (hasAttr) {
//       tabBar = TabBar(
//         controller: _controller,
//         tabs: [
//           Tab(key: const Key('order.set_attr'), text: S.orderSetAttributeTitle),
//           Tab(key: const Key('order.cashier'), text: S.orderCashierTitle),
//         ],
//       );

//       body = DefaultTabController(
//         length: 2,
//         child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
//           Expanded(
//             child: TabBarView(controller: _controller, children: const [
//               OderSetAttributeModal(),
//               OrderCashierModal(),
//             ]),
//           ),
//         ]),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         leading: const PopButton(),
//         actions: [
//           TextButton(
//             key: const Key('order.checkout'),
//             onPressed: onCheckout,
//             child: Text(S.orderCashierCheckout,style: const TextStyle(fontSize: 20),),
//           ),
//         ],
//         bottom: tabBar,
//       ),
//       body: body,
//     );
//   }

//   @override

//   void initState() {
//     super.initState();

//     hasAttr = OrderAttributes.instance.hasNotEmptyItems;
//     final setBefore = hasAttr && Cart.instance.attributes.isNotEmpty;

//     _controller = TabController(
//       initialIndex: setBefore ? 1 : 0,
//       length: hasAttr ? 2 : 1,
//       vsync: this,
//     );
//   }
//   //完成按鈕
//   void onCheckout() async {
//     if (context.mounted) {
//       final confirmed = await _confirmChangeHistory(context);
//       if (confirmed) {
//         try {
//           final result = await Cart.instance.checkout();
//           // send success message
//           if (context.mounted) {
//             Navigator.of(context).pop(result);
//           }
//         } on PaidException {
//           if (context.mounted) {
//             showSnackBar(context, S.orderCashierPaidFailed);
//           }
//         }
//       }
//     }
//   }

//   /// Confirm leaving history mode
//   Future<bool> _confirmChangeHistory(BuildContext context) async {
//     if (!Cart.instance.isHistoryMode) return true;

//     return await ConfirmDialog.show(
//       context,
//       title: S.orderCashierPaidConfirmLeaveHistoryMode,
//     );
//   }
// }
