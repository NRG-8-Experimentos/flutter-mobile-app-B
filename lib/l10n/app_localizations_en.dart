// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SynHub';

  @override
  String get insertUsername => 'Insert Username';

  @override
  String get insertPassword => 'Insert Password';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginError => 'Login failed. Please try again.';

  @override
  String get register => 'Register';

  @override
  String get login => 'Login';

  @override
  String get name => 'Name';

  @override
  String get surname => 'Surname';

  @override
  String get user => 'User';

  @override
  String get mail => 'Mail';

  @override
  String get urlPfp => 'Profile Picture URL';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidUrl => 'Invalid profile picture URL';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get metricsSummary => 'Metrics Summary';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String get noUpcomingTasks => 'You have no upcoming tasks';

  @override
  String get taskDueSoon => 'Your task due soon';

  @override
  String get group => 'Group';

  @override
  String get tasks => 'Tasks';

  @override
  String get performance => 'Performance';

  @override
  String get requests => 'Requests';

  @override
  String get signOut => 'Sign Out';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get help => 'Help';

  @override
  String get helpDialog1 =>
      'Here you can see all your assigned tasks. Tap a task to view details, send comments or mark it as completed.';

  @override
  String get helpDialog2 =>
      'Inside each task you\'ll see a colored bar that indicates the remaining time to complete it.';

  @override
  String get helpDialog3 => 'The bar colors indicate the following:';

  @override
  String get helpDialog4 =>
      'Green: Task in progress with progress less than 70%.';

  @override
  String get helpDialog5 =>
      'Yellow: Task in progress with progress greater than or equal to 70%.';

  @override
  String get helpDialog6 => 'Red: Task expired';

  @override
  String get helpDialog7 => 'Orange: Task pending a request or comment';

  @override
  String get helpDialog8 =>
      'Blue: Task finished or completed (already validated)';

  @override
  String get close => 'Close';

  @override
  String get noData => 'No data';

  @override
  String get noTasksInSection => 'There are no tasks in this section';

  @override
  String get section_in_progress => 'Tasks in progress';

  @override
  String get section_expired => 'Expired tasks';

  @override
  String get section_on_hold => 'Tasks awaiting validation';

  @override
  String get section_marked_done => 'Tasks marked as done';

  @override
  String get section_completed => 'Completed tasks';

  @override
  String get sendComment => 'Send a comment';

  @override
  String get markAsCompleted => 'Mark as completed';

  @override
  String get completedDialogTitle => 'Completed';

  @override
  String get confirmMarkCompleted =>
      'Do you want to mark this task as completed? A request will be created.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get requestCreatedSuccess => 'Request created successfully';

  @override
  String get requestCreatedFailure => 'Failed to create request';

  @override
  String get taskDetailTitle => 'Task Details';

  @override
  String get taskNotFound => 'Task not found';

  @override
  String get requestCompletionMessage => 'The task has been completed.';

  @override
  String get statisticsTitle => 'My performance summary';

  @override
  String get statMarkedCompleted => 'Marked as completed';

  @override
  String get statDone => 'Done';

  @override
  String get statPending => 'Pending';

  @override
  String get statOverdue => 'Overdue';

  @override
  String get tasksDistribution => 'Tasks distribution';

  @override
  String get totalReschedules => 'Total reschedules';

  @override
  String get rescheduled => 'Rescheduled';

  @override
  String get avgCompletionTimeTitle => 'Average completion time';

  @override
  String get noAssignedTasks => 'No tasks assigned.';

  @override
  String get requestsScreenTitle => 'My Requests';

  @override
  String get noSentRequests => 'No requests sent';

  @override
  String get section_pendingRequests => 'Pending requests';

  @override
  String get section_solvedRequests => 'Solved requests';

  @override
  String get noAvailableRequests => 'No requests available';

  @override
  String get requestAlreadyValidatedTitle => 'Request already validated';

  @override
  String get requestAlreadyValidatedContent =>
      'Do you want to clear this request?';

  @override
  String get clear => 'Clear';

  @override
  String get requestClearedSuccess => 'Request cleared successfully';

  @override
  String get requestClearedFailure => 'Failed to clear request';

  @override
  String get comment => 'Comment';

  @override
  String get commentHint => 'Write your comment here...';

  @override
  String get commentEmptyError => 'Please write a comment';

  @override
  String get joinGroupTitle => 'Join a group';

  @override
  String get groupFoundTitle => 'Group Found';

  @override
  String get sendGroupRequest => 'Send request';

  @override
  String get sendGroupRequestSent => 'Request sent to group';

  @override
  String get pendingInvitationCardTitle => 'You have a pending invitation';

  @override
  String get cancelGroupRequest => 'Cancel request';

  @override
  String get syncInvitationStatus => 'Sync invitation status';

  @override
  String get searchGroupButton => 'Search group';

  @override
  String get askAdminForCode => 'Ask the group administrator for the code';

  @override
  String get groupCodeLabel => 'Group code';

  @override
  String get groupCodeHint => 'Enter the 6‑digit code';

  @override
  String get groupCodeRequired => 'Please enter a code';

  @override
  String get groupCodeLengthError => 'Code must be 6 characters';

  @override
  String get groupNameLabel => 'Name';

  @override
  String get groupMembersLabel => 'Members';

  @override
  String get groupDescriptionLabel => 'Description';

  @override
  String get pendingInvitationSnack => 'You have a pending invitation.';

  @override
  String get invitationRejected => 'Your invitation was rejected.';

  @override
  String get loading => 'Loading';

  @override
  String get error => 'Error';

  @override
  String get teamMembersTitle => 'Your teammates:';

  @override
  String get leaveGroupDialogTitle => 'Leave group?';

  @override
  String get leaveGroupDialogContent =>
      'Are you sure you want to leave this group? This action cannot be undone.';

  @override
  String get leaveGroupAction => 'Leave';

  @override
  String get leaveGroupButton => 'Leave Group';

  @override
  String get groupLeftSuccess => 'You have left the group successfully.';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearance_system => 'System';

  @override
  String get appearance_light => 'Light';

  @override
  String get appearance_dark => 'Dark';
}
