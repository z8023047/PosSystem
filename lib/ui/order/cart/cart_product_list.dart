import 'package:flutter/material.dart';
//import 'package:possystem/components/meta_block.dart';
import 'package:possystem/models/order/order_product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/translator.dart';
import 'package:provider/provider.dart';

import 'cart_actions.dart';

class CartProductList extends StatefulWidget {
  const CartProductList({Key? key}) : super(key: key);

  @override
  State<CartProductList> createState() => _CartProductListState();
}

class _CartProductListState extends State<CartProductList> {
  //定義滾動控制器
  late ScrollController scrollController;
  int? productCount;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();
    var count = 0;
    if (productCount != null && productCount != cart.products.length) {
      scrollToBottom();
    }

    productCount = cart.products.length;
    return SingleChildScrollView(
      key: const Key('cart.product_list'),
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final product in cart.products)
            ChangeNotifierProvider<OrderProduct>.value(
              value: product,
              child: _CartProductListTile(count++),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  Future<void> scrollToBottom() {
    return scrollController.animateTo(
      scrollController.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _CartProductListTile extends StatelessWidget {
  final int index;

  const _CartProductListTile(this.index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //context.watch<T>:
    final product = context.watch<OrderProduct>();

    final leading = Checkbox(
      key: Key('cart.product.$index.select'),
      value: product.isSelected,
      onChanged: (checked) => product.toggleSelected(checked),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    //購物車的內容顯示
    final trailing = Wrap(
      //crossAxisAlignment:交叉軸對齊方式
      //WrapCrossAlignment:文本對齊方式
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        //大小杯
        Text(
          product.size,
          key: Key('cart.product.$index.size'),
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 6),
        //甜度
        Text(product.sugar,
            key: Key('cart.product.$index.sugar'),
            style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        //冰量
        Text(product.ice,
            key: Key('cart.product.$index.ice'),
            style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        //加料
        Text(product.content?.join(',') ?? '',
            key: Key('cart.product.$index.content'),
            style: TextStyle(fontSize: 18)),
        const SizedBox(width: 6),
        //++Icon
        IconButton(
          key: Key('cart.product.$index.add'),
          icon: const Icon(Icons.add_circle_outline_sharp),
          onPressed: () => product.increment(),
        ),
        //數量
        Text(product.count.toString(),
            key: Key('cart.product.$index.count'),
            style: TextStyle(fontSize: 18)),
        //--Icon
        IconButton(
          key: Key('cart.product.$index.decrease'),
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => {product.decrement()},
        ),
        //價格
        Text(S.orderCartItemPrice(product.newPrice),
            key: Key('cart.product.$index.price'),
            style: TextStyle(fontSize: 18)),
      ],
    );

    return MergeSemantics(
      //ListTileTheme:用於控制ListTile的樣式
      child: ListTileTheme.merge(
        selectedColor: DefaultTextStyle.of(context).style.color,
        child: ListTile(
          key: Key('cart.product.$index'),
          leading: leading,
          //TextOverflow:內容顯示方式，ellipsis為超過螢幕的為...
          title: Text(product.name,
              style:
                  TextStyle(fontSize: 18)), //, overflow: TextOverflow.ellipsis
          // subtitle: product.isEmpty
          //     ? null
          //     : MetaBlock.withString(
          //         context,
          //         product.getIngredientNames(),
          //       ),
          trailing: trailing,
          onTap: () => Cart.instance.toggleAll(false, except: product),
          onLongPress: () {
            Cart.instance.toggleAll(false, except: product);
            CartActions.showActions(context);
          },
          selected: product.isSelected,
          selectedTileColor: theme.primaryColorLight,
        ),
      ),
    );
  }
}
