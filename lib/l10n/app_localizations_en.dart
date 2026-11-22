// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Taxi Pay Merchant';

  @override
  String get signIn => 'Sign in';

  @override
  String get phoneOrEmail => 'Phone or email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get required => 'Required';

  @override
  String get noAccount => 'New to Taxi Pay? Register your business';

  @override
  String get registerTitle => 'Register your business';

  @override
  String get ownerSection => 'Owner';

  @override
  String get fullName => 'Full name';

  @override
  String get phone => 'Phone number';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get businessSection => 'Business';

  @override
  String get businessName => 'Business name';

  @override
  String get businessType => 'Business type';

  @override
  String get typeIndividual => 'Individual';

  @override
  String get typeCompany => 'Company';

  @override
  String get typeAssociation => 'Association';

  @override
  String get tin => 'TIN (10 digits)';

  @override
  String get tradeLicense => 'Trade licence number (optional)';

  @override
  String get city => 'City';

  @override
  String get subCity => 'Sub-city';

  @override
  String get settlementSection => 'Payout account';

  @override
  String get bankAccount => 'Bank account';

  @override
  String get mobileMoney => 'Mobile money';

  @override
  String get providerName => 'Bank or wallet';

  @override
  String get accountName => 'Account name';

  @override
  String get accountNumber => 'Account number';

  @override
  String get createAccount => 'Create account';

  @override
  String get changePasswordTitle => 'Set your password';

  @override
  String get changePasswordInfo => 'Choose your own password to continue.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get save => 'Save';

  @override
  String get statusPending => 'Your application is under review';

  @override
  String get statusPendingInfo =>
      'Upload your trade licence, TIN certificate and ID. We\'ll notify you when your business is approved.';

  @override
  String get statusRejected => 'Your application was not approved';

  @override
  String get statusRejectedInfo => 'Fix the problem below, then resubmit.';

  @override
  String get statusSuspended => 'Your business is suspended';

  @override
  String get statusSuspendedInfo =>
      'Contact Taxi Pay support to reactivate it.';

  @override
  String get reason => 'Reason';

  @override
  String get documents => 'Documents';

  @override
  String get uploadDocument => 'Upload document';

  @override
  String get resubmit => 'Resubmit application';

  @override
  String get refresh => 'Refresh';

  @override
  String get logout => 'Log out';

  @override
  String get tabHome => 'Home';

  @override
  String get tabOperate => 'Operate';

  @override
  String get tabFleet => 'Fleet';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabMore => 'More';

  @override
  String get taxis => 'Taxis';

  @override
  String get drivers => 'Drivers';

  @override
  String get routes => 'Routes';

  @override
  String get totalTaxis => 'Taxis';

  @override
  String get activeTaxis => 'Active taxis';

  @override
  String get pendingTaxis => 'Awaiting approval';

  @override
  String get completedTrips => 'Completed trips';

  @override
  String get passengers => 'Passengers';

  @override
  String get revenue => 'Revenue';

  @override
  String get onTheRoad => 'On the road now';

  @override
  String get noActiveOperations => 'No taxi is operating right now.';

  @override
  String get startOperation => 'Start operation';

  @override
  String get taxi => 'Taxi';

  @override
  String get route => 'Route';

  @override
  String get driverOptional => 'Driver (taxi\'s default if empty)';

  @override
  String get start => 'Start';

  @override
  String get depart => 'Depart';

  @override
  String get completeTrip => 'Arrived';

  @override
  String get completeAndReturn => 'Arrived — open return trip';

  @override
  String get openNextTrip => 'Open next trip';

  @override
  String get finishOperation => 'Finish operation';

  @override
  String get boarding => 'Boarding';

  @override
  String get onTheRoadStatus => 'On the road';

  @override
  String get seatsAvailable => 'Available';

  @override
  String get seatsUnpaid => 'Occupied, unpaid';

  @override
  String get seatsPaid => 'Paid';

  @override
  String get tapSeatHint => 'Tap a seat to mark it occupied or free.';

  @override
  String get trip => 'Trip';

  @override
  String get noTripOpen =>
      'No trip is open. Open the next trip to take passengers.';

  @override
  String get addTaxi => 'Add taxi';

  @override
  String get plateNumber => 'Plate number';

  @override
  String get sideNumber => 'Side number (optional)';

  @override
  String get vehicleType => 'Vehicle type';

  @override
  String get manufacturer => 'Make';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get color => 'Colour';

  @override
  String get seatLayout => 'Seat layout';

  @override
  String get seats => 'seats';

  @override
  String get qrCode => 'QR code';

  @override
  String get shareQr => 'Share QR to print';

  @override
  String get qrNotReady =>
      'The QR code is available once the taxi is approved.';

  @override
  String get defaultDriver => 'Default driver';

  @override
  String get none => 'None';

  @override
  String get addDriver => 'Add driver';

  @override
  String get licenseNumber => 'Licence number';

  @override
  String get licenseExpired => 'Licence expired';

  @override
  String get addRoute => 'Add route';

  @override
  String get routeName => 'Route name';

  @override
  String get stops => 'Stops in order';

  @override
  String get addStop => 'Add stop';

  @override
  String get stopName => 'Stop';

  @override
  String get routeInfo =>
      'Add the start, any stops in between, and the final stop. You\'ll price each leg next; an admin approves the prices.';

  @override
  String get submitForApproval => 'Submit for approval';

  @override
  String get assignTaxi => 'Assign taxi';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get telegram => 'Telegram';

  @override
  String get telegramConnected =>
      'Connected — notifications also arrive on Telegram.';

  @override
  String get telegramNotConnected =>
      'Get payment and approval notifications on Telegram.';

  @override
  String get connectTelegram => 'Connect Telegram';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get language => 'Language';

  @override
  String get offers => 'Receive offers from Taxi Pay';

  @override
  String get businessProfile => 'Business profile';

  @override
  String get all => 'All';

  @override
  String get empty => 'Nothing here yet.';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String get saved => 'Saved';

  @override
  String get status => 'Status';

  @override
  String get legsAndPrices => 'Legs and prices';

  @override
  String get legsInfo =>
      'Each pair of neighbouring stops is a leg, both ways, and the full route has its own price. You set the prices; an admin approves them.';

  @override
  String get outboundLegs => 'Outbound legs';

  @override
  String get returnLegs => 'Return legs';

  @override
  String get fullRoute => 'Full route';

  @override
  String get setPrices => 'Set prices';

  @override
  String get changePrices => 'Change prices';

  @override
  String get notPriced => 'Not priced';

  @override
  String get awaitingApproval => 'Awaiting approval';

  @override
  String newPrice(String amount) {
    return 'New: $amount';
  }

  @override
  String priceAllLegs(int count) {
    return 'Set a price for every leg before submitting ($count left).';
  }

  @override
  String get underReview => 'An admin is reviewing this route and its prices.';

  @override
  String pendingChangesInfo(int count) {
    return '$count price change(s) are waiting for an admin. Passengers pay the current prices until then.';
  }

  @override
  String get priceChangeInfo =>
      'Passengers keep paying the current prices until an admin approves your change.';

  @override
  String get applyFrom => 'Apply from';

  @override
  String get applyWhenApproved => 'As soon as approved';

  @override
  String get pricesSaved => 'Prices saved';

  @override
  String get priceChangeSent => 'Price change sent for approval';

  @override
  String get priceEtb => 'Price (ETB)';

  @override
  String get invalidPrice => 'Enter a price above 0';

  @override
  String get nothingChanged => 'No price changed';

  @override
  String get viewTaxi => 'Taxi details';

  @override
  String get notOnAnyRoute => 'Not assigned to any route yet.';
}
