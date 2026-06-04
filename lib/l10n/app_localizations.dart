import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NovaRide'**
  String get appName;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to NovaRide'**
  String get splashTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to Your Account'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get loginSubtitle;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get loginButton;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone}'**
  String otpSubtitle(Object phone);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend verification code'**
  String get resend;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoTitle;

  /// No description provided for @vehicleInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfoTitle;

  /// No description provided for @documentUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Documents'**
  String get documentUploadTitle;

  /// No description provided for @driverVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Verification'**
  String get driverVerificationTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earningsTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @tripsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsTitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Drive and Earn with us'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of drivers and start earning today.'**
  String get welcomeSubtitle;

  /// No description provided for @personalInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide your personal information to complete the registration process.'**
  String get personalInfoSubtitle;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameHint;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @dobHint.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dobHint;

  /// No description provided for @genderHint.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderHint;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordHint;

  /// No description provided for @fastEarnings.
  ///
  /// In en, this message translates to:
  /// **'Instant earnings tracking'**
  String get fastEarnings;

  /// No description provided for @safeTrips.
  ///
  /// In en, this message translates to:
  /// **'Safe & verified trips'**
  String get safeTrips;

  /// No description provided for @support247.
  ///
  /// In en, this message translates to:
  /// **'24/7 support team'**
  String get support247;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get startButton;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get otpTitle;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @driverOffersText.
  ///
  /// In en, this message translates to:
  /// **'Once you become a driver, we may occasionally send you offers and updates related to our services.'**
  String get driverOffersText;

  /// No description provided for @termsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get termsAgreement;

  /// No description provided for @legalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to comply with Syrian and local legislation and provide only legal services on the NovaRide Platform.'**
  String get legalDisclaimer;

  /// No description provided for @marketingText.
  ///
  /// In en, this message translates to:
  /// **'Join NovaRide today and start your journey towards earning a sustainable income by driving your own car. With NovaRide, you can enjoy flexible work, earn more money, and join a growing community of drivers who share the same goal.'**
  String get marketingText;

  /// No description provided for @legalText.
  ///
  /// In en, this message translates to:
  /// **'By registering, you agree to comply with Syrian and local legislation and provide only legal services on the NovaRide Platform.'**
  String get legalText;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get nameRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneRequired;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 9 or 10 digits'**
  String get invalidPhone;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @licenseCountry.
  ///
  /// In en, this message translates to:
  /// **'License Country'**
  String get licenseCountry;

  /// No description provided for @licenseNumberHint.
  ///
  /// In en, this message translates to:
  /// **'License Number'**
  String get licenseNumberHint;

  /// No description provided for @licenseCountryHint.
  ///
  /// In en, this message translates to:
  /// **'Select License Country'**
  String get licenseCountryHint;

  /// No description provided for @licenseCountryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a license country'**
  String get licenseCountryRequired;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms\n\nBy registering and using the NovaRide platform, you agree to comply with these Terms of Service and all applicable local and international laws and regulations.\n\n2. Eligibility\n\nYou confirm that you are legally authorized to provide transportation services in your country and possess a valid driving license and required permits.\n\n3. Driver Responsibilities\n\nDrivers must provide safe, lawful, and professional services, maintain valid vehicle registration and insurance, and comply with traffic laws and transportation regulations.\n\n4. Account Accuracy\n\nYou agree to provide accurate, current, and complete information during registration and update it when necessary.\n\n5. Prohibited Activities\n\nYou may not use the platform for unlawful, fraudulent, harmful, or misleading purposes.\n\n6. Payments and Fees\n\nNovaRide may collect service fees as agreed. Drivers are responsible for taxes and legal obligations in their jurisdiction.\n\n7. Data and Privacy\n\nYour personal data will be processed in accordance with applicable data protection regulations.\n\n8. Suspension and Termination\n\nNovaRide reserves the right to suspend or terminate accounts that violate these terms or applicable laws.\n\n9. Limitation of Liability\n\nNovaRide shall not be liable for indirect, incidental, or consequential damages arising from platform use.\n\n10. Modifications\n\nWe may update these terms from time to time. Continued use of the platform constitutes acceptance of any changes.'**
  String get termsContent;

  /// No description provided for @invalidName.
  ///
  /// In en, this message translates to:
  /// **'Invalid name'**
  String get invalidName;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get invalidPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get verifyPhone;

  /// No description provided for @codeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String codeSentTo(Object phone);

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String resendIn(Object seconds);

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @person.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @office.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get office;

  /// No description provided for @officeName.
  ///
  /// In en, this message translates to:
  /// **'Office Name'**
  String get officeName;

  /// No description provided for @officeLocation.
  ///
  /// In en, this message translates to:
  /// **'Office Location'**
  String get officeLocation;

  /// No description provided for @officeContact.
  ///
  /// In en, this message translates to:
  /// **'Office Contact Information'**
  String get officeContact;

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number'**
  String get idNumber;

  /// No description provided for @vehicleType.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicleType;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @motorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get motorcycle;

  /// No description provided for @van.
  ///
  /// In en, this message translates to:
  /// **'Van/microbus'**
  String get van;

  /// No description provided for @bicycle.
  ///
  /// In en, this message translates to:
  /// **'Bicycle'**
  String get bicycle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @personalInfoSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Only your first name and car details are visible to passengers during the booking'**
  String get personalInfoSubtitle2;

  /// No description provided for @personalInfoTitle2.
  ///
  /// In en, this message translates to:
  /// **'Personal information and car details'**
  String get personalInfoTitle2;

  /// No description provided for @joinAsDriver.
  ///
  /// In en, this message translates to:
  /// **'I want to join NovaRide as:'**
  String get joinAsDriver;

  /// No description provided for @explain.
  ///
  /// In en, this message translates to:
  /// **'Select \"office\" if you\'re using a limited office (Ltd) (if you\'re the sole owner or director) or a limited liability partnership (LLP).\n\nSelect \"Person\" if you operate individually, for example, as a sole trader or are self-employed.'**
  String get explain;

  /// No description provided for @licensePlate.
  ///
  /// In en, this message translates to:
  /// **'License Plate Number'**
  String get licensePlate;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manu facturer'**
  String get manufacturer;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'model'**
  String get brand;

  /// No description provided for @passengerCount.
  ///
  /// In en, this message translates to:
  /// **'Passenger Count'**
  String get passengerCount;

  /// No description provided for @vehicleColor.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Color'**
  String get vehicleColor;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @colorSelected.
  ///
  /// In en, this message translates to:
  /// **'Color Selected'**
  String get colorSelected;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @enterPlate.
  ///
  /// In en, this message translates to:
  /// **'Enter your license plate number'**
  String get enterPlate;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @grey.
  ///
  /// In en, this message translates to:
  /// **'Grey'**
  String get grey;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @selectBrandHint.
  ///
  /// In en, this message translates to:
  /// **'Select Brand'**
  String get selectBrandHint;

  /// No description provided for @brandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brandLabel;

  /// No description provided for @enterOtherBrand.
  ///
  /// In en, this message translates to:
  /// **'Enter Other Brand'**
  String get enterOtherBrand;

  /// No description provided for @selectModelHint.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModelHint;

  /// No description provided for @selectColorHint.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColorHint;

  /// No description provided for @selectPassengerHint.
  ///
  /// In en, this message translates to:
  /// **'Select Passenger Count'**
  String get selectPassengerHint;

  /// No description provided for @vehicleYear.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Year'**
  String get vehicleYear;

  /// No description provided for @selectYearHint.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Year'**
  String get selectYearHint;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select birth date'**
  String get selectBirthDate;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// No description provided for @idHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your ID number'**
  String get idHint;

  /// No description provided for @underAgeError.
  ///
  /// In en, this message translates to:
  /// **'Not allowed - Age must be 18+'**
  String get underAgeError;

  /// No description provided for @uploadRequiredDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload required documents'**
  String get uploadRequiredDocuments;

  /// No description provided for @driverId.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driverId;

  /// No description provided for @drivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get drivingLicense;

  /// No description provided for @vehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Registration'**
  String get vehicleRegistration;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @vehicleFrontPhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Front Photo'**
  String get vehicleFrontPhoto;

  /// No description provided for @vehicleInteriorPhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Interior Photo'**
  String get vehicleInteriorPhoto;

  /// No description provided for @documentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documentsTitle;

  /// No description provided for @documentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re legally required to ask you for some documents to sign you up as a driver. Document scans and quality photos are accepted.'**
  String get documentsSubtitle;

  /// No description provided for @profilePicture.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture'**
  String get profilePicture;

  /// No description provided for @profileDescription.
  ///
  /// In en, this message translates to:
  /// **'Please provide a clear picture of yourself on a white background. It must show your full face with no sunglasses, bluetooth headsets or earphones. This picture will be visible to passengers.'**
  String get profileDescription;

  /// No description provided for @driverIdFront.
  ///
  /// In en, this message translates to:
  /// **'Driver ID - Front'**
  String get driverIdFront;

  /// No description provided for @driverIdBack.
  ///
  /// In en, this message translates to:
  /// **'Driver ID - Back'**
  String get driverIdBack;

  /// No description provided for @idDescription.
  ///
  /// In en, this message translates to:
  /// **'Please upload a clear photo of your ID (front and back).'**
  String get idDescription;

  /// No description provided for @licenseFront.
  ///
  /// In en, this message translates to:
  /// **'Driving License - Front'**
  String get licenseFront;

  /// No description provided for @licenseBack.
  ///
  /// In en, this message translates to:
  /// **'Driving License - Back'**
  String get licenseBack;

  /// No description provided for @licenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Please upload a clear photo of your driving license (front and back).'**
  String get licenseDescription;

  /// No description provided for @vehicleBackPhoto.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Back Photo'**
  String get vehicleBackPhoto;

  /// No description provided for @workLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Work location and availability'**
  String get workLocationTitle;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @workArea.
  ///
  /// In en, this message translates to:
  /// **'Work area'**
  String get workArea;

  /// No description provided for @startLocation.
  ///
  /// In en, this message translates to:
  /// **'Set starting location'**
  String get startLocation;

  /// No description provided for @selectOnMap.
  ///
  /// In en, this message translates to:
  /// **'Select on map'**
  String get selectOnMap;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get workingHours;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @registrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Registration Complete'**
  String get registrationComplete;

  /// No description provided for @accountUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Your account is under review.'**
  String get accountUnderReview;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @damascus.
  ///
  /// In en, this message translates to:
  /// **'Damascus'**
  String get damascus;

  /// No description provided for @rifDamascus.
  ///
  /// In en, this message translates to:
  /// **'Rif Damascus'**
  String get rifDamascus;

  /// No description provided for @barzeh.
  ///
  /// In en, this message translates to:
  /// **'Barzeh'**
  String get barzeh;

  /// No description provided for @mazzeh.
  ///
  /// In en, this message translates to:
  /// **'Mazzeh'**
  String get mazzeh;

  /// No description provided for @kafr_sousa.
  ///
  /// In en, this message translates to:
  /// **'Kafr Sousa'**
  String get kafr_sousa;

  /// No description provided for @abu_rummaneh.
  ///
  /// In en, this message translates to:
  /// **'Abu Rummaneh'**
  String get abu_rummaneh;

  /// No description provided for @midane.
  ///
  /// In en, this message translates to:
  /// **'Midane'**
  String get midane;

  /// No description provided for @rukn_al_din.
  ///
  /// In en, this message translates to:
  /// **'Rukn Al Din'**
  String get rukn_al_din;

  /// No description provided for @ash_al_warwar.
  ///
  /// In en, this message translates to:
  /// **'Ash Al Warwar'**
  String get ash_al_warwar;

  /// No description provided for @qadam.
  ///
  /// In en, this message translates to:
  /// **'Qadam'**
  String get qadam;

  /// No description provided for @al_tal.
  ///
  /// In en, this message translates to:
  /// **'Al Tal'**
  String get al_tal;

  /// No description provided for @manin.
  ///
  /// In en, this message translates to:
  /// **'Manin'**
  String get manin;

  /// No description provided for @saydnaya.
  ///
  /// In en, this message translates to:
  /// **'Saydnaya'**
  String get saydnaya;

  /// No description provided for @maarraba.
  ///
  /// In en, this message translates to:
  /// **'Maarraba'**
  String get maarraba;

  /// No description provided for @qudsaya.
  ///
  /// In en, this message translates to:
  /// **'Qudsaya'**
  String get qudsaya;

  /// No description provided for @jaramana.
  ///
  /// In en, this message translates to:
  /// **'Jaramana'**
  String get jaramana;

  /// No description provided for @sahnaya.
  ///
  /// In en, this message translates to:
  /// **'Sahnaya'**
  String get sahnaya;

  /// No description provided for @daraya.
  ///
  /// In en, this message translates to:
  /// **'Daraya'**
  String get daraya;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @detailedAddress.
  ///
  /// In en, this message translates to:
  /// **'Detailed address'**
  String get detailedAddress;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street name, building, landmark...'**
  String get addressHint;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @reviewMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'re reviewing your application and will notify you within 3 days. For real-time updates and next steps, check the app.'**
  String get reviewMessage;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open the app'**
  String get openApp;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'home'**
  String get home;

  /// No description provided for @trips.
  ///
  /// In en, this message translates to:
  /// **'trips'**
  String get trips;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'earning'**
  String get earnings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get account;

  /// No description provided for @tripsToday.
  ///
  /// In en, this message translates to:
  /// **' trips for today'**
  String get tripsToday;

  /// No description provided for @earningsLabel.
  ///
  /// In en, this message translates to:
  /// **'earning label'**
  String get earningsLabel;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get rating;

  /// No description provided for @goOnline.
  ///
  /// In en, this message translates to:
  /// **' go online'**
  String get goOnline;

  /// No description provided for @goOffline.
  ///
  /// In en, this message translates to:
  /// **' go offline'**
  String get goOffline;

  /// No description provided for @newRideRequest.
  ///
  /// In en, this message translates to:
  /// **'new Ride Reqest'**
  String get newRideRequest;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'pickup location '**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'drop off'**
  String get dropoff;

  /// No description provided for @fare.
  ///
  /// In en, this message translates to:
  /// **'fare'**
  String get fare;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'account setting '**
  String get accountSettings;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support & Help'**
  String get support;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportIssue;

  /// No description provided for @complaintTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem type'**
  String get complaintTypeTitle;

  /// No description provided for @complaintDescTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get complaintDescTitle;

  /// No description provided for @complaintDescHint.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue in detail...'**
  String get complaintDescHint;

  /// No description provided for @complaintSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit complaint'**
  String get complaintSubmit;

  /// No description provided for @complaintSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted'**
  String get complaintSuccessTitle;

  /// No description provided for @complaintSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'We will respond within 24 hours'**
  String get complaintSuccessBody;

  /// No description provided for @complaintOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get complaintOk;

  /// No description provided for @complaintError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your request'**
  String get complaintError;

  /// No description provided for @complaintTypePassenger.
  ///
  /// In en, this message translates to:
  /// **'Issue with passenger'**
  String get complaintTypePassenger;

  /// No description provided for @complaintTypeTechnical.
  ///
  /// In en, this message translates to:
  /// **'Technical issue'**
  String get complaintTypeTechnical;

  /// No description provided for @complaintTypeBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing issue'**
  String get complaintTypeBilling;

  /// No description provided for @complaintTypeSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety issue'**
  String get complaintTypeSafety;

  /// No description provided for @whatsappUs.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsappUs;

  /// No description provided for @whatsappUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with us on WhatsApp'**
  String get whatsappUsDesc;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'log out '**
  String get logout;

  /// No description provided for @driverAccount.
  ///
  /// In en, this message translates to:
  /// **'driver account '**
  String get driverAccount;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'app version '**
  String get appVersion;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'reject'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'accept'**
  String get accept;

  /// No description provided for @rideAccepted.
  ///
  /// In en, this message translates to:
  /// **'ride accepted '**
  String get rideAccepted;

  /// No description provided for @vehicleInfo.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information'**
  String get vehicleInfo;

  /// No description provided for @carType.
  ///
  /// In en, this message translates to:
  /// **'Car Type'**
  String get carType;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @manufactureYear.
  ///
  /// In en, this message translates to:
  /// **'Manufacture Year'**
  String get manufactureYear;

  /// No description provided for @vehicleStatus.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Status'**
  String get vehicleStatus;

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Information'**
  String get editVehicle;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @noTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips'**
  String get noTrips;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @driverPerformance.
  ///
  /// In en, this message translates to:
  /// **'Driver Performance'**
  String get driverPerformance;

  /// No description provided for @acceptanceRate.
  ///
  /// In en, this message translates to:
  /// **'Acceptance Rate'**
  String get acceptanceRate;

  /// No description provided for @cancellationRate.
  ///
  /// In en, this message translates to:
  /// **'Cancellation Rate'**
  String get cancellationRate;

  /// No description provided for @verifiedDriver.
  ///
  /// In en, this message translates to:
  /// **'Verified Driver'**
  String get verifiedDriver;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @exportStatement.
  ///
  /// In en, this message translates to:
  /// **'Export Statement'**
  String get exportStatement;

  /// No description provided for @earningsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get earningsBreakdown;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get months;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get dec;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @modelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @plateLabel.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plateLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @vehicleImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleImageLabel;

  /// No description provided for @licenseImageLabel.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get licenseImageLabel;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @noVehicleFound.
  ///
  /// In en, this message translates to:
  /// **'noVehicleFound'**
  String get noVehicleFound;

  /// No description provided for @supportDesc.
  ///
  /// In en, this message translates to:
  /// **'We’re here to help you anytime, anywhere.'**
  String get supportDesc;

  /// No description provided for @chatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get chatWithUs;

  /// No description provided for @chatWithUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Live chat with our support team'**
  String get chatWithUsDesc;

  /// No description provided for @callUs.
  ///
  /// In en, this message translates to:
  /// **'Call us'**
  String get callUs;

  /// No description provided for @callUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Talk directly with our support team'**
  String get callUsDesc;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get emailUs;

  /// No description provided for @emailUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Send us your questions via email'**
  String get emailUsDesc;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @faqDesc.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqDesc;

  /// No description provided for @supportFooter.
  ///
  /// In en, this message translates to:
  /// **'Your safety and satisfaction are our top priority.'**
  String get supportFooter;

  /// No description provided for @driverFaq.
  ///
  /// In en, this message translates to:
  /// **'Driver FAQ'**
  String get driverFaq;

  /// No description provided for @driverFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver Frequently Asked Questions'**
  String get driverFaqTitle;

  /// No description provided for @driverFaqSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find answers to common issues faced by drivers'**
  String get driverFaqSubtitle;

  /// No description provided for @driverFaqVehicleUpdateQ.
  ///
  /// In en, this message translates to:
  /// **'How can I update my vehicle or upload a new vehicle image?'**
  String get driverFaqVehicleUpdateQ;

  /// No description provided for @driverFaqVehicleUpdateA.
  ///
  /// In en, this message translates to:
  /// **'Go to your vehicle profile and click on \'Edit Vehicle\'. You can upload a new vehicle image or change details.'**
  String get driverFaqVehicleUpdateA;

  /// No description provided for @driverFaqScheduleQ.
  ///
  /// In en, this message translates to:
  /// **'How can I manage my schedule and available trips?'**
  String get driverFaqScheduleQ;

  /// No description provided for @driverFaqScheduleA.
  ///
  /// In en, this message translates to:
  /// **'Use the Schedule section in your driver app to set your working hours and available trip slots.'**
  String get driverFaqScheduleA;

  /// No description provided for @driverFaqPaymentQ.
  ///
  /// In en, this message translates to:
  /// **'When and how will I receive my payments?'**
  String get driverFaqPaymentQ;

  /// No description provided for @driverFaqPaymentA.
  ///
  /// In en, this message translates to:
  /// **'Payments are processed weekly and transferred directly to your registered bank account.'**
  String get driverFaqPaymentA;

  /// No description provided for @driverFaqSafetyQ.
  ///
  /// In en, this message translates to:
  /// **'What should I do if I face a safety issue with a passenger?'**
  String get driverFaqSafetyQ;

  /// No description provided for @driverFaqSafetyA.
  ///
  /// In en, this message translates to:
  /// **'Immediately contact driver support using the \'Support\' section in the app.'**
  String get driverFaqSafetyA;

  /// No description provided for @driverFaqSupportQ.
  ///
  /// In en, this message translates to:
  /// **'How can I contact support if I have an issue?'**
  String get driverFaqSupportQ;

  /// No description provided for @driverFaqSupportA.
  ///
  /// In en, this message translates to:
  /// **'Use Support & Help to call us, submit a complaint, or reach us on WhatsApp and email.'**
  String get driverFaqSupportA;

  /// No description provided for @driverFaqTripCancelQ.
  ///
  /// In en, this message translates to:
  /// **'What happens if a trip is canceled?'**
  String get driverFaqTripCancelQ;

  /// No description provided for @driverFaqTripCancelA.
  ///
  /// In en, this message translates to:
  /// **'If a trip is canceled, you will be notified immediately. Earnings for completed trips remain unaffected.'**
  String get driverFaqTripCancelA;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location of the office'**
  String get location;

  /// No description provided for @officeN.
  ///
  /// In en, this message translates to:
  /// **'Office Name'**
  String get officeN;

  /// No description provided for @ageError.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old.'**
  String get ageError;

  /// No description provided for @nameError.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 3 letters.'**
  String get nameError;

  /// No description provided for @idError.
  ///
  /// In en, this message translates to:
  /// **'ID number must be at least 6 digits.'**
  String get idError;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameHint;

  /// No description provided for @enterEngineCapacity.
  ///
  /// In en, this message translates to:
  /// **'Enter engine capacity'**
  String get enterEngineCapacity;

  /// No description provided for @engineCapacity.
  ///
  /// In en, this message translates to:
  /// **'Engine Capacity (cc)'**
  String get engineCapacity;

  /// No description provided for @enterMotorPlate.
  ///
  /// In en, this message translates to:
  /// **'Enter motorcycle plate number'**
  String get enterMotorPlate;

  /// No description provided for @enterOtherModel.
  ///
  /// In en, this message translates to:
  /// **'Type other model'**
  String get enterOtherModel;

  /// No description provided for @motorcycleBrand.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle Brand'**
  String get motorcycleBrand;

  /// No description provided for @motorcycleEngineSize.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle Engine Size (cc)'**
  String get motorcycleEngineSize;

  /// No description provided for @motorcycleModel.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle Model'**
  String get motorcycleModel;

  /// No description provided for @motorcyclePlateNumber.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle Plate Number'**
  String get motorcyclePlateNumber;

  /// No description provided for @specialServices.
  ///
  /// In en, this message translates to:
  /// **'Special Services'**
  String get specialServices;

  /// No description provided for @waterTanker.
  ///
  /// In en, this message translates to:
  /// **'Water Tanker'**
  String get waterTanker;

  /// No description provided for @movingTruck.
  ///
  /// In en, this message translates to:
  /// **'Moving Truck'**
  String get movingTruck;

  /// No description provided for @carWash.
  ///
  /// In en, this message translates to:
  /// **'Car Wash'**
  String get carWash;

  /// No description provided for @tankerCapacity.
  ///
  /// In en, this message translates to:
  /// **'Tanker Capacity (liters)'**
  String get tankerCapacity;

  /// No description provided for @enterTankerCapacity.
  ///
  /// In en, this message translates to:
  /// **'Enter tanker capacity'**
  String get enterTankerCapacity;

  /// No description provided for @cargoVolume.
  ///
  /// In en, this message translates to:
  /// **'Cargo Volume (m³)'**
  String get cargoVolume;

  /// No description provided for @enterCargoVolume.
  ///
  /// In en, this message translates to:
  /// **'Enter cargo volume'**
  String get enterCargoVolume;

  /// No description provided for @carWashHasPressureWasher.
  ///
  /// In en, this message translates to:
  /// **'Has pressure washer?'**
  String get carWashHasPressureWasher;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @mySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'My Subscriptions'**
  String get mySubscriptions;

  /// No description provided for @mySubscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'My Subscription'**
  String get mySubscriptionTitle;

  /// No description provided for @noSubscriptionFound.
  ///
  /// In en, this message translates to:
  /// **'No subscription found'**
  String get noSubscriptionFound;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get choosePlan;

  /// No description provided for @changePlan.
  ///
  /// In en, this message translates to:
  /// **'Change Plan'**
  String get changePlan;

  /// No description provided for @commissionPlan.
  ///
  /// In en, this message translates to:
  /// **'Commission Plan'**
  String get commissionPlan;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @paymentOverdue.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Payment Overdue'**
  String get paymentOverdue;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'✅ Active'**
  String get active;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get amountDue;

  /// No description provided for @totalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// No description provided for @totalOwed.
  ///
  /// In en, this message translates to:
  /// **'Total Owed'**
  String get totalOwed;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @nextDue.
  ///
  /// In en, this message translates to:
  /// **'Next Due'**
  String get nextDue;

  /// No description provided for @howToPay.
  ///
  /// In en, this message translates to:
  /// **'How to Pay'**
  String get howToPay;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @payWeeklyInPerson.
  ///
  /// In en, this message translates to:
  /// **'Pay weekly in person to admin'**
  String get payWeeklyInPerson;

  /// No description provided for @shamCash.
  ///
  /// In en, this message translates to:
  /// **'Sham Cash'**
  String get shamCash;

  /// No description provided for @mobileBalance.
  ///
  /// In en, this message translates to:
  /// **'Mobile Balance'**
  String get mobileBalance;

  /// No description provided for @transferToPhone.
  ///
  /// In en, this message translates to:
  /// **'Transfer to: 0900000000'**
  String get transferToPhone;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank: Syria & Overseas Bank'**
  String get bankName;

  /// No description provided for @iban.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get iban;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @myMethod.
  ///
  /// In en, this message translates to:
  /// **'My Method'**
  String get myMethod;

  /// No description provided for @currencyShort.
  ///
  /// In en, this message translates to:
  /// **'SYP'**
  String get currencyShort;

  /// No description provided for @cashKey.
  ///
  /// In en, this message translates to:
  /// **'cash'**
  String get cashKey;

  /// No description provided for @shamCashKey.
  ///
  /// In en, this message translates to:
  /// **'sham_cash'**
  String get shamCashKey;

  /// No description provided for @balanceKey.
  ///
  /// In en, this message translates to:
  /// **'balance'**
  String get balanceKey;

  /// No description provided for @bankKey.
  ///
  /// In en, this message translates to:
  /// **'bank'**
  String get bankKey;

  /// No description provided for @commission.
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get commission;

  /// No description provided for @payPerRide.
  ///
  /// In en, this message translates to:
  /// **'Pay per ride'**
  String get payPerRide;

  /// No description provided for @fixedFee.
  ///
  /// In en, this message translates to:
  /// **'Fixed fee'**
  String get fixedFee;

  /// No description provided for @chooseYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// No description provided for @novaRidePartnership.
  ///
  /// In en, this message translates to:
  /// **'NovaRide Partnership'**
  String get novaRidePartnership;

  /// No description provided for @chooseHowYouWork.
  ///
  /// In en, this message translates to:
  /// **'Choose how you work with us'**
  String get chooseHowYouWork;

  /// No description provided for @paymentMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodTitle;

  /// No description provided for @commissionRate.
  ///
  /// In en, this message translates to:
  /// **'Commission Rate'**
  String get commissionRate;

  /// No description provided for @commissionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Each completed ride: 10% is taken by the app and accumulated weekly to be paid.'**
  String get commissionExplanation;

  /// No description provided for @commissionShort.
  ///
  /// In en, this message translates to:
  /// **'commission'**
  String get commissionShort;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @perRide.
  ///
  /// In en, this message translates to:
  /// **'per ride'**
  String get perRide;

  /// No description provided for @monthlyFeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Fee'**
  String get monthlyFeeTitle;

  /// No description provided for @fixedAmountPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Fixed amount per month'**
  String get fixedAmountPerMonth;

  /// No description provided for @monthlyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Keep 100% of ride earnings. Pay fixed monthly fee.'**
  String get monthlyExplanation;

  /// No description provided for @startDriving.
  ///
  /// In en, this message translates to:
  /// **'Start Driving 🚀'**
  String get startDriving;

  /// No description provided for @updatePlan.
  ///
  /// In en, this message translates to:
  /// **'Update Plan'**
  String get updatePlan;

  /// No description provided for @subscriptionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated!'**
  String get subscriptionUpdated;

  /// No description provided for @subscriptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update subscription'**
  String get subscriptionFailed;

  /// No description provided for @changePlanAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change your plan anytime from settings'**
  String get changePlanAnytime;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @ofEachRideFare.
  ///
  /// In en, this message translates to:
  /// **'of each ride fare'**
  String get ofEachRideFare;

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'Transfer to'**
  String get transferTo;

  /// No description provided for @ref.
  ///
  /// In en, this message translates to:
  /// **'Ref'**
  String get ref;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @rideHeadToPickup.
  ///
  /// In en, this message translates to:
  /// **'Head to pickup point'**
  String get rideHeadToPickup;

  /// No description provided for @rideWaitingPassenger.
  ///
  /// In en, this message translates to:
  /// **'Waiting for passenger'**
  String get rideWaitingPassenger;

  /// No description provided for @ridePassengerOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Passenger on board'**
  String get ridePassengerOnBoard;

  /// No description provided for @rideInProgress.
  ///
  /// In en, this message translates to:
  /// **'Heading to destination'**
  String get rideInProgress;

  /// No description provided for @rideBtnArrived.
  ///
  /// In en, this message translates to:
  /// **'I have arrived'**
  String get rideBtnArrived;

  /// No description provided for @rideBtnPassengerOnBoard.
  ///
  /// In en, this message translates to:
  /// **'Passenger is on board'**
  String get rideBtnPassengerOnBoard;

  /// No description provided for @rideBtnStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Start trip'**
  String get rideBtnStartTrip;

  /// No description provided for @rideBtnCompleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete trip'**
  String get rideBtnCompleteTrip;

  /// No description provided for @rideMarkerPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get rideMarkerPickup;

  /// No description provided for @rideMarkerDropoff.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get rideMarkerDropoff;

  /// No description provided for @rideMarkerYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get rideMarkerYou;

  /// No description provided for @ridePickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get ridePickupLabel;

  /// No description provided for @rideDropoffLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get rideDropoffLabel;

  /// No description provided for @rideCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip completed!'**
  String get rideCompletedTitle;

  /// No description provided for @rideDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get rideDone;

  /// No description provided for @rideCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride?'**
  String get rideCancelTitle;

  /// No description provided for @rideCancelRide.
  ///
  /// In en, this message translates to:
  /// **'Cancel ride'**
  String get rideCancelRide;

  /// No description provided for @ridePassengerLabel.
  ///
  /// In en, this message translates to:
  /// **'Passenger'**
  String get ridePassengerLabel;

  /// No description provided for @ridePaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get ridePaymentMethod;

  /// No description provided for @rideCancelledByPassenger.
  ///
  /// In en, this message translates to:
  /// **'Passenger cancelled the ride'**
  String get rideCancelledByPassenger;

  /// No description provided for @rideNavigatingToDropoff.
  ///
  /// In en, this message translates to:
  /// **'Navigating to destination'**
  String get rideNavigatingToDropoff;

  /// No description provided for @rideNoPassengerPhone.
  ///
  /// In en, this message translates to:
  /// **'Passenger phone number is not available'**
  String get rideNoPassengerPhone;

  /// No description provided for @rideCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not start a phone call'**
  String get rideCallFailed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmpty;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @rideMessageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open messaging app'**
  String get rideMessageFailed;

  /// No description provided for @rideOpenInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get rideOpenInMaps;

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @incomingRideTitle.
  ///
  /// In en, this message translates to:
  /// **'New ride request!'**
  String get incomingRideTitle;

  /// No description provided for @incomingRideSec.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String incomingRideSec(int seconds);

  /// No description provided for @incomingRideFare.
  ///
  /// In en, this message translates to:
  /// **'Fare'**
  String get incomingRideFare;

  /// No description provided for @incomingRideDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get incomingRideDistance;

  /// No description provided for @incomingRideEta.
  ///
  /// In en, this message translates to:
  /// **'ETA'**
  String get incomingRideEta;

  /// No description provided for @incomingRideDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get incomingRideDecline;

  /// No description provided for @incomingRideAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept ride'**
  String get incomingRideAccept;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @rateYourPassenger.
  ///
  /// In en, this message translates to:
  /// **'Rate your passenger'**
  String get rateYourPassenger;

  /// No description provided for @howWasPassenger.
  ///
  /// In en, this message translates to:
  /// **'How was this passenger?'**
  String get howWasPassenger;

  /// No description provided for @ratingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get ratingSubmitted;

  /// No description provided for @ratingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit rating'**
  String get ratingFailed;

  /// No description provided for @chatEmpty.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello!'**
  String get chatEmpty;

  /// No description provided for @chatTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatTypeMessage;

  /// No description provided for @walletTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get walletAvailable;

  /// No description provided for @walletWithdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal amount'**
  String get walletWithdrawAmount;

  /// No description provided for @walletRequestPayout.
  ///
  /// In en, this message translates to:
  /// **'Request payout'**
  String get walletRequestPayout;

  /// No description provided for @walletPayoutHistory.
  ///
  /// In en, this message translates to:
  /// **'Payout history'**
  String get walletPayoutHistory;

  /// No description provided for @walletNoPayouts.
  ///
  /// In en, this message translates to:
  /// **'No payouts yet'**
  String get walletNoPayouts;

  /// No description provided for @walletInvalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get walletInvalidAmount;

  /// No description provided for @walletInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds your balance'**
  String get walletInsufficient;

  /// No description provided for @walletPayoutRequested.
  ///
  /// In en, this message translates to:
  /// **'Payout requested'**
  String get walletPayoutRequested;

  /// No description provided for @workZonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Work zones & schedule'**
  String get workZonesTitle;

  /// No description provided for @workZonesOnShift.
  ///
  /// In en, this message translates to:
  /// **'You are within your work hours'**
  String get workZonesOnShift;

  /// No description provided for @workZonesOffShift.
  ///
  /// In en, this message translates to:
  /// **'Outside work hours'**
  String get workZonesOffShift;

  /// No description provided for @workZonesScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'You can only go online during your scheduled hours'**
  String get workZonesScheduleHint;

  /// No description provided for @workZoneAdd.
  ///
  /// In en, this message translates to:
  /// **'Add work zone'**
  String get workZoneAdd;

  /// No description provided for @workZonePrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get workZonePrimary;

  /// No description provided for @workZonesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No work zones yet. Add one to set your schedule.'**
  String get workZonesEmpty;

  /// No description provided for @workZonesOffShiftOnline.
  ///
  /// In en, this message translates to:
  /// **'Outside scheduled hours. Update your schedule in Work zones.'**
  String get workZonesOffShiftOnline;

  /// No description provided for @voiceNavOn.
  ///
  /// In en, this message translates to:
  /// **'Voice navigation on'**
  String get voiceNavOn;

  /// No description provided for @voiceNavOff.
  ///
  /// In en, this message translates to:
  /// **'Voice navigation off'**
  String get voiceNavOff;

  /// No description provided for @voiceNavToggle.
  ///
  /// In en, this message translates to:
  /// **'Voice navigation'**
  String get voiceNavToggle;

  /// No description provided for @rideTakenByAnother.
  ///
  /// In en, this message translates to:
  /// **'This ride was taken by another driver'**
  String get rideTakenByAnother;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
