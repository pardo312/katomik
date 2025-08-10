// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Katomik - Habit Tracker';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpToGetStarted => 'Sign up to get started';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get or => 'Or';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get creatingYourAccount => 'Creating your account...';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get retry => 'Retry';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String passwordMustBeAtLeastChars(int minLength) {
    return 'Password must be at least $minLength characters';
  }

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterUsername => 'Please enter a username';

  @override
  String usernameMustBeAtLeastChars(int minLength) {
    return 'Username must be at least $minLength characters';
  }

  @override
  String usernameMustBeLessThanChars(int maxLength) {
    return 'Username must be less than $maxLength characters';
  }

  @override
  String get usernameCanOnlyContain =>
      'Username can only contain letters, numbers, and underscores';

  @override
  String get invalidCredentials =>
      'Invalid email/username or password. Please try again.';

  @override
  String get noAccountFound =>
      'No account found with this email/username. Please register first.';

  @override
  String get unableToConnect =>
      'Unable to connect to server. Please check your internet connection.';

  @override
  String get checkLoginDetails =>
      'Please check your login details and try again.';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please use a different email or login.';

  @override
  String get usernameAlreadyTaken =>
      'This username is already taken. Please choose a different username.';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters long.';

  @override
  String get connectionError =>
      'Connection error. Please check your internet connection.';

  @override
  String get requestTimeout => 'Request timed out. Please try again.';

  @override
  String get serverError => 'Server error. Please try again later.';

  @override
  String get discoverCommunities => 'Discover Communities';

  @override
  String get loadingCommunities => 'Loading communities...';

  @override
  String get errorLoadingCommunities => 'Error loading communities';

  @override
  String get noCommunitiesFound => 'No communities found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your filters';

  @override
  String get beFirstToCreateOne => 'Be the first to create one!';

  @override
  String get searchCommunities => 'Search communities...';

  @override
  String get leaveCommunity => 'Leave Community?';

  @override
  String get logout => 'Logout';

  @override
  String get areYouSureLogout => 'Are you sure you want to logout?';

  @override
  String get profile => 'Profile';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get verifyEmail => 'Verify Email';

  @override
  String get yourEmailNotVerified => 'Your email is not verified';

  @override
  String get changeProfilePicture => 'Change Profile Picture';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get useGoogleProfilePicture => 'Use Google Profile Picture';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get newHabit => 'New Habit';

  @override
  String get habitName => 'Habit Name';

  @override
  String get habitNamePlaceholder => 'e.g., Drink Water, Exercise, Read';

  @override
  String get missingInformation => 'Missing Information';

  @override
  String get provideHabitNameAndPhrase =>
      'Please provide a habit name and at least one phrase.';

  @override
  String get error => 'Error';

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get startBuildingFirstHabit => 'Start building your first habit!';

  @override
  String get joinCommunity => 'Join Community';

  @override
  String get governance => 'Governance';

  @override
  String get createProposal => 'Create Proposal';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get viewCommunity => 'View Community';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get loadingCommunity => 'Loading community...';

  @override
  String get errorLoadingCommunity => 'Error loading community';

  @override
  String get communityNotFound => 'Community not found';

  @override
  String get somethingWentWrong => 'Something went wrong!';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get photoLibrary => 'Photo Library';

  @override
  String get modifyHabit => 'Modify Habit';

  @override
  String get changeRules => 'Change Rules';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String get unknown => 'Unknown';

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get expired => 'Expired';

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String hoursRemaining(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String minutesRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get aboutThisCommunity => 'About this Community';

  @override
  String get enterMotivatingPhrase => 'Enter a motivating phrase';

  @override
  String get describeHabitCommunityGoals =>
      'Describe your habit and community goals...';

  @override
  String get enterClearDescriptiveTitle => 'Enter a clear, descriptive title';

  @override
  String get explainProposalDetail => 'Explain your proposal in detail';

  @override
  String get about => 'About';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get stats => 'Stats';

  @override
  String get proposals => 'Proposals';

  @override
  String get votingMembers => 'Voting Members';

  @override
  String get whyImDoingThis => 'Why I\'m doing this';

  @override
  String get images => 'Images';

  @override
  String get phrases => 'Phrases';

  @override
  String get communityInfo => 'Community Info';

  @override
  String get chooseColor => 'Choose Color';

  @override
  String get chooseIcon => 'Choose Icon';

  @override
  String get makeHabitPublic => 'Make Habit Public';

  @override
  String get pendingProposals => 'Pending Proposals';

  @override
  String get noProposals => 'No proposals';

  @override
  String get weeklyStreak => 'Weekly Streak';

  @override
  String get totalStreak => 'Total Streak';

  @override
  String get members => 'Members';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get home => 'Home';

  @override
  String get communities => 'Communities';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get submit => 'Submit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get close => 'Close';

  @override
  String get open => 'Open';

  @override
  String get more => 'More';

  @override
  String get less => 'Less';

  @override
  String get showMore => 'Show more';

  @override
  String get showLess => 'Show less';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get select => 'Select';

  @override
  String get selected => 'Selected';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get clear => 'Clear';

  @override
  String get done => 'Done';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get aboutApp => 'About';

  @override
  String get version => 'Version';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get paste => 'Paste';

  @override
  String get cut => 'Cut';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';
}
