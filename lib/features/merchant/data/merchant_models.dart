import '../../../core/utils/json.dart';

enum MerchantStatus { draft, pending, approved, rejected, suspended }

MerchantStatus merchantStatusOf(String value) =>
    MerchantStatus.values.firstWhere((s) => s.name.toUpperCase() == value, orElse: () => MerchantStatus.pending);

class MerchantDocument {
  MerchantDocument({required this.id, required this.type, required this.fileName, required this.createdAt});

  final int id;
  final String type;
  final String fileName;
  final String createdAt;

  factory MerchantDocument.fromJson(Json j) => MerchantDocument(
        id: (j['id'] as num).toInt(),
        type: j['type'] as String,
        fileName: j['fileName'] as String,
        createdAt: j['createdAt'] as String,
      );
}

class Merchant {
  Merchant({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.tin,
    required this.contactPerson,
    required this.phoneNumber,
    this.city,
    this.subCity,
    this.addressLine,
    this.tradeLicenseNumber,
    this.latitude,
    this.longitude,
    this.payout,
    required this.status,
    this.statusReason,
    required this.documents,
  });

  final int id;
  final String businessName;
  final String businessType;
  final String? tin;
  final String contactPerson;
  final String phoneNumber;
  final String? city;
  final String? subCity;
  final String? addressLine;
  final String? tradeLicenseNumber;
  final double? latitude;
  final double? longitude;
  final Payout? payout;
  final MerchantStatus status;
  final String? statusReason;
  final List<MerchantDocument> documents;

  bool get approved => status == MerchantStatus.approved;

  factory Merchant.fromJson(Json j) => Merchant(
        id: (j['id'] as num).toInt(),
        businessName: j['businessName'] as String,
        businessType: j['businessType'] as String,
        tin: j['tin'] as String?,
        contactPerson: j['contactPerson'] as String,
        phoneNumber: j['phoneNumber'] as String,
        city: j['city'] as String?,
        subCity: j['subCity'] as String?,
        addressLine: j['addressLine'] as String?,
        tradeLicenseNumber: j['tradeLicenseNumber'] as String?,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        payout: objOf(j['settlement']) == null ? null : Payout.fromJson(objOf(j['settlement'])!),
        status: merchantStatusOf(j['status'] as String),
        statusReason: j['statusReason'] as String?,
        documents: listOf(j['documents'], MerchantDocument.fromJson),
      );
}

/// Where Taxi Pay pays the merchant: a bank account or a mobile-money wallet.
class Payout {
  Payout({required this.method, required this.provider, required this.accountName, required this.accountNumber});

  /// BANK_ACCOUNT or MOBILE_MONEY.
  final String method;
  final String provider;
  final String accountName;
  final String accountNumber;

  factory Payout.fromJson(Json j) => Payout(
        method: j['method'] as String,
        provider: j['provider'] as String,
        accountName: j['accountName'] as String,
        accountNumber: j['accountNumber'] as String,
      );

  Json toJson() => {'method': method, 'provider': provider, 'accountName': accountName, 'accountNumber': accountNumber};
}

/// `GET /api/merchant/context`: who is signed in (owner or driver) and what is left to set up.
class AppContext {
  AppContext({
    required this.isDriver,
    required this.merchantId,
    required this.businessName,
    required this.status,
    this.statusReason,
    required this.businessSetUp,
    required this.approved,
    required this.payoutAccount,
    this.driverId,
    this.driverTaxiIds = const [],
  });

  final bool isDriver;
  final int merchantId;
  final String businessName;
  final MerchantStatus status;
  final String? statusReason;

  /// Business details submitted (needed before adding taxis).
  final bool businessSetUp;
  final bool approved;

  /// Payout account set (needed before starting an operation).
  final bool payoutAccount;
  final int? driverId;
  final List<int> driverTaxiIds;

  bool get canOperate => approved && payoutAccount;

  /// Setup steps still open, for the owner's reminders.
  bool get setupComplete => businessSetUp && approved && payoutAccount;

  factory AppContext.fromJson(Json j) {
    final setup = objOf(j['setup']) ?? const {};
    final driver = objOf(j['driver']);
    return AppContext(
      isDriver: j['role'] == 'DRIVER',
      merchantId: (j['merchantId'] as num).toInt(),
      businessName: j['businessName'] as String,
      status: merchantStatusOf(j['status'] as String),
      statusReason: j['statusReason'] as String?,
      businessSetUp: (setup['businessSetUp'] as bool?) ?? false,
      approved: (setup['approved'] as bool?) ?? false,
      payoutAccount: (setup['payoutAccount'] as bool?) ?? false,
      driverId: (driver?['id'] as num?)?.toInt(),
      driverTaxiIds: [for (final id in (driver?['taxiIds'] as List?) ?? const []) (id as num).toInt()],
    );
  }
}

class Dashboard {
  Dashboard({
    required this.totalTaxis,
    required this.activeTaxis,
    required this.pendingTaxis,
    required this.drivers,
    required this.approvedRoutes,
    required this.completedTrips,
    required this.passengers,
    required this.revenue,
  });

  final int totalTaxis, activeTaxis, pendingTaxis, drivers, approvedRoutes, completedTrips, passengers;
  final num revenue;

  factory Dashboard.fromJson(Json j) => Dashboard(
        totalTaxis: numOf(j['totalTaxis']).toInt(),
        activeTaxis: numOf(j['activeTaxis']).toInt(),
        pendingTaxis: numOf(j['pendingTaxis']).toInt(),
        drivers: numOf(j['drivers']).toInt(),
        approvedRoutes: numOf(j['approvedRoutes']).toInt(),
        completedTrips: numOf(j['completedTrips']).toInt(),
        passengers: numOf(j['passengers']).toInt(),
        revenue: numOf(j['revenue']),
      );
}

/// Document types the API accepts.
const documentTypes = ['TRADE_LICENSE', 'TIN_CERTIFICATE', 'BUSINESS_REGISTRATION', 'OWNER_NATIONAL_ID', 'OTHER'];
