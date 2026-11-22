import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/utils/json.dart';
import 'merchant_models.dart';

class MerchantApi {
  MerchantApi(this._api);

  final ApiClient _api;

  Future<Merchant> profile() => _api.get('/api/merchant/profile', map: (d) => Merchant.fromJson(d as Json));

  Future<Dashboard> dashboard() => _api.get('/api/merchant/dashboard', map: (d) => Dashboard.fromJson(d as Json));

  Future<void> uploadDocument(String type, Uint8List bytes, String filename) => _api.upload(
      '/api/merchant/profile/documents', bytes: bytes, filename: filename, query: {'type': type}, map: (_) {});

  Future<Merchant> resubmit() =>
      _api.post('/api/merchant/profile/resubmit', map: (d) => Merchant.fromJson(d as Json));
}

final merchantApiProvider = Provider<MerchantApi>((ref) => MerchantApi(ref.watch(apiClientProvider)));
