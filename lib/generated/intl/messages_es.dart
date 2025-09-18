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

  static String m3(path) => "Archivo descargado en ${path}";

  static String m4(name) => "${name} - descarga cancelada";

  static String m5(name) => "${name} - fallo durante descarga";

  static String m6(entry) =>
      "${entry} con el mismo nombre ya existe en este directorio.";

  static String m8(path) =>
      "Este directorio no existe más, navegando al ancestro: ${path}";

  static String m9(error) => "Error: ${error}";

  static String m10(dokanUrl) => "Dokan ha desaparecido.${dokanUrl}";

  static String m11(name) =>
      "La inicialización del repositorio \"${name}\" falló";

  static String m12(path) => "${path} no está vacío";

  static String m13(name) => "Error al importar el repositorio ${name}";

  static String m14(name) => "No se pudo crear el repositorio ${name}";

  static String m15(reason) =>
      "El acceso a los repositorios a través del Explorador de archivos no está disponible: ${reason}";

  static String m16(name) =>
      "${name} ya existe en esta ubicación.\n\n¿Qué deseas hacer?";

  static String m19(name) => "Directorio borrado exitosamente: ${name}";

  static String m21(number) =>
      "Desea bloquear todos los repositorios abiertos?\n\n(${number} actualmente)";

  static String m23(path) => "desde ${path}";

  static String m24(name) => "Error creando archivo ${name}";

  static String m25(name) => "Error al abrir el archivo ${name}";

  static String m26(path) => "Error al previsualizar el archivo ${path}";

  static String m27(name) => "No pudimos borrar el repositorio \"${name}\"";

  static String m28(name) =>
      "No pudimos encontrar el repositorio \"${name}\" en la ubicación habitual";

  static String m29(access) => "Modo de aceso otorgado: ${access}";

  static String m30(name) =>
      "Este repositorio ya existe en la aplicación con el nombre \"${name}\".";

  static String m33(name) =>
      "Sugerido: ${name}\n(clic aquí para usar este nombre)";

  static String m35(name) => "Ordenar por: ${name}";

  static String m36(access) => "Abierto en modo ${access}";

  static String m37(name) =>
      "Introduzca la contraseña para desbloquear \"${name}\"";

  static String m38(name) => "${name} escritura cancelada";

  static String m39(name) => "${name} - fallo durante escritura";

  static String m40(access) => "${access}";

  static String m41(changes) => "${changes}";

  static String m42(entry) => "${entry}";

  static String m43(error) => "${error}";

  static String m44(name) => "${name}";

  static String m45(number) => "${number}";

  static String m46(path) => "${path}";

  static String m47(status) => "${status}";

  static String m49(name) => "Compartir repositorio \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "actionAccept": MessageLookupByLibrary.simpleMessage("Aceptar"),
    "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACEPTAR"),
    "actionAddRepository": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio",
    ),
    "actionAddRepositoryWithToken": MessageLookupByLibrary.simpleMessage(
      "Importar un Repositorio",
    ),
    "actionBack": MessageLookupByLibrary.simpleMessage("Volver"),
    "actionCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "actionCancelCapital": MessageLookupByLibrary.simpleMessage("CANCELAR"),
    "actionClear": MessageLookupByLibrary.simpleMessage("Limpiar"),
    "actionCloseCapital": MessageLookupByLibrary.simpleMessage("CERRAR"),
    "actionCreate": MessageLookupByLibrary.simpleMessage("Crear"),
    "actionCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Crear un repositorio",
    ),
    "actionDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
    "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("BORRAR"),
    "actionDeleteFile": MessageLookupByLibrary.simpleMessage("Borrar archivo"),
    "actionDeleteFolder": MessageLookupByLibrary.simpleMessage(
      "Borrar directorio",
    ),
    "actionDeleteRepository": MessageLookupByLibrary.simpleMessage(
      "Borrar repositorio",
    ),
    "actionDiscard": MessageLookupByLibrary.simpleMessage("Descartar"),
    "actionDone": MessageLookupByLibrary.simpleMessage("Hecho"),
    "actionEditRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Cambiar nombre",
    ),
    "actionEject": MessageLookupByLibrary.simpleMessage("Expulsar"),
    "actionExit": MessageLookupByLibrary.simpleMessage("Salir"),
    "actionGoToSettings": MessageLookupByLibrary.simpleMessage(
      "Ir a la configuración",
    ),
    "actionHide": MessageLookupByLibrary.simpleMessage("Ocultar"),
    "actionHideCapital": MessageLookupByLibrary.simpleMessage("OCULTAR"),
    "actionIAgree": MessageLookupByLibrary.simpleMessage("Estoy de acuerdo"),
    "actionIDontAgree": MessageLookupByLibrary.simpleMessage(
      "No estoy de acuerdo",
    ),
    "actionImport": MessageLookupByLibrary.simpleMessage("Importar"),
    "actionImportRepo": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio",
    ),
    "actionInstallDokan": MessageLookupByLibrary.simpleMessage(
      "Instalar Dokan",
    ),
    "actionLockCapital": MessageLookupByLibrary.simpleMessage("BLOQUEAR"),
    "actionMove": MessageLookupByLibrary.simpleMessage("Mover"),
    "actionNewFile": MessageLookupByLibrary.simpleMessage("Archivo"),
    "actionNewFolder": MessageLookupByLibrary.simpleMessage("Carpeta"),
    "actionNewMediaFile": MessageLookupByLibrary.simpleMessage("Multimedia"),
    "actionNewRepo": MessageLookupByLibrary.simpleMessage("Crear repositorio"),
    "actionNext": MessageLookupByLibrary.simpleMessage("Siguiente"),
    "actionNo": MessageLookupByLibrary.simpleMessage("No"),
    "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
    "actionPreviewFile": MessageLookupByLibrary.simpleMessage(
      "Vista previa de archivo",
    ),
    "actionReloadContents": MessageLookupByLibrary.simpleMessage("Recargar"),
    "actionReloadRepo": MessageLookupByLibrary.simpleMessage(
      "Recargar repositorio",
    ),
    "actionRemove": MessageLookupByLibrary.simpleMessage("Eliminar"),
    "actionRemoveLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Eliminar la contraseña local",
    ),
    "actionRemoveRepo": MessageLookupByLibrary.simpleMessage(
      "Eliminar el repositorio",
    ),
    "actionRename": MessageLookupByLibrary.simpleMessage("Renombrar"),
    "actionRetry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "actionSave": MessageLookupByLibrary.simpleMessage("Guardar"),
    "actionSaveChanges": MessageLookupByLibrary.simpleMessage(
      "Guardar los cambios",
    ),
    "actionScanQR": MessageLookupByLibrary.simpleMessage(
      "Escanea un código QR",
    ),
    "actionShare": MessageLookupByLibrary.simpleMessage("Compartir"),
    "actionShareFile": MessageLookupByLibrary.simpleMessage(
      "Compartir archivo",
    ),
    "actionShow": MessageLookupByLibrary.simpleMessage("Mostrar"),
    "actionSkip": MessageLookupByLibrary.simpleMessage("Omitir"),
    "actionUndo": MessageLookupByLibrary.simpleMessage("Deshacer"),
    "actionUnlock": MessageLookupByLibrary.simpleMessage("Abrir"),
    "actionUpdate": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "actionUpdateDokan": MessageLookupByLibrary.simpleMessage(
      "Actualizar Dokan",
    ),
    "actionYes": MessageLookupByLibrary.simpleMessage("Sí"),
    "buttonLocateRepository": MessageLookupByLibrary.simpleMessage("Localizar"),
    "iconAccessMode": MessageLookupByLibrary.simpleMessage("Modo de aceso"),
    "iconAddExistingRepository": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio",
    ),
    "iconCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Crear un nuevo repositorio",
    ),
    "iconDelete": MessageLookupByLibrary.simpleMessage("Borrar"),
    "iconDownload": MessageLookupByLibrary.simpleMessage("Descargar"),
    "iconInformation": MessageLookupByLibrary.simpleMessage("Información"),
    "iconMove": MessageLookupByLibrary.simpleMessage("Mover"),
    "iconPreview": MessageLookupByLibrary.simpleMessage("Vista previa"),
    "iconRename": MessageLookupByLibrary.simpleMessage("Renombrar"),
    "iconShare": MessageLookupByLibrary.simpleMessage("Compartir"),
    "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
      "Comparte este token con tu par",
    ),
    "labelAppVersion": MessageLookupByLibrary.simpleMessage(
      "Versión de la App",
    ),
    "labelAttachLogs": MessageLookupByLibrary.simpleMessage(
      "Adjuntar los registros",
    ),
    "labelBitTorrentDHT": MessageLookupByLibrary.simpleMessage(
      "BitTorrent DHT",
    ),
    "labelConnectionType": MessageLookupByLibrary.simpleMessage(
      "Tipo de conexión",
    ),
    "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copia el link"),
    "labelDestination": MessageLookupByLibrary.simpleMessage("Destino"),
    "labelDownloadedTo": MessageLookupByLibrary.simpleMessage("Descargado en:"),
    "labelEndpoint": MessageLookupByLibrary.simpleMessage("Punto final: "),
    "labelExternalIPv4": MessageLookupByLibrary.simpleMessage(
      "Dirección IPv4 externa",
    ),
    "labelExternalIPv6": MessageLookupByLibrary.simpleMessage(
      "Dirección IPv6 externa",
    ),
    "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("IPv4 local"),
    "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("IPv6 local"),
    "labelLocation": MessageLookupByLibrary.simpleMessage("Localización: "),
    "labelLockAllRepos": MessageLookupByLibrary.simpleMessage("Bloquear todos"),
    "labelName": MessageLookupByLibrary.simpleMessage("Nombre: "),
    "labelNewName": MessageLookupByLibrary.simpleMessage("Nuevo nombre: "),
    "labelPassword": MessageLookupByLibrary.simpleMessage("Clave: "),
    "labelPeers": MessageLookupByLibrary.simpleMessage("Pares"),
    "labelQRCode": MessageLookupByLibrary.simpleMessage("Código QR"),
    "labelQuicListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Escuchar sobre QUIC/UDP IPv4",
    ),
    "labelQuicListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Escuchando sobre QUIC/UPD IPv6",
    ),
    "labelRememberPassword": MessageLookupByLibrary.simpleMessage(
      "Recordar clave",
    ),
    "labelRenameRepository": MessageLookupByLibrary.simpleMessage(
      "Ingrese el nuevo nombre: ",
    ),
    "labelRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña actual",
    ),
    "labelRepositoryLink": MessageLookupByLibrary.simpleMessage(
      "Link del repositorio: ",
    ),
    "labelRetypePassword": MessageLookupByLibrary.simpleMessage(
      "Repita la clave: ",
    ),
    "labelSelectRepository": MessageLookupByLibrary.simpleMessage(
      "Seleccione el repositorio ",
    ),
    "labelSetPermission": MessageLookupByLibrary.simpleMessage(
      "Determine el accesso",
    ),
    "labelShareLink": MessageLookupByLibrary.simpleMessage("Comparte el link"),
    "labelSize": MessageLookupByLibrary.simpleMessage("Tamaño: "),
    "labelSyncStatus": MessageLookupByLibrary.simpleMessage(
      "Estado de la sincronización: ",
    ),
    "labelTcpListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Escuchar sobre TCP IPv4",
    ),
    "labelTcpListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Escuchar sobre TCP IPv6",
    ),
    "labelTokenLink": MessageLookupByLibrary.simpleMessage(
      "Link del repositorio",
    ),
    "labelTypePassword": MessageLookupByLibrary.simpleMessage(
      "Ingrese la clave: ",
    ),
    "languageIsNotAvailable": MessageLookupByLibrary.simpleMessage(
      "no disponible",
    ),
    "languageOfTheDevice": MessageLookupByLibrary.simpleMessage(
      "idioma del dispositivo",
    ),
    "menuItemAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "menuItemLogs": MessageLookupByLibrary.simpleMessage("Registros"),
    "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Red"),
    "menuItemRepository": MessageLookupByLibrary.simpleMessage("Repositorio"),
    "messageAccessModeDisabled": m0,
    "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
      "Acceso seguro al almacenamiento",
    ),
    "messageAck": MessageLookupByLibrary.simpleMessage("¡Ay!"),
    "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Esta opción no está disponible en repositorios de solo lectura",
    ),
    "messageAddRepoDb": MessageLookupByLibrary.simpleMessage(
      "Importar repositorio desde el sistema de archivos",
    ),
    "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio usando un enlace de token",
    ),
    "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio usando un código QR",
    ),
    "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
      "Este repositorio está cerrado o es una copia ciega.\n\nSi usted tiene la clave, abralo e intente de nuevo.",
    ),
    "messageAddingFileToReadRepository": MessageLookupByLibrary.simpleMessage(
      "Este repositorio es sólo-lectura.",
    ),
    "messageAuthenticate": MessageLookupByLibrary.simpleMessage("Autenticar"),
    "messageAutomaticUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "No pudimos desbloquear el repositorio",
        ),
    "messageAvailableOnMobile": MessageLookupByLibrary.simpleMessage(
      "Disponible para móviles",
    ),
    "messageAwaitingResult": MessageLookupByLibrary.simpleMessage(
      "Esperando el resultado...",
    ),
    "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
      "En poco Android te predirá autorización para correr esta app en el trasfondo.\n\nEsto es requerido para poder continuar sincronizando mientras la app no está siendo usada activamente",
    ),
    "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
      "Fallo en la autentificación biométrica",
    ),
    "messageBiometricUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "Fallo en el desbloqueo biométrico",
        ),
    "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Tu par no puede escribir o leer los contenidos",
    ),
    "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
      "Este repositorio es una copia ciega.",
    ),
    "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
      "La <bold>clave</bold> ingresada no da acceso a los contenidos de este repositorio.",
    ),
    "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
    "messageBy": MessageLookupByLibrary.simpleMessage("por"),
    "messageCamera": MessageLookupByLibrary.simpleMessage("Cámara"),
    "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
      "Necesitamos este permiso para utilizar la cámara y leer el código QR",
    ),
    "messageCanadaPrivacyAct": MessageLookupByLibrary.simpleMessage(
      "Ley de Protección de Datos de Canadá",
    ),
    "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
      "Cambiar la extensión del archivo puede hacerlo inutilizable",
    ),
    "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
      "Es posible que actualicemos nuestras Condiciones de vez en cuando. Por lo tanto, le recomendamos que revise periódicamente esta página para comprobar si se han producido cambios",
    ),
    "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
      "Esta política entrará en vigor el 9 de Marzo de 2022",
    ),
    "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
      "No recopilamos a sabiendas información de identificación personal de niños. Animamos a todos los niños a que nunca envíen información de identificación personal a través de la Aplicación y/o los Servicios. Animamos a los padres y tutores legales a monitorear el uso de Internet de sus hijos y a ayudar a hacer cumplir esta Política instruyendo a sus hijos a que nunca proporcionen información de identificación personal a través de la Aplicación y/o los Servicios sin su permiso. Si tiene motivos para creer que un niño nos ha proporcionado información de identificación personal a través de la Aplicación y/o los Servicios, póngase en contacto con nosotros. También debe tener al menos 16 años de edad para dar su consentimiento al procesamiento de su información de identificación personal en su país (en algunos países podemos permitir que su padre o tutor lo haga en su nombre)",
    ),
    "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
      "¿Borrar este archivo?",
    ),
    "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "¿Borrar este directorio?",
    ),
    "messageConfirmIrreversibleChange": MessageLookupByLibrary.simpleMessage(
      "Esta acción es irreversible, ¿desea proceder?",
    ),
    "messageConfirmNotEmptyFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "Este directorio no está vacío.\n\n¿Aún así quiere borrarlo? (esto borrarar todos sus contenidos)",
    ),
    "messageConfirmRepositoryDeletion": MessageLookupByLibrary.simpleMessage(
      "¿Borrar este repositorio?",
    ),
    "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
      "Si tiene alguna pregunta o sugerencia sobre nuestra Política de Privacidad, no dude en ponerse en contacto con nosotros en",
    ),
    "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
      "La aplicación Ouisync no utiliza cookies",
    ),
    "messageCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Copiado al portapapeles.",
    ),
    "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
      "Crea un nuevo <bold>directorio</bold>, o agrega un <bold>archivo</bold>, usando <icon></icon>",
    ),
    "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
      "Crea un nuevo <bold>repositorio</bold>, o agrega el de un colega usando un <bold>token</bold>",
    ),
    "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
      "Creando el token para compartir…",
    ),
    "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
      "El equipo de Ouisync valora la privacidad de los usuarios y en consecuencia no recolecta ninguna información del usuario",
    ),
    "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
      "La aplicación Ouisync está diseñada para proporcionar servicios para compartir archivos sin identificador de usuario, nombre, apodo, cuenta de usuario ni ningún dato del usuario. No sabemos quién utiliza nuestra aplicación ni con quién sincroniza o comparte los datos",
    ),
    "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
      "Ouisync (y eQualit.ie) no comparte ningún dato con terceros",
    ),
    "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
      "Declaración para servicios distribuidos en línea",
    ),
    "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
      "El equipo de Ouisync no puede eliminar archivos individuales de los repositorios, ya que no es posible identificarlos porque están encriptados. Podemos eliminar repositorios enteros si nos envías el enlace al repositorio que necesitas eliminar",
    ),
    "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
      "La forma más sencilla de eliminar tus datos es eliminar archivos o repositorios de tu propio dispositivo. Cualquier eliminación de archivos se propagará a todos sus pares - es decir, si tiene acceso de escritura a un repositorio, puede eliminar cualquier archivo dentro de él y los mismos archivos se eliminarán de los repositorios de sus pares, así como de nuestro Always-On-Peer. Si necesita eliminar sólo los repositorios de nuestro Always-On-Peer (pero aún así mantenerlos en su propio repositorio en su propio dispositivo), por favor contáctenos en la dirección abajo",
    ),
    "messageDistributedHashTables": MessageLookupByLibrary.simpleMessage(
      "Tablas de control distribuidas",
    ),
    "messageDokan": MessageLookupByLibrary.simpleMessage("Dokan"),
    "messageDokanDifferentMayorP1": MessageLookupByLibrary.simpleMessage(
      "La versión installada de",
    ),
    "messageDokanDifferentMayorP2": MessageLookupByLibrary.simpleMessage(
      "está desactualizada. Por favor actualízala a la versión más reciente.",
    ),
    "messageDokanInstallationFailed": MessageLookupByLibrary.simpleMessage(
      "La instalación de Dokan falló.",
    ),
    "messageDokanOlderVersionP2": MessageLookupByLibrary.simpleMessage(
      "está desactualizada.\n\nPor favor desinstale la versión existente de Dokan, reinicie el sistema y ejecute Ouisync nuevamente.",
    ),
    "messageDownloadFileCanceled": MessageLookupByLibrary.simpleMessage(
      "Descarga de archivos cancelada",
    ),
    "messageDownloadFileLocation": m3,
    "messageDownloadingFileCanceled": m4,
    "messageDownloadingFileError": m5,
    "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "Este <bold>directorio</bold> está vacío",
    ),
    "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
      "Este <bold>repositorio</bold> está vacío",
    ),
    "messageEnterDifferentName": MessageLookupByLibrary.simpleMessage(
      "Por favor, introduzca otro nombre",
    ),
    "messageEntryAlreadyExist": m6,
    "messageEntryTypeDefault": MessageLookupByLibrary.simpleMessage(
      "Una entrada",
    ),
    "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("Un archivo"),
    "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage(
      "Un directorio",
    ),
    "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
      "Los derechos básicos y las libertades fundamentales son inherentes, inalienables y se aplican a todos por igual. Los derechos humanos son universales; protegido en el derecho internacional y consagrado en la ",
    ),
    "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
      "Como organización, buscamos ser transparentes con nuestras políticas y procedimientos. Con la mayor frecuencia posible, nuestro código fuente está abierto y disponible gratuitamente, protegido por licencias que fomentan el desarrollo, el intercambio y la propagación de estos principios impulsados por la comunidad",
    ),
    "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
      "La capacidad de expresarse libremente y de acceder a la información pública es la columna vertebral de una verdadera democracia. La información pública debe ser de dominio público. La libertad de expresión incluye debates activos y acalorados, incluso argumentos mal articulados, mal construidos y que pueden considerarse ofensivos para algunos. Sin embargo, la libertad de expresión no es un derecho absoluto. Nos oponemos firmemente a la violencia y la incitación a violar los derechos de otros, especialmente la propagación de la violencia, el odio, la discriminación y la privación de derechos de cualquier grupo étnico o social identificable",
    ),
    "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
      "Operamos desde diferentes países y venimos de diversos orígenes sociales. Trabajamos juntos por una sociedad que respete y defienda los derechos de los demás en el mundo físico y digital. La Declaración Internacional de Derechos articula el conjunto de derechos humanos que inspira nuestro trabajo; Creemos que las personas tienen el derecho y el deber de proteger estos derechos",
    ),
    "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
      "Entendemos que se puede abusar de nuestras herramientas y servicios para contravenir estos principios y nuestros términos de servicio, por lo que condenamos y prohibimos firme y activamente dicho uso. No permitimos que nuestro software y servicios se utilicen para promover la comisión de actividades ilícitas, ni ayudaremos en la propagación del discurso de odio o la promoción de la violencia a través de Internet",
    ),
    "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
      "Hemos implementado medidas de seguridad para mitigar el uso indebido de nuestros productos y servicios. Cuando tomamos conocimiento de cualquier uso que viole nuestros principios o términos de servicio, tomamos medidas para detenerle. Guiados por nuestras políticas internas, deliberamos cuidadosamente sobre actos que podrían comprometer nuestros principios. Nuestros procedimientos seguirán evolucionando en función de la experiencia y las mejores prácticas para que podamos lograr el equilibrio adecuado entre permitir el acceso abierto a nuestros productos y servicios y defender nuestros principios",
    ),
    "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
      "Las personas valientes arriesgan la vida y la libertad para defender los derechos humanos, movilizarse, criticar y denunciar a los perpetradores de abusos. Las personas valientes expresan su apoyo a los demás, a las ideas y comunican sus preocupaciones al mundo. Estos valientes ejercen sus derechos humanos en línea",
    ),
    "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
      "Internet es una plataforma para la libre expresión y la autodeterminación. Como toda herramienta de comunicación, Internet no es inmune a la censura, la vigilancia, los ataques y los intentos de actores estatales y grupos criminales por silenciar las voces disidentes. Cuando se criminaliza la expresión democrática, cuando hay discriminación étnica y política, Internet se convierte en otro campo de batalla para la resistencia no violenta",
    ),
    "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
      "Nuestra misión es promover y defender las libertades fundamentales y los derechos humanos, incluido el libre flujo de información en línea. Nuestro objetivo es crear tecnología accesible y mejorar el conjunto de habilidades necesarias para defender los derechos humanos y las libertades en la era digital",
    ),
    "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
      "Nuestro objetivo es educar y aumentar la capacidad de nuestros constituyentes para disfrutar de operaciones seguras en el dominio digital. Hacemos esto mediante la creación de herramientas que permiten y protegen la libertad de expresión, eluden la censura, potencian el anonimato y protegen de la vigilancia donde y cuando sea necesario. Nuestras herramientas también mejoran la gestión de la información y las funciones analíticas",
    ),
    "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
      "Somos un grupo internacional de activistas de diversos orígenes y creencias, unidos para defender los principios comunes entre nosotros. Somos desarrolladores de software, criptógrafos, especialistas en seguridad, así como educadores, sociólogos, historiadores, antropólogos y periodistas. Desarrollamos herramientas abiertas y reutilizables con un enfoque en la privacidad, la seguridad en línea y una mejor gestión de la información. Financiamos nuestras operaciones con subvenciones públicas y consultorías con el sector privado. Creemos en una Internet libre de vigilancia, censura y opresión intrusiva e injustificada",
    ),
    "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
      "Inspirados en la Carta Internacional de Derechos Humanos, nuestros principios se aplican a todos los individuos, grupos y órganos de la sociedad con los que trabajamos, incluidos los beneficiarios del software y los servicios que lanzamos. Todos nuestros proyectos están diseñados teniendo en cuenta nuestros principios. Nuestros conocimientos, herramientas y servicios están disponibles para estos grupos e individuos siempre que se respeten nuestros principios y términos de servicio",
    ),
    "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
      "El derecho a la privacidad es un derecho fundamental que pretendemos proteger siempre que sea posible. La privacidad de nuestros beneficiarios directos es sacrosanta para nuestras operaciones. Nuestras herramientas, servicios y políticas internas están diseñadas para este efecto. Utilizaremos todos los recursos técnicos y legales a nuestro alcance para proteger la privacidad de nuestros beneficiarios. Consulte nuestra Política de privacidad y nuestra ",
    ),
    "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
      "La seguridad es un tema constante en todos nuestros proyectos de desarrollo de software, prestación de servicios y desarrollo de capacidades. Diseñamos nuestros sistemas y procesos para mejorar la seguridad de la información en Internet y elevar el perfil de seguridad y la experiencia del usuario. Intentamos predicar con el ejemplo al no comprometer las propiedades de seguridad de una herramienta o sistema por razones de velocidad, usabilidad o costo. No creemos en la seguridad a través de la oscuridad y mantenemos la transparencia a través del acceso abierto a nuestro código base. Siempre pecamos de cautelosos y tratamos de implementar una buena seguridad tanto operativa como interna",
    ),
    "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
      "está construido en línea con nuestros valores.\n\nAl utilizarlo, usted accede a cumplir con estos principios, y aceptar nuestros términos de uso y notas de privacidad.",
    ),
    "messageError": MessageLookupByLibrary.simpleMessage("Error!"),
    "messageErrorAuthenticatingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Se ha producido un error al autenticarse mediante datos biométricos. Por favor, inténtelo de nuevo",
    ),
    "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
      "Ha habido un problema al cambiar la contraseña. Por favor, inténtelo de nuevo",
    ),
    "messageErrorCharactersNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Usar \\ o / no está permitido",
    ),
    "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
      "Error creando el repositorio",
    ),
    "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
      "Error creando el token para compartir.",
    ),
    "messageErrorCurrentPathMissing": m8,
    "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
      "Algo falló. Por favor intente de nuevo.",
    ),
    "messageErrorDefaultShort": MessageLookupByLibrary.simpleMessage("Falló."),
    "messageErrorDetail": m9,
    "messageErrorDokanNotInstalled": m10,
    "messageErrorEntryNotFound": MessageLookupByLibrary.simpleMessage(
      "entrada no encontrada",
    ),
    "messageErrorFormValidatorNameDefault":
        MessageLookupByLibrary.simpleMessage(
          "Por favor ingrese un nombre válido.",
        ),
    "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
      "No pudimos cargar el contenido de esta carpeta. Inténtalo de nuevo.",
    ),
    "messageErrorNewPasswordSameOldPassword":
        MessageLookupByLibrary.simpleMessage(
          "La nueva contraseña es la misma que la vieja",
        ),
    "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
      "Error al abrir el repositorio",
    ),
    "messageErrorOpeningRepoDescription": m11,
    "messageErrorPathNotEmpty": m12,
    "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
      "Ya existe un repositorio con este nombre",
    ),
    "messageErrorRepositoryPasswordValidation":
        MessageLookupByLibrary.simpleMessage("Por favor ingrese la clave."),
    "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
      "La clave y la repetición de la clave no concuerdan.",
    ),
    "messageErrorTokenEmpty": MessageLookupByLibrary.simpleMessage(
      "Por favor ingrese un token.",
    ),
    "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
      "El token parece no ser válido.",
    ),
    "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
      "Por favor ingrese un token válido.",
    ),
    "messageErrorUnhandledState": MessageLookupByLibrary.simpleMessage(
      "Error: estado no manejado",
    ),
    "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
    "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
      "Presione de nuevo el botón para ir atrás para salir de la aplicación.",
    ),
    "messageFAQ": MessageLookupByLibrary.simpleMessage("Preguntas frecuentes"),
    "messageFailedAddRepository": m13,
    "messageFailedCreateRepository": m14,
    "messageFailedToMount": m15,
    "messageFile": MessageLookupByLibrary.simpleMessage("archivo"),
    "messageFileAlreadyExist": m16,
    "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
      "El archivo ya se está subiendo",
    ),
    "messageFileName": MessageLookupByLibrary.simpleMessage(
      "Nombre de archivo",
    ),
    "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
      "No pudimos iniciar la vista previa del archivo",
    ),
    "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
      "La vista previa de archivo no está disponible todavía",
    ),
    "messageFiles": MessageLookupByLibrary.simpleMessage("archivos"),
    "messageFolderDeleted": m19,
    "messageFolderName": MessageLookupByLibrary.simpleMessage(
      "Nombre de directorio",
    ),
    "messageGeneratePassword": MessageLookupByLibrary.simpleMessage(
      "Generar una contraseña",
    ),
    "messageGoToMailApp": MessageLookupByLibrary.simpleMessage(
      "Ir a la aplicación de correo",
    ),
    "messageGoToPeers": MessageLookupByLibrary.simpleMessage(
      "Ir a los compañeros",
    ),
    "messageGood": MessageLookupByLibrary.simpleMessage("Buena"),
    "messageGranted": MessageLookupByLibrary.simpleMessage("Concedido"),
    "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
      "Para conceder este permiso hay que ir a los ajustes:\n\n Ajustes > Aplicaciones y notificaciones",
    ),
    "messageIgnoreBatteryOptimizationsPermission":
        MessageLookupByLibrary.simpleMessage(
          "Permite que la aplicación siga sincronizándose en segundo plano",
        ),
    "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
      "Es una herramienta que permite a los pares encontrarse entre si en la red P2P (red de pares) sin un servidor central",
    ),
    "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "El Local Peer Discovery permite que tus aplicaciones Ouisync compartan archivos con tus pares sin pasar por proveedores de servicios de Internet, cuando haya disponible una red WiFi local u otra red.\n\nPara la conectividad local, esta opción debe estar activada",
    ),
    "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
      "Este valor depende de su router y/o de su proveedor de servicios de Internet.\n\nLa conectividad con sus pares se logra mejor cuando es Endpoint Independent",
    ),
    "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
      "Es una herramienta para intercambiar la lista de pares con los pares a los que estás conectado",
    ),
    "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
      "Es un identificador único generado por Ouisync cada vez que inicia.\n\nPuedes usarlo para confirmar tu conexión con otros en la sección Pares de la aplicación",
    ),
    "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "Cuando esta opción está activada, tu proveedor de servicios móviles puede cobrarte por los datos utilizados al sincronizar los repositorios que compartes con tus compañeros",
    ),
    "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
      "Es un conjunto de protocolos de red que permitirán a tus aplicaciones Ouisync descubrir y comunicarse entre sí.\n\nPara una mejor conectividad, recomendamos que esta opción esté activada",
    ),
    "messageInitializing": MessageLookupByLibrary.simpleMessage(
      "Inicializando…",
    ),
    "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
      "Toque el botón <bold>Abrir</bold> e ingrese la clave para acceder los contenidos.",
    ),
    "messageInstallDokanForOuisyncP1": MessageLookupByLibrary.simpleMessage(
      "Ouisync utiliza",
    ),
    "messageInstallDokanForOuisyncP2": MessageLookupByLibrary.simpleMessage(
      "para acceder a los repositorios a través del Explorador de Archivos.\nor favor instala Dokan para mejorar tu experiencia con Ouisync.",
    ),
    "messageInternationalBillHumanRights": MessageLookupByLibrary.simpleMessage(
      "Declaración Internacional de Derechos Humanos",
    ),
    "messageKeepBothFiles": MessageLookupByLibrary.simpleMessage(
      "Guarde ambos archivos",
    ),
    "messageKeepBothFolders": MessageLookupByLibrary.simpleMessage(
      "Mantener las dos carpetas",
    ),
    "messageLaunchAtStartup": MessageLookupByLibrary.simpleMessage(
      "Iniciar al arrancar",
    ),
    "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
      "Fallo interno detectado.",
    ),
    "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
      "Este Servicio puede contener enlaces a otros sitios. Si hace clic en un enlace de terceros, será dirigido a ese sitio. Tenga en cuenta que estos sitios externos no son nuestros. Por lo tanto, le recomendamos encarecidamente que revise la Política de Privacidad de estos sitios web. No tenemos ningún control ni asumimos ninguna responsabilidad por el contenido, las políticas de privacidad o las prácticas de los sitios o servicios de terceros",
    ),
    "messageLoadingDefault": MessageLookupByLibrary.simpleMessage("Cargando…"),
    "messageLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "Descubrir la zona",
    ),
    "messageLockOpenRepos": m21,
    "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
      "Este <bold>repositorio</bold> está cerrado.",
    ),
    "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
      "Bloqueando todos los repositorios abiertos…",
    ),
    "messageLogData1": MessageLookupByLibrary.simpleMessage(
      "Dirección de correo electrónico - si el usuario decidió ponerse en contacto con nosotros por correo electrónico",
    ),
    "messageLogData2": MessageLookupByLibrary.simpleMessage(
      "La información que el usuario pueda facilitar por correo electrónico, a través de los tickets de ayuda o de nuestra página web, y los metadatos asociados, con el fin de prestar asistencia técnica",
    ),
    "messageLogData3": MessageLookupByLibrary.simpleMessage(
      "Dirección IP del usuario - para proporcionar asistencia técnica",
    ),
    "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
      "La aplicación Ouisync crea archivos de registro en los dispositivos de los usuarios. Su único propósito es registrar la actividad del dispositivo para facilitar el proceso de depuración en caso de que el usuario experimente dificultades para conectarse con sus compañeros o utilizar la aplicación Ouisync. El archivo de registro permanece en el dispositivo del usuario a menos que el usuario decida enviarlo a nosotros con fines de soporte",
    ),
    "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
      "Si el usuario decide ponerse en contacto con nosotros, los datos personales que podemos recopilar son:",
    ),
    "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
      "Ninguno de estos datos se comparte con terceros",
    ),
    "messageMedium": MessageLookupByLibrary.simpleMessage("Mediana"),
    "messageMissingBackgroundServicePermission":
        MessageLookupByLibrary.simpleMessage(
          "Ouisync no tiene permiso para ejecutarse en segundo plano, abrir otra aplicación puede detener la sincronización en curso",
        ),
    "messageMobile": MessageLookupByLibrary.simpleMessage("Móvil"),
    "messageMoveEntryOrigin": m23,
    "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
      "Esta función no está disponible mientras se está moviendo una entrada.",
    ),
    "messageNATOnWikipedia": MessageLookupByLibrary.simpleMessage(
      "NAT en Wikipedia",
    ),
    "messageNATType": MessageLookupByLibrary.simpleMessage("Tipo de NAT"),
    "messageNetworkIsUnavailable": MessageLookupByLibrary.simpleMessage(
      "Red no disponible",
    ),
    "messageNewFileError": m24,
    "messageNewPasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "La nueva contraseña fue copiada en el portapapeles",
    ),
    "messageNewVersionIsAvailable": MessageLookupByLibrary.simpleMessage(
      "Existe una nueva versión.",
    ),
    "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
      "No se han encontrado aplicaciones que pueden realizar esta acción",
    ),
    "messageNoMediaPresent": MessageLookupByLibrary.simpleMessage(
      "No hay medios presentes.",
    ),
    "messageNoRepo": MessageLookupByLibrary.simpleMessage(
      "Antes de agregar archivos, tienes que crear un repositorio",
    ),
    "messageNoRepoIsSelected": MessageLookupByLibrary.simpleMessage(
      "No hay ningún repositorio seleccionado",
    ),
    "messageNoRepos": MessageLookupByLibrary.simpleMessage(
      "No se hayaron repositorios",
    ),
    "messageNone": MessageLookupByLibrary.simpleMessage("Ninguno"),
    "messageNote": MessageLookupByLibrary.simpleMessage("Nota"),
    "messageNothingHereYet": MessageLookupByLibrary.simpleMessage(
      "No hay nada aún!",
    ),
    "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "Comparte archivos a todos tus dispositivos o con otros usuarios y construye tu propia nube segura!",
    ),
    "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "Los repositorios pueden ser compartidos en modo lectura/escritura, sólo lectura, o \"ciegamente\" (almacenas archivos para otras personas, pero no puedes accederlos)",
    ),
    "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "Todos los archivos y carpetas agregados a Ouisync son cifrados de manera segura de forma predeterminada, tanto en reposo como en tránsito.",
    ),
    "messageOnlyAvailableFiles": MessageLookupByLibrary.simpleMessage(
      "Solo disponible para archivos",
    ),
    "messageOpenFileError": m25,
    "messageOr": MessageLookupByLibrary.simpleMessage("O..."),
    "messageOuiSyncDesktopTitle": MessageLookupByLibrary.simpleMessage(
      "Ouisync",
    ),
    "messagePIPEDA": MessageLookupByLibrary.simpleMessage("PIPEDA"),
    "messagePassword": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "Contraseña copiada al portapapeles",
    ),
    "messagePasswordStrength": MessageLookupByLibrary.simpleMessage(
      "Fuerza de contraseña",
    ),
    "messagePeerAdded": MessageLookupByLibrary.simpleMessage("Par agregado"),
    "messagePeerExchange": MessageLookupByLibrary.simpleMessage(
      "Intercambio entre pares",
    ),
    "messagePeerExchangeWikipedia": MessageLookupByLibrary.simpleMessage(
      "Intercambio entre pares en Wikipedia",
    ),
    "messagePeerRemoved": MessageLookupByLibrary.simpleMessage("Par eliminado"),
    "messagePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Este permiso es requerido",
    ),
    "messagePreviewingFileFailed": m26,
    "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
      "Esta sección se utiliza para informar a los visitantes sobre nuestras políticas con la recopilación, uso y divulgación de Información personal si alguien decide utilizar nuestro servicio",
    ),
    "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
      "“El hombre nace libre, y en todas partes está encadenado.”",
    ),
    "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
      "Este repositorio es de <bold>solo lectura</bold>.",
    ),
    "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "No puede ser modificado, sólo acceder sus contenidos",
    ),
    "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
      "Recuerda guardar la contraseña de forma segura. No hay forma de recuperarla si se pierde o se olvida.",
    ),
    "messageRemoveBiometricValidation": MessageLookupByLibrary.simpleMessage(
      "Remover validación biométrica",
    ),
    "messageRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "Eliminar los datos biométricos",
    ),
    "messageRemoveBiometricsConfirmationMoreInfo":
        MessageLookupByLibrary.simpleMessage(
          "Esto eliminará la contraseña del repositorio y utilizará la validación biométrica para el desbloqueo",
        ),
    "messageRemoveLocalPasswordConfirmation": MessageLookupByLibrary.simpleMessage(
      "¿Quitar la contraseña local de este repositorio?\n\nEl repositorio se desbloqueará automáticamente, a menos que se vuelva a añadir una contraseña local",
    ),
    "messageRemovedInBrackets": MessageLookupByLibrary.simpleMessage(
      "<eliminado>",
    ),
    "messageRenameFile": MessageLookupByLibrary.simpleMessage(
      "Cambiar nombre de archivo",
    ),
    "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
      "Cambiar nombre de directorio",
    ),
    "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
      "Cambiar nombre de repositorio",
    ),
    "messageReplaceExistingFile": MessageLookupByLibrary.simpleMessage(
      "Sustituir el archivo existente",
    ),
    "messageReplaceExistingFolder": MessageLookupByLibrary.simpleMessage(
      "Reemplazar carpeta existente",
    ),
    "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
      "Fallo en la autentificación del repositorio",
    ),
    "messageRepoDeletionErrorDescription": m27,
    "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
      "El borrado del repositorio falló",
    ),
    "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
      "El repositorio ya no está allí",
    ),
    "messageRepoMissingErrorDescription": m28,
    "messageRepositoryAccessMode": m29,
    "messageRepositoryAlreadyExist": m30,
    "messageRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "La contraseña actual",
    ),
    "messageRepositoryIsNotOpen": MessageLookupByLibrary.simpleMessage(
      "El repositorio no está abierto",
    ),
    "messageRepositoryName": MessageLookupByLibrary.simpleMessage(
      "De un nombre al repositorio",
    ),
    "messageRepositoryNewName": MessageLookupByLibrary.simpleMessage(
      "Nuevo nombre del repositorio",
    ),
    "messageRepositoryNewPassword": MessageLookupByLibrary.simpleMessage(
      "Nueva contraseña",
    ),
    "messageRepositoryNotMounted": MessageLookupByLibrary.simpleMessage(
      "El repositorio no se ha montado. ",
    ),
    "messageRepositoryPassword": MessageLookupByLibrary.simpleMessage(
      "Contraseña",
    ),
    "messageRepositorySuggestedName": m33,
    "messageRepositoryToken": MessageLookupByLibrary.simpleMessage(
      "Pegue el link aquí",
    ),
    "messageResetLocalSecret": MessageLookupByLibrary.simpleMessage(
      "Restablecer secreto local",
    ),
    "messageRousseau": MessageLookupByLibrary.simpleMessage(
      "Jean-Jacques Rousseau",
    ),
    "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
      "Guardar el archivo en este directorio",
    ),
    "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
      "¿Deseas guardar los cambios actuales?",
    ),
    "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
      "Escanea este código con tu otro dispositivo or compartelo con tus pares",
    ),
    "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Protección biométrica",
    ),
    "messageSecurityOptionsNotAvailableBlind": MessageLookupByLibrary.simpleMessage(
      "Las opciones de seguridad no están disponibles para repositorios vacíos",
    ),
    "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
      "Los datos que el usuario carga en los repositorios de Ouisync se cifran de extremo a extremo tanto en tránsito como en reposo. Esto incluye los metadatos como los nombres de los archivos, los tamaños, la estructura de las carpetas, etc. En Ouisync, sólo pueden leer los datos la persona que los ha cargado y las personas con las que comparte sus repositorios",
    ),
    "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
      "Usted puede aprender más sobre las técnicas de cifrado por medio de nuestra documentación",
    ),
    "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
      "La aplicación Ouisync almacena los datos de los usuarios en un \"par siempre activo\", que es un servidor ubicado en Canadá. Todos los datos se almacenan en trozos cifrados y ni el servidor ni sus operadores pueden leerlos. El propósito de este servidor es simplemente salvar las distancias entre pares que no están conectados al mismo tiempo. Todos los datos se eliminan periódicamente de este servidor: su objetivo no es proporcionar un almacenamiento permanente de los datos, sino simplemente facilitar la sincronización de datos entre los pares",
    ),
    "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
      "Si tiene motivos para creer que sus datos personales han sido obtenidos y compartidos ilegalmente por otros usuarios de Ouisync, póngase en contacto con nosotros en la siguiente dirección",
    ),
    "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
      "Escoge el nivel de acceso para crear el link para compartir",
    ),
    "messageSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Seleccione el lugar",
    ),
    "messageSettingsRuntimeID": MessageLookupByLibrary.simpleMessage(
      "Identificador del tiempo de ejecución",
    ),
    "messageSettingsVersionNewerThanCurrent": MessageLookupByLibrary.simpleMessage(
      "Los ajustes de este dispositivo se crearón con una versión más reciente de Ouisync y no se pueden migrar.",
    ),
    "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
      "Necesitas seleccionar un permiso primero para crear un link de repository",
    ),
    "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
      "Comparte con Código QR",
    ),
    "messageSortBy": m35,
    "messageStorage": MessageLookupByLibrary.simpleMessage("Almacenamiento"),
    "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
      "Necesario para acceder a los archivos",
    ),
    "messageStrong": MessageLookupByLibrary.simpleMessage("Fuerte"),
    "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "Sincronizar con datos móviles",
    ),
    "messageSyncingIsDisabledOnMobileInternet":
        MessageLookupByLibrary.simpleMessage(
          "La sincronización a través de Internet está desactivada cuando se utilizan datos móviles",
        ),
    "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "Pulse aquí para leer nuestros Términos de Uso y Notas de Privacidad",
    ),
    "messageTapForValues": MessageLookupByLibrary.simpleMessage(
      "Pulse aquí para leer nuestros valores",
    ),
    "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
      "Infringe los derechos de protección de la información personal, incluidos los valores subyacentes o la carta de ",
    ),
    "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
      "(Ley de Protección de Información Personal y Documentos Electrónicos)",
    ),
    "messageTerms2": MessageLookupByLibrary.simpleMessage(
      "Constituya material de explotación sexual infantil (incluido material que puede no ser material ilegal de abuso sexual infantil pero que, no obstante, explota o promueve la explotación sexual de menores), pornografía ilegal o que sea de otro modo indecente",
    ),
    "messageTerms3": MessageLookupByLibrary.simpleMessage(
      "Contiene o promueve actos extremos de violencia o actividad terrorista, incluido el terror o la propaganda extremista violenta",
    ),
    "messageTerms4": MessageLookupByLibrary.simpleMessage(
      "Defienda la intolerancia, el odio o la incitación a la violencia contra cualquier persona o grupo de personas por motivos de raza, religión, etnia, origen nacional, sexo, identidad de género, orientación sexual, discapacidad, impedimento o cualquier otra característica asociada con discriminación o marginación sistémica",
    ),
    "messageTerms5": MessageLookupByLibrary.simpleMessage(
      "Archivos que contengan virus, troyanos, gusanos, bombas lógicas u otro material malicioso o tecnológicamente dañino",
    ),
    "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
      "Estos términos de uso de Ouisync (el \"Acuerdo\"), junto con nuestro aviso de privacidad (colectivamente, los \"Términos\"), rigen el uso de Ouisync - un protocolo y software de sincronización de archivos en línea.",
    ),
    "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
      "Al instalar y ejecutar la aplicación Ouisync, usted indica su consentimiento para estar sujeto y cumplir con este acuerdo entre usted y eQualie inc. (“eQualie”, “nosotros”). El uso de la aplicación Ouisync y de la red Ouisync (el Servicio) es proporcionado por eQualie sin costo alguno y está diseñado para su uso tal como está",
    ),
    "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
      "La aplicación Ouisync está construida alineada con los valores de eQualie. Al utilizar este software, usted acepta que no utilizará Ouisync para publicar, compartir o almacenar materiales que sean contrarios a los valores subyacentes ni a la letra de las leyes de Quebec o Canadá o la Carta Internacional de Derechos Humanos, incluido el contenido que:",
    ),
    "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Token de repositorio copiado al portapapeles.",
    ),
    "messageUnknownFileExtension": MessageLookupByLibrary.simpleMessage(
      "Extensión de archivo desconocida",
    ),
    "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
      "La contraseña no desbloqueó el repositorio",
    ),
    "messageUnlockRepoOk": m36,
    "messageUnlockRepository": m37,
    "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Abrir usando biométricos",
    ),
    "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "Tienes cambios sin guardar.\n\n¿Te gustaría descartarlos?",
    ),
    "messageUpdateLocalPasswordConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "¿Actualizar la contraseña local de este repositorio?",
        ),
    "messageUpdateLocalSecretFailed": MessageLookupByLibrary.simpleMessage(
      "Error al actualizar las propiedades de seguridad del repositorio.",
    ),
    "messageUpdateLocalSecretOk": MessageLookupByLibrary.simpleMessage(
      "Las propiedades de seguridad del repositorio han sido actualizadas.",
    ),
    "messageUseCacheServers": MessageLookupByLibrary.simpleMessage(
      "Usar los servidores de almacenamiento temporal",
    ),
    "messageUseLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Usar clave local",
    ),
    "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
    "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Validar la contraseña localmente",
    ),
    "messageView": MessageLookupByLibrary.simpleMessage("Ver"),
    "messageWeak": MessageLookupByLibrary.simpleMessage("Débil"),
    "messageWiFi": MessageLookupByLibrary.simpleMessage("Wifi"),
    "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Acceso total. Tu par puede leer y modificar",
    ),
    "messageWritingFileCanceled": m38,
    "messageWritingFileError": m39,
    "popupMenuItemChangePassword": MessageLookupByLibrary.simpleMessage(
      "Cambiar la contraseña",
    ),
    "popupMenuItemCopyPassword": MessageLookupByLibrary.simpleMessage(
      "Copiar la contraseña",
    ),
    "replacementAccess": m40,
    "replacementChanges": m41,
    "replacementEntry": m42,
    "replacementError": m43,
    "replacementName": m44,
    "replacementNumber": m45,
    "replacementPath": m46,
    "replacementStatus": m47,
    "repositoryIsAlreadyImported": MessageLookupByLibrary.simpleMessage(
      "El repositorio ya ha sido importado",
    ),
    "statusSync": MessageLookupByLibrary.simpleMessage("SINCRONIZADO"),
    "statusUnspecified": MessageLookupByLibrary.simpleMessage(
      "No especificado",
    ),
    "titleAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "titleAddFile": MessageLookupByLibrary.simpleMessage(
      "Añadir un archivo a Ouisync",
    ),
    "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio con token",
    ),
    "titleAddRepository": MessageLookupByLibrary.simpleMessage(
      "Importar un repositorio",
    ),
    "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
    "titleApplicationLanguage": MessageLookupByLibrary.simpleMessage(
      "Idioma de la aplicación",
    ),
    "titleBackgroundAndroidPermissionsTitle":
        MessageLookupByLibrary.simpleMessage("Permisos requeridos"),
    "titleChangePassword": MessageLookupByLibrary.simpleMessage(
      "Cambiar la contraseña",
    ),
    "titleChangesToTerms": MessageLookupByLibrary.simpleMessage(
      "Cambios a esos términos",
    ),
    "titleChildrensPrivacy": MessageLookupByLibrary.simpleMessage(
      "Privacidad de los niños",
    ),
    "titleContactUs": MessageLookupByLibrary.simpleMessage("Contáctenos"),
    "titleCookies": MessageLookupByLibrary.simpleMessage("\"Cookies\""),
    "titleCreateFolder": MessageLookupByLibrary.simpleMessage(
      "Crear un directorio",
    ),
    "titleCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Crear un repositorio nuevo",
    ),
    "titleDataCollection": MessageLookupByLibrary.simpleMessage(
      "3.1 Recopilación de Datos",
    ),
    "titleDataSharing": MessageLookupByLibrary.simpleMessage(
      "3.2 Intercambio de Datos",
    ),
    "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Borrar archivo"),
    "titleDeleteFolder": MessageLookupByLibrary.simpleMessage(
      "Borrar directorio",
    ),
    "titleDeleteNotEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "Borrar directorio no vacío",
    ),
    "titleDeleteRepository": MessageLookupByLibrary.simpleMessage(
      "Borrar repositorio",
    ),
    "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
      "3.4 Eliminación de sus datos de nuestro servidor Always-On-Peer",
    ),
    "titleDigitalSecurity": MessageLookupByLibrary.simpleMessage(
      "Seguridad Digital",
    ),
    "titleDokanInstallation": MessageLookupByLibrary.simpleMessage(
      "Instalación de Dokan",
    ),
    "titleDokanInstallationFound": MessageLookupByLibrary.simpleMessage(
      "Instalación de Dokan encontrada",
    ),
    "titleDokanMissing": MessageLookupByLibrary.simpleMessage("Falta Dokan"),
    "titleDownloadLocation": MessageLookupByLibrary.simpleMessage(
      "Ubicación de descarga",
    ),
    "titleDownloadToDevice": MessageLookupByLibrary.simpleMessage(
      "Descargar al dispositivo",
    ),
    "titleEditRepository": MessageLookupByLibrary.simpleMessage(
      "Editar repositorio",
    ),
    "titleEqualitiesValues": MessageLookupByLibrary.simpleMessage(
      "Valores de eQualitie",
    ),
    "titleFAQShort": MessageLookupByLibrary.simpleMessage(
      "PREGUNTAS FRECUENTES",
    ),
    "titleFileDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de archivo",
    ),
    "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
      "Extensión de archivo modificada",
    ),
    "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
      "Extensión de archivo faltante",
    ),
    "titleFolderActions": MessageLookupByLibrary.simpleMessage("Añadir"),
    "titleFolderDetails": MessageLookupByLibrary.simpleMessage(
      "Detalles de directorio",
    ),
    "titleFreedomExpressionAccessInfo": MessageLookupByLibrary.simpleMessage(
      "Libertad de expresión y acceso a la información",
    ),
    "titleIssueTracker": MessageLookupByLibrary.simpleMessage(
      "Rastreador de los problemas",
    ),
    "titleJustLegalSociety": MessageLookupByLibrary.simpleMessage(
      "Sociedad justa y legal",
    ),
    "titleLinksOtherSites": MessageLookupByLibrary.simpleMessage(
      "Enlaces a otros sitios",
    ),
    "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
      "Bloquear todos los repositorios",
    ),
    "titleLogData": MessageLookupByLibrary.simpleMessage("Datos de registros"),
    "titleLogs": MessageLookupByLibrary.simpleMessage("Registros"),
    "titleMovingEntry": MessageLookupByLibrary.simpleMessage(
      "Moviendo entrada",
    ),
    "titleNetwork": MessageLookupByLibrary.simpleMessage("Conectividad"),
    "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "Accede a archivos desde múltiples dispositivos",
    ),
    "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "Establece permisos para colaborar, transmitir, o simplemente almacenar",
    ),
    "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "Envía y recibe archivos de manera segura",
    ),
    "titleOpennessTransparency": MessageLookupByLibrary.simpleMessage(
      "Apertura y Transparencia",
    ),
    "titleOurMission": MessageLookupByLibrary.simpleMessage("Nuestra misión"),
    "titleOurPrinciples": MessageLookupByLibrary.simpleMessage(
      "Nuestros Principios",
    ),
    "titleOurValues": MessageLookupByLibrary.simpleMessage("Nuestros valores"),
    "titleOverview": MessageLookupByLibrary.simpleMessage(
      "1. Descripción general",
    ),
    "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
      "La acta de protección de información personal y documentos electrónicos (PIPEDA en inglés)",
    ),
    "titlePrivacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
    "titlePrivacyNotice": MessageLookupByLibrary.simpleMessage(
      "3. Aviso de Privacidad",
    ),
    "titlePrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Política de Privacidad",
    ),
    "titleRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "Remover biométricos",
    ),
    "titleRepositoriesList": MessageLookupByLibrary.simpleMessage(
      "Mis repositorios",
    ),
    "titleRepository": MessageLookupByLibrary.simpleMessage("Repositorio"),
    "titleRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Nombre del repositorio",
    ),
    "titleRequiredPermission": MessageLookupByLibrary.simpleMessage(
      "Permiso requerido",
    ),
    "titleSaveChanges": MessageLookupByLibrary.simpleMessage(
      "Guardar los cambios",
    ),
    "titleScanRepoQR": MessageLookupByLibrary.simpleMessage(
      "Escanear QR de Repositorio",
    ),
    "titleSecurity": MessageLookupByLibrary.simpleMessage("Seguridad"),
    "titleSecurityPractices": MessageLookupByLibrary.simpleMessage(
      "3.3 Prácticas de Seguridad",
    ),
    "titleSendFeedback": MessageLookupByLibrary.simpleMessage(
      "Envía tus comentarios",
    ),
    "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
      "Establecer una contraseña para",
    ),
    "titleSettings": MessageLookupByLibrary.simpleMessage("Configuraciones"),
    "titleShareRepository": m49,
    "titleSortBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
    "titleStateMonitor": MessageLookupByLibrary.simpleMessage(
      "Monitor de Estado",
    ),
    "titleTermsOfUse": MessageLookupByLibrary.simpleMessage(
      "2. Términos de uso",
    ),
    "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "Terminos de Uso y Aviso de Privacidad de Ouisync",
    ),
    "titleUPnP": MessageLookupByLibrary.simpleMessage(
      "Plug and Play universal (UPnP)",
    ),
    "titleUnlockRepository": MessageLookupByLibrary.simpleMessage(
      "Abrir repositorio",
    ),
    "titleUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "Cambios sin guardar",
    ),
    "titleUserProvidedPeers": MessageLookupByLibrary.simpleMessage(
      "Compañeros proporcionados por el usuario",
    ),
    "titleWeAreEq": MessageLookupByLibrary.simpleMessage("Somos eQualit.ie"),
    "typeFile": MessageLookupByLibrary.simpleMessage("Archivo"),
    "typeFolder": MessageLookupByLibrary.simpleMessage("Directorio"),
  };
}
