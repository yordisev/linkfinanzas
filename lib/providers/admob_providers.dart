import 'package:codigoqr/config/adsmob_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final interstitialAdProvider =
    FutureProvider.autoDispose<InterstitialAd>((ref) async {
  // TODO validar si esta en modo premiun para quitar los anuncios
  final ad = await AdmobPlugin.loadIntersticialAd();
  return ad;
});
