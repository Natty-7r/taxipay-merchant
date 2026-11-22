import '../../../core/utils/json.dart';

class PaymentItem {
  PaymentItem({required this.reference, required this.status, required this.amount, required this.provider,
      required this.plateNumber, required this.origin, required this.destination, this.seatCode, this.payerPhone,
      required this.createdAt});

  final String reference;
  final String status;
  final num amount;
  final String provider;
  final String plateNumber;
  final String origin;
  final String destination;
  final String? seatCode;
  final String? payerPhone;
  final String createdAt;

  factory PaymentItem.fromJson(Json j) => PaymentItem(
        reference: j['reference'] as String,
        status: j['status'] as String,
        amount: numOf(j['amount']),
        provider: j['provider'] as String,
        plateNumber: j['plateNumber'] as String,
        origin: j['origin'] as String,
        destination: j['destination'] as String,
        seatCode: j['seatCode'] as String?,
        payerPhone: j['payerPhone'] as String?,
        createdAt: j['createdAt'] as String,
      );
}
