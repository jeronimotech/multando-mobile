// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Multando';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone (optional)';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithGithub => 'Continue with GitHub';

  @override
  String get agreeTerms => 'I agree to the Terms of Service and Privacy Policy';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get onboardingTitle1 => 'Report Infractions';

  @override
  String get onboardingDesc1 =>
      'Capture traffic infractions with secure evidence collection, including GPS, timestamp, and motion verification.';

  @override
  String get onboardingTitle2 => 'Community Verification';

  @override
  String get onboardingDesc2 =>
      'Help verify reports from other citizens. Swipe to approve or reject - earn rewards for every verification.';

  @override
  String get onboardingTitle3 => 'Earn Rewards';

  @override
  String get onboardingDesc3 =>
      'Earn MULTA points for every report and verification. Stake your tokens and climb the leaderboard.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get home => 'Home';

  @override
  String get reports => 'Reports';

  @override
  String get verify => 'Verify';

  @override
  String get wallet => 'Wallet';

  @override
  String get profile => 'Profile';

  @override
  String get reportViolation => 'Report Infraction';

  @override
  String get newReport => 'New Report';

  @override
  String get myReports => 'My Reports';

  @override
  String get allReports => 'All Reports';

  @override
  String get listView => 'List';

  @override
  String get mapView => 'Map';

  @override
  String get noReports => 'No reports yet';

  @override
  String get noReportsDesc => 'Start reporting infractions to earn rewards!';

  @override
  String get captureEvidence => 'Capture Evidence';

  @override
  String get selectInfraction => 'Select Infraction';

  @override
  String get vehicleDetails => 'Vehicle Details';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get vehicleType => 'Vehicle Type';

  @override
  String get location => 'Location';

  @override
  String get description => 'Description (optional)';

  @override
  String get confirmDetails => 'Confirm Details';

  @override
  String get reviewSubmit => 'Review & Submit';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get submitting => 'Submitting...';

  @override
  String get reportSubmitted => 'Report Submitted!';

  @override
  String get reportSubmittedDesc =>
      'Your report has been submitted for community verification.';

  @override
  String step(int number, int total) {
    return 'Step $number of $total';
  }

  @override
  String get capture => 'Capture';

  @override
  String get retake => 'Retake';

  @override
  String get confirm => 'Confirm';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get evidenceCaptured => 'Evidence captured successfully';

  @override
  String get verifyReports => 'Verify Reports';

  @override
  String get swipeToVerify => 'Swipe right to verify, left to reject';

  @override
  String get verified => 'Verified';

  @override
  String get rejected => 'Rejected';

  @override
  String get noMoreReports => 'No more reports to verify';

  @override
  String get noMoreReportsDesc => 'Check back later for new reports.';

  @override
  String get rejectReason => 'Reason for rejection';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String get available => 'Available';

  @override
  String get staked => 'Staked';

  @override
  String get pendingRewards => 'Pending Rewards';

  @override
  String get total => 'Total';

  @override
  String get transactions => 'Transactions';

  @override
  String get noTransactions => 'No transactions yet';

  @override
  String get stake => 'Stake';

  @override
  String get unstake => 'Unstake';

  @override
  String get claimRewards => 'Claim Rewards';

  @override
  String get stakingInfo => 'Staking Info';

  @override
  String get apy => 'APY';

  @override
  String get locked => 'Locked';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get rewardsPreview => 'Rewards Preview';

  @override
  String get rewardsPreviewDesc =>
      'MULTA points are tracked in our database. Blockchain integration coming soon!';

  @override
  String get amount => 'Amount';

  @override
  String get enterAmount => 'Enter amount';

  @override
  String get achievements => 'Achievements';

  @override
  String get badges => 'Badges';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get levels => 'Levels';

  @override
  String get rank => 'Rank';

  @override
  String get points => 'Points';

  @override
  String get noBadges => 'No badges yet';

  @override
  String get noBadgesDesc => 'Start reporting to earn your first badge!';

  @override
  String level(int number) {
    return 'Level $number';
  }

  @override
  String get profileSettings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get developerMode => 'Developer Mode';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get totalReports => 'Total Reports';

  @override
  String get verifiedReports => 'Verified Reports';

  @override
  String get reputationScore => 'Reputation';

  @override
  String get memberSince => 'Member since';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusAppealed => 'Appealed';

  @override
  String get statusResolved => 'Resolved';

  @override
  String get parking => 'Parking';

  @override
  String get speeding => 'Speeding';

  @override
  String get redLight => 'Red Light';

  @override
  String get illegalTurn => 'Illegal Turn';

  @override
  String get wrongWay => 'Wrong Way';

  @override
  String get noSeatbelt => 'No Seatbelt';

  @override
  String get phoneUse => 'Phone Use';

  @override
  String get recklessDriving => 'Reckless Driving';

  @override
  String get dui => 'DUI';

  @override
  String get other => 'Other';

  @override
  String get car => 'Car';

  @override
  String get motorcycle => 'Motorcycle';

  @override
  String get truck => 'Truck';

  @override
  String get bus => 'Bus';

  @override
  String get van => 'Van';

  @override
  String get bicycle => 'Bicycle';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Please check your network.';

  @override
  String get errorAuth => 'Session expired. Please log in again.';

  @override
  String get errorValidation => 'Please check your input and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get reward => 'Reward';

  @override
  String get stakeAction => 'Stake';

  @override
  String get unstakeAction => 'Unstake';

  @override
  String get transferIn => 'Transfer In';

  @override
  String get transferOut => 'Transfer Out';

  @override
  String get claim => 'Claim';

  @override
  String get penalty => 'Penalty';

  @override
  String get severityLow => 'Low';

  @override
  String get severityMedium => 'Medium';

  @override
  String get severityHigh => 'High';

  @override
  String get severityCritical => 'Critical';

  @override
  String get sandbox => 'Sandbox Mode';

  @override
  String get sandboxDesc => 'Connect to the sandbox API for testing';
}
