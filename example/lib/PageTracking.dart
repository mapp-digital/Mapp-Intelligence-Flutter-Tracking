import 'package:flutter/material.dart';
import 'package:plugin_mappintelligence/plugin_mappintelligence.dart';
import 'package:plugin_mappintelligence/object_tracking_classes.dart';

class PageTracking extends StatelessWidget {
  List<Widget> _buildButtons(BuildContext context) {
    List<Widget> buttons = [];
    buttons.add(ElevatedButton(
      onPressed: () async {
        String className = this.runtimeType.toString();
        PluginMappintelligence.trackPage(className);
      },
      child: Text('Track Page'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var pageParameters = {'uc709': 'Berlin'};
        PluginMappintelligence.trackPage("customName", pageParameters);
      },
      child: Text('Track Custom Page'),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var pageProperties = PageParameters();
        pageProperties.searchTerm = "searchTerm";
        pageProperties.categories = {1: 'tom', 2: 'pass@123'};
        pageProperties.params = {11: 'tom', 22: 'pass@123'};

        var sessionPropertis = SessionParameters();
        sessionPropertis.parameters = {10: 'sessionParameter1'};

        var userCategorises = UserCategories();
        userCategorises.birthday = Birthday(7, 12, 1991);
        userCategorises.city = "Nis";
        userCategorises.country = "Serbia";
        userCategorises.customerId = "99898390";
        userCategorises.gender = Gender.female;
        userCategorises.newsletterSubscribed = true;
        userCategorises.street = "Jovana Ristica";
        userCategorises.customCategories = {17: 'usercat1', 22: 'usercat2'};
        userCategorises.zipCode = "780s00";

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
        var product1 = Product();
        product1.name = "T-Shirt";
        product1.quantity = 10;
        product1.cost = 33.2;
        product1.productAdvertiseID = 99099;
        product1.productSoldOut = true;
        product1.productVariant = "varient";
        product1.categories = {44: "product1Cat"};
        product1.ecommerceParameters = {22: "dada"};
        ecommerceProperties.products = [product1];

        var campaignProperties = CampaignParameters(null);
        campaignProperties.action = CampaignAction.click;
        campaignProperties.campaignId = "4387324978789234";
        campaignProperties.customParameters = {78: 'campaignParameter1'};
        campaignProperties.mediaCode = "mediaCode";
        campaignProperties.oncePerSession = false;

        var pageViewEvent = PageViewEvent("testNameFlutter");
        pageViewEvent.pageParameters = pageProperties;
        pageViewEvent.sessionParameters = sessionPropertis;
        pageViewEvent.userCategories = userCategorises;
        pageViewEvent.ecommerceParameters = ecommerceProperties;
        pageViewEvent.campaignParameters = campaignProperties;
        PluginMappintelligence.trackPageWithCustomData(pageViewEvent);
      },
      child: Text('Track Page with custom data'),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Tracking'),
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
