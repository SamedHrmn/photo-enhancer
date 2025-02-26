import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:photo_enhancer/common/helpers/app_asset_manager.dart';
import 'package:photo_enhancer/common/helpers/app_initializer.dart';
import 'package:photo_enhancer/core/enums/env_keys.dart';

class PhotoCoins extends Equatable {
  final PhotoCoinTypes? type;
  final ProductDetails productDetails;

  const PhotoCoins({
    required this.type,
    required this.productDetails,
  });

  @override
  List<Object?> get props => [type, productDetails];
}

enum PhotoCoinTypes {
  pack1(10),
  pack2(25),
  pack3(40),
  pack4(70),
  pack5(100);

  const PhotoCoinTypes(this.count);

  final int count;

  String toAssetImage() {
    switch (this) {
      case PhotoCoinTypes.pack1:
        return AppAssetManager.photoCoinPack1;
      case PhotoCoinTypes.pack2:
        return AppAssetManager.photoCoinPack2;
      case PhotoCoinTypes.pack3:
        return AppAssetManager.photoCoinPack3;
      case PhotoCoinTypes.pack4:
        return AppAssetManager.photoCoinPack4;
      case PhotoCoinTypes.pack5:
        return AppAssetManager.photoCoinPack5;
    }
  }

  static PhotoCoinTypes? fromId(String productId) {
    final pack1 = AppInitializer.getStringEnv(EnvKeys.coinsPack1);
    final pack2 = AppInitializer.getStringEnv(EnvKeys.coinsPack2);
    final pack3 = AppInitializer.getStringEnv(EnvKeys.coinsPack3);
    final pack4 = AppInitializer.getStringEnv(EnvKeys.coinsPack4);
    final pack5 = AppInitializer.getStringEnv(EnvKeys.coinsPack5);

    if (pack1 == productId) {
      return PhotoCoinTypes.pack1;
    } else if (pack2 == productId) {
      return PhotoCoinTypes.pack2;
    } else if (pack3 == productId) {
      return PhotoCoinTypes.pack3;
    } else if (pack4 == productId) {
      return PhotoCoinTypes.pack4;
    } else if (pack5 == productId) {
      return PhotoCoinTypes.pack5;
    } else {
      return null;
    }
  }
}
