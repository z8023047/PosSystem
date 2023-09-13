import 'package:flutter/material.dart';
import 'package:possystem/components/style/image_holder.dart';
import 'package:possystem/components/mixin/item_modal.dart';
import 'package:possystem/helpers/validator.dart';
import 'package:possystem/models/menu/catalog.dart';
import 'package:possystem/models/menu/product.dart';
import 'package:possystem/models/objects/menu_object.dart';
import 'package:possystem/models/repository/menu.dart';
import 'package:possystem/routes.dart';
import 'package:possystem/translator.dart';

class ProductModal extends StatefulWidget {
  final Product? product;
  final Catalog catalog;
  final bool isNew;

  const ProductModal({
    Key? key,
    this.product,
    required this.catalog,
  })  : isNew = product == null,
        super(key: key);

  @override
  State<ProductModal> createState() => _ProductModalState();
}

class _ProductModalState extends State<ProductModal>
    with ItemModal<ProductModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costController;

  late FocusNode _nameFocusNode;
  late FocusNode _priceFocusNode;
  late FocusNode _costFocusNode;

  String? _image;

  @override
  List<Widget> buildFormFields() {
    return [
      EditImageHolder(
        path: _image,
        onSelected: (image) => setState(() => _image = image),
      ),
      TextFormField(
        key: const Key('product.name'),
        controller: _nameController,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        autofocus: widget.isNew,
        focusNode: _nameFocusNode,
        decoration: InputDecoration(
          labelText: S.menuProductNameLabel,
          hintText: S.menuProductNameHint,
          filled: false,
        ),
        maxLength: 30,
        validator: Validator.textLimit(
          //飲品名稱
          S.menuProductNameLabel,
          30,
          focusNode: _nameFocusNode,
          validator: (name) {
            return widget.product?.name != name &&
                    Menu.instance.hasProductByName(name)
                ? S.menuProductNameRepeatError
                : null;
          },
        ),
      ),
      TextFormField(
        key: const Key('product.price'),
        controller: _priceController,
        textInputAction: TextInputAction.next,
        //鍵盤的類型
        keyboardType: TextInputType.number,
        focusNode: _priceFocusNode,
        decoration: InputDecoration(
          //飲品價格
          labelText: S.menuProductPriceLabel,
          //hintText: S.menuProductPriceHint,
          filled: false,
        ),
        validator: Validator.isNumber(
          S.menuProductPriceLabel,
          focusNode: _priceFocusNode,
        ),
      ),
      TextFormField(
        key: const Key('product.cost'),
        controller: _costController,
        //鍵盤操作按鈕的類行 done:完成動作 
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.number,
        focusNode: _costFocusNode,
        decoration: InputDecoration(
          //飲品成本
          labelText: S.menuProductCostLabel,
          hintText: S.menuProductCostHint,
          filled: false,
        ),
        onFieldSubmitted: (_) => handleSubmit(),
        validator: Validator.positiveNumber(
          S.menuProductCostLabel,
          focusNode: _costFocusNode,
        ),
      ),
      // TextFormField(
      //   key: const Key('product.ice'),
      //   controller: _iceController,
      //   //next:下個
      //   textInputAction: TextInputAction.done,
      //   textCapitalization: TextCapitalization.words,
      //   focusNode: _iceFocusNode,
      //   decoration: InputDecoration(
      //     //test新增東西
      //     labelText: S.menuProductIceLabel,
      //     //hintText: S.menuProductCostHint,
      //     filled: false,
      //   ),
      //   maxLength: 30,
      //   validator: Validator.textLimit(
          
      //     S.menuProductIceLabel,
      //     20,
      //     focusNode: _iceFocusNode,
      //     // validator: (ice) {
      //     //   return widget.product?.ice != ice &&
      //     //           Menu.instance.hasProductByName(ice)
      //     //       ? S.menuProductNameRepeatError
      //     //       : null;
          
      //   ),
      // ),
    ];
  }
  //儲存後把物品新增進去
  Future<Product> getProduct() async {
    final object = _parseObject();
    final product = widget.product ??
        Product(
          index: widget.catalog.newIndex,
          name: object.name!,
          price: object.price!,
          cost: object.cost!,
          //ice: object.ice!,
          //size: object.size!,
          imagePath: _image,
        );

    if (widget.isNew) {
      await widget.catalog.addItem(product);
    } else {
      await product.update(object);
    }

    return product;
  }

  @override
  void initState() {
    super.initState();

    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _priceController = TextEditingController(text: p?.price.toString());
    _costController = TextEditingController(text: p?.cost.toString());
    _nameFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _costFocusNode = FocusNode();
    _image = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();

    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _costFocusNode.dispose();

    super.dispose();
  }
  //Future:異步，用在結果會在未來完成的情況
  @override
  Future<void> updateItem() async {
    final product = await getProduct();

    if (mounted) {
      // go to product screen
      widget.isNew
          ? Navigator.of(context).popAndPushNamed(
              Routes.menuProduct,
              arguments: product,
            )
          : Navigator.of(context).pop();
    }
  }

  ProductObject _parseObject() {
    return ProductObject(
      name: _nameController.text,
      imagePath: _image,
      //tryParse: 把文字化的數字變成真正能提供運算的數字，本身會嘗試轉換會視成功與否回傳1或0
      price: num.tryParse(_priceController.text),
      cost: num.tryParse(_costController.text),

    );
  }
}
