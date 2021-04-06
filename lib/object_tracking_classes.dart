class MIPageParameters {
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

class MISessionParameters {
  Map<int, String>? parameters;

  Map<String, dynamic> toJson() => {
        'parameters':
            parameters?.map((key, value) => MapEntry(key.toString(), value))
      };
}

enum MIGender { unknown, male, female }

class MIBirthday {
  final int day;
  final int month;
  final int year;
  const MIBirthday(this.day, this.month, this.year);

  Map<String, dynamic> toJson() => {'day': day, 'month': month, 'year': year};
}

class MIUserCategories {
  MIBirthday? birthday;
  String? city;
  String? country;
  String? emailAddress;
  String? emailReceiverId;
  String? firstName;
  MIGender? gender;
  String? customerId;
  String? lastName;
  bool? newsletterSubscribed;
  String? phoneNumber;
  String? street;
  String? streetNumber;
  String? zipCode;
  Map<int, String>? ustomCategories;

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
        'ustomCategories': ustomCategories
            ?.map((key, value) => MapEntry(key.toString(), value))
      };
}

enum MIStatus { noneStatus, addedToBasket, purchased, viewed }

class MIProduct {
  String? name;
  double? cost;
  int? quantity;
  Map<int, String>? categories;

  Map<String, dynamic> toJson() => {
        'name': name,
        'cost': cost,
        'quantity': quantity,
        'categories':
            categories?.map((key, value) => MapEntry(key.toString(), value))
      };
}

class MIEcommerceParameters {
  List<MIProduct>? products;
  MIStatus? status;
  String? currency;
  String? orderID;
  double? orderValue;
//new values
  String? returningOrNewCustomer;
  double? returnValue;
  double? cancellationValue;
  double? couponValue;
  double? productAdvertiseID;
  int? productSoldOut;
  String? paymentMethod;
  String? shippingServiceProvider;
  String? shippingSpeed;
  double? shippingCost;
  double? markUp;
  String? orderStatus;
  String? productVariant;

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
        'productAdvertiseID': productAdvertiseID,
        'productSoldOut': productSoldOut,
        'paymentMethod': paymentMethod,
        'shippingServiceProvider': shippingServiceProvider,
        'shippingSpeed': shippingSpeed,
        'shippingCost': shippingCost,
        'markUp': markUp,
        'orderStatus': orderStatus,
        'productVariant': productVariant,
        'customParameters': customParameters
            ?.map((key, value) => MapEntry(key.toString(), value))
      };
}

enum MICampaignAction { click, view }

class MICampaignParameters {
  MICampaignParameters(this.campaignId);
  String? campaignId;
  MICampaignAction? action;
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

class MIPageViewEvent {
  MIPageViewEvent(this.name);
  String? name;
  MIPageParameters? pageParameters;
  MISessionParameters? sessionParameters;
  MIUserCategories? userCategories;
  MIEcommerceParameters? ecommerceParameters;
  MICampaignParameters? campaignParameters;

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
  MISessionParameters? sessionParameters;
  MIUserCategories? userCategories;
  MIEcommerceParameters? ecommerceParameters;
  MICampaignParameters? campaignParameters;

  Map<String, dynamic> toJson() => {
        'name': name,
        'eventParameters': eventParameters?.toJson(),
        'sessionParameters': sessionParameters?.toJson(),
        'userCategories': userCategories?.toJson(),
        'ecommerceParameters': ecommerceParameters?.toJson(),
        'campaignParameters': campaignParameters?.toJson()
      };
}
