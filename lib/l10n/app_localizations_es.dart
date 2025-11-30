// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'SynHub';

  @override
  String get insertUsername => 'Inserte Nombre de Usuario';

  @override
  String get insertPassword => 'Inserte Contraseña';

  @override
  String get username => 'Nombre de Usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get loginError =>
      'Error al iniciar sesión. Por favor, inténtelo de nuevo.';

  @override
  String get register => 'Registrarse';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get name => 'Nombre';

  @override
  String get surname => 'Apellido';

  @override
  String get user => 'Usuario';

  @override
  String get mail => 'Correo Electrónico';

  @override
  String get urlPfp => 'URL de Foto de Perfil';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get invalidEmail => 'Correo electrónico no válido';

  @override
  String get invalidUrl => 'URL de foto de perfil no válida';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden';

  @override
  String get metricsSummary => 'Resumen de métricas';

  @override
  String get completed => 'Terminadas';

  @override
  String get inProgress => 'En progreso';

  @override
  String get noUpcomingTasks => 'No tienes tareas próximas';

  @override
  String get taskDueSoon => 'Tu tarea más cercana a vencer';

  @override
  String get group => 'Grupo';

  @override
  String get tasks => 'Tareas';

  @override
  String get performance => 'Desempeño';

  @override
  String get requests => 'Solicitudes';

  @override
  String get signOut => 'Cerrar Sesión';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get help => 'Ayuda';

  @override
  String get helpDialog1 =>
      'Aquí puedes ver todas tus tareas asignadas. Toca una tarea para ver los detalles, enviar comentarios o marcarla como completada.';

  @override
  String get helpDialog2 =>
      'Dentro de cada tarea, podrás ver una barra de color que indica el tiempo restante para completarla.';

  @override
  String get helpDialog3 => 'Los colores de la barra indican lo siguiente:';

  @override
  String get helpDialog4 =>
      'Verde: Tarea en progreso con un tiempo de progreso menor al 70%.';

  @override
  String get helpDialog5 =>
      'Amarillo: Tarea en progreso con un tiempo de progreso mayor o igual al 70%.';

  @override
  String get helpDialog6 => 'Rojo: Tarea vencida';

  @override
  String get helpDialog7 =>
      'Naranja: Tarea pendiente de una solicitud o comentario';

  @override
  String get helpDialog8 => 'Azul: Tarea terminada o completada (ya validada)';

  @override
  String get close => 'Cerrar';

  @override
  String get noData => 'No hay datos';

  @override
  String get noTasksInSection => 'No hay tareas en esta sección';

  @override
  String get section_in_progress => 'Tareas en progreso';

  @override
  String get section_expired => 'Tareas vencidas';

  @override
  String get section_on_hold => 'Tareas en espera de validación';

  @override
  String get section_marked_done => 'Tareas marcadas como hechas';

  @override
  String get section_completed => 'Tareas completadas';

  @override
  String get sendComment => 'Enviar un comentario';

  @override
  String get markAsCompleted => 'Marcar como completada';

  @override
  String get completedDialogTitle => 'Completado';

  @override
  String get confirmMarkCompleted =>
      '¿Deseas marcar esta tarea como completada? Se creará una solicitud.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get requestCreatedSuccess => 'Solicitud creada correctamente';

  @override
  String get requestCreatedFailure => 'Error al crear la solicitud';

  @override
  String get taskDetailTitle => 'Detalles de la tarea';

  @override
  String get taskNotFound => 'No se encontró la tarea';

  @override
  String get requestCompletionMessage => 'Se ha completado la tarea.';

  @override
  String get statisticsTitle => 'Resumen de mi desempeño';

  @override
  String get statMarkedCompleted => 'Marcadas como Completadas';

  @override
  String get statDone => 'Terminadas';

  @override
  String get statPending => 'Pendientes';

  @override
  String get statOverdue => 'Atrasadas';

  @override
  String get tasksDistribution => 'Distribución de Tareas';

  @override
  String get totalReschedules => 'Cantidad total de reprogramaciones';

  @override
  String get rescheduled => 'Reprogramadas';

  @override
  String get avgCompletionTimeTitle => 'Tiempo Promedio de Finalización';

  @override
  String get noAssignedTasks => 'No hay tareas asignadas.';

  @override
  String get requestsScreenTitle => 'Mis solicitudes';

  @override
  String get noSentRequests => 'No hay solicitudes enviadas';

  @override
  String get section_pendingRequests => 'Solicitudes pendientes';

  @override
  String get section_solvedRequests => 'Solicitudes resueltas';

  @override
  String get noAvailableRequests => 'No hay solicitudes disponibles';

  @override
  String get requestAlreadyValidatedTitle => 'Tu solicitud ya fue validada';

  @override
  String get requestAlreadyValidatedContent =>
      '¿Deseas limpiar esta solicitud?';

  @override
  String get clear => 'Limpiar';

  @override
  String get requestClearedSuccess => 'Solicitud limpiada correctamente';

  @override
  String get requestClearedFailure => 'Error al limpiar la solicitud';

  @override
  String get comment => 'Comentario';

  @override
  String get commentHint => 'Escribe tu comentario aquí...';

  @override
  String get commentEmptyError => 'Por favor, escribe un comentario';

  @override
  String get joinGroupTitle => 'Únete a un grupo';

  @override
  String get groupFoundTitle => 'Grupo Encontrado';

  @override
  String get sendGroupRequest => 'Enviar solicitud';

  @override
  String get sendGroupRequestSent => 'Solicitud enviada al grupo';

  @override
  String get pendingInvitationCardTitle => 'Tienes una invitación pendiente';

  @override
  String get cancelGroupRequest => 'Cancelar solicitud';

  @override
  String get syncInvitationStatus => 'Sincronizar el estado de la invitación';

  @override
  String get searchGroupButton => 'Buscar grupo';

  @override
  String get askAdminForCode => 'Pide el código al administrador del grupo';

  @override
  String get groupCodeLabel => 'Código del grupo';

  @override
  String get groupCodeHint => 'Ingresa el código de 6 dígitos';

  @override
  String get groupCodeRequired => 'Por favor ingresa un código';

  @override
  String get groupCodeLengthError => 'El código debe tener 6 caracteres';

  @override
  String get groupNameLabel => 'Nombre';

  @override
  String get groupMembersLabel => 'Miembros';

  @override
  String get groupDescriptionLabel => 'Descripción';

  @override
  String get pendingInvitationSnack => 'Tienes una invitación pendiente.';

  @override
  String get invitationRejected => 'Tu invitación fue rechazada.';

  @override
  String get loading => 'Cargando';

  @override
  String get error => 'Error';

  @override
  String get teamMembersTitle => 'Tus compañeros de equipo:';

  @override
  String get leaveGroupDialogTitle => '¿Abandonar grupo?';

  @override
  String get leaveGroupDialogContent =>
      '¿Estás seguro de que deseas abandonar este grupo? Esta acción no se puede deshacer.';

  @override
  String get leaveGroupAction => 'Abandonar';

  @override
  String get leaveGroupButton => 'Abandonar Grupo';

  @override
  String get groupLeftSuccess => 'Has abandonado el grupo exitosamente.';
}
