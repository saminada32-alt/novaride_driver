// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'NovaRide';

  @override
  String get splashTitle => 'Welcome to NovaRide';

  @override
  String get loginTitle => 'Login to Your Account';

  @override
  String get loginSubtitle => 'Enter your phone number to continue';

  @override
  String get phoneHint => 'Phone Number';

  @override
  String get loginButton => 'Send verification code';

  @override
  String get accountNotRegistered => 'This number is not registered. Please create a new account.';

  @override
  String get accountNotRegisteredTitle => 'Not registered';

  @override
  String otpSubtitle(Object phone) {
    return 'We sent a code to $phone';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get resend => 'Resend verification code';

  @override
  String get personalInfoTitle => 'Personal Information';

  @override
  String get vehicleInfoTitle => 'Vehicle Information';

  @override
  String get documentUploadTitle => 'Upload Documents';

  @override
  String get driverVerificationTitle => 'Driver Verification';

  @override
  String get homeTitle => 'Home';

  @override
  String get earningsTitle => 'Earnings';

  @override
  String get profileTitle => 'Profile';

  @override
  String get tripsTitle => 'Trips';

  @override
  String get getStarted => 'Get Started';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Join thousands of drivers and start earning today.';

  @override
  String get personalInfoSubtitle => 'Please provide your personal information to complete the registration process.';

  @override
  String get fullNameHint => 'Full Name';

  @override
  String get emailHint => 'Email';

  @override
  String get dobHint => 'Date of Birth';

  @override
  String get genderHint => 'Gender';

  @override
  String get nextButton => 'Next';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get loading => 'Loading...';

  @override
  String get continueButton => 'Continue';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get passwordHint => 'Password';

  @override
  String get confirmPasswordHint => 'Confirm Password';

  @override
  String get fastEarnings => 'Instant earnings tracking';

  @override
  String get safeTrips => 'Safe & verified trips';

  @override
  String get support247 => '24/7 support team';

  @override
  String get startButton => 'Get Started';

  @override
  String get otpTitle => 'Verify Your Number';

  @override
  String get verifyButton => 'Verify';

  @override
  String get resendCode => 'Resend Code';

  @override
  String get signIn => 'Sign In';

  @override
  String get register => 'Register';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get phone => 'Phone Number';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get optional => 'Optional';

  @override
  String get createAccount => 'Create Account';

  @override
  String get driverOffersText => 'Once you become a driver, we may occasionally send you offers and updates related to our services.';

  @override
  String get termsAgreement => 'I agree to the Terms of Service and Privacy Policy.';

  @override
  String get legalDisclaimer => 'By registering, you agree to comply with Syrian and local legislation and provide only legal services on the NovaRide Platform.';

  @override
  String get marketingText => 'Join NovaRide today and start your journey towards earning a sustainable income by driving your own car. With NovaRide, you can enjoy flexible work, earn more money, and join a growing community of drivers who share the same goal.';

  @override
  String get legalText => 'By registering, you agree to comply with Syrian and local legislation and provide only legal services on the NovaRide Platform.';

  @override
  String get nameRequired => 'Please enter your full name';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get phoneRequired => 'Please enter your phone number';

  @override
  String get invalidPhone => 'Phone number must be 9 or 10 digits';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get licenseCountry => 'License Country';

  @override
  String get licenseNumberHint => 'License Number';

  @override
  String get licenseCountryHint => 'Select License Country';

  @override
  String get licenseCountryRequired => 'Please select a license country';

  @override
  String get termsContent => '1. Acceptance of Terms\n\nBy registering and using the NovaRide platform, you agree to comply with these Terms of Service and all applicable local and international laws and regulations.\n\n2. Eligibility\n\nYou confirm that you are legally authorized to provide transportation services in your country and possess a valid driving license and required permits.\n\n3. Driver Responsibilities\n\nDrivers must provide safe, lawful, and professional services, maintain valid vehicle registration and insurance, and comply with traffic laws and transportation regulations.\n\n4. Account Accuracy\n\nYou agree to provide accurate, current, and complete information during registration and update it when necessary.\n\n5. Prohibited Activities\n\nYou may not use the platform for unlawful, fraudulent, harmful, or misleading purposes.\n\n6. Payments and Fees\n\nNovaRide may collect service fees as agreed. Drivers are responsible for taxes and legal obligations in their jurisdiction.\n\n7. Data and Privacy\n\nYour personal data will be processed in accordance with applicable data protection regulations.\n\n8. Suspension and Termination\n\nNovaRide reserves the right to suspend or terminate accounts that violate these terms or applicable laws.\n\n9. Limitation of Liability\n\nNovaRide shall not be liable for indirect, incidental, or consequential damages arising from platform use.\n\n10. Modifications\n\nWe may update these terms from time to time. Continued use of the platform constitutes acceptance of any changes.';

  @override
  String get invalidName => 'Invalid name';

  @override
  String get invalidPassword => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get search => 'Search';

  @override
  String get verifyPhone => 'Verify Phone Number';

  @override
  String codeSentTo(Object phone) {
    return 'Code sent to $phone';
  }

  @override
  String get verify => 'Verify';

  @override
  String resendIn(Object seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get person => 'Person';

  @override
  String get office => 'Office';

  @override
  String get officeName => 'Office Name';

  @override
  String get officeLocation => 'Office Location';

  @override
  String get officeContact => 'Office Contact Information';

  @override
  String get idNumber => 'ID Number';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get car => 'Car';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get van => 'Van/microbus';

  @override
  String get bicycle => 'Bicycle';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get personalInfoSubtitle2 => 'Only your first name and car details are visible to passengers during the booking';

  @override
  String get personalInfoTitle2 => 'Personal information and car details';

  @override
  String get joinAsDriver => 'I want to join NovaRide as:';

  @override
  String get explain => 'Select \"office\" if you\'re using a limited office (Ltd) (if you\'re the sole owner or director) or a limited liability partnership (LLP).\n\nSelect \"Person\" if you operate individually, for example, as a sole trader or are self-employed.';

  @override
  String get licensePlate => 'License Plate Number';

  @override
  String get manufacturer => 'Manu facturer';

  @override
  String get brand => 'model';

  @override
  String get passengerCount => 'Passenger Count';

  @override
  String get vehicleColor => 'Vehicle Color';

  @override
  String get selectColor => 'Select Color';

  @override
  String get colorSelected => 'Color Selected';

  @override
  String get other => 'Other';

  @override
  String get enterPlate => 'Enter your license plate number';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get green => 'Green';

  @override
  String get blue => 'Blue';

  @override
  String get red => 'Red';

  @override
  String get yellow => 'Yellow';

  @override
  String get grey => 'Grey';

  @override
  String get orange => 'Orange';

  @override
  String get purple => 'Purple';

  @override
  String get brown => 'Brown';

  @override
  String get selectBrandHint => 'Select Brand';

  @override
  String get brandLabel => 'Brand';

  @override
  String get enterOtherBrand => 'Enter Other Brand';

  @override
  String get selectModelHint => 'Select Model';

  @override
  String get selectColorHint => 'Select Color';

  @override
  String get selectPassengerHint => 'Select Passenger Count';

  @override
  String get vehicleYear => 'Vehicle Year';

  @override
  String get selectYearHint => 'Select Vehicle Year';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get selectBirthDate => 'Select birth date';

  @override
  String get firstNameHint => 'Enter your first name';

  @override
  String get idHint => 'Enter your ID number';

  @override
  String get underAgeError => 'Not allowed - Age must be 18+';

  @override
  String get uploadRequiredDocuments => 'Upload required documents';

  @override
  String get driverId => 'Driver ID';

  @override
  String get drivingLicense => 'Driving License';

  @override
  String get vehicleRegistration => 'Vehicle Registration';

  @override
  String get insurance => 'Insurance';

  @override
  String get wheelchairAccessible => 'Wheelchair accessible';

  @override
  String get vehicleFrontPhoto => 'Vehicle Front Photo';

  @override
  String get vehicleInteriorPhoto => 'Vehicle Interior Photo';

  @override
  String get documentsTitle => 'Documents';

  @override
  String get documentsSubtitle => 'We\'re legally required to ask you for some documents to sign you up as a driver. Document scans and quality photos are accepted.';

  @override
  String get profilePicture => 'Profile Picture';

  @override
  String get profileDescription => 'Please provide a clear picture of yourself on a white background. It must show your full face with no sunglasses, bluetooth headsets or earphones. This picture will be visible to passengers.';

  @override
  String get driverIdFront => 'Driver ID - Front';

  @override
  String get driverIdBack => 'Driver ID - Back';

  @override
  String get idDescription => 'Please upload a clear photo of your ID (front and back).';

  @override
  String get licenseFront => 'Driving License - Front';

  @override
  String get licenseBack => 'Driving License - Back';

  @override
  String get licenseDescription => 'Please upload a clear photo of your driving license (front and back).';

  @override
  String get vehicleBackPhoto => 'Vehicle Back Photo';

  @override
  String get workLocationTitle => 'Work location and availability';

  @override
  String get city => 'City';

  @override
  String get workArea => 'Work area';

  @override
  String get startLocation => 'Set starting location';

  @override
  String get selectOnMap => 'Select on map';

  @override
  String get workingHours => 'Working hours';

  @override
  String get startTime => 'Start time';

  @override
  String get endTime => 'End time';

  @override
  String get registrationComplete => 'Registration Complete';

  @override
  String get accountUnderReview => 'Your account is under review.';

  @override
  String get finish => 'Finish';

  @override
  String get damascus => 'Damascus';

  @override
  String get rifDamascus => 'Rif Damascus';

  @override
  String get barzeh => 'Barzeh';

  @override
  String get mazzeh => 'Mazzeh';

  @override
  String get kafr_sousa => 'Kafr Sousa';

  @override
  String get abu_rummaneh => 'Abu Rummaneh';

  @override
  String get midane => 'Midane';

  @override
  String get rukn_al_din => 'Rukn Al Din';

  @override
  String get ash_al_warwar => 'Ash Al Warwar';

  @override
  String get qadam => 'Qadam';

  @override
  String get al_tal => 'Al Tal';

  @override
  String get manin => 'Manin';

  @override
  String get saydnaya => 'Saydnaya';

  @override
  String get maarraba => 'Maarraba';

  @override
  String get qudsaya => 'Qudsaya';

  @override
  String get jaramana => 'Jaramana';

  @override
  String get sahnaya => 'Sahnaya';

  @override
  String get daraya => 'Daraya';

  @override
  String get translate => 'Translate';

  @override
  String get detailedAddress => 'Detailed address';

  @override
  String get addressHint => 'Street name, building, landmark...';

  @override
  String get almostThere => 'Almost there!';

  @override
  String get reviewMessage => 'We\'re reviewing your application and will notify you within 3 days. For real-time updates and next steps, check the app.';

  @override
  String get openApp => 'Open the app';

  @override
  String get home => 'home';

  @override
  String get trips => 'trips';

  @override
  String get scheduledRidesTitle => 'Scheduled rides';

  @override
  String get scheduledRidesEmpty => 'No upcoming scheduled rides nearby';

  @override
  String get scheduledRidesEmptyHint => 'Scheduled rides in your area will appear here before pickup time';

  @override
  String get scheduledRideBadge => 'Scheduled';

  @override
  String scheduledRideStartsIn(String time) {
    return 'Starts in $time';
  }

  @override
  String get scheduledRideDriverHint => 'You will get an accept offer ~15 min before pickup — stay online';

  @override
  String incomingScheduledPickup(String time) {
    return 'Pickup at: $time';
  }

  @override
  String get earnings => 'earning';

  @override
  String get account => 'account';

  @override
  String get tripsToday => ' trips for today';

  @override
  String get earningsLabel => 'earning label';

  @override
  String get rating => 'rating';

  @override
  String get goOnline => 'Start work';

  @override
  String get goOffline => 'Stop work';

  @override
  String get newRideRequest => 'new Ride Reqest';

  @override
  String get pickup => 'pickup location ';

  @override
  String get dropoff => 'drop off';

  @override
  String get fare => 'fare';

  @override
  String get accountSettings => 'account setting ';

  @override
  String get support => 'Support & Help';

  @override
  String get reportIssue => 'Report an issue';

  @override
  String get complaintTypeTitle => 'Problem type';

  @override
  String get complaintDescTitle => 'Description';

  @override
  String get complaintDescHint => 'Describe your issue in detail...';

  @override
  String get complaintSubmit => 'Submit complaint';

  @override
  String get complaintSuccessTitle => 'Complaint submitted';

  @override
  String get complaintSuccessBody => 'We will respond within 24 hours';

  @override
  String get complaintOk => 'OK';

  @override
  String get complaintError => 'Could not submit your request';

  @override
  String get complaintTypePassenger => 'Issue with passenger';

  @override
  String get complaintTypeTechnical => 'Technical issue';

  @override
  String get complaintTypeBilling => 'Billing issue';

  @override
  String get complaintTypeSafety => 'Safety issue';

  @override
  String get whatsappUs => 'WhatsApp';

  @override
  String get whatsappUsDesc => 'Chat with us on WhatsApp';

  @override
  String get logout => 'log out ';

  @override
  String get driverAccount => 'driver account ';

  @override
  String get appVersion => 'app version ';

  @override
  String get reject => 'reject';

  @override
  String get accept => 'accept';

  @override
  String get rideAccepted => 'ride accepted ';

  @override
  String get vehicleInfo => 'Vehicle Information';

  @override
  String get carType => 'Car Type';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get color => 'Color';

  @override
  String get manufactureYear => 'Manufacture Year';

  @override
  String get vehicleStatus => 'Vehicle Status';

  @override
  String get editVehicle => 'Edit Information';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get all => 'All';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get noTrips => 'No trips';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get requiredField => 'This field is required';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get driverPerformance => 'Driver Performance';

  @override
  String get acceptanceRate => 'Acceptance Rate';

  @override
  String get cancellationRate => 'Cancellation Rate';

  @override
  String get verifiedDriver => 'Verified Driver';

  @override
  String get pending => 'Pending';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get exportStatement => 'Export Statement';

  @override
  String get earningsBreakdown => 'Breakdown';

  @override
  String get noData => 'No data available';

  @override
  String get week => 'Week';

  @override
  String get months => 'Months';

  @override
  String get jan => 'January';

  @override
  String get feb => 'February';

  @override
  String get mar => 'March';

  @override
  String get apr => 'April';

  @override
  String get may => 'May';

  @override
  String get jun => 'June';

  @override
  String get jul => 'July';

  @override
  String get aug => 'August';

  @override
  String get sep => 'September';

  @override
  String get oct => 'October';

  @override
  String get nov => 'November';

  @override
  String get dec => 'December';

  @override
  String get save => 'Save';

  @override
  String get modelLabel => 'Model';

  @override
  String get yearLabel => 'Year';

  @override
  String get plateLabel => 'Plate';

  @override
  String get colorLabel => 'Color';

  @override
  String get vehicleImageLabel => 'Vehicle';

  @override
  String get licenseImageLabel => 'License';

  @override
  String get verified => 'Verified';

  @override
  String get noVehicleFound => 'noVehicleFound';

  @override
  String get supportDesc => 'We’re here to help you anytime, anywhere.';

  @override
  String get chatWithUs => 'Chat with us';

  @override
  String get chatWithUsDesc => 'Live chat with our support team';

  @override
  String get callUs => 'Call us';

  @override
  String get callUsDesc => 'Talk directly with our support team';

  @override
  String get emailUs => 'Email us';

  @override
  String get emailUsDesc => 'Send us your questions via email';

  @override
  String get faq => 'FAQ';

  @override
  String get faqDesc => 'Frequently Asked Questions';

  @override
  String get supportFooter => 'Your safety and satisfaction are our top priority.';

  @override
  String get driverFaq => 'Driver FAQ';

  @override
  String get driverFaqTitle => 'Driver Frequently Asked Questions';

  @override
  String get driverFaqSubtitle => 'Find answers to common issues faced by drivers';

  @override
  String get driverFaqVehicleUpdateQ => 'How can I update my vehicle or upload a new vehicle image?';

  @override
  String get driverFaqVehicleUpdateA => 'Go to your vehicle profile and click on \'Edit Vehicle\'. You can upload a new vehicle image or change details.';

  @override
  String get driverFaqScheduleQ => 'How can I manage my schedule and available trips?';

  @override
  String get driverFaqScheduleA => 'Use the Schedule section in your driver app to set your working hours and available trip slots.';

  @override
  String get driverFaqPaymentQ => 'When and how will I receive my payments?';

  @override
  String get driverFaqPaymentA => 'Payments are processed weekly and transferred directly to your registered bank account.';

  @override
  String get driverFaqSafetyQ => 'What should I do if I face a safety issue with a passenger?';

  @override
  String get driverFaqSafetyA => 'Immediately contact driver support using the \'Support\' section in the app.';

  @override
  String get driverFaqSupportQ => 'How can I contact support if I have an issue?';

  @override
  String get driverFaqSupportA => 'Use Support & Help to call us, submit a complaint, or reach us on WhatsApp and email.';

  @override
  String get driverFaqTripCancelQ => 'What happens if a trip is canceled?';

  @override
  String get driverFaqTripCancelA => 'If a trip is canceled, you will be notified immediately. Earnings for completed trips remain unaffected.';

  @override
  String get location => 'Location of the office';

  @override
  String get officeN => 'Office Name';

  @override
  String get ageError => 'You must be at least 18 years old.';

  @override
  String get nameError => 'Name must be at least 3 letters.';

  @override
  String get idError => 'ID number must be at least 6 digits.';

  @override
  String get lastNameHint => 'Enter your last name';

  @override
  String get enterEngineCapacity => 'Enter engine capacity';

  @override
  String get engineCapacity => 'Engine Capacity (cc)';

  @override
  String get enterMotorPlate => 'Enter motorcycle plate number';

  @override
  String get enterOtherModel => 'Type other model';

  @override
  String get motorcycleBrand => 'Motorcycle Brand';

  @override
  String get motorcycleEngineSize => 'Motorcycle Engine Size (cc)';

  @override
  String get motorcycleModel => 'Motorcycle Model';

  @override
  String get motorcyclePlateNumber => 'Motorcycle Plate Number';

  @override
  String get specialServices => 'Special Services';

  @override
  String get waterTanker => 'Water Tanker';

  @override
  String get movingTruck => 'Moving Truck';

  @override
  String get carWash => 'Car Wash';

  @override
  String get tankerCapacity => 'Tanker Capacity (liters)';

  @override
  String get enterTankerCapacity => 'Enter tanker capacity';

  @override
  String get cargoVolume => 'Cargo Volume (m³)';

  @override
  String get enterCargoVolume => 'Enter cargo volume';

  @override
  String get carWashHasPressureWasher => 'Has pressure washer?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get mySubscriptions => 'My Subscriptions';

  @override
  String get mySubscriptionTitle => 'My Subscription';

  @override
  String get noSubscriptionFound => 'No subscription found';

  @override
  String get noSubscriptionPlanRequired => 'No subscription plan. Please choose a plan in the app.';

  @override
  String get subscriptionPaymentRequired => 'Subscription payment required';

  @override
  String get subscriptionSuspended => 'Subscription suspended. Please settle payment to go online.';

  @override
  String get monthlySubscriptionPaymentRequired => 'Monthly subscription payment required before going online.';

  @override
  String get subscriptionPaymentOverdue => 'Payment overdue. Please submit payment in Subscriptions.';

  @override
  String get saved => 'Saved';

  @override
  String get preferencesLoadFailed => 'Could not load preferences';

  @override
  String get onlineStatus => 'Online';

  @override
  String get offlineStatus => 'Offline';

  @override
  String todayEarningsBar(String amount) {
    return 'Today: $amount';
  }

  @override
  String rideEtaToPickup(int minutes) {
    return 'Reach pickup in $minutes min';
  }

  @override
  String rideEtaToDropoff(int minutes) {
    return 'Arrive at destination in $minutes min';
  }

  @override
  String get rideTripDetails => 'Trip details';

  @override
  String get rideTripDetailsHint => 'Meet the passenger at the pickup point';

  @override
  String get safetyRecordAudio => 'Record audio for added safety';

  @override
  String get safetyRecordStart => 'Start';

  @override
  String get safetyRecording => 'Recording...';

  @override
  String incomingRideEtaHeadline(int minutes) {
    return 'Arrive in $minutes min';
  }

  @override
  String get minutesShort => 'min';

  @override
  String rideNumber(int id) {
    return 'Ride #$id';
  }

  @override
  String get sendMessage => 'Send message';

  @override
  String get call => 'Call';

  @override
  String get choosePlan => 'Choose Plan';

  @override
  String get changePlan => 'Change Plan';

  @override
  String get commissionPlan => 'Commission Plan';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get paymentOverdue => '⚠️ Payment Overdue';

  @override
  String get active => '✅ Active';

  @override
  String get amountDue => 'Amount Due';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get totalOwed => 'Total Owed';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get nextDue => 'Next Due';

  @override
  String get howToPay => 'How to Pay';

  @override
  String get cash => 'Cash';

  @override
  String get payWeeklyInPerson => 'Pay weekly in person to admin';

  @override
  String get shamCash => 'Sham Cash';

  @override
  String get mobileBalance => 'Mobile Balance';

  @override
  String get transferToPhone => 'Transfer to: 0900000000';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get bankName => 'Bank: Syria & Overseas Bank';

  @override
  String get iban => 'IBAN';

  @override
  String get paymentHistory => 'Payment History';

  @override
  String get myMethod => 'My Method';

  @override
  String get currencyShort => 'SYP';

  @override
  String get cashKey => 'cash';

  @override
  String get shamCashKey => 'sham_cash';

  @override
  String get balanceKey => 'balance';

  @override
  String get bankKey => 'bank';

  @override
  String get commission => 'Commission';

  @override
  String get payPerRide => 'Pay per ride';

  @override
  String get fixedFee => 'Fixed fee';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get novaRidePartnership => 'NovaRide Partnership';

  @override
  String get chooseHowYouWork => 'Choose how you work with us';

  @override
  String get paymentMethodTitle => 'Payment Method';

  @override
  String get commissionRate => 'Commission Rate';

  @override
  String get commissionExplanation => 'Each completed ride: 10% is taken by the app and accumulated weekly to be paid.';

  @override
  String get commissionShort => 'commission';

  @override
  String get amount => 'Amount';

  @override
  String get payment => 'Payment';

  @override
  String get due => 'Due';

  @override
  String get perRide => 'per ride';

  @override
  String get monthlyFeeTitle => 'Monthly Fee';

  @override
  String get fixedAmountPerMonth => 'Fixed amount per month';

  @override
  String get monthlyExplanation => 'Keep 100% of ride earnings. Pay fixed monthly fee.';

  @override
  String get startDriving => 'Start Driving 🚀';

  @override
  String get updatePlan => 'Update Plan';

  @override
  String get subscriptionUpdated => 'Subscription updated!';

  @override
  String get subscriptionFailed => 'Failed to update subscription';

  @override
  String get changePlanAnytime => 'You can change your plan anytime from settings';

  @override
  String get month => 'month';

  @override
  String get ofEachRideFare => 'of each ride fare';

  @override
  String get transferTo => 'Transfer to';

  @override
  String get ref => 'Ref';

  @override
  String get plan => 'Plan';

  @override
  String get rideHeadToPickup => 'Head to pickup point';

  @override
  String get rideWaitingPassenger => 'Waiting for passenger';

  @override
  String get ridePassengerOnBoard => 'Passenger on board';

  @override
  String get rideInProgress => 'Heading to destination';

  @override
  String get rideBtnArrived => 'I have arrived';

  @override
  String get rideBtnPassengerOnBoard => 'Passenger is on board';

  @override
  String get rideBtnStartTrip => 'Start trip';

  @override
  String get rideBtnCompleteTrip => 'Complete trip';

  @override
  String get rideMarkerPickup => 'Pickup';

  @override
  String get rideMarkerDropoff => 'Destination';

  @override
  String get rideMarkerYou => 'You';

  @override
  String get ridePickupLabel => 'Pickup';

  @override
  String get rideDropoffLabel => 'Destination';

  @override
  String get rideCompletedTitle => 'Trip completed!';

  @override
  String get rideDone => 'Done';

  @override
  String get rideCancelTitle => 'Cancel ride?';

  @override
  String get rideCancelRide => 'Cancel ride';

  @override
  String get ridePassengerLabel => 'Passenger';

  @override
  String get ridePaymentMethod => 'Payment method';

  @override
  String get rideCancelledByPassenger => 'Passenger cancelled the ride';

  @override
  String get rideNavigatingToDropoff => 'Navigating to destination';

  @override
  String get rideNoPassengerPhone => 'Passenger phone number is not available';

  @override
  String get rideCallFailed => 'Could not start a phone call';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get rideMessageFailed => 'Could not open messaging app';

  @override
  String get rideOpenInMaps => 'Open in Google Maps';

  @override
  String get km => 'km';

  @override
  String get incomingRideTitle => 'New ride request!';

  @override
  String incomingRideSec(int seconds) {
    return '$seconds sec';
  }

  @override
  String get incomingRideFare => 'Fare';

  @override
  String get incomingRideDistance => 'Distance';

  @override
  String get incomingRideEta => 'ETA';

  @override
  String get incomingRideDecline => 'Decline';

  @override
  String get incomingRideAccept => 'Accept ride';

  @override
  String get comingSoon => 'Coming soon!';

  @override
  String get rateYourPassenger => 'Rate your passenger';

  @override
  String get howWasPassenger => 'How was this passenger?';

  @override
  String get ratingSubmitted => 'Thank you for your feedback!';

  @override
  String get ratingFailed => 'Could not submit rating';

  @override
  String get chatEmpty => 'No messages yet. Say hello!';

  @override
  String get chatTypeMessage => 'Type a message…';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletAvailable => 'Available balance';

  @override
  String get walletWithdrawAmount => 'Withdrawal amount';

  @override
  String get walletRequestPayout => 'Request payout';

  @override
  String get walletPayoutHistory => 'Payout history';

  @override
  String get walletNoPayouts => 'No payouts yet';

  @override
  String get walletInvalidAmount => 'Enter a valid amount';

  @override
  String get walletInsufficient => 'Amount exceeds your balance';

  @override
  String get walletPayoutRequested => 'Payout requested';

  @override
  String get workZonesTitle => 'Work zones & schedule';

  @override
  String get workZonesOnShift => 'You are within your work hours';

  @override
  String get workZonesOffShift => 'Outside work hours';

  @override
  String get workZonesScheduleHint => 'You can only go online during your scheduled hours';

  @override
  String get workZoneAdd => 'Add work zone';

  @override
  String get workZonePrimary => 'Primary';

  @override
  String get workZonesEmpty => 'No work zones yet. Add one to set your schedule.';

  @override
  String get workZonesOffShiftOnline => 'Outside scheduled hours. Update your schedule in Work zones.';

  @override
  String get language => 'Language';

  @override
  String get gpsPermissionRequired => 'Location permission is required to go online';

  @override
  String get locationRequiredForOnline => 'Turn on location services to go online';

  @override
  String get outsideWorkZoneOnline => 'You must be in your work area to go online';

  @override
  String get voiceNavOn => 'Voice navigation on';

  @override
  String get voiceNavOff => 'Voice navigation off';

  @override
  String get voiceNavToggle => 'Voice navigation';

  @override
  String get rideTakenByAnother => 'This ride was taken by another driver';

  @override
  String get sosButton => 'Emergency SOS';

  @override
  String get sosConfirm => 'Notify support and share your location?';

  @override
  String get sosActivated => 'SOS sent — support notified';

  @override
  String get driverIncentivesTitle => 'Bonuses & incentives';

  @override
  String get driverIncentivesEmpty => 'No rewards';

  @override
  String get driverIncentivesBonus => 'Zone bonus';

  @override
  String get driverIncentivesActiveCount => 'active bonuses';

  @override
  String get multiStopLabel => 'Stop';

  @override
  String get multiStopNext => 'Next stop';

  @override
  String get multiStopReached => 'Stop reached — navigating to next';

  @override
  String get accessibilityRide => 'Accessibility ride — extra care at pickup';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get remove => 'Remove';

  @override
  String get readyToUpload => 'Ready to upload';

  @override
  String get uploadFailedTryAgain => 'Upload failed. Try again.';

  @override
  String get documentsSelected => 'Documents selected';

  @override
  String get uploading => 'Uploading...';

  @override
  String get resubmitDocumentsTitle => 'Re-upload documents';

  @override
  String get resubmitDocumentsSubtitle => 'Please re-upload only the rejected documents. Your application stays pending.';

  @override
  String get documentsSentReview => 'Documents sent. They will be reviewed shortly.';

  @override
  String get awaitingApproval => 'Awaiting Approval';

  @override
  String get documentsNeedResubmit => 'Documents need re-upload';

  @override
  String get resubmitPendingMessage => 'Some documents were rejected. Please re-upload them only.\nYour application stays pending.';

  @override
  String get pendingReviewMessage => 'Your account is under review.\nYou\'ll be notified once approved and the app is activated.';

  @override
  String get reuploadDocuments => 'Re-upload documents';

  @override
  String get autoChecking => 'Auto-checking every 30 seconds';

  @override
  String get checkStatusNow => 'Check Status Now';

  @override
  String get checking => 'Checking...';

  @override
  String get signOut => 'Sign Out';

  @override
  String get applicationRejected => 'Application Rejected';

  @override
  String get rejectedLogoutMessage => 'Sorry, your application was rejected.\nYou will be logged out automatically.';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get resubmitBadge => 'Resubmit';

  @override
  String get notSet => 'Not set';

  @override
  String get driverLabel => 'Driver';

  @override
  String get statusOnline => 'ONLINE';

  @override
  String get statusOffline => 'OFFLINE';

  @override
  String get preferences => 'Preferences';

  @override
  String get referrals => 'Referrals';

  @override
  String get preferencesTitle => 'Driver preferences';

  @override
  String get destinationFilterTitle => 'Destination filter';

  @override
  String get destinationFilterDesc => 'Only accept rides heading toward your destination';

  @override
  String get enableFilter => 'Enable filter';

  @override
  String get destinationLabel => 'Destination';

  @override
  String acceptRadiusKm(String km) {
    return 'Accept radius (km): $km';
  }

  @override
  String get saveFilter => 'Save filter';

  @override
  String get autoAcceptTitle => 'Auto-accept';

  @override
  String get autoAcceptDesc => 'Automatically accept rides matching your criteria';

  @override
  String get enableAutoAccept => 'Enable auto-accept';

  @override
  String maxPickupKmLabel(String km) {
    return 'Max pickup distance (km): $km';
  }

  @override
  String minFareLabel(String amount) {
    return 'Min fare: $amount';
  }

  @override
  String get saveAutoAccept => 'Save auto-accept';

  @override
  String get submitPaymentTitle => 'Submit payment';

  @override
  String get paymentNote => 'Note';

  @override
  String get paymentSubmittedReview => 'Payment submitted — admin will review';

  @override
  String get suspendedStatus => 'Suspended';

  @override
  String get pendingReview => 'Pending review';

  @override
  String get cannotGoOnlineUntilPaid => 'You cannot go online until payment is confirmed.';

  @override
  String get referralsTitle => 'Referrals';

  @override
  String get yourReferralCode => 'Your referral code';

  @override
  String get copied => 'Copied';

  @override
  String referralsCount(int count) {
    return 'Referrals: $count';
  }

  @override
  String earnedAmount(String amount) {
    return 'Earned: $amount';
  }

  @override
  String get tripStatusScheduled => 'Scheduled';

  @override
  String get tripStatusSearching => 'Searching';

  @override
  String get tripStatusAssigned => 'Assigned';

  @override
  String get tripStatusArrived => 'Arrived';

  @override
  String get tripStatusOnboard => 'On board';

  @override
  String get tripStatusStarted => 'In progress';

  @override
  String get tripStatusCompleted => 'Completed';

  @override
  String get tripStatusCancelled => 'Cancelled';

  @override
  String incomingReachPickup(int minutes) {
    return 'Reach pickup in $minutes min';
  }

  @override
  String get incomingOfferSubtitle => 'New ride in your area';

  @override
  String get activeRideMeetPassenger => 'Meet the passenger at the pickup point';

  @override
  String activeRideMeetPassengerEta(int minutes) {
    return 'Pick up passenger in $minutes min';
  }

  @override
  String activeRideArriveDropoffEta(int minutes) {
    return 'Arrive at destination in $minutes min';
  }

  @override
  String passengerTripsCount(int count) {
    return '$count trips';
  }

  @override
  String get ridePickupPoint => 'Pickup point';

  @override
  String get activeRideMoreOptions => 'More';

  @override
  String distanceKmUnit(String km) {
    return '$km km';
  }

  @override
  String get invalidOtpCode => 'Invalid code';

  @override
  String get actionFailed => 'Something went wrong';
}
