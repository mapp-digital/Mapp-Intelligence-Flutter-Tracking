import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';

class ProductStatuses extends StatelessWidget {
  const ProductStatuses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ecommerceProperties = EcommerceParameters();
    ecommerceProperties.cancellationValue = 99.4;
    ecommerceProperties.couponValue = 88.9;
    ecommerceProperties.currency = "EUR";
    ecommerceProperties.customParameters = {7: 'ecommerceParameter1'};
    ecommerceProperties.markUp = 11.3;
    ecommerceProperties.orderID = "2121";
    ecommerceProperties.orderStatus = "payed";
    ecommerceProperties.orderValue = 4445.8;
    ecommerceProperties.paymentMethod = "credit card";
    ecommerceProperties.returnValue = 23.7;
    ecommerceProperties.returningOrNewCustomer = "new one";
    ecommerceProperties.shippingCost = 22.3;
    ecommerceProperties.shippingServiceProvider = "DHL";
    ecommerceProperties.shippingSpeed = "low";
    ecommerceProperties.status = Status.addedToBasket;

    final product = Product();
    product.name = "T-Shirt";
    product.quantity = 10;
    product.cost = 33.2;
    product.productAdvertiseID = 99099;
    product.productSoldOut = true;
    product.productVariant = "varient";
    product.categories = {44: "product1Cat"};
    product.ecommerceParameters = {22: "dada"};

    final pageViewEvent = PageViewEvent("testNameFlutter");
    pageViewEvent.ecommerceParameters = ecommerceProperties;

    ecommerceProperties.products = [product];

    final buttons = [
      MaterialButton(
          child: Text("None"),
          onPressed: () {
            ecommerceProperties.status = Status.noneStatus;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Added to basked"),
          onPressed: () {
            ecommerceProperties.status = Status.addedToBasket;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Purchased"),
          onPressed: () {
            ecommerceProperties.status = Status.purchased;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Viewed"),
          onPressed: () {
            ecommerceProperties.status = Status.viewed;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Deleted From Basked"),
          onPressed: () {
            ecommerceProperties.status = Status.deletedFromBasket;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Added to Whishlist"),
          onPressed: () {
            ecommerceProperties.status = Status.addedToWishlist;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Deleted from Whishlist"),
          onPressed: () {
            ecommerceProperties.status = Status.deletedFromWishlist;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
      MaterialButton(
          child: Text("Checkout"),
          onPressed: () {
            ecommerceProperties.status = Status.checkout;
            PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
          }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Product Statuses"),
      ),
      body: ListView(
        children: buttons,
      ),
    );
  }
}
