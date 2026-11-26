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
  /// **'Create your account'**
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
  /// **'Profile'**
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

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String hello(String name);

  /// No description provided for @totalCollected.
  ///
  /// In en, this message translates to:
  /// **'Total collected'**
  String get totalCollected;

  /// No description provided for @fromPassengers.
  ///
  /// In en, this message translates to:
  /// **'From {count} paying passengers'**
  String fromPassengers(int count);

  /// No description provided for @yourFleet.
  ///
  /// In en, this message translates to:
  /// **'Your fleet'**
  String get yourFleet;

  /// No description provided for @approvedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Approved routes'**
  String get approvedRoutes;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @via.
  ///
  /// In en, this message translates to:
  /// **'via {provider}'**
  String via(String provider);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet. They appear here as passengers pay.'**
  String get noPaymentsYet;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get errorNetworkTitle;

  /// No description provided for @errorTimeoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Taking too long'**
  String get errorTimeoutTitle;

  /// No description provided for @errorServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server problem'**
  String get errorServerTitle;

  /// No description provided for @errorDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get errorDeniedTitle;

  /// No description provided for @errorNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get errorNotFoundTitle;

  /// No description provided for @errorGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGenericTitle;

  /// No description provided for @errorReference.
  ///
  /// In en, this message translates to:
  /// **'Reference: {id}'**
  String errorReference(String id);

  /// No description provided for @qrPoster.
  ///
  /// In en, this message translates to:
  /// **'QR poster'**
  String get qrPoster;

  /// No description provided for @qrPosterHint.
  ///
  /// In en, this message translates to:
  /// **'Print it and stick it where passengers can scan it.'**
  String get qrPosterHint;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay your fare'**
  String get scanToPay;

  /// No description provided for @posterStep1.
  ///
  /// In en, this message translates to:
  /// **'Scan this code with your phone camera'**
  String get posterStep1;

  /// No description provided for @posterStep2.
  ///
  /// In en, this message translates to:
  /// **'Choose where you get off'**
  String get posterStep2;

  /// No description provided for @posterStep3.
  ///
  /// In en, this message translates to:
  /// **'Pay with telebirr, M-Pesa or CBE Birr'**
  String get posterStep3;

  /// No description provided for @operatedBy.
  ///
  /// In en, this message translates to:
  /// **'Operated by {name}'**
  String operatedBy(String name);

  /// No description provided for @formatImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get formatImage;

  /// No description provided for @formatPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get formatPdf;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveToPhone.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveToPhone;

  /// No description provided for @savedFile.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedFile;

  /// No description provided for @makePoster.
  ///
  /// In en, this message translates to:
  /// **'Make a poster to print'**
  String get makePoster;

  /// No description provided for @sideNumberValue.
  ///
  /// In en, this message translates to:
  /// **'Side no. {number}'**
  String sideNumberValue(String number);

  /// No description provided for @customLayout.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customLayout;

  /// No description provided for @rowLabel.
  ///
  /// In en, this message translates to:
  /// **'Row {letter}'**
  String rowLabel(String letter);

  /// No description provided for @addRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get addRow;

  /// No description provided for @sideSeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Side seats'**
  String get sideSeatsLabel;

  /// No description provided for @sideSeatsHint.
  ///
  /// In en, this message translates to:
  /// **'Extra seats along the side, e.g. by the door'**
  String get sideSeatsHint;

  /// No description provided for @seatCount.
  ///
  /// In en, this message translates to:
  /// **'{count} seats'**
  String seatCount(int count);

  /// No description provided for @editSeats.
  ///
  /// In en, this message translates to:
  /// **'Edit seats'**
  String get editSeats;

  /// No description provided for @seatsSaved.
  ///
  /// In en, this message translates to:
  /// **'Seat layout saved'**
  String get seatsSaved;

  /// No description provided for @chooseLayout.
  ///
  /// In en, this message translates to:
  /// **'Choose a layout or build your own'**
  String get chooseLayout;

  /// No description provided for @vehicleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get vehicleOther;

  /// No description provided for @editTaxi.
  ///
  /// In en, this message translates to:
  /// **'Edit taxi'**
  String get editTaxi;

  /// No description provided for @editRoute.
  ///
  /// In en, this message translates to:
  /// **'Edit route'**
  String get editRoute;

  /// No description provided for @editApprovedTaxiHint.
  ///
  /// In en, this message translates to:
  /// **'Changing the plate, type, make, model or year sends the taxi back for review.'**
  String get editApprovedTaxiHint;

  /// No description provided for @qrCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code: {code}'**
  String qrCodeLabel(String code);

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @firstTripDirection.
  ///
  /// In en, this message translates to:
  /// **'First trip goes'**
  String get firstTripDirection;

  /// No description provided for @allowStanding.
  ///
  /// In en, this message translates to:
  /// **'Allow passengers without a seat'**
  String get allowStanding;

  /// No description provided for @allowStandingHint.
  ///
  /// In en, this message translates to:
  /// **'Off: every passenger must pick a seat to pay. You can change this during the trip.'**
  String get allowStandingHint;

  /// No description provided for @freeSeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Seat {seat}'**
  String freeSeatTitle(String seat);

  /// No description provided for @freeSeatPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid · {from} → {to}'**
  String freeSeatPaid(String from, String to);

  /// No description provided for @freeSeatQuestion.
  ///
  /// In en, this message translates to:
  /// **'Did this passenger get off? Freeing the seat lets someone else pay for it.'**
  String get freeSeatQuestion;

  /// No description provided for @freeSeat.
  ///
  /// In en, this message translates to:
  /// **'Free the seat'**
  String get freeSeat;

  /// No description provided for @paidOnTrip.
  ///
  /// In en, this message translates to:
  /// **'Paid on this trip ({count})'**
  String paidOnTrip(int count);

  /// No description provided for @noPaymentsOnTrip.
  ///
  /// In en, this message translates to:
  /// **'No payments on this trip yet.'**
  String get noPaymentsOnTrip;

  /// No description provided for @onBoard.
  ///
  /// In en, this message translates to:
  /// **'On board'**
  String get onBoard;

  /// No description provided for @gotOff.
  ///
  /// In en, this message translates to:
  /// **'Got off'**
  String get gotOff;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @shareTaxiQr.
  ///
  /// In en, this message translates to:
  /// **'Share QR'**
  String get shareTaxiQr;

  /// No description provided for @nextTripDirection.
  ///
  /// In en, this message translates to:
  /// **'Next trip goes'**
  String get nextTripDirection;

  /// No description provided for @notificationsOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications'**
  String get notificationsOffTitle;

  /// No description provided for @notificationsOffBody.
  ///
  /// In en, this message translates to:
  /// **'Get told the moment a passenger pays, even when the app is closed.'**
  String get notificationsOffBody;

  /// No description provided for @notificationsAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get notificationsAllow;

  /// No description provided for @notificationsSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notificationsSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @fromStopTitle.
  ///
  /// In en, this message translates to:
  /// **'From {stop}'**
  String fromStopTitle(String stop);

  /// No description provided for @fromStopReturn.
  ///
  /// In en, this message translates to:
  /// **'From {stop} (return)'**
  String fromStopReturn(String stop);

  /// No description provided for @registerIntro.
  ///
  /// In en, this message translates to:
  /// **'Create your account. You\'ll set up your business and payout account after signing in.'**
  String get registerIntro;

  /// No description provided for @setupBusiness.
  ///
  /// In en, this message translates to:
  /// **'Set up your business'**
  String get setupBusiness;

  /// No description provided for @setupBusinessHint.
  ///
  /// In en, this message translates to:
  /// **'Needed before you add taxis, routes and drivers.'**
  String get setupBusinessHint;

  /// No description provided for @applicationRejectedHint.
  ///
  /// In en, this message translates to:
  /// **'Fix your business details and resubmit.'**
  String get applicationRejectedHint;

  /// No description provided for @awaitingApprovalHint.
  ///
  /// In en, this message translates to:
  /// **'Taxi Pay is reviewing your business. Upload your documents to speed it up.'**
  String get awaitingApprovalHint;

  /// No description provided for @addPayout.
  ///
  /// In en, this message translates to:
  /// **'Add a payout account'**
  String get addPayout;

  /// No description provided for @addPayoutHint.
  ///
  /// In en, this message translates to:
  /// **'Needed before you start operating. Taxi Pay sends your money here.'**
  String get addPayoutHint;

  /// No description provided for @finishSetup.
  ///
  /// In en, this message translates to:
  /// **'Finish setting up'**
  String get finishSetup;

  /// No description provided for @finishSetupHint.
  ///
  /// In en, this message translates to:
  /// **'A few steps before you can run your taxis.'**
  String get finishSetupHint;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @individualUsesYourName.
  ///
  /// In en, this message translates to:
  /// **'As an individual, you operate under your own name.'**
  String get individualUsesYourName;

  /// No description provided for @tinOptional.
  ///
  /// In en, this message translates to:
  /// **'TIN (optional)'**
  String get tinOptional;

  /// No description provided for @tinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 10-digit TIN'**
  String get tinInvalid;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address (street, landmark)'**
  String get addressLine;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Pick the location on the map'**
  String get pickOnMap;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLocation;

  /// No description provided for @mapPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Business location'**
  String get mapPickerTitle;

  /// No description provided for @mapPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the map to place the pin'**
  String get mapPickerHint;

  /// No description provided for @useThisLocation.
  ///
  /// In en, this message translates to:
  /// **'Use this location'**
  String get useThisLocation;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for review'**
  String get submitForReview;

  /// No description provided for @businessDetails.
  ///
  /// In en, this message translates to:
  /// **'Business details'**
  String get businessDetails;

  /// No description provided for @businessSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Sent to Taxi Pay for review'**
  String get businessSubmitted;

  /// No description provided for @businessLocked.
  ///
  /// In en, this message translates to:
  /// **'Your business is approved, so its name, type and TIN can\'t change. Contact Taxi Pay support to change them.'**
  String get businessLocked;

  /// No description provided for @payoutSaved.
  ///
  /// In en, this message translates to:
  /// **'Payout account saved'**
  String get payoutSaved;

  /// No description provided for @payoutIntro.
  ///
  /// In en, this message translates to:
  /// **'Where Taxi Pay sends what your passengers pay.'**
  String get payoutIntro;

  /// No description provided for @walletPhone.
  ///
  /// In en, this message translates to:
  /// **'Wallet phone number'**
  String get walletPhone;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @driverRole.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverRole;

  /// No description provided for @driverLogin.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get driverLogin;

  /// No description provided for @canSignIn.
  ///
  /// In en, this message translates to:
  /// **'Driver can sign in'**
  String get canSignIn;

  /// No description provided for @driverLoginHint.
  ///
  /// In en, this message translates to:
  /// **'They sign in on this app with their phone and this password, and see only their taxis.'**
  String get driverLoginHint;

  /// No description provided for @driverPasswordKeep.
  ///
  /// In en, this message translates to:
  /// **'New password (leave empty to keep)'**
  String get driverPasswordKeep;

  /// No description provided for @assignedTaxis.
  ///
  /// In en, this message translates to:
  /// **'Assigned taxis'**
  String get assignedTaxis;

  /// No description provided for @assignedTaxisHint.
  ///
  /// In en, this message translates to:
  /// **'A taxi has one driver: picking it here moves it to this driver.'**
  String get assignedTaxisHint;

  /// No description provided for @editDriver.
  ///
  /// In en, this message translates to:
  /// **'Edit driver'**
  String get editDriver;

  /// No description provided for @deactivateDriver.
  ///
  /// In en, this message translates to:
  /// **'Deactivate driver'**
  String get deactivateDriver;

  /// No description provided for @activateDriver.
  ///
  /// In en, this message translates to:
  /// **'Activate driver'**
  String get activateDriver;

  /// No description provided for @yourTaxis.
  ///
  /// In en, this message translates to:
  /// **'Your taxis'**
  String get yourTaxis;

  /// No description provided for @noAssignedTaxis.
  ///
  /// In en, this message translates to:
  /// **'No taxis are assigned to you yet. Ask the owner to assign one.'**
  String get noAssignedTaxis;

  /// No description provided for @noTaxiReady.
  ///
  /// In en, this message translates to:
  /// **'No taxi is ready to start: it needs to be approved, active, on an approved route and not already running.'**
  String get noTaxiReady;

  /// No description provided for @taxiNotActive.
  ///
  /// In en, this message translates to:
  /// **'Not approved or not active'**
  String get taxiNotActive;

  /// No description provided for @noRoutesForTaxi.
  ///
  /// In en, this message translates to:
  /// **'No approved route yet'**
  String get noRoutesForTaxi;

  /// No description provided for @takeOver.
  ///
  /// In en, this message translates to:
  /// **'Take over'**
  String get takeOver;

  /// No description provided for @takeOverHint.
  ///
  /// In en, this message translates to:
  /// **'Only one person can run a taxi at a time.'**
  String get takeOverHint;

  /// No description provided for @tookOver.
  ///
  /// In en, this message translates to:
  /// **'You\'re running this taxi now'**
  String get tookOver;

  /// No description provided for @currentDriver.
  ///
  /// In en, this message translates to:
  /// **'Now with {name}'**
  String currentDriver(String name);

  /// No description provided for @operatingBy.
  ///
  /// In en, this message translates to:
  /// **'{name} is running this taxi'**
  String operatingBy(String name);
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
