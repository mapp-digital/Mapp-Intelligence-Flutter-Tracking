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
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    buttons.add(ElevatedButton(
      onPressed: () async {
        var pageParameters = {'Usrname': 'tom', 'Password': 'pass@123'};
        PluginMappintelligence.trackPage("customName", pageParameters);
      },
      child: Text('Track Custom Page'),
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
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
        userCategorises.emailAddress = "stefan.stevanovic@mapp.com";
        userCategorises.emailReceiverId = "8743798";
        userCategorises.firstName = "Stefan";
        userCategorises.gender = Gender.male;
        userCategorises.lastName = "Stevanovic";
        userCategorises.newsletterSubscribed = true;
        userCategorises.phoneNumber = "83203298320923";
        userCategorises.street = "Jovana Ristica";
        userCategorises.streetNumber = "2A";
        userCategorises.ustomCategories = {111: 'usercat1', 222: 'usercat2'};
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
        ecommerceProperties.productAdvertiseID = 99099;
        ecommerceProperties.productSoldOut = 13;
        ecommerceProperties.productVariant = "varient";
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
        product1.categories = {44: "product1Cat"};
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
      style:
          ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
    ));
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page Tracking'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        children: _buildButtons(context),
        padding: EdgeInsets.all(8.0),
      ),
    );
  }
}
