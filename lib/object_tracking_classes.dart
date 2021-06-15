class PageParameters {
  String? searchTerm;
  Map<int, String>? params;
  Map<int, String>? categories;

  Map<String, dynamic> toJson() => {
        'searchTerm': searchTerm,
        'params': params?.map((key, value) => MapEntry(key.toString(), value)),
        'categories':
            categories?.map((key, value) => MapEntry(key.toString(), value))
      };
}

class SessionParameters {
  Map<int, String>? parameters;

  Map<String, dynamic> toJson() => {
        'parameters':
            parameters?.map((key, value) => MapEntry(key.toString(), value))
      };
}

enum Gender { unknown, male, female }

class Birthday {
  final int day;
  final int month;
  final int year;
  const Birthday(this.day, this.month, this.year);

  Map<String, dynamic> toJson() => {'day': day, 'month': month, 'year': year};
}

class UserCategories {
  Birthday? birthday;
  String? city;
  String? country;
  String? emailAddress;
  String? emailReceiverId;
  String? firstName;
  Gender? gender;
  String? customerId;
  String? lastName;
  bool? newsletterSubscribed;
  String? phoneNumber;
  String? street;
  String? streetNumber;
  String? zipCode;
  Map<int, String>? customCategories;

  Map<String, dynamic> toJson() => {
        'birthday': birthday?.toJson(),
        'city': city,
        'country': country,
        'emailAddress': emailAddress,
        'emailReceiverId': emailReceiverId,
        'firstName': firstName,
        'gender': gender?.index,
        'customerId': customerId,
        'lastName': lastName,
        'newsletterSubscribed': newsletterSubscribed,
        'phoneNumber': phoneNumber,
        'street': street,
        'streetNumber': streetNumber,
        'zipCode': zipCode,
        'customCategories': customCategories
            ?.map((key, value) => MapEntry(key.toString(), value))
      };
}

enum Status { noneStatus, addedToBasket, purchased, viewed }

class Product {
  String? name;
  double? cost;
  int? quantity;
  double? productAdvertiseID;
  bool? productSoldOut;
  String? productVariant;
  Map<int, String>? categories;
  Map<int, String>? ecommerceParameters;

  Map<String, dynamic> toJson() => {
        'name': name,
        'cost': cost,
        'quantity': quantity,
        'productAdvertiseID': productAdvertiseID,
        'productSoldOut': productSoldOut,
        'productVariant': productVariant,
        'categories':
            categories?.map((key, value) => MapEntry(key.toString(), value)),
        'ecommerceParameters':
            ecommerceParameters?.map((key, value) => MapEntry(key.toString(), value))
      };
}

class EcommerceParameters {
  List<Product>? products;
  Status? status;
  String? currency;
  String? orderID;
  double? orderValue;
//new values
  String? returningOrNewCustomer;
  double? returnValue;
  double? cancellationValue;
  double? couponValue;
  String? paymentMethod;
  String? shippingServiceProvider;
  String? shippingSpeed;
  double? shippingCost;
  double? markUp;
  String? orderStatus;

  Map<int, String>? customParameters;

  Map<String, dynamic> toJson() => {
        'products': (products?.map((e) => e.toJson()))?.toList(),
        'status': status?.index,
        'currency': currency,
        'orderID': orderID,
        'orderValue': orderValue,
        'returningOrNewCustomer': returningOrNewCustomer,
        'returnValue': returnValue,
        'cancellationValue': cancellationValue,
        'couponValue': couponValue,
        'paymentMethod': paymentMethod,
        'shippingServiceProvider': shippingServiceProvider,
        'shippingSpeed': shippingSpeed,
        'shippingCost': shippingCost,
        'markUp': markUp,
        'orderStatus': orderStatus,
        'customParameters': customParameters
            ?.map((key, value) => MapEntry(key.toString(), value))
      };
}

enum CampaignAction { click, view }

class CampaignParameters {
  CampaignParameters(this.campaignId);
  String? campaignId;
  CampaignAction? action;
  String? mediaCode;
  bool? oncePerSession;
  Map<int, String>? customParameters;

  Map<String, dynamic> toJson() => {
        'campaignId': campaignId,
        'action': action?.index,
        'mediaCode': mediaCode,
        'oncePerSession': oncePerSession,
        'customParameters': customParameters
            ?.map((key, value) => MapEntry(key.toString(), value))
      };
}

class PageViewEvent {
  PageViewEvent(this.name);
  String? name;
  PageParameters? pageParameters;
  SessionParameters? sessionParameters;
  UserCategories? userCategories;
  EcommerceParameters? ecommerceParameters;
  CampaignParameters? campaignParameters;

  Map<String, dynamic> toJson() => {
        'name': name,
        'pageParameters': pageParameters?.toJson(),
        'sessionParameters': sessionParameters?.toJson(),
        'userCategories': userCategories?.toJson(),
        'ecommerceParameters': ecommerceParameters?.toJson(),
        'campaignParameters': campaignParameters?.toJson()
      };
}

class EventParameters {
  Map<int, String>? parameters;

  Map<String, dynamic> toJson() => {
        'parameters':
            parameters?.map((key, value) => MapEntry(key.toString(), value))
      };
}

class ActionEvent {
  ActionEvent(this.name);
  String? name;
  EventParameters? eventParameters;
  SessionParameters? sessionParameters;
  UserCategories? userCategories;
  EcommerceParameters? ecommerceParameters;
  CampaignParameters? campaignParameters;

  Map<String, dynamic> toJson() => {
        'name': name,
        'eventParameters': eventParameters?.toJson(),
        'sessionParameters': sessionParameters?.toJson(),
        'userCategories': userCategories?.toJson(),
        'ecommerceParameters': ecommerceParameters?.toJson(),
        'campaignParameters': campaignParameters?.toJson()
      };
}

class MediaParameters {
  MediaParameters(this.name);
  String? name;
  String? action;
  int? bandwith;
  int? duration;
  int? position;
  bool? soundIsMuted;
  double? soundVolume;
  Map<int, String>? customCategories;

  Map<String, dynamic> toJson() => {
        'name': name,
        'action': action,
        'bandwith': bandwith,
        'duration': duration,
        'position': position,
        'soundIsMuted': soundIsMuted,
        'soundVolume': soundVolume,
        'customCategories': customCategories
            ?.map((key, value) => MapEntry(key.toString(), value))
      };
}

class MediaEvent {
  MediaEvent(this.name, this.mediaParameters);
  String? name;
  EventParameters? eventParameters;
  //media parameters is mandatory
  MediaParameters mediaParameters;
  EcommerceParameters? ecommerceParameters;
  SessionParameters? sessionParameters;

  Map<String, dynamic> toJson() => {
        'name': name,
        'eventParameters': eventParameters?.toJson(),
        'mediaParameters': mediaParameters.toJson(),
        'ecommerceParameters': ecommerceParameters?.toJson(),
        'sessionParameters': sessionParameters?.toJson()
      };
}

enum LogLevel { all, debug, warning, error, fault, info, none }
