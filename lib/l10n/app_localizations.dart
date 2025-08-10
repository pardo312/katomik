import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Katomik - Habit Tracker'**
  String get appTitle;

  /// Login button and screen title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button and screen title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Welcome message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Subtitle on register screen
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpToGetStarted;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Divider text between login options
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// Google sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Loading message during sign in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Loading message during registration
  ///
  /// In en, this message translates to:
  /// **'Creating your account...'**
  String get creatingYourAccount;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// Password length validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {minLength} characters'**
  String passwordMustBeAtLeastChars(int minLength);

  /// Confirm password validation message
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// Password mismatch validation message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Username validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// Username minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Username must be at least {minLength} characters'**
  String usernameMustBeAtLeastChars(int minLength);

  /// Username maximum length validation
  ///
  /// In en, this message translates to:
  /// **'Username must be less than {maxLength} characters'**
  String usernameMustBeLessThanChars(int maxLength);

  /// Username format validation message
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get usernameCanOnlyContain;

  /// Invalid login credentials error
  ///
  /// In en, this message translates to:
  /// **'Invalid email/username or password. Please try again.'**
  String get invalidCredentials;

  /// Account not found error
  ///
  /// In en, this message translates to:
  /// **'No account found with this email/username. Please register first.'**
  String get noAccountFound;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server. Please check your internet connection.'**
  String get unableToConnect;

  /// Generic login error message
  ///
  /// In en, this message translates to:
  /// **'Please check your login details and try again.'**
  String get checkLoginDetails;

  /// Email already exists error
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please use a different email or login.'**
  String get emailAlreadyRegistered;

  /// Username already exists error
  ///
  /// In en, this message translates to:
  /// **'This username is already taken. Please choose a different username.'**
  String get usernameAlreadyTaken;

  /// Password too short error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters long.'**
  String get passwordTooShort;

  /// Connection error message
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please check your internet connection.'**
  String get connectionError;

  /// Request timeout error
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get requestTimeout;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// Discover communities screen title
  ///
  /// In en, this message translates to:
  /// **'Discover Communities'**
  String get discoverCommunities;

  /// Loading communities message
  ///
  /// In en, this message translates to:
  /// **'Loading communities...'**
  String get loadingCommunities;

  /// Error loading communities message
  ///
  /// In en, this message translates to:
  /// **'Error loading communities'**
  String get errorLoadingCommunities;

  /// No communities found message
  ///
  /// In en, this message translates to:
  /// **'No communities found'**
  String get noCommunitiesFound;

  /// Empty state suggestion
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// Empty state call to action
  ///
  /// In en, this message translates to:
  /// **'Be the first to create one!'**
  String get beFirstToCreateOne;

  /// Search communities placeholder
  ///
  /// In en, this message translates to:
  /// **'Search communities...'**
  String get searchCommunities;

  /// Leave community dialog title
  ///
  /// In en, this message translates to:
  /// **'Leave Community?'**
  String get leaveCommunity;

  /// Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureLogout;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Theme settings option
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// Verify email option
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmail;

  /// Email not verified message
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified'**
  String get yourEmailNotVerified;

  /// Change profile picture option
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Use Google profile picture option
  ///
  /// In en, this message translates to:
  /// **'Use Google Profile Picture'**
  String get useGoogleProfilePicture;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Edit habit screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// New habit screen title
  ///
  /// In en, this message translates to:
  /// **'New Habit'**
  String get newHabit;

  /// Habit name field label
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitName;

  /// Habit name placeholder
  ///
  /// In en, this message translates to:
  /// **'e.g., Drink Water, Exercise, Read'**
  String get habitNamePlaceholder;

  /// Missing information dialog title
  ///
  /// In en, this message translates to:
  /// **'Missing Information'**
  String get missingInformation;

  /// Missing habit information message
  ///
  /// In en, this message translates to:
  /// **'Please provide a habit name and at least one phrase.'**
  String get provideHabitNameAndPhrase;

  /// Error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No habits empty state title
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabitsYet;

  /// No habits empty state message
  ///
  /// In en, this message translates to:
  /// **'Start building your first habit!'**
  String get startBuildingFirstHabit;

  /// Join community button text
  ///
  /// In en, this message translates to:
  /// **'Join Community'**
  String get joinCommunity;

  /// Governance section title
  ///
  /// In en, this message translates to:
  /// **'Governance'**
  String get governance;

  /// Create proposal button text
  ///
  /// In en, this message translates to:
  /// **'Create Proposal'**
  String get createProposal;

  /// Approve button text
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// Reject button text
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// View community button text
  ///
  /// In en, this message translates to:
  /// **'View Community'**
  String get viewCommunity;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// Category selection placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// Loading community message
  ///
  /// In en, this message translates to:
  /// **'Loading community...'**
  String get loadingCommunity;

  /// Error loading community message
  ///
  /// In en, this message translates to:
  /// **'Error loading community'**
  String get errorLoadingCommunity;

  /// Community not found message
  ///
  /// In en, this message translates to:
  /// **'Community not found'**
  String get communityNotFound;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get somethingWentWrong;

  /// Image source selection title
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Photo library option
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// Modify habit proposal type
  ///
  /// In en, this message translates to:
  /// **'Modify Habit'**
  String get modifyHabit;

  /// Change rules proposal type
  ///
  /// In en, this message translates to:
  /// **'Change Rules'**
  String get changeRules;

  /// Remove member proposal type
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// Delete habit proposal type
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// Unknown status or type
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Days ago time format
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day ago} other{{days} days ago}}'**
  String daysAgo(int days);

  /// Hours ago time format
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour ago} other{{hours} hours ago}}'**
  String hoursAgo(int hours);

  /// Minutes ago time format
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute ago} other{{minutes} minutes ago}}'**
  String minutesAgo(int minutes);

  /// Expired status
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// Days remaining format
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String daysRemaining(int days);

  /// Hours remaining format
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour} other{{hours} hours}}'**
  String hoursRemaining(int hours);

  /// Minutes remaining format
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String minutesRemaining(int minutes);

  /// About community section title
  ///
  /// In en, this message translates to:
  /// **'About this Community'**
  String get aboutThisCommunity;

  /// Motivating phrase placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter a motivating phrase'**
  String get enterMotivatingPhrase;

  /// Habit description placeholder
  ///
  /// In en, this message translates to:
  /// **'Describe your habit and community goals...'**
  String get describeHabitCommunityGoals;

  /// Proposal title placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter a clear, descriptive title'**
  String get enterClearDescriptiveTitle;

  /// Proposal description placeholder
  ///
  /// In en, this message translates to:
  /// **'Explain your proposal in detail'**
  String get explainProposalDetail;

  /// About tab
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Leaderboard tab
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Stats tab
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// Proposals tab
  ///
  /// In en, this message translates to:
  /// **'Proposals'**
  String get proposals;

  /// Voting members tab
  ///
  /// In en, this message translates to:
  /// **'Voting Members'**
  String get votingMembers;

  /// Motivation section title
  ///
  /// In en, this message translates to:
  /// **'Why I\'m doing this'**
  String get whyImDoingThis;

  /// Images section title
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// Phrases section title
  ///
  /// In en, this message translates to:
  /// **'Phrases'**
  String get phrases;

  /// Community info section title
  ///
  /// In en, this message translates to:
  /// **'Community Info'**
  String get communityInfo;

  /// Color picker title
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get chooseColor;

  /// Icon picker title
  ///
  /// In en, this message translates to:
  /// **'Choose Icon'**
  String get chooseIcon;

  /// Make habit public option
  ///
  /// In en, this message translates to:
  /// **'Make Habit Public'**
  String get makeHabitPublic;

  /// Pending proposals section title
  ///
  /// In en, this message translates to:
  /// **'Pending Proposals'**
  String get pendingProposals;

  /// No proposals message
  ///
  /// In en, this message translates to:
  /// **'No proposals'**
  String get noProposals;

  /// Weekly streak label
  ///
  /// In en, this message translates to:
  /// **'Weekly Streak'**
  String get weeklyStreak;

  /// Total streak label
  ///
  /// In en, this message translates to:
  /// **'Total Streak'**
  String get totalStreak;

  /// Members label
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive status
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Communities navigation item
  ///
  /// In en, this message translates to:
  /// **'Communities'**
  String get communities;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Yes option
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No option
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort button text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Open button text
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// More button text
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Less button text
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// Show more button text
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// Show less button text
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// Week label
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Month label
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Year label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// All option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// None option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Selected label
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Settings navigation item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Help option
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// About app option
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Copied confirmation
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// Paste button text
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// Cut button text
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// Undo button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Redo button text
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// January month name
  ///
  /// In en, this message translates to:
  /// **'JANUARY'**
  String get january;

  /// February month name
  ///
  /// In en, this message translates to:
  /// **'FEBRUARY'**
  String get february;

  /// March month name
  ///
  /// In en, this message translates to:
  /// **'MARCH'**
  String get march;

  /// April month name
  ///
  /// In en, this message translates to:
  /// **'APRIL'**
  String get april;

  /// May month name
  ///
  /// In en, this message translates to:
  /// **'MAY'**
  String get may;

  /// June month name
  ///
  /// In en, this message translates to:
  /// **'JUNE'**
  String get june;

  /// July month name
  ///
  /// In en, this message translates to:
  /// **'JULY'**
  String get july;

  /// August month name
  ///
  /// In en, this message translates to:
  /// **'AUGUST'**
  String get august;

  /// September month name
  ///
  /// In en, this message translates to:
  /// **'SEPTEMBER'**
  String get september;

  /// October month name
  ///
  /// In en, this message translates to:
  /// **'OCTOBER'**
  String get october;

  /// November month name
  ///
  /// In en, this message translates to:
  /// **'NOVEMBER'**
  String get november;

  /// December month name
  ///
  /// In en, this message translates to:
  /// **'DECEMBER'**
  String get december;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get sundayShort;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get mondayShort;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get tuesdayShort;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get wednesdayShort;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get thursdayShort;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fridayShort;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get saturdayShort;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// Invalid argument error
  ///
  /// In en, this message translates to:
  /// **'Invalid argument'**
  String get invalidArgument;

  /// Failed to make habit public error
  ///
  /// In en, this message translates to:
  /// **'Failed to make habit public - no data returned'**
  String get failedToMakePublic;

  /// Habit ID required error
  ///
  /// In en, this message translates to:
  /// **'Habit ID cannot be empty'**
  String get habitIdRequired;

  /// Description required error
  ///
  /// In en, this message translates to:
  /// **'Community description is required'**
  String get descriptionRequired;

  /// Category required error
  ///
  /// In en, this message translates to:
  /// **'Category is required'**
  String get categoryRequired;

  /// Invalid category error
  ///
  /// In en, this message translates to:
  /// **'Invalid category: {category}'**
  String invalidCategory(String category);

  /// Invalid difficulty error
  ///
  /// In en, this message translates to:
  /// **'Invalid difficulty level: {difficulty}'**
  String invalidDifficulty(String difficulty);

  /// Failed to load completions error
  ///
  /// In en, this message translates to:
  /// **'Failed to load completions'**
  String get failedToLoadCompletions;

  /// Failed to refresh habit error
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh habit'**
  String get failedToRefreshHabit;

  /// Failed to make habit public error
  ///
  /// In en, this message translates to:
  /// **'Failed to make habit public'**
  String get failedToMakeHabitPublic;

  /// Already shared with community message
  ///
  /// In en, this message translates to:
  /// **'already shared with the community'**
  String get alreadySharedWithCommunity;

  /// Generic error with details
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String anErrorOccurred(String error);

  /// Character count requirement
  ///
  /// In en, this message translates to:
  /// **'{min}-{max} characters required'**
  String charactersRequired(int min, int max);

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Input validation message
  ///
  /// In en, this message translates to:
  /// **'Please check your input and try again. Make sure your password is at least 8 characters.'**
  String get pleaseCheckYourInput;

  /// Community control sharing warning
  ///
  /// In en, this message translates to:
  /// **'Once your habit has 5 members, control will be shared with the top 5 members by streak length.'**
  String get onceYourHabitHasFiveMembers;

  /// Community settings section title
  ///
  /// In en, this message translates to:
  /// **'Community Settings'**
  String get communitySettings;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// Difficulty level field label
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// Description required error message
  ///
  /// In en, this message translates to:
  /// **'Please provide a description for your habit'**
  String get pleaseProvideDescription;

  /// Description minimum length error
  ///
  /// In en, this message translates to:
  /// **'Description must be at least 10 characters long'**
  String get descriptionMustBeAtLeast;

  /// Description maximum length error
  ///
  /// In en, this message translates to:
  /// **'Description must be 500 characters or less'**
  String get descriptionMustBeOrLess;

  /// Empty proposals state message for users with voting rights
  ///
  /// In en, this message translates to:
  /// **'Be the first to propose a change'**
  String get beFirstToPropose;

  /// Empty proposals state message for users without voting rights
  ///
  /// In en, this message translates to:
  /// **'Check back later for new proposals'**
  String get checkBackLater;

  /// Health category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Fitness category
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// Productivity category
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// Learning category
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// Mindfulness category
  ///
  /// In en, this message translates to:
  /// **'Mindfulness'**
  String get mindfulness;

  /// Creativity category
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get creativity;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
