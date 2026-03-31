// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Multando';

  @override
  String get login => 'Iniciar Sesion';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo electronico';

  @override
  String get password => 'Contrasena';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get phone => 'Telefono (opcional)';

  @override
  String get forgotPassword => 'Olvidaste tu contrasena?';

  @override
  String get noAccount => 'No tienes cuenta?';

  @override
  String get haveAccount => 'Ya tienes cuenta?';

  @override
  String get orContinueWith => 'O continuar con';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithGithub => 'Continuar con GitHub';

  @override
  String get agreeTerms =>
      'Acepto los Terminos de Servicio y Politica de Privacidad';

  @override
  String get logout => 'Cerrar Sesion';

  @override
  String get logoutConfirm => 'Estas seguro que deseas cerrar sesion?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get onboardingTitle1 => 'Reporta Infracciones';

  @override
  String get onboardingDesc1 =>
      'Captura infracciones de transito con recoleccion segura de evidencia, incluyendo GPS, marca de tiempo y verificacion de movimiento.';

  @override
  String get onboardingTitle2 => 'Verificacion Comunitaria';

  @override
  String get onboardingDesc2 =>
      'Ayuda a verificar reportes de otros ciudadanos. Desliza para aprobar o rechazar - gana recompensas por cada verificacion.';

  @override
  String get onboardingTitle3 => 'Gana Recompensas';

  @override
  String get onboardingDesc3 =>
      'Gana puntos MULTA por cada reporte y verificacion. Apuesta tus tokens y sube en la tabla de posiciones.';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get next => 'Siguiente';

  @override
  String get skip => 'Omitir';

  @override
  String get home => 'Inicio';

  @override
  String get reports => 'Reportes';

  @override
  String get verify => 'Verificar';

  @override
  String get wallet => 'Billetera';

  @override
  String get profile => 'Perfil';

  @override
  String get reportViolation => 'Reportar Infraccion';

  @override
  String get newReport => 'Nuevo Reporte';

  @override
  String get myReports => 'Mis Reportes';

  @override
  String get allReports => 'Todos los Reportes';

  @override
  String get listView => 'Lista';

  @override
  String get mapView => 'Mapa';

  @override
  String get noReports => 'Sin reportes aun';

  @override
  String get noReportsDesc =>
      'Comienza a reportar infracciones para ganar recompensas!';

  @override
  String get captureEvidence => 'Capturar Evidencia';

  @override
  String get selectInfraction => 'Seleccionar Infraccion';

  @override
  String get vehicleDetails => 'Detalles del Vehiculo';

  @override
  String get plateNumber => 'Numero de Placa';

  @override
  String get vehicleType => 'Tipo de Vehiculo';

  @override
  String get location => 'Ubicacion';

  @override
  String get description => 'Descripcion (opcional)';

  @override
  String get confirmDetails => 'Confirmar Detalles';

  @override
  String get reviewSubmit => 'Revisar y Enviar';

  @override
  String get submitReport => 'Enviar Reporte';

  @override
  String get submitting => 'Enviando...';

  @override
  String get reportSubmitted => 'Reporte Enviado!';

  @override
  String get reportSubmittedDesc =>
      'Tu reporte ha sido enviado para verificacion comunitaria.';

  @override
  String step(int number, int total) {
    return 'Paso $number de $total';
  }

  @override
  String get capture => 'Capturar';

  @override
  String get retake => 'Repetir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get evidenceCaptured => 'Evidencia capturada exitosamente';

  @override
  String get verifyReports => 'Verificar Reportes';

  @override
  String get swipeToVerify =>
      'Desliza a la derecha para verificar, izquierda para rechazar';

  @override
  String get verified => 'Verificado';

  @override
  String get rejected => 'Rechazado';

  @override
  String get noMoreReports => 'No hay mas reportes para verificar';

  @override
  String get noMoreReportsDesc => 'Vuelve mas tarde para nuevos reportes.';

  @override
  String get rejectReason => 'Razon del rechazo';

  @override
  String get walletBalance => 'Saldo de Billetera';

  @override
  String get available => 'Disponible';

  @override
  String get staked => 'En Staking';

  @override
  String get pendingRewards => 'Recompensas Pendientes';

  @override
  String get total => 'Total';

  @override
  String get transactions => 'Transacciones';

  @override
  String get noTransactions => 'Sin transacciones aun';

  @override
  String get stake => 'Apostar';

  @override
  String get unstake => 'Retirar Apuesta';

  @override
  String get claimRewards => 'Reclamar Recompensas';

  @override
  String get stakingInfo => 'Info de Staking';

  @override
  String get apy => 'APY';

  @override
  String get locked => 'Bloqueado';

  @override
  String get unlocked => 'Desbloqueado';

  @override
  String get rewardsPreview => 'Vista Previa de Recompensas';

  @override
  String get rewardsPreviewDesc =>
      'Los puntos MULTA se registran en nuestra base de datos. Integracion blockchain pronto!';

  @override
  String get amount => 'Cantidad';

  @override
  String get enterAmount => 'Ingrese cantidad';

  @override
  String get achievements => 'Logros';

  @override
  String get badges => 'Insignias';

  @override
  String get leaderboard => 'Tabla de Posiciones';

  @override
  String get levels => 'Niveles';

  @override
  String get rank => 'Rango';

  @override
  String get points => 'Puntos';

  @override
  String get noBadges => 'Sin insignias aun';

  @override
  String get noBadgesDesc =>
      'Comienza a reportar para ganar tu primera insignia!';

  @override
  String level(int number) {
    return 'Nivel $number';
  }

  @override
  String get profileSettings => 'Configuracion';

  @override
  String get language => 'Idioma';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get developerMode => 'Modo Desarrollador';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Version';

  @override
  String get totalReports => 'Total de Reportes';

  @override
  String get verifiedReports => 'Reportes Verificados';

  @override
  String get reputationScore => 'Reputacion';

  @override
  String get memberSince => 'Miembro desde';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get statusDraft => 'Borrador';

  @override
  String get statusSubmitted => 'Enviado';

  @override
  String get statusUnderReview => 'En Revision';

  @override
  String get statusVerified => 'Verificado';

  @override
  String get statusRejected => 'Rechazado';

  @override
  String get statusAppealed => 'Apelado';

  @override
  String get statusResolved => 'Resuelto';

  @override
  String get parking => 'Estacionamiento';

  @override
  String get speeding => 'Exceso de Velocidad';

  @override
  String get redLight => 'Luz Roja';

  @override
  String get illegalTurn => 'Giro Ilegal';

  @override
  String get wrongWay => 'Contramano';

  @override
  String get noSeatbelt => 'Sin Cinturon';

  @override
  String get phoneUse => 'Uso de Telefono';

  @override
  String get recklessDriving => 'Conduccion Temeraria';

  @override
  String get dui => 'DUI';

  @override
  String get other => 'Otro';

  @override
  String get car => 'Auto';

  @override
  String get motorcycle => 'Motocicleta';

  @override
  String get truck => 'Camion';

  @override
  String get bus => 'Autobus';

  @override
  String get van => 'Camioneta';

  @override
  String get bicycle => 'Bicicleta';

  @override
  String get errorGeneric => 'Algo salio mal. Intenta de nuevo.';

  @override
  String get errorNetwork => 'Sin conexion a internet. Revisa tu red.';

  @override
  String get errorAuth => 'Sesion expirada. Inicia sesion nuevamente.';

  @override
  String get errorValidation => 'Revisa tu informacion e intenta de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get reward => 'Recompensa';

  @override
  String get stakeAction => 'Apostar';

  @override
  String get unstakeAction => 'Retirar';

  @override
  String get transferIn => 'Transferencia Entrante';

  @override
  String get transferOut => 'Transferencia Saliente';

  @override
  String get claim => 'Reclamo';

  @override
  String get penalty => 'Penalidad';

  @override
  String get severityLow => 'Bajo';

  @override
  String get severityMedium => 'Medio';

  @override
  String get severityHigh => 'Alto';

  @override
  String get severityCritical => 'Critico';

  @override
  String get sandbox => 'Modo Sandbox';

  @override
  String get sandboxDesc => 'Conectar al API sandbox para pruebas';
}
