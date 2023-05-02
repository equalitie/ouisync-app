// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(access) =>
      "El permiso no puede ser más alto que el modo de acceso actual del repositorio: ${access}";

  static String m1(name) =>
      "Validación biométrica añadida para el repositorio \"${name}\"";

  static String m2(name) => "${name} - descarga cancelada";

  static String m3(name) => "${name} - fallo durante descarga";

  static String m4(entry) =>
      "${entry} con el mismo nombre ya existe en este directorio.";

  static String m5(path) =>
      "Este directorio no existe más, navegando al ancestro: ${path}";

  static String m6(name) =>
      "La inicialización del repositorio \"${name}\" falló";

  static String m7(path) => "${path} no está vacío";

  static String m9(name) => "Directorio borrado exitosamente: ${name}";

  static String m10(number) =>
      "Desea bloquear todos los repositorios abiertos?\n\n(${number} actualmente)";

  static String m11(path) => "desde ${path}";

  static String m12(name) => "Error creando archivo ${name}";

  static String m14(name) => "No pudimos borrar el repositorio \"${name}\"";

  static String m15(name) =>
      "No pudimos encontrar el repositorio \"${name}\" en la ubicación habitual";

  static String m16(access) => "Modo de aceso otorgado: ${access}";

  static String m17(name) =>
      "Este repositorio ya existe en la aplicación con el nombre \"${name}\".";

  static String m18(name) =>
      "Sugerido: ${name}\n(clic aquí para usar este nombre)";

  static String m19(access) => "Abierto en modo ${access}";

  static String m20(name) => "${name} escritura cancelada";

  static String m21(name) => "${name} - fallo durante escritura";

  static String m22(name) => "Error al importar el repositorio ${name}";

  static String m23(name) => "Fallo creando el repositorio ${name}";

  static String m24(access) => "${access}";

  static String m25(changes) => "${changes}";

  static String m26(entry) => "${entry}";

  static String m27(name) => "${name}";

  static String m28(number) => "${number}";

  static String m29(path) => "${path}";

  static String m30(status) => "${status}";

  static String m31(name) => "Compartir repositorio \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Aceptar"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACEPTAR"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Importar un repositorio"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Importar un Repositorio"),
        "actionBack": MessageLookupByLibrary.simpleMessage("Volver"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("CANCELAR"),
        "actionClear": MessageLookupByLibrary.simpleMessage("Limpiar"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("CERRAR"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Crear"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Crear un repositorio"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("BORRAR"),
        "actionDeleteFile":
            MessageLookupByLibrary.simpleMessage("Borrar archivo"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Borrar directorio"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Borrar repositorio"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("Descartar"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Cambiar nombre"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Salir"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Ir a la configuración"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Ocultar"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("OCULTAR"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Importar"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Importar un repositorio"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("BLOQUEAR"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Mover"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Archivo"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Carpeta"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Crear repositorio"),
        "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Vista previa de archivo"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Recargar"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Recargar repositorio"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Eliminar"),
        "actionRemoveRepo":
            MessageLookupByLibrary.simpleMessage("Eliminar el repositorio"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Renombrar"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Reintentar"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Guardar"),
        "actionSaveChanges":
            MessageLookupByLibrary.simpleMessage("Guardar los cambios"),
        "actionScanQR":
            MessageLookupByLibrary.simpleMessage("Escanea un código QR"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Compartir"),
        "actionShareFile":
            MessageLookupByLibrary.simpleMessage("Compartir archivo"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Deshacer"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Abrir"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Modo de aceso"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Importar un repositorio"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Crear un nuevo repositorio"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("Descargar"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Información"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Mover"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Vista previa"),
        "iconRename": MessageLookupByLibrary.simpleMessage("Renombrar"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Compartir"),
        "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
            "Comparte este token con tu par"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("Versión de la App"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copia el link"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Destino"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Descargado en:"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("Punto final: "),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Localización: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Bloquear todos"),
        "labelName": MessageLookupByLibrary.simpleMessage("Nombre: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Nuevo nombre: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Clave: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Pares"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("Código QR"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Ingrese el nuevo nombre: "),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("Link del repositorio: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("Repita la clave: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("Seleccione el repositorio "),
        "labelSetPermission":
            MessageLookupByLibrary.simpleMessage("Determine el accesso"),
        "labelShareLink":
            MessageLookupByLibrary.simpleMessage("Comparte el link"),
        "labelSize": MessageLookupByLibrary.simpleMessage("Tamaño: "),
        "labelSyncStatus": MessageLookupByLibrary.simpleMessage(
            "Estado de la sincronización: "),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("Link del repositorio"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Ingrese la clave: "),
        "labelUseExternalStorage":
            MessageLookupByLibrary.simpleMessage("Usar almacenamiento externo"),
        "menuItemAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "menuItemLogs": MessageLookupByLibrary.simpleMessage("Registros"),
        "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Red"),
        "menuItemRepository":
            MessageLookupByLibrary.simpleMessage("Repositorio"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("No hay archivos presentes."),
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "Acceso seguro al almacenamiento"),
        "messageAck": MessageLookupByLibrary.simpleMessage("¡Ay!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Esta opción no está disponible en repositorios de solo lectura"),
        "messageAddLocalPassword":
            MessageLookupByLibrary.simpleMessage("Añadir una contraseña local"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Importar un repositorio usando un enlace de token"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Importar un repositorio usando un código QR"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Este repositorio está cerrado o es una copia ciega.\n\nSi usted tiene la clave, abralo e intente de nuevo."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Este repositorio es sólo-lectura."),
        "messageAlertSaveCopyPassword": MessageLookupByLibrary.simpleMessage(
            "Si elimina la validación biométrica, una vez que salga de esta pantalla ya no podrá ver ni copiar la contraseña; guárdela en un lugar seguro."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "En poco Android te predirá autorización para correr esta app en el trasfondo.\n\nEsto es requerido para poder continuar sincronizando mientras la app no está siendo usada activamente"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("OuiSync está corriendo"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Validación biométrica eliminada"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Tu par no puede escribir o leer los contenidos"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "Este repositorio es una copia ciega."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "La <bold>clave</bold> ingresada no da acceso a los contenidos de este repositorio."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
        "messageCamera": MessageLookupByLibrary.simpleMessage("Cámara"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "Necesitamos este permiso para utilizar la cámara y leer el código QR"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Cambiar la extensión del archivo puede hacerlo inutilizable"),
        "messageChangeLocalPassword":
            MessageLookupByLibrary.simpleMessage("Cambiar la contraseña local"),
        "messageConfirmFileDeletion":
            MessageLookupByLibrary.simpleMessage("¿Borrar este archivo?"),
        "messageConfirmFolderDeletion":
            MessageLookupByLibrary.simpleMessage("¿Borrar este directorio?"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Este directorio no está vacío.\n\n¿Aún así quiere borrarlo? (esto borrarar todos sus contenidos)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage("¿Borrar este repositorio?"),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Crea un nuevo <bold>directorio</bold>, o agrega un <bold>archivo</bold>, usando <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Crea un nuevo <bold>repositorio</bold>, o agrega el de un colega usando un <bold>token</bold>"),
        "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Creando el token para compartir…"),
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Este <bold>directorio</bold> está vacío"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "Este <bold>repositorio</bold> está vacío"),
        "messageEntryAlreadyExist": m4,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("Una entrada"),
        "messageEntryTypeFile":
            MessageLookupByLibrary.simpleMessage("Un archivo"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("Un directorio"),
        "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
        "messageErrorAddingLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Error al añadir una contraseña local"),
        "messageErrorAddingSecureStorge": MessageLookupByLibrary.simpleMessage(
            "Error al añadir una contraseña local"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "Se ha producido un error al autenticarse mediante datos biométricos. Por favor, inténtelo de nuevo"),
        "messageErrorChangingLocalPassword":
            MessageLookupByLibrary.simpleMessage(
                "Error al cambiar la contraseña local"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "Ha habido un problema al cambiar la contraseña. Por favor, inténtelo de nuevo"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Usar \\ o / no está permitido"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Error creando el repositorio"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Error creando el token para compartir."),
        "messageErrorCurrentPathMissing": m5,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Algo falló. Por favor intente de nuevo."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Falló."),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("entrada no encontrada"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage(
                "Por favor ingrese un nombre válido."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "No pudimos cargar los contenidos de este directorio. Por favor intente de nuevo."),
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "La nueva contraseña es la misma que la vieja"),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Error al abrir el repositorio"),
        "messageErrorOpeningRepoDescription": m6,
        "messageErrorPathNotEmpty": m7,
        "messageErrorRemovingPassword": MessageLookupByLibrary.simpleMessage(
            "Error al eliminar la contraseña"),
        "messageErrorRemovingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Error al eliminar la contraseña del almacenamiento seguro"),
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "Ya existe un repositorio con este nombre"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("Por favor ingrese la clave."),
        "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
            "La clave y la repetición de la clave no concuerdan."),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Por favor ingrese un token."),
        "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
            "El token parece no ser válido."),
        "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
            "Por favor ingrese un token válido."),
        "messageErrorUnhandledState":
            MessageLookupByLibrary.simpleMessage("Error: estado no gestionado"),
        "messageErrorUpdatingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Error al actualizar la contraseña en el almacenamiento seguro"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "Presione de nuevo el botón para ir atrás para salir de la aplicación."),
        "messageFile": MessageLookupByLibrary.simpleMessage("archivo"),
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "El archivo ya se está subiendo"),
        "messageFileName":
            MessageLookupByLibrary.simpleMessage("Nombre de archivo"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "La vista previa de archivo no está disponible todavía"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("archivos"),
        "messageFolderDeleted": m9,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Nombre de directorio"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Generar una contraseña"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Concedido"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Para conceder este permiso hay que ir a los ajustes:\n\n Ajustes > Aplicaciones y notificaciones"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Permite que la aplicación siga sincronizándose en segundo plano"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Inicializando…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Toque el botón <bold>Abrir</bold> e ingrese la clave para acceder los contenidos."),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Fallo interno detectado."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Cargando…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Descubrir la zona"),
        "messageLockOpenRepos": m10,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Este <bold>repositorio</bold> está cerrado."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Bloqueando todos los repositorios abiertos…"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("Todos"),
        "messageLogLevelErroWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage(
                "Error, Alerta, Información y Depuración"),
        "messageLogLevelError":
            MessageLookupByLibrary.simpleMessage("Solo error"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("Error y Alerta"),
        "messageLogLevelErrorWarnInfo":
            MessageLookupByLibrary.simpleMessage("Error, Alerta e Información"),
        "messageLogViewer":
            MessageLookupByLibrary.simpleMessage("Visor de registro"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Móvil"),
        "messageMoveEntryOrigin": m11,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Esta función no está disponible mientras se está moviendo una entrada."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Tipo de NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Red no disponible"),
        "messageNewFileError": m12,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "La nueva contraseña fue copiada en el portapapeles"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("Existe una nueva versión."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Antes de agregar archivos, tienes que crear un repositorio"),
        "messageNoRepoIsSelected": MessageLookupByLibrary.simpleMessage(
            "No hay ningún repositorio seleccionado"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No se hayaron repositorios"),
        "messageNone": MessageLookupByLibrary.simpleMessage("Ninguno"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("No hay nada aún!"),
        "messageOr": MessageLookupByLibrary.simpleMessage("O..."),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Contraseña copiada al portapapeles"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Intercambio entre pares"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("Este permiso es requerido"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Este repositorio es de <bold>solo lectura</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "No puede ser modificado, sólo acceder sus contenidos"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Recuerda guardar la contraseña de forma segura; si la olvidas, no hay forma de recuperarla."),
        "messageRemovaLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Eliminar la contraseña local"),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage(
                "Eliminar la validación biométrica"),
        "messageRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
            "Eliminar los datos biométricos"),
        "messageRemoveBiometricsConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "¿Está seguro de que desea eliminar este repositorio biométrico?"),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("<eliminado>"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Cambiar nombre de archivo"),
        "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
            "Cambiar nombre de directorio"),
        "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
            "Cambiar nombre de repositorio"),
        "messageRepoDeletionErrorDescription": m14,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "El borrado del repositorio falló"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "El repositorio ya no está allí"),
        "messageRepoMissingErrorDescription": m15,
        "messageRepositoryAccessMode": m16,
        "messageRepositoryAlreadyExist": m17,
        "messageRepositoryIsNotOpen": MessageLookupByLibrary.simpleMessage(
            "El repositorio no está abierto"),
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("De un nombre al repositorio"),
        "messageRepositoryNewName": MessageLookupByLibrary.simpleMessage(
            "Nuevo nombre del repositorio"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("Nueva contraseña"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Contraseña"),
        "messageRepositorySuggestedName": m18,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Pegue el link aquí"),
        "messageSaveLogFile": MessageLookupByLibrary.simpleMessage(
            "Guardar el archivo de registro"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "Guardar el archivo en este directorio"),
        "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
            "¿Deseas guardar los cambios actuales?"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Escanea este código con tu otro dispositivo or compartelo con tus pares"),
        "messageSecureUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Protección biométrica"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Escoge el nivel de acceso para crear el link para compartir"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Seleccione el lugar"),
        "messageSettingsRuntimeID": MessageLookupByLibrary.simpleMessage(
            "Identificador del tiempo de ejecución"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "Necesitas seleccionar un permiso primero para crear un link de repository"),
        "messageShareWithWR":
            MessageLookupByLibrary.simpleMessage("Comparte con Código QR"),
        "messageStorage":
            MessageLookupByLibrary.simpleMessage("Almacenamiento"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "Necesario para acceder a los archivos"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Sincronizar con datos móviles"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "La sincronización está desactivada cuando usas los datos móviles"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Token de repositorio copiado al portapapeles."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "La contraseña no desbloqueó el repositorio"),
        "messageUnlockRepoOk": m19,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Ingrese la clave para abrir el repositorio"),
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Abrir usando biométricos"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "Tienes cambios sin guardar.\n\n¿Desea descartarlos?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Registro detallado"),
        "messageView": MessageLookupByLibrary.simpleMessage("Ver"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wifi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Acceso total. Tu par puede leer y modificar"),
        "messageWritingFileCanceled": m20,
        "messageWritingFileError": m21,
        "messsageFailedAddRepository": m22,
        "messsageFailedCreateRepository": m23,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Cambiar la contraseña"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Copiar la contraseña"),
        "replacementAccess": m24,
        "replacementChanges": m25,
        "replacementEntry": m26,
        "replacementName": m27,
        "replacementNumber": m28,
        "replacementPath": m29,
        "replacementStatus": m30,
        "statusSync": MessageLookupByLibrary.simpleMessage("SINCRONIZADO"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("No especificado"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "titleAddFile": MessageLookupByLibrary.simpleMessage(
            "Agregar un archivo a OuiSync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Importar un repositorio con token"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Importar un repositorio"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Permisos requeridos"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Cambiar la contraseña"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Crear un directorio"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Crear un repositorio nuevo"),
        "titleDeleteFile":
            MessageLookupByLibrary.simpleMessage("Borrar archivo"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Borrar directorio"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Borrar directorio no vacío"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Borrar repositorio"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Ubicación de descarga"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Descargar al dispositivo"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Editar repositorio"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("Detalles de archivo"),
        "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
            "Extensión de archivo modificada"),
        "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
            "Extensión de archivo faltante"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Añadir"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Detalles de directorio"),
        "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
            "Bloquear todos los repositorios"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Registros"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Moviendo entrada"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Conectividad"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Remover biométricos"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Tus repositorios"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Repositorio"),
        "titleRepositoryName":
            MessageLookupByLibrary.simpleMessage("Nombre del repositorio"),
        "titleRequiredPermission":
            MessageLookupByLibrary.simpleMessage("Permiso requerido"),
        "titleSaveChanges":
            MessageLookupByLibrary.simpleMessage("Guardar los cambios"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("Escanear QR de Repositorio"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Seguridad"),
        "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
            "Establecer una contraseña para"),
        "titleSettings":
            MessageLookupByLibrary.simpleMessage("Configuraciones"),
        "titleShareRepository": m31,
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Monitor de Estado"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Abrir repositorio"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Cambios sin guardar"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Archivo"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Directorio")
      };
}
