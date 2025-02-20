enum EnvKeys {
  packageName('PACKAGE_NAME'),
  createUserUrl('CREATE_USER_URL'),
  getUserDataUrl('GET_USER_DATA_URL'),
  deleteAccountUrl('DELETE_ACCOUNT_URL'),
  colorizeImageUrl('COLORIZE_IMAGE_URL'),
  deblurImageUrl('DEBLUR_IMAGE_URL'),
  gcpId('GCP_PROJECT_ID'),
  verifyIntegrityUrl('VERIFY_INTEGRITY_URL');

  final String keyName;
  const EnvKeys(this.keyName);
}
