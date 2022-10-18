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

  static String m1(name) => "${name} - descarga cancelada";

  static String m2(name) => "${name} - fallo durante descarga";

  static String m3(entry) =>
      "${entry} con el mismo nombre ya existe en este directorio";

  static String m4(path) =>
      "Este directorio no existe más, navegando al ancestro: ${path}";

  static String m5(path) => "${path} no está vacío";

  static String m6(name) => "Directorio borrado exitosamente: ${name}";

  static String m7(number) =>
      "Desea bloquear todos los repositorios abiertos?\n\n(${number} actualmente)";

  static String m8(path) => "desde ${path}";

  static String m9(name) => "Error creando archivo ${name}";

  static String m10(access) => "Modo de aceso otorgado: ${access}";

  static String m12(name) =>
      "Sugerido: ${name}\n(clic aquí para usar este nombre)";

  static String m13(name) => "${name} escritura cancelada";

  static String m14(name) => "${name} - fallo durante escritura";

  static String m15(name) => "Fallo agregando el repositorio ${name}";

  static String m16(name) => "Fallo creando el repositorio ${name}";

  static String m17(access) => "${access}";

  static String m18(entry) => "${entry}";

  static String m19(name) => "${name}";

  static String m20(number) => "${number}";

  static String m21(path) => "${path}";

  static String m22(status) => "${status}";

  static String m23(name) => "Compartir repositorio \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Aceptar"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACEPTAR"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Agregar Repositorio"),
        "actionAddRepositoryWithToken": MessageLookupByLibrary.simpleMessage(
            "Agregar Repositorio con Link"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("CANCELAR"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("CERRAR"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Crear"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("BORRAR"),
        "actionDeleteFile":
            MessageLookupByLibrary.simpleMessage("Borrar archivo"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Borrar directorio"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Borrar repositorio"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Cambiar nombre"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Salir"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Ocultar"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("OCULTAR"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("BLOQUEAR"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Mover"),
        "actionNewFile":
            MessageLookupByLibrary.simpleMessage("Agregar archivo"),
        "actionNewFolder":
            MessageLookupByLibrary.simpleMessage("Crear directorio"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Crear repositorio"),
        "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Vista previa de archivo"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Recargar"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Renombrar"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Reintentar"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Guardar"),
        "actionScanQR":
            MessageLookupByLibrary.simpleMessage("Escanea un código QR"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Compartir"),
        "actionShareFile":
            MessageLookupByLibrary.simpleMessage("Compartir archivo"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Mostrar"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Abrir"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Modo de aceso"),
        "iconAddRepository":
            MessageLookupByLibrary.simpleMessage("Agregar un Repositorio"),
        "iconAddRepositoryWithToken": MessageLookupByLibrary.simpleMessage(
            "Agregar un repositorio usando un token"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("Descargar"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Información"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Mover"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Vista previa"),
        "iconRename": MessageLookupByLibrary.simpleMessage("Renombrar"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Compartir"),
        "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
            "Comparte este token con tu colega"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("Versión de la App"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copia el link"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Destino"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Descargado en:"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("Endpoint: "),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Localización: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Bloquear todos"),
        "labelName": MessageLookupByLibrary.simpleMessage("Nombre: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Nuevo nombre: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Clave: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Compañeras"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("Código QR"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Ingrese el nuevo nombre"),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("Link del repositorio: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("Repita la clave: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("seleccione el repositorio"),
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
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("No hay archivos presentes"),
        "messageAccessModeDisabled": m0,
        "messageAck": MessageLookupByLibrary.simpleMessage("Ack!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Esta opción no está disponible en repositorios de solo lectura"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Agrega un repositorio usando un link"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Agrega un repositorio usando un código QR"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Este repositorio está cerrado o es una copia ciega.\n\nSi usted tiene la clave, abralo e intente de nuevo."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Este repositorio es sólo-lectura."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "En poco Android te predirá autorización para correr esta app en el trasfondo.\n\nEsto es requerido para poder continuar sincronizando mientras la app no está siendo usada activamente"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("OuiSync está corriendo"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Tu colega no puede escribir o leer los contenidos"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "Este repositorio es de sólo lectura"),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "La <bold>clave</bold> ingresada no da acceso a los contenidos"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Cambiar la extensión del archivo puede hacerlo inutilizable"),
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
            "Crea un nuevo <bold>directorio</bold>, o agregar un <bold>archivo</bold>, usando <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Crea un  nuevo <bold>repositorio</bold>, o agrega el de un colega usando un <bold>token</bold>"),
        "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Creando el token para compartir..."),
        "messageDownloadingFileCanceled": m1,
        "messageDownloadingFileError": m2,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Este <bold>directorio</bold> está vacío"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "Este <bold>repositorio</bold> está vacío"),
        "messageEntryAlreadyExist": m3,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("Una entrada"),
        "messageEntryTypeFile":
            MessageLookupByLibrary.simpleMessage("Un archivo"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("Un directorio"),
        "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Usar \\ o / no está permitido"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Error creando el repositorio"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Error creando el token para compartir"),
        "messageErrorCurrentPathMissing": m4,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Algo falló. Por favor intente de nuevo"),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Falló"),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("entrada no encontrada"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage(
                "Por favor ingrese in nombre válido (unico, no spacios, ...)"),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "No pudimos cargar los contenidos de este directorio. Por favor intente de nuevo"),
        "messageErrorPathNotEmpty": m5,
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "Ya existe un repositorio con este nombre"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("Por favor ingrese la clave"),
        "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
            "La clave y la repetición de la clave no concuerdan"),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Por favor ingrese un token"),
        "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
            "El token parece no ser válido"),
        "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
            "Por favor ingrese in token válido"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "Presione de nuevo el botón para ir atrás para salir de la aplicación"),
        "messageFileName":
            MessageLookupByLibrary.simpleMessage("Nombre de archivo"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "La vista previa de archivo no está disponible todavía"),
        "messageFolderDeleted": m6,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Nombre de directorio"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Inicializando..."),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Toque el botón <bold>Abrir</bold> e ingrese la clave para acceder los contenidos"),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Cargando…"),
        "messageLockOpenRepos": m7,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Este <bold>repositorio</bold> está cerrado"),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Bloqueando todos los repositorios abiertos..."),
        "messageMoveEntryOrigin": m8,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Esta función no está disponible mientras se está moviendo una entrada"),
        "messageNewFileError": m9,
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Antes de agregar un <bold>archivo</bold>, tienes que crear un <bold>repositorio</bold>"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("No se hayaron repositorios"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("No hay nada aún!"),
        "messageOr": MessageLookupByLibrary.simpleMessage("O..."),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Este repositorio es de <bold>solo lectura</bold>"),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "No puede ser modificado, sólo acceder sus contenidos"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Cambiar nombre de archivo"),
        "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
            "Cambiar nombre de directorio"),
        "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
            "Cambiar nombre de repositorio"),
        "messageRepositoryAccessMode": m10,
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("De un nombre al repositorio"),
        "messageRepositoryNewName": MessageLookupByLibrary.simpleMessage(
            "Nuevo nombre del repositorio"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Clave del repositorio"),
        "messageRepositorySuggestedName": m12,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Pegue el link aquí"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "Guardar el archivo en este directorio"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Escanea este código con tu otro dispositivo or compartelo con tus pares"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Escoge el nivel de acceso para crear el link para compartir"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Seleccione el lugar"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "Necesitas seleccionar un permiso para primero crear un link de repository"),
        "messageShareWithWR":
            MessageLookupByLibrary.simpleMessage("Comparte con Código QR"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Token de repositorio copiado al portapapeles"),
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Ingrese la clave para abrir el repositorio"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Aceso total. Tu colega puede leer y modificar"),
        "messageWritingFileCanceled": m13,
        "messageWritingFileError": m14,
        "messsageFailedAddRepository": m15,
        "messsageFailedCreateRepository": m16,
        "replacementAccess": m17,
        "replacementEntry": m18,
        "replacementName": m19,
        "replacementNumber": m20,
        "replacementPath": m21,
        "replacementStatus": m22,
        "statusSync": MessageLookupByLibrary.simpleMessage("SINCRONIZADO"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("No especificado"),
        "titleAddFile": MessageLookupByLibrary.simpleMessage(
            "Agregar un archivo a OuiSync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Agregar repositorio usando un token"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Agregar un repositorio"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Permisos requeridos"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Crear un directorio"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Crear un repositorio"),
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
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Crear"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Detalles de directorio"),
        "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
            "Bloquear todos los repositorios"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Logs"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Moviendo entrada"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Conectividad"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Tus repositorios"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Repositorio"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("Escanear QR de Repositorio"),
        "titleSettings":
            MessageLookupByLibrary.simpleMessage("Configuraciones"),
        "titleShareRepository": m23,
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Abrir repositorio"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Archivo"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Directorio")
      };
}
