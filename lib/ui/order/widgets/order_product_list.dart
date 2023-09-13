import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/components/tutorial.dart';
import 'package:possystem/constants/constant.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/repository/cart.dart';
import 'package:possystem/settings/order_product_axis_count_setting.dart';
import 'package:possystem/settings/settings_provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

class OrderProductList extends StatelessWidget {
  final List<Product> products;
  
  const OrderProductList({
    Key? key,
    required this.products,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = SettingsProvider.of<OrderProductAxisCountSetting>().value;
    int index = 0;

    return Card(
      // Small top margin to avoid double size between catalogs
      //margin:外部間距,horizontal水平間距，也就是與左右2邊的距離
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(kSpacing1),
        child: count == 0
            ? Wrap(children: [
                for (final product in products)
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    //種類欄按鈕的樣式
                    child: ElevatedButton(
                      key: Key('order.product.${product.id}'),
                      onPressed: () => {
                        _onSelected(product,context),
                        //showAlertDialog(product,context),
                      },
                      child: Text(product.name),
                    ),
                  ),
              ])
            : GridView.count(
              //表示橫軸上顯示子組件的數量
                crossAxisCount: 4,
              //表示主軸上子組件間的間隙大小  
                mainAxisSpacing: 12.0,
              //表示交叉軸上子組件間的間隙大小   
                crossAxisSpacing: 8.0,
                children: [
                  for (final product in products)
                    Tutorial(
                      id: 'order.menu_product',
                      title: '開始點餐！',
                      message: '透過圖片點餐更方便！\n'
                          '你也可以到「設定」頁面，\n'
                          '設定「每行顯示幾個產品」或僅使用文字點餐',
                      spotlightBuilder:
                          const SpotlightRectBuilder(borderRadius: 16),
                      disable: index++ != 0,
                      //飲品本身按鈕的樣式
                      child: ImageHolder(
                        key: Key('order.product.${product.id}'),
                        image: product.image,
                        title: product.name,
                        onPressed: () => _onSelected(product,context),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
  
  void _onSelected(Product product,BuildContext context) {
    Cart.instance
      //確定目前是誰被選到
      ..toggleAll(false)
      ..showAlertDialog(product,context);
      //加入購物車
      //..add(product);
  }

}

