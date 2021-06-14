import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

// ignore: must_be_immutable
class Ecommerce extends StatelessWidget {
  List<Product> prepareProducts() {
    Product product1 = Product();
    product1.name = "Product1";
    product1.categories = {1: "ProductCat1", 2: "ProductCat2"};
    product1.cost = 13;
    product1.productAdvertiseID = 56291;
    product1.productSoldOut = 0;
    product1.quantity = 4;

    Product product2 = Product();
    product2.name = "Product2";
    product2.categories = {2: "ProductCat2"};
    product2.cost = 50;
    product2.productAdvertiseID = 562918888888888;
    product2.productSoldOut = 1;
    product2.productVariant = "testVariant";
    return [product1, product2];
  }

  EcommerceParameters getBaseEcommerce() {
    var parameters = EcommerceParameters();
    parameters.customParameters = {
      1: "ProductParam1;ProductParam1",
      2: "ProductParam2"
    };
    return parameters;
  }

  double calculateOrderValue(EcommerceParameters ecommerceParameters) {
    var totalCost = 0.0;
    ecommerceParameters.products?.forEach((product) {
      totalCost = totalCost + (product.cost ?? 0) * (product.quantity ?? 1);
    });
    totalCost = totalCost +
        (ecommerceParameters.shippingCost ?? 0) -
        (ecommerceParameters.couponValue ?? 0);
    return totalCost;
  }

  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        var ecommerceParameters1 = EcommerceParameters();
        ecommerceParameters1.customParameters = {
          1: "ProductParam1",
          2: "ProductParam2"
        };

        ecommerceParameters1.products = [prepareProducts()[0]];
        ecommerceParameters1.status = Status.viewed;
        ecommerceParameters1.cancellationValue = 2;
        ecommerceParameters1.couponValue = 33;
        ecommerceParameters1.currency = "EUR";
        ecommerceParameters1.markUp = 1;
        ecommerceParameters1.orderStatus = "order received";
        ecommerceParameters1.orderID = "ud679adn";
        ecommerceParameters1.orderValue = 456;
        ecommerceParameters1.paymentMethod = "credit card";
        ecommerceParameters1.returnValue = 3;
        ecommerceParameters1.returningOrNewCustomer = "new customer";
        ecommerceParameters1.shippingCost = 35;
        ecommerceParameters1.shippingSpeed = "highest";
        ecommerceParameters1.shippingServiceProvider = "DHL";

        var pageEvent = PageViewEvent("TrackProductView");
        pageEvent.ecommerceParameters = ecommerceParameters1;

        PluginMappintelligence.trackPageWithCustomData(pageEvent);

        pageEvent.ecommerceParameters!.products = [prepareProducts()[1]];
        PluginMappintelligence.trackPageWithCustomData(pageEvent);
      },
      child: Text('View Product'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var ecommerceParameters1 = EcommerceParameters();
        ecommerceParameters1.customParameters = {
          1: "ProductParam1",
          2: "ProductParam2"
        };
        var product1 = prepareProducts()[0];
        var product2 = prepareProducts()[1];
        product1.quantity = 3;
        product2.quantity = 2;

        ecommerceParameters1.status = Status.addedToBasket;
        ecommerceParameters1.products = [product1];

        var pageEvent = PageViewEvent("TrackProductAddedToBasket");
        pageEvent.ecommerceParameters = ecommerceParameters1;

        PluginMappintelligence.trackPageWithCustomData(pageEvent);

        pageEvent.ecommerceParameters!.products = [product2];
        PluginMappintelligence.trackPageWithCustomData(pageEvent);
      },
      child: Text('Add to basket'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var product1 = prepareProducts()[0];
        var product2 = prepareProducts()[1];
        product1.quantity = 3;
        product2.quantity = 2;

        var ecommerceParameters = getBaseEcommerce();

        ecommerceParameters.products = [product1, product2];
        ecommerceParameters.currency = "EUR";
        ecommerceParameters.orderID = "1234nb5";
        ecommerceParameters.paymentMethod = "Credit Card";
        ecommerceParameters.shippingServiceProvider = "DHL";
        ecommerceParameters.shippingSpeed = "express";
        ecommerceParameters.shippingCost = 20;
        ecommerceParameters.couponValue = 10;
        ecommerceParameters.orderValue =
            calculateOrderValue(ecommerceParameters);
        ecommerceParameters.status = Status.purchased;

        var pageEvent = PageViewEvent("TrackProductConfirmed");
        pageEvent.ecommerceParameters = ecommerceParameters;

        PluginMappintelligence.trackPageWithCustomData(pageEvent);
      },
      child: Text('Confirmation'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ecommerce'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
