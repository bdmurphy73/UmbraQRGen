class AppStrings {
  AppStrings._();

  static const String appName = 'UmbraQRGen';
  static const String appTagline = 'QR CODE GENERATOR';

  // Navigation
  static const String tabWebsite = 'Website';
  static const String tabWifi = 'WiFi';
  static const String tabContact = 'Contact';
  static const String tabSaved = 'Saved';

  // Website screen
  static const String labelWebsiteUrl = 'Enter website URL';
  static const String hintWebsiteUrl = 'https://example.com';
  static const String defaultWebsiteUrl = 'https://authorbdmurphy.com';
  static const String emptyStateWebsite = 'Enter a URL to generate a QR code';

  // WiFi screen
  static const String labelWifiSsid = 'Network Name (SSID)';
  static const String labelWifiPassword = 'Password';
  static const String emptyStateWifi =
      'Enter WiFi details to generate a QR code';

  // Contact screen
  static const String labelContactName = 'Full Name';
  static const String labelContactEmail = 'Email';
  static const String labelContactPhone = 'Phone Number';
  static const String labelImportContacts = 'Import from Contacts';
  static const String labelAllowContacts = 'Allow Contact Access';
  static const String emptyStateContact =
      'Enter contact details\n(Name + email or phone required)';

  // Saved screen
  static const String titleSaved = 'Saved QR Codes';
  static const String emptyStateSaved =
      'No saved QR codes yet\nGenerate and save one to see it here';
  static const String emptyStatePermission =
      'Storage access needed to view saved codes';
  static const String grantAccess = 'Grant Access';

  // Actions
  static const String actionSave = 'Save';
  static const String actionShare = 'Share';
  static const String actionDelete = 'Delete';
  static const String actionCancel = 'Cancel';
  static const String actionClose = 'Close';
  static const String actionEmail = 'Email QR Code';
  static const String actionSaveAgain = 'Save Again';

  // Dialogs
  static const String titleDeleteConfirm = 'Delete QR Code';
  static const String messageDeleteConfirm = 'This cannot be undone.';

  // About screen
  static const String aboutTitle = 'About';
  static const String aboutDeveloperNote =
      'UmbraQRGen generates QR codes entirely on your device. '
      'No accounts, no logins, no servers. Your data never leaves your phone.';
  static const String aboutPrivacyPolicy = 'Privacy Policy';
  static const String aboutDisclaimer = 'Disclaimer of Warranty';
  static const String aboutLiability = 'Limitation of Liability';
  static const String aboutTermsLink = 'Full Terms of Service';
  static const String aboutFooter = 'Part of the UmbraTools suite';
  static const String aboutWebsite = 'UmbraTools.com';

  // Links
  static const String linkGitHub = 'https://github.com/bdmurphy73/UmbraQRGen';
  static const String linkBuyMeCoffee = 'https://buymeacoffee.com/umbratools';
  static const String linkPersonalSite = 'https://umbratools.com/';
  static const String linkTerms =
      'https://github.com/bdmurphy73/UmbraQRGen/blob/main/Privacy_TermsOfService.txt';
  static const String linkUmbraTools = 'https://umbratools.com';

  // Share subjects
  static const String shareSubjectWebsite = 'QR Code — UmbraQRGen';
  static const String shareSubjectWifi = 'WiFi QR Code — UmbraQRGen';
  static const String shareSubjectContact = 'Contact QR Code — UmbraQRGen';
  static const String shareSubjectSaved = 'QR Code — UmbraQRGen';

  // Share body templates
  static const String shareBodyWebsite = 'Check out this link: ';
  static const String shareBodyWifiNetwork = 'WiFi Network: ';
  static const String shareBodyWifiPassword = 'Password: ';
  static const String shareBodyWifiNote =
      '\n\nScan the attached QR code to connect.';
  static const String shareBodyContactName = 'Name: ';
  static const String shareBodyContactPhone = 'Phone: ';
  static const String shareBodyContactEmail = 'Email: ';
  static const String shareBodyContactNote =
      '\n\nScan the attached QR code to save this contact.';
  static const String shareBodySaved = 'QR Code: ';

  // Messages
  static const String msgSaveSuccess = 'QR code saved to gallery';
  static const String msgSaveFailed = 'Failed to save QR code';
  static const String msgShareFailed = 'Failed to share QR code';
  static const String msgDeleteSuccess = 'QR code deleted';
  static const String msgQrFailed = 'Failed to generate QR code';
  static const String msgContactNoData =
      'Selected contact has no email or phone';

  // QR type labels
  static const String typeUrl = 'URL';
  static const String typeWifi = 'WiFi';
  static const String typeContact = 'Contact';
}
