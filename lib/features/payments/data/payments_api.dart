import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import 'payment_models.dart';

class PaymentsApi {
  PaymentsApi(this._api);

  final ApiClient _api;

  Future<List<PaymentItem>> list({String? status}) async => (await _api.getPage(
          '/api/merchant/payments', PaymentItem.fromJson, query: {'size': 50, 'status': status}))
      .content;
}

final paymentsApiProvider = Provider<PaymentsApi>((ref) => PaymentsApi(ref.watch(apiClientProvider)));
