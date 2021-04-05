class MIPageParameters {
  String? searchTerm;
  Map<int, String>? params;
  Map<int, String>? categories;
}

class MISessionParameters {
  Map<int, String>? parameters;
}

enum MIGender { unknown, male, female }

class MIBirthday {
  final int day;
  final int month;
  final int year;
  const MIBirthday(this.day, this.month, this.year);
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
}

class MIEcommerceParameters {
  //@property (nullable) NSArray<MIProduct*>* products;
//@property (nonatomic) Status status;
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
}

class MICampaignParameters {}

class MIPageViewEvent {
  MIPageViewEvent(this.name);
  var name = "";
  var pageParameters = MIPageParameters();
}
