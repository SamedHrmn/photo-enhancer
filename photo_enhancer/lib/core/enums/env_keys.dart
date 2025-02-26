enum EnvKeys {
  packageName('PACKAGE_NAME'),
  createUserUrl('CREATE_USER_URL'),
  getUserDataUrl('GET_USER_DATA_URL'),
  deleteAccountUrl('DELETE_ACCOUNT_URL'),
  colorizeImageUrl('COLORIZE_IMAGE_URL'),
  deblurImageUrl('DEBLUR_IMAGE_URL'),
  gcpId('GCP_PROJECT_ID'),
  coinsPack1('COINS_PACK_1'),
  coinsPack2('COINS_PACK_2'),
  coinsPack3('COINS_PACK_3'),
  coinsPack4('COINS_PACK_4'),
  coinsPack5('COINS_PACK_5'),
  verifyPurchaseUrl('VERIFY_PURCHASE_URL'),
  updateUserCreditUrl('UPDATE_USER_CREDIT_URL'),
  verifyIntegrityUrl('VERIFY_INTEGRITY_URL');

  final String keyName;
  const EnvKeys(this.keyName);
}
