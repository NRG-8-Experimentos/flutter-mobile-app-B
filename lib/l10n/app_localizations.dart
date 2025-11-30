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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SynHub'**
  String get appName;

  /// No description provided for @insertUsername.
  ///
  /// In en, this message translates to:
  /// **'Insert Username'**
  String get insertUsername;

  /// No description provided for @insertPassword.
  ///
  /// In en, this message translates to:
  /// **'Insert Password'**
  String get insertPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginError;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In en, this message translates to:
  /// **'Surname'**
  String get surname;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @mail.
  ///
  /// In en, this message translates to:
  /// **'Mail'**
  String get mail;

  /// No description provided for @urlPfp.
  ///
  /// In en, this message translates to:
  /// **'Profile Picture URL'**
  String get urlPfp;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid profile picture URL'**
  String get invalidUrl;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @metricsSummary.
  ///
  /// In en, this message translates to:
  /// **'Metrics Summary'**
  String get metricsSummary;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @noUpcomingTasks.
  ///
  /// In en, this message translates to:
  /// **'You have no upcoming tasks'**
  String get noUpcomingTasks;

  /// No description provided for @taskDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Your task due soon'**
  String get taskDueSoon;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpDialog1.
  ///
  /// In en, this message translates to:
  /// **'Here you can see all your assigned tasks. Tap a task to view details, send comments or mark it as completed.'**
  String get helpDialog1;

  /// No description provided for @helpDialog2.
  ///
  /// In en, this message translates to:
  /// **'Inside each task you\'ll see a colored bar that indicates the remaining time to complete it.'**
  String get helpDialog2;

  /// No description provided for @helpDialog3.
  ///
  /// In en, this message translates to:
  /// **'The bar colors indicate the following:'**
  String get helpDialog3;

  /// No description provided for @helpDialog4.
  ///
  /// In en, this message translates to:
  /// **'Green: Task in progress with progress less than 70%.'**
  String get helpDialog4;

  /// No description provided for @helpDialog5.
  ///
  /// In en, this message translates to:
  /// **'Yellow: Task in progress with progress greater than or equal to 70%.'**
  String get helpDialog5;

  /// No description provided for @helpDialog6.
  ///
  /// In en, this message translates to:
  /// **'Red: Task expired'**
  String get helpDialog6;

  /// No description provided for @helpDialog7.
  ///
  /// In en, this message translates to:
  /// **'Orange: Task pending a request or comment'**
  String get helpDialog7;

  /// No description provided for @helpDialog8.
  ///
  /// In en, this message translates to:
  /// **'Blue: Task finished or completed (already validated)'**
  String get helpDialog8;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noTasksInSection.
  ///
  /// In en, this message translates to:
  /// **'There are no tasks in this section'**
  String get noTasksInSection;

  /// No description provided for @section_in_progress.
  ///
  /// In en, this message translates to:
  /// **'Tasks in progress'**
  String get section_in_progress;

  /// No description provided for @section_expired.
  ///
  /// In en, this message translates to:
  /// **'Expired tasks'**
  String get section_expired;

  /// No description provided for @section_on_hold.
  ///
  /// In en, this message translates to:
  /// **'Tasks awaiting validation'**
  String get section_on_hold;

  /// No description provided for @section_marked_done.
  ///
  /// In en, this message translates to:
  /// **'Tasks marked as done'**
  String get section_marked_done;

  /// No description provided for @section_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks'**
  String get section_completed;

  /// No description provided for @sendComment.
  ///
  /// In en, this message translates to:
  /// **'Send a comment'**
  String get sendComment;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get markAsCompleted;

  /// No description provided for @completedDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedDialogTitle;

  /// No description provided for @confirmMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Do you want to mark this task as completed? A request will be created.'**
  String get confirmMarkCompleted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @requestCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request created successfully'**
  String get requestCreatedSuccess;

  /// No description provided for @requestCreatedFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to create request'**
  String get requestCreatedFailure;

  /// No description provided for @taskDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetailTitle;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'Task not found'**
  String get taskNotFound;

  /// No description provided for @requestCompletionMessage.
  ///
  /// In en, this message translates to:
  /// **'The task has been completed.'**
  String get requestCompletionMessage;

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'My performance summary'**
  String get statisticsTitle;

  /// No description provided for @statMarkedCompleted.
  ///
  /// In en, this message translates to:
  /// **'Marked as completed'**
  String get statMarkedCompleted;

  /// No description provided for @statDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statDone;

  /// No description provided for @statPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statPending;

  /// No description provided for @statOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statOverdue;

  /// No description provided for @tasksDistribution.
  ///
  /// In en, this message translates to:
  /// **'Tasks distribution'**
  String get tasksDistribution;

  /// No description provided for @totalReschedules.
  ///
  /// In en, this message translates to:
  /// **'Total reschedules'**
  String get totalReschedules;

  /// No description provided for @rescheduled.
  ///
  /// In en, this message translates to:
  /// **'Rescheduled'**
  String get rescheduled;

  /// No description provided for @avgCompletionTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Average completion time'**
  String get avgCompletionTimeTitle;

  /// No description provided for @noAssignedTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned.'**
  String get noAssignedTasks;

  /// No description provided for @requestsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get requestsScreenTitle;

  /// No description provided for @noSentRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests sent'**
  String get noSentRequests;

  /// No description provided for @section_pendingRequests.
  ///
  /// In en, this message translates to:
  /// **'Pending requests'**
  String get section_pendingRequests;

  /// No description provided for @section_solvedRequests.
  ///
  /// In en, this message translates to:
  /// **'Solved requests'**
  String get section_solvedRequests;

  /// No description provided for @noAvailableRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests available'**
  String get noAvailableRequests;

  /// No description provided for @requestAlreadyValidatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request already validated'**
  String get requestAlreadyValidatedTitle;

  /// No description provided for @requestAlreadyValidatedContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to clear this request?'**
  String get requestAlreadyValidatedContent;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @requestClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request cleared successfully'**
  String get requestClearedSuccess;

  /// No description provided for @requestClearedFailure.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear request'**
  String get requestClearedFailure;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your comment here...'**
  String get commentHint;

  /// No description provided for @commentEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Please write a comment'**
  String get commentEmptyError;

  /// No description provided for @joinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a group'**
  String get joinGroupTitle;

  /// No description provided for @groupFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Found'**
  String get groupFoundTitle;

  /// No description provided for @sendGroupRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendGroupRequest;

  /// No description provided for @sendGroupRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to group'**
  String get sendGroupRequestSent;

  /// No description provided for @pendingInvitationCardTitle.
  ///
  /// In en, this message translates to:
  /// **'You have a pending invitation'**
  String get pendingInvitationCardTitle;

  /// No description provided for @cancelGroupRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelGroupRequest;

  /// No description provided for @syncInvitationStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync invitation status'**
  String get syncInvitationStatus;

  /// No description provided for @searchGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Search group'**
  String get searchGroupButton;

  /// No description provided for @askAdminForCode.
  ///
  /// In en, this message translates to:
  /// **'Ask the group administrator for the code'**
  String get askAdminForCode;

  /// No description provided for @groupCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Group code'**
  String get groupCodeLabel;

  /// No description provided for @groupCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6‑digit code'**
  String get groupCodeHint;

  /// No description provided for @groupCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a code'**
  String get groupCodeRequired;

  /// No description provided for @groupCodeLengthError.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 characters'**
  String get groupCodeLengthError;

  /// No description provided for @groupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get groupNameLabel;

  /// No description provided for @groupMembersLabel.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get groupMembersLabel;

  /// No description provided for @groupDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get groupDescriptionLabel;

  /// No description provided for @pendingInvitationSnack.
  ///
  /// In en, this message translates to:
  /// **'You have a pending invitation.'**
  String get pendingInvitationSnack;

  /// No description provided for @invitationRejected.
  ///
  /// In en, this message translates to:
  /// **'Your invitation was rejected.'**
  String get invitationRejected;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @teamMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Your teammates:'**
  String get teamMembersTitle;

  /// No description provided for @leaveGroupDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get leaveGroupDialogTitle;

  /// No description provided for @leaveGroupDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave this group? This action cannot be undone.'**
  String get leaveGroupDialogContent;

  /// No description provided for @leaveGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leaveGroupAction;

  /// No description provided for @leaveGroupButton.
  ///
  /// In en, this message translates to:
  /// **'Leave Group'**
  String get leaveGroupButton;

  /// No description provided for @groupLeftSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have left the group successfully.'**
  String get groupLeftSuccess;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearance_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearance_system;

  /// No description provided for @appearance_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearance_light;

  /// No description provided for @appearance_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearance_dark;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @addCommentButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addCommentButton;

  /// No description provided for @sendCommentButton.
  ///
  /// In en, this message translates to:
  /// **'Send comment'**
  String get sendCommentButton;

  /// No description provided for @commentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load comments'**
  String get commentsLoadError;

  /// No description provided for @commentAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully'**
  String get commentAddedSuccess;

  /// No description provided for @commentAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add comment'**
  String get commentAddError;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;
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
