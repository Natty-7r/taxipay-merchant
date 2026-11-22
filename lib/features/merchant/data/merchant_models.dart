import '../../../core/utils/json.dart';

enum MerchantStatus { pending, approved, rejected, suspended }

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
    required this.city,
    this.subCity,
    required this.status,
    this.statusReason,
    required this.documents,
  });

  final int id;
  final String businessName;
  final String businessType;
  final String tin;
  final String contactPerson;
  final String phoneNumber;
  final String city;
  final String? subCity;
  final MerchantStatus status;
  final String? statusReason;
  final List<MerchantDocument> documents;

  bool get approved => status == MerchantStatus.approved;

  factory Merchant.fromJson(Json j) => Merchant(
        id: (j['id'] as num).toInt(),
        businessName: j['businessName'] as String,
        businessType: j['businessType'] as String,
        tin: j['tin'] as String,
        contactPerson: j['contactPerson'] as String,
        phoneNumber: j['phoneNumber'] as String,
        city: j['city'] as String,
        subCity: j['subCity'] as String?,
        status: merchantStatusOf(j['status'] as String),
        statusReason: j['statusReason'] as String?,
        documents: listOf(j['documents'], MerchantDocument.fromJson),
      );
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
