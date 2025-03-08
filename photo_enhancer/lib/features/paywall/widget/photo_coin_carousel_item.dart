import 'package:flutter/material.dart';
import 'package:photo_enhancer/common/helpers/app_sizer.dart';
import 'package:photo_enhancer/common/widgets/app_text.dart';
import 'package:photo_enhancer/core/enums/app_localized_keys.dart';
import 'package:photo_enhancer/features/paywall/data/photo_coins.dart';

class PhotoCoinCarouselItem extends StatelessWidget {
  const PhotoCoinCarouselItem({
    super.key,
    required this.photoCoin,
    required this.onSelected,
  });

  final PhotoCoins photoCoin;
  final Function(PhotoCoins coin) onSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onSelected(photoCoin),
      customBorder: RoundedRectangleBorder(borderRadius: AppSizer.borderRadius),
      child: Container(
        width: AppSizer.scaleWidth(280),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: AppSizer.borderRadius,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.amber,
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Expanded(
              child: Image.asset(
                photoCoin.type!.toAssetImage(),
              ),
            ),
            AppText(
              AppLocalizedKeys.photoCoin,
              localizedArg: [
                photoCoin.type!.count.toString(),
              ],
            ),
            AppText(
              null,
              text: photoCoin.productDetails.price,
            ),
            const SizedBox(height: 12)
          ],
        ),
      ),
    );
  }
}
