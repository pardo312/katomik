// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Katomik - Rastreador de Hábitos';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get welcomeBack => 'Bienvenido de Vuelta';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get signUpToGetStarted => 'Regístrate para comenzar';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get username => 'Nombre de Usuario';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get or => 'O';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signingIn => 'Iniciando sesión...';

  @override
  String get creatingYourAccount => 'Creando tu cuenta...';

  @override
  String get cancel => 'Cancelar';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Guardar';

  @override
  String get update => 'Actualizar';

  @override
  String get create => 'Crear';

  @override
  String get retry => 'Reintentar';

  @override
  String get pleaseEnterYourEmail => 'Por favor ingresa tu correo electrónico';

  @override
  String get pleaseEnterValidEmail =>
      'Por favor ingresa un correo electrónico válido';

  @override
  String get pleaseEnterYourPassword => 'Por favor ingresa tu contraseña';

  @override
  String passwordMustBeAtLeastChars(int minLength) {
    return 'La contraseña debe tener al menos $minLength caracteres';
  }

  @override
  String get pleaseConfirmYourPassword => 'Por favor confirma tu contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get pleaseEnterUsername => 'Por favor ingresa un nombre de usuario';

  @override
  String usernameMustBeAtLeastChars(int minLength) {
    return 'El nombre de usuario debe tener al menos $minLength caracteres';
  }

  @override
  String usernameMustBeLessThanChars(int maxLength) {
    return 'El nombre de usuario debe tener menos de $maxLength caracteres';
  }

  @override
  String get usernameCanOnlyContain =>
      'El nombre de usuario solo puede contener letras, números y guiones bajos';

  @override
  String get invalidCredentials =>
      'Correo/usuario o contraseña inválidos. Por favor intenta de nuevo.';

  @override
  String get noAccountFound =>
      'No se encontró cuenta con este correo/usuario. Por favor regístrate primero.';

  @override
  String get unableToConnect =>
      'No se puede conectar al servidor. Por favor verifica tu conexión a internet.';

  @override
  String get checkLoginDetails =>
      'Por favor verifica tus datos de inicio de sesión e intenta de nuevo.';

  @override
  String get emailAlreadyRegistered =>
      'Este correo ya está registrado. Por favor usa un correo diferente o inicia sesión.';

  @override
  String get usernameAlreadyTaken =>
      'Este nombre de usuario ya está tomado. Por favor elige un nombre de usuario diferente.';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get connectionError =>
      'Error de conexión. Por favor verifica tu conexión a internet.';

  @override
  String get requestTimeout =>
      'La solicitud expiró. Por favor intenta de nuevo.';

  @override
  String get serverError => 'Error del servidor. Por favor intenta más tarde.';

  @override
  String get discoverCommunities => 'Descubrir Comunidades';

  @override
  String get loadingCommunities => 'Cargando comunidades...';

  @override
  String get errorLoadingCommunities => 'Error al cargar comunidades';

  @override
  String get noCommunitiesFound => 'No se encontraron comunidades';

  @override
  String get tryAdjustingFilters => 'Intenta ajustar tus filtros';

  @override
  String get beFirstToCreateOne => '¡Sé el primero en crear una!';

  @override
  String get searchCommunities => 'Buscar comunidades...';

  @override
  String get leaveCommunity => '¿Abandonar Comunidad?';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get areYouSureLogout => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get profile => 'Perfil';

  @override
  String get themeSettings => 'Configuración de Tema';

  @override
  String get verifyEmail => 'Verificar Correo';

  @override
  String get yourEmailNotVerified => 'Tu correo no está verificado';

  @override
  String get changeProfilePicture => 'Cambiar Foto de Perfil';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de la Galería';

  @override
  String get useGoogleProfilePicture => 'Usar Foto de Perfil de Google';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get editHabit => 'Editar Hábito';

  @override
  String get newHabit => 'Nuevo Hábito';

  @override
  String get habitName => 'Nombre del Hábito';

  @override
  String get habitNamePlaceholder => 'ej., Beber Agua, Ejercicio, Leer';

  @override
  String get missingInformation => 'Información Faltante';

  @override
  String get provideHabitNameAndPhrase =>
      'Por favor proporciona un nombre de hábito y al menos una frase.';

  @override
  String get error => 'Error';

  @override
  String get noHabitsYet => 'No hay hábitos aún';

  @override
  String get startBuildingFirstHabit =>
      '¡Empieza a construir tu primer hábito!';

  @override
  String get joinCommunity => 'Unirse a la Comunidad';

  @override
  String get governance => 'Gobernanza';

  @override
  String get createProposal => 'Crear Propuesta';

  @override
  String get approve => 'Aprobar';

  @override
  String get reject => 'Rechazar';

  @override
  String get viewCommunity => 'Ver Comunidad';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get selectCategory => 'Selecciona una categoría';

  @override
  String get loadingCommunity => 'Cargando comunidad...';

  @override
  String get errorLoadingCommunity => 'Error al cargar comunidad';

  @override
  String get communityNotFound => 'Comunidad no encontrada';

  @override
  String get somethingWentWrong => '¡Algo salió mal!';

  @override
  String get selectImageSource => 'Seleccionar Fuente de Imagen';

  @override
  String get camera => 'Cámara';

  @override
  String get photoLibrary => 'Biblioteca de Fotos';

  @override
  String get modifyHabit => 'Modificar Hábito';

  @override
  String get changeRules => 'Cambiar Reglas';

  @override
  String get removeMember => 'Eliminar Miembro';

  @override
  String get deleteHabit => 'Eliminar Hábito';

  @override
  String get unknown => 'Desconocido';

  @override
  String daysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'hace $days días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: 'hace $hours horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'hace $minutes minutos',
      one: 'hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get expired => 'Expirado';

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String hoursRemaining(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String minutesRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get aboutThisCommunity => 'Acerca de esta Comunidad';

  @override
  String get enterMotivatingPhrase => 'Ingresa una frase motivadora';

  @override
  String get describeHabitCommunityGoals =>
      'Describe tu hábito y metas comunitarias...';

  @override
  String get enterClearDescriptiveTitle =>
      'Ingresa un título claro y descriptivo';

  @override
  String get explainProposalDetail => 'Explica tu propuesta en detalle';

  @override
  String get about => 'Acerca de';

  @override
  String get leaderboard => 'Tabla de Líderes';

  @override
  String get stats => 'Estadísticas';

  @override
  String get proposals => 'Propuestas';

  @override
  String get votingMembers => 'Miembros Votantes';

  @override
  String get whyImDoingThis => 'Por qué estoy haciendo esto';

  @override
  String get images => 'Imágenes';

  @override
  String get phrases => 'Frases';

  @override
  String get communityInfo => 'Información de la Comunidad';

  @override
  String get chooseColor => 'Elegir Color';

  @override
  String get chooseIcon => 'Elegir Ícono';

  @override
  String get makeHabitPublic => 'Hacer Hábito Público';

  @override
  String get pendingProposals => 'Propuestas Pendientes';

  @override
  String get noProposals => 'Sin propuestas';

  @override
  String get weeklyStreak => 'Racha Semanal';

  @override
  String get totalStreak => 'Racha Total';

  @override
  String get members => 'Miembros';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get status => 'Estado';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get pending => 'Pendiente';

  @override
  String get completed => 'Completado';

  @override
  String get home => 'Inicio';

  @override
  String get communities => 'Comunidades';

  @override
  String get add => 'Agregar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get loading => 'Cargando...';

  @override
  String get submit => 'Enviar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get finish => 'Finalizar';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get close => 'Cerrar';

  @override
  String get open => 'Abrir';

  @override
  String get more => 'Más';

  @override
  String get less => 'Menos';

  @override
  String get showMore => 'Mostrar más';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get year => 'Año';

  @override
  String get all => 'Todo';

  @override
  String get none => 'Ninguno';

  @override
  String get select => 'Seleccionar';

  @override
  String get selected => 'Seleccionado';

  @override
  String get apply => 'Aplicar';

  @override
  String get reset => 'Restablecer';

  @override
  String get clear => 'Limpiar';

  @override
  String get done => 'Hecho';

  @override
  String get settings => 'Configuración';

  @override
  String get help => 'Ayuda';

  @override
  String get aboutApp => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get share => 'Compartir';

  @override
  String get copy => 'Copiar';

  @override
  String get copied => 'Copiado';

  @override
  String get paste => 'Pegar';

  @override
  String get cut => 'Cortar';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get january => 'ENERO';

  @override
  String get february => 'FEBRERO';

  @override
  String get march => 'MARZO';

  @override
  String get april => 'ABRIL';

  @override
  String get may => 'MAYO';

  @override
  String get june => 'JUNIO';

  @override
  String get july => 'JULIO';

  @override
  String get august => 'AGOSTO';

  @override
  String get september => 'SEPTIEMBRE';

  @override
  String get october => 'OCTUBRE';

  @override
  String get november => 'NOVIEMBRE';

  @override
  String get december => 'DICIEMBRE';

  @override
  String get sundayShort => 'd';

  @override
  String get mondayShort => 'l';

  @override
  String get tuesdayShort => 'm';

  @override
  String get wednesdayShort => 'm';

  @override
  String get thursdayShort => 'j';

  @override
  String get fridayShort => 'v';

  @override
  String get saturdayShort => 's';

  @override
  String get networkError => 'Error de red. Por favor verifica tu conexión.';

  @override
  String get unexpectedError => 'Ocurrió un error inesperado';

  @override
  String get invalidArgument => 'Argumento inválido';

  @override
  String get failedToMakePublic =>
      'No se pudo hacer público el hábito - no se recibieron datos';

  @override
  String get habitIdRequired => 'El ID del hábito no puede estar vacío';

  @override
  String get descriptionRequired =>
      'La descripción de la comunidad es requerida';

  @override
  String get categoryRequired => 'La categoría es requerida';

  @override
  String invalidCategory(String category) {
    return 'Categoría inválida: $category';
  }

  @override
  String invalidDifficulty(String difficulty) {
    return 'Nivel de dificultad inválido: $difficulty';
  }

  @override
  String get failedToLoadCompletions => 'Error al cargar las completaciones';

  @override
  String get failedToRefreshHabit => 'Error al actualizar el hábito';

  @override
  String get failedToMakeHabitPublic => 'Error al hacer público el hábito';

  @override
  String get alreadySharedWithCommunity => 'ya compartido con la comunidad';

  @override
  String anErrorOccurred(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String charactersRequired(int min, int max) {
    return '$min-$max caracteres requeridos';
  }

  @override
  String get description => 'Descripción';

  @override
  String get pleaseCheckYourInput =>
      'Por favor verifica tu entrada e intenta de nuevo. Asegúrate de que tu contraseña tenga al menos 8 caracteres.';

  @override
  String get onceYourHabitHasFiveMembers =>
      'Una vez que tu hábito tenga 5 miembros, el control se compartirá con los 5 miembros principales por longitud de racha.';

  @override
  String get communitySettings => 'Configuración de la Comunidad';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get categoryLabel => 'Categoría';

  @override
  String get difficultyLevel => 'Nivel de Dificultad';

  @override
  String get pleaseProvideDescription =>
      'Por favor proporciona una descripción para tu hábito';

  @override
  String get descriptionMustBeAtLeast =>
      'La descripción debe tener al menos 10 caracteres';

  @override
  String get descriptionMustBeOrLess =>
      'La descripción debe tener 500 caracteres o menos';

  @override
  String get beFirstToPropose => 'Sé el primero en proponer un cambio';

  @override
  String get checkBackLater => 'Vuelve más tarde para ver nuevas propuestas';

  @override
  String get health => 'Salud';

  @override
  String get fitness => 'Fitness';

  @override
  String get productivity => 'Productividad';

  @override
  String get learning => 'Aprendizaje';

  @override
  String get mindfulness => 'Atención Plena';

  @override
  String get creativity => 'Creatividad';
}
