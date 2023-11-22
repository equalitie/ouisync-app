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

  static String m7(name) =>
      "La inicialización del repositorio \"${name}\" falló";

  static String m8(path) => "${path} no está vacío";

  static String m10(name) =>
      "${name} ya existe en esta ubicación.\n\n¿Qué deseas hacer?";

  static String m11(name) => "Directorio borrado exitosamente: ${name}";

  static String m12(number) =>
      "Desea bloquear todos los repositorios abiertos?\n\n(${number} actualmente)";

  static String m13(path) => "desde ${path}";

  static String m14(name) => "Error creando archivo ${name}";

  static String m15(name) => "Error al abrir el archivo ${name}";

  static String m16(name) => "No pudimos borrar el repositorio \"${name}\"";

  static String m17(name) =>
      "No pudimos encontrar el repositorio \"${name}\" en la ubicación habitual";

  static String m18(access) => "Modo de aceso otorgado: ${access}";

  static String m19(name) =>
      "Este repositorio ya existe en la aplicación con el nombre \"${name}\".";

  static String m20(name) =>
      "Sugerido: ${name}\n(clic aquí para usar este nombre)";

  static String m21(access) => "Abierto en modo ${access}";

  static String m22(name) => "${name} escritura cancelada";

  static String m23(name) => "${name} - fallo durante escritura";

  static String m24(name) => "Error al importar el repositorio ${name}";

  static String m25(name) => "Fallo creando el repositorio ${name}";

  static String m26(access) => "${access}";

  static String m27(changes) => "${changes}";

  static String m28(entry) => "${entry}";

  static String m29(name) => "${name}";

  static String m30(number) => "${number}";

  static String m31(path) => "${path}";

  static String m32(status) => "${status}";

  static String m33(name) => "Compartir repositorio \"${name}\"";

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
        "actionDone": MessageLookupByLibrary.simpleMessage("Hecho"),
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
        "actionNext": MessageLookupByLibrary.simpleMessage("Siguiente"),
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
        "labelAttachLogs":
            MessageLookupByLibrary.simpleMessage("Adjuntar los registros"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelConnectionType":
            MessageLookupByLibrary.simpleMessage("Tipo de conexión"),
        "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copia el link"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Destino"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Descargado en:"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("Punto final: "),
        "labelInternalIP": MessageLookupByLibrary.simpleMessage("IP interna"),
        "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("IPv4 local"),
        "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("IPv6 local"),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Localización: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Bloquear todos"),
        "labelName": MessageLookupByLibrary.simpleMessage("Nombre: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Nuevo nombre: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Clave: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Pares"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("Código QR"),
        "labelQuicListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
            "Escuchar sobre QUIC/UDP IPv4"),
        "labelQuicListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
            "Escuchando sobre QUIC/UPD IPv6"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Ingrese el nuevo nombre: "),
        "labelRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Contraseña actual"),
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
        "labelTcpListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("Escuchar sobre TCP IPv4"),
        "labelTcpListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("Escuchar sobre TCP IPv6"),
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
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "En poco Android te predirá autorización para correr esta app en el trasfondo.\n\nEsto es requerido para poder continuar sincronizando mientras la app no está siendo usada activamente"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("Se está ejecutando"),
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Fallo en la autentificación biométrica"),
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
        "messageBy": MessageLookupByLibrary.simpleMessage("por"),
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
        "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
            "Declaración para servicios distribuidos en línea"),
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
        "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
            "Los derechos básicos y las libertades fundamentales son inherentes, inalienables y se aplican a todos por igual. Los derechos humanos son universales; protegido en el derecho internacional y consagrado en la "),
        "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
            "Como organización, buscamos ser transparentes con nuestras políticas y procedimientos. Con la mayor frecuencia posible, nuestro código fuente está abierto y disponible gratuitamente, protegido por licencias que fomentan el desarrollo, el intercambio y la propagación de estos principios impulsados por la comunidad"),
        "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
            "La capacidad de expresarse libremente y de acceder a la información pública es la columna vertebral de una verdadera democracia. La información pública debe ser de dominio público. La libertad de expresión incluye debates activos y acalorados, incluso argumentos mal articulados, mal construidos y que pueden considerarse ofensivos para algunos. Sin embargo, la libertad de expresión no es un derecho absoluto. Nos oponemos firmemente a la violencia y la incitación a violar los derechos de otros, especialmente la propagación de la violencia, el odio, la discriminación y la privación de derechos de cualquier grupo étnico o social identificable"),
        "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
            "Operamos desde diferentes países y venimos de diversos orígenes sociales. Trabajamos juntos por una sociedad que respete y defienda los derechos de los demás en el mundo físico y digital. La Declaración Internacional de Derechos articula el conjunto de derechos humanos que inspira nuestro trabajo; Creemos que las personas tienen el derecho y el deber de proteger estos derechos"),
        "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
            "Entendemos que se puede abusar de nuestras herramientas y servicios para contravenir estos principios y nuestros términos de servicio, por lo que condenamos y prohibimos firme y activamente dicho uso. No permitimos que nuestro software y servicios se utilicen para promover la comisión de actividades ilícitas, ni ayudaremos en la propagación del discurso de odio o la promoción de la violencia a través de Internet"),
        "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
            "Hemos implementado medidas de seguridad para mitigar el uso indebido de nuestros productos y servicios. Cuando tomamos conocimiento de cualquier uso que viole nuestros principios o términos de servicio, tomamos medidas para detenerle. Guiados por nuestras políticas internas, deliberamos cuidadosamente sobre actos que podrían comprometer nuestros principios. Nuestros procedimientos seguirán evolucionando en función de la experiencia y las mejores prácticas para que podamos lograr el equilibrio adecuado entre permitir el acceso abierto a nuestros productos y servicios y defender nuestros principios"),
        "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
            "Las personas valientes arriesgan la vida y la libertad para defender los derechos humanos, movilizarse, criticar y denunciar a los perpetradores de abusos. Las personas valientes expresan su apoyo a los demás, a las ideas y comunican sus preocupaciones al mundo. Estos valientes ejercen sus derechos humanos en línea"),
        "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
            "Internet es una plataforma para la libre expresión y la autodeterminación. Como toda herramienta de comunicación, Internet no es inmune a la censura, la vigilancia, los ataques y los intentos de actores estatales y grupos criminales por silenciar las voces disidentes. Cuando se criminaliza la expresión democrática, cuando hay discriminación étnica y política, Internet se convierte en otro campo de batalla para la resistencia no violenta"),
        "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
            "Nuestra misión es promover y defender las libertades fundamentales y los derechos humanos, incluido el libre flujo de información en línea. Nuestro objetivo es crear tecnología accesible y mejorar el conjunto de habilidades necesarias para defender los derechos humanos y las libertades en la era digital"),
        "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
            "Nuestro objetivo es educar y aumentar la capacidad de nuestros constituyentes para disfrutar de operaciones seguras en el dominio digital. Hacemos esto mediante la creación de herramientas que permiten y protegen la libertad de expresión, eluden la censura, potencian el anonimato y protegen de la vigilancia donde y cuando sea necesario. Nuestras herramientas también mejoran la gestión de la información y las funciones analíticas"),
        "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
            "Somos un grupo internacional de activistas de diversos orígenes y creencias, unidos para defender los principios comunes entre nosotros. Somos desarrolladores de software, criptógrafos, especialistas en seguridad, así como educadores, sociólogos, historiadores, antropólogos y periodistas. Desarrollamos herramientas abiertas y reutilizables con un enfoque en la privacidad, la seguridad en línea y una mejor gestión de la información. Financiamos nuestras operaciones con subvenciones públicas y consultorías con el sector privado. Creemos en una Internet libre de vigilancia, censura y opresión intrusiva e injustificada"),
        "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
            "Inspirados en la Carta Internacional de Derechos Humanos, nuestros principios se aplican a todos los individuos, grupos y órganos de la sociedad con los que trabajamos, incluidos los beneficiarios del software y los servicios que lanzamos. Todos nuestros proyectos están diseñados teniendo en cuenta nuestros principios. Nuestros conocimientos, herramientas y servicios están disponibles para estos grupos e individuos siempre que se respeten nuestros principios y términos de servicio"),
        "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
            "El derecho a la privacidad es un derecho fundamental que pretendemos proteger siempre que sea posible. La privacidad de nuestros beneficiarios directos es sacrosanta para nuestras operaciones. Nuestras herramientas, servicios y políticas internas están diseñadas para este efecto. Utilizaremos todos los recursos técnicos y legales a nuestro alcance para proteger la privacidad de nuestros beneficiarios. Consulte nuestra Política de privacidad y nuestra "),
        "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
            "La seguridad es un tema constante en todos nuestros proyectos de desarrollo de software, prestación de servicios y desarrollo de capacidades. Diseñamos nuestros sistemas y procesos para mejorar la seguridad de la información en Internet y elevar el perfil de seguridad y la experiencia del usuario. Intentamos predicar con el ejemplo al no comprometer las propiedades de seguridad de una herramienta o sistema por razones de velocidad, usabilidad o costo. No creemos en la seguridad a través de la oscuridad y mantenemos la transparencia a través del acceso abierto a nuestro código base. Siempre pecamos de cautelosos y tratamos de implementar una buena seguridad tanto operativa como interna"),
        "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
            "esta construido en línea con nuestros valores.\nAl utilizarlo, usted accede a cumplir con estos principios, y aceptar nuestros términos de uso y notas de privacidad."),
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
        "messageErrorOpeningRepoDescription": m7,
        "messageErrorPathNotEmpty": m8,
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
            MessageLookupByLibrary.simpleMessage("Error: estado no manejado"),
        "messageErrorUpdatingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Error al actualizar la contraseña en el almacenamiento seguro"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "Presione de nuevo el botón para ir atrás para salir de la aplicación."),
        "messageFAQ":
            MessageLookupByLibrary.simpleMessage("Preguntas frecuentes"),
        "messageFile": MessageLookupByLibrary.simpleMessage("archivo"),
        "messageFileAlreadyExist": m10,
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "El archivo ya se está subiendo"),
        "messageFileName":
            MessageLookupByLibrary.simpleMessage("Nombre de archivo"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "La vista previa de archivo no está disponible todavía"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("archivos"),
        "messageFolderDeleted": m11,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Nombre de directorio"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Generar una contraseña"),
        "messageGood": MessageLookupByLibrary.simpleMessage("Buena"),
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
        "messageInternationalBillHumanRights":
            MessageLookupByLibrary.simpleMessage(
                "Declaración Internacional de Derechos Humanos"),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("Guarde ambos archivos"),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Fallo interno detectado."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Cargando…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Descubrir la zona"),
        "messageLockOpenRepos": m12,
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
        "messageMedium": MessageLookupByLibrary.simpleMessage("Mediana"),
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "Ouisync no tiene permiso para ejecutarse en segundo plano, abrir otra aplicación puede detener la sincronización en curso"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Móvil"),
        "messageMoveEntryOrigin": m13,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Esta función no está disponible mientras se está moviendo una entrada."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Tipo de NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Red no disponible"),
        "messageNewFileError": m14,
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
        "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Comparte archivos a todos tus dispositivos o con otros usuarios y construye tu propia nube segura!"),
        "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Los repositorios pueden ser compartidos en modo lectura/escritura, sólo lectura, o \"ciegamente\" (almacenas archivos para otras personas, pero no puedes accederlos)"),
        "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Todos los archivos y carpetas agregados a Ouisync son cifrados de manera segura de forma predeterminada, tanto en reposo como en tránsito."),
        "messageOpenFileError": m15,
        "messageOr": MessageLookupByLibrary.simpleMessage("O..."),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Contraseña"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Contraseña copiada al portapapeles"),
        "messagePasswordStrength":
            MessageLookupByLibrary.simpleMessage("Fuerza de contraseña"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Intercambio entre pares"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("Este permiso es requerido"),
        "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
            "Esta sección se utiliza para informar a los visitantes sobre nuestras políticas con la recopilación, uso y divulgación de Información personal si alguien decide utilizar nuestro servicio"),
        "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
            "“El hombre nace libre, y en todas partes está encadenado.”"),
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
                "Remover validación biométrica"),
        "messageRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
            "Eliminar los datos biométricos"),
        "messageRemoveBiometricsConfirmation": MessageLookupByLibrary.simpleMessage(
            "¿Remover la validación biométrica para este repositorio?\n\nEl repositorio se desbloqueará automáticamente, a menos que se agregue una contraseña local."),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("<eliminado>"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Cambiar nombre de archivo"),
        "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
            "Cambiar nombre de directorio"),
        "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
            "Cambiar nombre de repositorio"),
        "messageReplaceExistingFile": MessageLookupByLibrary.simpleMessage(
            "Sustituir el archivo existente"),
        "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Fallo en la autentificación del repositorio"),
        "messageRepoDeletionErrorDescription": m16,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "El borrado del repositorio falló"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "El repositorio ya no está allí"),
        "messageRepoMissingErrorDescription": m17,
        "messageRepositoryAccessMode": m18,
        "messageRepositoryAlreadyExist": m19,
        "messageRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("La contraseña actual"),
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
        "messageRepositorySuggestedName": m20,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Pegue el link aquí"),
        "messageRousseau":
            MessageLookupByLibrary.simpleMessage("Jean-Jacques Rousseau"),
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
        "messageStrong": MessageLookupByLibrary.simpleMessage("Fuerte"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Sincronizar con datos móviles"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "La sincronización está desactivada cuando usas los datos móviles"),
        "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Pulse aquí para leer nuestros Términos de Uso y Notas de Privacidad"),
        "messageTapForValues": MessageLookupByLibrary.simpleMessage(
            "Pulse aquí para leer nuestros valores"),
        "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
            "Infringe los derechos de protección de la información personal, incluidos los valores subyacentes o la carta de "),
        "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
            "(Ley de Protección de Información Personal y Documentos Electrónicos)"),
        "messageTerms2": MessageLookupByLibrary.simpleMessage(
            "Constituya material de explotación sexual infantil (incluido material que puede no ser material ilegal de abuso sexual infantil pero que, no obstante, explota o promueve la explotación sexual de menores), pornografía ilegal o que sea de otro modo indecente"),
        "messageTerms3": MessageLookupByLibrary.simpleMessage(
            "Contiene o promueve actos extremos de violencia o actividad terrorista, incluido el terror o la propaganda extremista violenta"),
        "messageTerms4": MessageLookupByLibrary.simpleMessage(
            "Defienda la intolerancia, el odio o la incitación a la violencia contra cualquier persona o grupo de personas por motivos de raza, religión, etnia, origen nacional, sexo, identidad de género, orientación sexual, discapacidad, impedimento o cualquier otra característica asociada con discriminación o marginación sistémica"),
        "messageTerms5": MessageLookupByLibrary.simpleMessage(
            "Archivos que contengan virus, troyanos, gusanos, bombas lógicas u otro material malicioso o tecnológicamente dañino"),
        "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
            "Estos términos de uso de Ouisync (el \"Acuerdo\"), junto con nuestro aviso de privacidad (colectivamente, los \"Términos\"), rigen el uso de Ouisync - un protocolo y software de sincronización de archivos en línea."),
        "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
            "Al instalar y ejecutar la aplicación Ouisync, usted indica su consentimiento para estar sujeto y cumplir con este acuerdo entre usted y eQualie inc. (“eQualie”, “nosotros”). El uso de la aplicación Ouisync y de la red Ouisync (el Servicio) es proporcionado por eQualie sin costo alguno y está diseñado para su uso tal como está"),
        "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
            "La aplicación Ouisync está construida alineada con los valores de eQualie. Al utilizar este software, usted acepta que no utilizará Ouisync para publicar, compartir o almacenar materiales que sean contrarios a los valores subyacentes ni a la letra de las leyes de Quebec o Canadá o la Carta Internacional de Derechos Humanos, incluido el contenido que:"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Token de repositorio copiado al portapapeles."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "La contraseña no desbloqueó el repositorio"),
        "messageUnlockRepoOk": m21,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Ingrese la clave para abrir el repositorio"),
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Abrir usando biométricos"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "Tienes cambios sin guardar.\n\n¿Desea descartarlos?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
        "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Validar la contraseña localmente"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Detalle del registro"),
        "messageView": MessageLookupByLibrary.simpleMessage("Ver"),
        "messageWeak": MessageLookupByLibrary.simpleMessage("Débil"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wifi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Acceso total. Tu par puede leer y modificar"),
        "messageWritingFileCanceled": m22,
        "messageWritingFileError": m23,
        "messsageFailedAddRepository": m24,
        "messsageFailedCreateRepository": m25,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Cambiar la contraseña"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Copiar la contraseña"),
        "replacementAccess": m26,
        "replacementChanges": m27,
        "replacementEntry": m28,
        "replacementName": m29,
        "replacementNumber": m30,
        "replacementPath": m31,
        "replacementStatus": m32,
        "statusSync": MessageLookupByLibrary.simpleMessage("SINCRONIZADO"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("No especificado"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Añadir un archivo a Ouisync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Importar un repositorio con token"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Importar un repositorio"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Permisos requeridos"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Cambiar la contraseña"),
        "titleChangesToTerms":
            MessageLookupByLibrary.simpleMessage("Cambios a esos términos"),
        "titleChildrensPrivacy":
            MessageLookupByLibrary.simpleMessage("Privacidad de los niños"),
        "titleContactUs": MessageLookupByLibrary.simpleMessage("Contáctenos"),
        "titleCookies": MessageLookupByLibrary.simpleMessage("\"Cookies\""),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Crear un directorio"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Crear un repositorio nuevo"),
        "titleDataCollection":
            MessageLookupByLibrary.simpleMessage("3.1 Recopilación de Datos"),
        "titleDataSharing":
            MessageLookupByLibrary.simpleMessage("3.2 Intercambio de Datos"),
        "titleDeleteFile":
            MessageLookupByLibrary.simpleMessage("Borrar archivo"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Borrar directorio"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Borrar directorio no vacío"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Borrar repositorio"),
        "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
            "3.4 Eliminación de sus datos de nuestro servidor Always-On-Peer"),
        "titleDigitalSecurity":
            MessageLookupByLibrary.simpleMessage("Seguridad Digital"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Ubicación de descarga"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Descargar al dispositivo"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Editar repositorio"),
        "titleEqualitiesValues":
            MessageLookupByLibrary.simpleMessage("Valores de eQualitie"),
        "titleFAQShort":
            MessageLookupByLibrary.simpleMessage("PREGUNTAS FRECUENTES"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("Detalles de archivo"),
        "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
            "Extensión de archivo modificada"),
        "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
            "Extensión de archivo faltante"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Añadir"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Detalles de directorio"),
        "titleFreedomExpresionAccessInfo": MessageLookupByLibrary.simpleMessage(
            "Libertad de expresión y acceso a la información"),
        "titleIssueTracker":
            MessageLookupByLibrary.simpleMessage("Rastreador de los problemas"),
        "titleJustLegalSociety":
            MessageLookupByLibrary.simpleMessage("Sociedad justa y legal"),
        "titleLinksOtherSites":
            MessageLookupByLibrary.simpleMessage("Enlaces a otros sitios"),
        "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
            "Bloquear todos los repositorios"),
        "titleLogData":
            MessageLookupByLibrary.simpleMessage("Datos de registros"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Registros"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Moviendo entrada"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Conectividad"),
        "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Accede a archivos desde múltiples dispositivos"),
        "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Establece permisos para colaborar, transmitir, o simplemente almacenar"),
        "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Envía y recibe archivos de manera segura"),
        "titleOpennessTransparency":
            MessageLookupByLibrary.simpleMessage("Apertura y Transparencia"),
        "titleOurMission":
            MessageLookupByLibrary.simpleMessage("Nuestra misión"),
        "titleOurPrinciples":
            MessageLookupByLibrary.simpleMessage("Nuestros Principios"),
        "titleOurValues":
            MessageLookupByLibrary.simpleMessage("Nuestros valores"),
        "titleOverview":
            MessageLookupByLibrary.simpleMessage("1. Descripción general"),
        "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
            "La acta de protección de información personal y documentos electrónicos (PIPEDA en inglés)"),
        "titlePrivacy": MessageLookupByLibrary.simpleMessage("Privacidad"),
        "titlePrivacyNotice":
            MessageLookupByLibrary.simpleMessage("3. Aviso de Privacidad"),
        "titlePrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("Política de Privacidad"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Remover biométricos"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Mis repositorios"),
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
        "titleSecurityPractices":
            MessageLookupByLibrary.simpleMessage("3.3 Prácticas de Seguridad"),
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("Envía tus comentarios"),
        "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
            "Establecer una contraseña para"),
        "titleSettings":
            MessageLookupByLibrary.simpleMessage("Configuraciones"),
        "titleShareRepository": m33,
        "titleSortBy": MessageLookupByLibrary.simpleMessage("Ordenar por"),
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Monitor de Estado"),
        "titleTermsOfUse":
            MessageLookupByLibrary.simpleMessage("2. Términos de uso"),
        "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Terminos de Uso y Aviso de Privacidad de Ouisync"),
        "titleUPnP": MessageLookupByLibrary.simpleMessage(
            "Plug and Play universal (UPnP)"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Abrir repositorio"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Cambios sin guardar"),
        "titleWeAreEq":
            MessageLookupByLibrary.simpleMessage("Somos eQualit.ie"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Archivo"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Directorio")
      };
}
