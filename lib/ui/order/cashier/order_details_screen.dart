import 'package:flutter/material.dart';
import 'package:possystem/components/dialog/confirm_dialog.dart';
import 'package:possystem/components/style/pop_button.dart';
import 'package:possystem/components/style/snackbar.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/models/repository/order_attributes.dart';
import 'package:possystem/translator.dart';

import 'order_cashier_modal.dart';
import 'order_set_attribute_modal.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({Key? key}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}
// SingleTickerProviderStateMixin用於實現滾動的動態效果
class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  //選項卡控制器
  late final TabController _controller;

  late bool hasAttr;

  @override
  Widget build(BuildContext context) {
    // tab widgets
    PreferredSizeWidget? tabBar;
    Widget body = const OrderCashierModal();

    if (hasAttr) {
      tabBar = TabBar(
        controller: _controller,
        tabs: [
          Tab(key: const Key('order.set_attr'), text: S.orderSetAttributeTitle),
          Tab(key: const Key('order.cashier'), text: S.orderCashierTitle),
        ],
      );

      body = DefaultTabController(
        length: 2,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Expanded(
            child: TabBarView(controller: _controller, children: const [
              OderSetAttributeModal(),
              OrderCashierModal(),
            ]),
          ),
        ]),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const PopButton(),
        actions: [
          TextButton(
            key: const Key('order.checkout'),
            onPressed: onCheckout,
            child: Text(S.orderCashierCheckout,style: const TextStyle(fontSize: 20),),
          ),
        ],
        bottom: tabBar,
      ),
      body: body,
    );
  }

  @override
  
  void initState() {
    super.initState();

    hasAttr = OrderAttributes.instance.hasNotEmptyItems;
    final setBefore = hasAttr && Cart.instance.attributes.isNotEmpty;

    _controller = TabController(
      initialIndex: setBefore ? 1 : 0,
      length: hasAttr ? 2 : 1,
      vsync: this,
    );
  }
  //完成按鈕
  void onCheckout() async {
    if (context.mounted) {
      final confirmed = await _confirmChangeHistory(context);
      if (confirmed) {
        try {
          final result = await Cart.instance.checkout();
          // send success message
          if (context.mounted) {
            Navigator.of(context).pop(result);
          }
        } on PaidException {
          if (context.mounted) {
            showSnackBar(context, S.orderCashierPaidFailed);
          }
        }
      }
    }
  }

  /// Confirm leaving history mode
  Future<bool> _confirmChangeHistory(BuildContext context) async {
    if (!Cart.instance.isHistoryMode) return true;

    return await ConfirmDialog.show(
      context,
      title: S.orderCashierPaidConfirmLeaveHistoryMode,
    );
  }
}
