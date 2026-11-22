import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Taxi Pay Merchant'**
  String get appTitle;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @phoneOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Phone or email'**
  String get phoneOrEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'New to Taxi Pay? Register your business'**
  String get noAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register your business'**
  String get registerTitle;

  /// No description provided for @ownerSection.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerSection;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @businessSection.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessSection;

  /// No description provided for @businessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get businessName;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business type'**
  String get businessType;

  /// No description provided for @typeIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get typeIndividual;

  /// No description provided for @typeCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get typeCompany;

  /// No description provided for @typeAssociation.
  ///
  /// In en, this message translates to:
  /// **'Association'**
  String get typeAssociation;

  /// No description provided for @tin.
  ///
  /// In en, this message translates to:
  /// **'TIN (10 digits)'**
  String get tin;

  /// No description provided for @tradeLicense.
  ///
  /// In en, this message translates to:
  /// **'Trade licence number (optional)'**
  String get tradeLicense;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @subCity.
  ///
  /// In en, this message translates to:
  /// **'Sub-city'**
  String get subCity;

  /// No description provided for @settlementSection.
  ///
  /// In en, this message translates to:
  /// **'Payout account'**
  String get settlementSection;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get bankAccount;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get mobileMoney;

  /// No description provided for @providerName.
  ///
  /// In en, this message translates to:
  /// **'Bank or wallet'**
  String get providerName;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'Choose your own password to continue.'**
  String get changePasswordInfo;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Your application is under review'**
  String get statusPending;

  /// No description provided for @statusPendingInfo.
  ///
  /// In en, this message translates to:
  /// **'Upload your trade licence, TIN certificate and ID. We\'ll notify you when your business is approved.'**
  String get statusPendingInfo;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Your application was not approved'**
  String get statusRejected;

  /// No description provided for @statusRejectedInfo.
  ///
  /// In en, this message translates to:
  /// **'Fix the problem below, then resubmit.'**
  String get statusRejectedInfo;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Your business is suspended'**
  String get statusSuspended;

  /// No description provided for @statusSuspendedInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Taxi Pay support to reactivate it.'**
  String get statusSuspendedInfo;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @uploadDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload document'**
  String get uploadDocument;

  /// No description provided for @resubmit.
  ///
  /// In en, this message translates to:
  /// **'Resubmit application'**
  String get resubmit;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabOperate.
  ///
  /// In en, this message translates to:
  /// **'Operate'**
  String get tabOperate;

  /// No description provided for @tabFleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get tabFleet;

  /// No description provided for @tabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tabPayments;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @taxis.
  ///
  /// In en, this message translates to:
  /// **'Taxis'**
  String get taxis;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @routes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routes;

  /// No description provided for @totalTaxis.
  ///
  /// In en, this message translates to:
  /// **'Taxis'**
  String get totalTaxis;

  /// No description provided for @activeTaxis.
  ///
  /// In en, this message translates to:
  /// **'Active taxis'**
  String get activeTaxis;

  /// No description provided for @pendingTaxis.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get pendingTaxis;

  /// No description provided for @completedTrips.
  ///
  /// In en, this message translates to:
  /// **'Completed trips'**
  String get completedTrips;

  /// No description provided for @passengers.
  ///
  /// In en, this message translates to:
  /// **'Passengers'**
  String get passengers;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @onTheRoad.
  ///
  /// In en, this message translates to:
  /// **'On the road now'**
  String get onTheRoad;

  /// No description provided for @noActiveOperations.
  ///
  /// In en, this message translates to:
  /// **'No taxi is operating right now.'**
  String get noActiveOperations;

  /// No description provided for @startOperation.
  ///
  /// In en, this message translates to:
  /// **'Start operation'**
  String get startOperation;

  /// No description provided for @taxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get taxi;

  /// No description provided for @route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get route;

  /// No description provided for @driverOptional.
  ///
  /// In en, this message translates to:
  /// **'Driver (taxi\'s default if empty)'**
  String get driverOptional;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @depart.
  ///
  /// In en, this message translates to:
  /// **'Depart'**
  String get depart;

  /// No description provided for @completeTrip.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get completeTrip;

  /// No description provided for @completeAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Arrived — open return trip'**
  String get completeAndReturn;

  /// No description provided for @openNextTrip.
  ///
  /// In en, this message translates to:
  /// **'Open next trip'**
  String get openNextTrip;

  /// No description provided for @finishOperation.
  ///
  /// In en, this message translates to:
  /// **'Finish operation'**
  String get finishOperation;

  /// No description provided for @boarding.
  ///
  /// In en, this message translates to:
  /// **'Boarding'**
  String get boarding;

  /// No description provided for @onTheRoadStatus.
  ///
  /// In en, this message translates to:
  /// **'On the road'**
  String get onTheRoadStatus;

  /// No description provided for @seatsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get seatsAvailable;

  /// No description provided for @seatsUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Occupied, unpaid'**
  String get seatsUnpaid;

  /// No description provided for @seatsPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get seatsPaid;

  /// No description provided for @tapSeatHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a seat to mark it occupied or free.'**
  String get tapSeatHint;

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// No description provided for @noTripOpen.
  ///
  /// In en, this message translates to:
  /// **'No trip is open. Open the next trip to take passengers.'**
  String get noTripOpen;

  /// No description provided for @addTaxi.
  ///
  /// In en, this message translates to:
  /// **'Add taxi'**
  String get addTaxi;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate number'**
  String get plateNumber;

  /// No description provided for @sideNumber.
  ///
  /// In en, this message translates to:
  /// **'Side number (optional)'**
  String get sideNumber;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleType;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get manufacturer;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get color;

  /// No description provided for @seatLayout.
  ///
  /// In en, this message translates to:
  /// **'Seat layout'**
  String get seatLayout;

  /// No description provided for @seats.
  ///
  /// In en, this message translates to:
  /// **'seats'**
  String get seats;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// No description provided for @shareQr.
  ///
  /// In en, this message translates to:
  /// **'Share QR to print'**
  String get shareQr;

  /// No description provided for @qrNotReady.
  ///
  /// In en, this message translates to:
  /// **'The QR code is available once the taxi is approved.'**
  String get qrNotReady;

  /// No description provided for @defaultDriver.
  ///
  /// In en, this message translates to:
  /// **'Default driver'**
  String get defaultDriver;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @addDriver.
  ///
  /// In en, this message translates to:
  /// **'Add driver'**
  String get addDriver;

  /// No description provided for @licenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Licence number'**
  String get licenseNumber;

  /// No description provided for @licenseExpired.
  ///
  /// In en, this message translates to:
  /// **'Licence expired'**
  String get licenseExpired;

  /// No description provided for @addRoute.
  ///
  /// In en, this message translates to:
  /// **'Add route'**
  String get addRoute;

  /// No description provided for @routeName.
  ///
  /// In en, this message translates to:
  /// **'Route name'**
  String get routeName;

  /// No description provided for @stops.
  ///
  /// In en, this message translates to:
  /// **'Stops in order'**
  String get stops;

  /// No description provided for @addStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get addStop;

  /// No description provided for @stopName.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopName;

  /// No description provided for @routeInfo.
  ///
  /// In en, this message translates to:
  /// **'Add the start, any stops in between, and the final stop. You\'ll price each leg next; an admin approves the prices.'**
  String get routeInfo;

  /// No description provided for @submitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for approval'**
  String get submitForApproval;

  /// No description provided for @assignTaxi.
  ///
  /// In en, this message translates to:
  /// **'Assign taxi'**
  String get assignTaxi;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @telegram.
  ///
  /// In en, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @telegramConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected — notifications also arrive on Telegram.'**
  String get telegramConnected;

  /// No description provided for @telegramNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Get payment and approval notifications on Telegram.'**
  String get telegramNotConnected;

  /// No description provided for @connectTelegram.
  ///
  /// In en, this message translates to:
  /// **'Connect Telegram'**
  String get connectTelegram;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Receive offers from Taxi Pay'**
  String get offers;

  /// No description provided for @businessProfile.
  ///
  /// In en, this message translates to:
  /// **'Business profile'**
  String get businessProfile;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get empty;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @legsAndPrices.
  ///
  /// In en, this message translates to:
  /// **'Legs and prices'**
  String get legsAndPrices;

  /// No description provided for @legsInfo.
  ///
  /// In en, this message translates to:
  /// **'Each pair of neighbouring stops is a leg, both ways, and the full route has its own price. You set the prices; an admin approves them.'**
  String get legsInfo;

  /// No description provided for @outboundLegs.
  ///
  /// In en, this message translates to:
  /// **'Outbound legs'**
  String get outboundLegs;

  /// No description provided for @returnLegs.
  ///
  /// In en, this message translates to:
  /// **'Return legs'**
  String get returnLegs;

  /// No description provided for @fullRoute.
  ///
  /// In en, this message translates to:
  /// **'Full route'**
  String get fullRoute;

  /// No description provided for @setPrices.
  ///
  /// In en, this message translates to:
  /// **'Set prices'**
  String get setPrices;

  /// No description provided for @changePrices.
  ///
  /// In en, this message translates to:
  /// **'Change prices'**
  String get changePrices;

  /// No description provided for @notPriced.
  ///
  /// In en, this message translates to:
  /// **'Not priced'**
  String get notPriced;

  /// No description provided for @awaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting approval'**
  String get awaitingApproval;

  /// No description provided for @newPrice.
  ///
  /// In en, this message translates to:
  /// **'New: {amount}'**
  String newPrice(String amount);

  /// No description provided for @priceAllLegs.
  ///
  /// In en, this message translates to:
  /// **'Set a price for every leg before submitting ({count} left).'**
  String priceAllLegs(int count);

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'An admin is reviewing this route and its prices.'**
  String get underReview;

  /// No description provided for @pendingChangesInfo.
  ///
  /// In en, this message translates to:
  /// **'{count} price change(s) are waiting for an admin. Passengers pay the current prices until then.'**
  String pendingChangesInfo(int count);

  /// No description provided for @priceChangeInfo.
  ///
  /// In en, this message translates to:
  /// **'Passengers keep paying the current prices until an admin approves your change.'**
  String get priceChangeInfo;

  /// No description provided for @applyFrom.
  ///
  /// In en, this message translates to:
  /// **'Apply from'**
  String get applyFrom;

  /// No description provided for @applyWhenApproved.
  ///
  /// In en, this message translates to:
  /// **'As soon as approved'**
  String get applyWhenApproved;

  /// No description provided for @pricesSaved.
  ///
  /// In en, this message translates to:
  /// **'Prices saved'**
  String get pricesSaved;

  /// No description provided for @priceChangeSent.
  ///
  /// In en, this message translates to:
  /// **'Price change sent for approval'**
  String get priceChangeSent;

  /// No description provided for @priceEtb.
  ///
  /// In en, this message translates to:
  /// **'Price (ETB)'**
  String get priceEtb;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a price above 0'**
  String get invalidPrice;

  /// No description provided for @nothingChanged.
  ///
  /// In en, this message translates to:
  /// **'No price changed'**
  String get nothingChanged;

  /// No description provided for @viewTaxi.
  ///
  /// In en, this message translates to:
  /// **'Taxi details'**
  String get viewTaxi;

  /// No description provided for @notOnAnyRoute.
  ///
  /// In en, this message translates to:
  /// **'Not assigned to any route yet.'**
  String get notOnAnyRoute;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
