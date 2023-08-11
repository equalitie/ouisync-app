// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static String m0(access) =>
      "Уровень доступа не может быть выше чем текущий уровень: ${access}";

  static String m1(name) =>
      "Биометрическая авторизация добавлена для хранилища \"${name}\"";

  static String m2(name) => "${name} - загрузка отменена";

  static String m3(name) => "${name} - ошибка скачивания";

  static String m4(entry) => "${entry} уже существует.";

  static String m5(path) =>
      "Текущая папка отсутствует, переходим в вышестоящую: ${path}";

  static String m7(name) => "Ошибка инициализации хранилища ${name}";

  static String m8(path) => "${path} не пустой";

  static String m10(name) =>
      "${name} уже существует в этой локации\n\nЧто вы хотите делать?";

  static String m11(name) => "Папка успешно удалена: ${name}";

  static String m12(number) =>
      "Хотите закрыть все открытые хранилища?\n\n(${number}открыто)";

  static String m13(path) => "от ${path}";

  static String m14(name) => "Ошибка при создании файла ${name}";

  static String m15(name) => "Ошибка при открытии файла ${name}";

  static String m16(name) => "Мы не смогли удалить хранилище \"${name}\"";

  static String m17(name) =>
      "Хранилище \"${name}\" не найдено в привычной локации";

  static String m18(access) => "Доступ дан: ${access}";

  static String m19(name) =>
      "Это хранилище уже существует в приложеним под именем \"${name}\".";

  static String m20(name) =>
      "Рекомендация: ${name}\n(нажмите сюда чтобы использовать это имя)";

  static String m21(access) => "Открыт в качестве ${access} копии";

  static String m22(name) => "Запись ${name} отменена";

  static String m23(name) => "${name} - ошибка записи";

  static String m24(name) => "Ошибка импортирования хранилища ${name}";

  static String m25(name) => "Ошибка создания хранилища ${name}";

  static String m26(access) => "${access}";

  static String m27(changes) => "${changes}";

  static String m28(entry) => "${entry}";

  static String m29(name) => "${name}";

  static String m30(number) => "${number}";

  static String m31(path) => "${path}";

  static String m32(status) => "${status}";

  static String m33(name) => "Поделиться хранилищем \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Принять"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ПРИНЯТЬ"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Импортировать хранилище"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Импортировать хранилище"),
        "actionBack": MessageLookupByLibrary.simpleMessage("Назад"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Отменить"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("ОТМЕНИТЬ"),
        "actionClear": MessageLookupByLibrary.simpleMessage("Стереть"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("ЗАКРЫТЬ"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Создать"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Создать хранилище"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("УДАЛИТЬ"),
        "actionDeleteFile":
            MessageLookupByLibrary.simpleMessage("Удалить файл"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Удалить папку"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Удалить хранилище"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("Отменить"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Редактировать имя"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Выйти"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Перейти в настройки"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("СКРЫТЬ"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Импортировать"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Импортировать хранилище"),
        "actionLockCapital":
            MessageLookupByLibrary.simpleMessage("ЗАБЛОКИРОВАТЬ"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Переместить"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Папка"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Создать хранилище"),
        "actionNo": MessageLookupByLibrary.simpleMessage("Нет"),
        "actionOK": MessageLookupByLibrary.simpleMessage("ОК"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Предпросмотр файла"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Обновить"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Обновить хранилище"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Удалить"),
        "actionRemoveRepo":
            MessageLookupByLibrary.simpleMessage("Удалить хранилище"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Переименовать"),
        "actionRetry":
            MessageLookupByLibrary.simpleMessage("Попробовать снова"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "actionSaveChanges":
            MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
        "actionScanQR":
            MessageLookupByLibrary.simpleMessage("Сканировать QR код"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "actionShareFile":
            MessageLookupByLibrary.simpleMessage("Поделиться файлом"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Показать"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Отменить"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Разблокировать"),
        "actionYes": MessageLookupByLibrary.simpleMessage("Да"),
        "iconAccessMode":
            MessageLookupByLibrary.simpleMessage("Уровень доступа"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Импортировать хранилище"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Создать новое хранилище"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Информация"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Переместить"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
        "iconRename": MessageLookupByLibrary.simpleMessage("Переименовать"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Поделиться"),
        "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
            "Поделиться этим с вашими пирами"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("Версия приложения"),
        "labelAttachLogs":
            MessageLookupByLibrary.simpleMessage("Прикрепить логи"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelCopyLink":
            MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Назначение"),
        "labelDownloadedTo": MessageLookupByLibrary.simpleMessage("Скачано в:"),
        "labelEndpoint":
            MessageLookupByLibrary.simpleMessage("Конечный пункт "),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Локация: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Всё заблокировать"),
        "labelName": MessageLookupByLibrary.simpleMessage("Имя: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Новое имя "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Пароль: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Пиры"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("QR код"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Ввести новое имя: "),
        "labelRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Текущий пароль"),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("Ссылка на хранилище: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("Подтвердите пароль: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("Выбрать хранилище "),
        "labelSetPermission":
            MessageLookupByLibrary.simpleMessage("Дать разрешение"),
        "labelShareLink":
            MessageLookupByLibrary.simpleMessage("Поделиться ссылкой"),
        "labelSize": MessageLookupByLibrary.simpleMessage("Размер: "),
        "labelSyncStatus":
            MessageLookupByLibrary.simpleMessage("Статус синхронизации: "),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("Ссылка на хранилище"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Введите пароль: "),
        "labelUseExternalStorage": MessageLookupByLibrary.simpleMessage(
            "Использовать внешнее хранилище"),
        "menuItemAbout": MessageLookupByLibrary.simpleMessage("О программе"),
        "menuItemLogs": MessageLookupByLibrary.simpleMessage("Логи"),
        "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
        "menuItemRepository": MessageLookupByLibrary.simpleMessage("Хранилище"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("Медиафайлов не обнаружено."),
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "Получить доступ к безопасному хранилищу"),
        "messageAck": MessageLookupByLibrary.simpleMessage("Ой!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Эта опция недоступна в хранилищах только для чтения"),
        "messageAddLocalPassword":
            MessageLookupByLibrary.simpleMessage("Добавить локальный пароль"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Импортировать хранилище используя ссылку-токен"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Импортировать хранилище используя QR код"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Это хранилище заблокировано или в слепом доступе.\n\nЕсли у вас есть пароль, разблокируйте его и попробуйте снова."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Это хранилище доступно только для чтения."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Скоро ваша операционная система попросит вас разрешения на работу приложения в фоновом режиме.\n\nЭто нужно чтобы продолжать синхронизацию когда приложение свернуто"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("Ouisync работает"),
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Ошибка аутентификации по биометрии"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Биометрическая авторизация удалена"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Ваш пир не сможет читать и изменять контент"),
        "messageBlindRepository":
            MessageLookupByLibrary.simpleMessage("Это слепая копия хранилища."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "Введенный <bold>пароль</bold> не дает вам доступа к контенту хранилища."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
        "messageCamera": MessageLookupByLibrary.simpleMessage("Камера"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "Это разрешение требуется для использования камеры и чтения QR-кода"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Изменение расширения файла может помешать его дальнейшему использованию"),
        "messageChangeLocalPassword":
            MessageLookupByLibrary.simpleMessage("Изменить локальный пароль"),
        "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
            "Вы уверены что хотите удалить этот файл?"),
        "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
            "Вы уверены что хотите удалить эту папку?"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Эта папка не пустая.\n\nВы все еще хотите ее удалить? (Это удалит все ее содержимое)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Вы уверены что хотите удалить это хранилище?"),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Создайте новую <bold>папку</bold>, или добавьте <bold>файл</bold> используя <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Создать новое <bold>хранилище</bold> или импортировать хранилище другв используя <bold>токен хранилища</bold>"),
        "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Генерация токена для раздачи…"),
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Эта <bold>папка</bold> пуста"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "Это <bold>хранилище</bold> пусто"),
        "messageEntryAlreadyExist": m4,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("Запись"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage("Папка"),
        "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
            "Это приложение разработано в соответствии с нашими ценностями.\n\nИспользуя Ouisync вы соглашаетесь с этими приницами."),
        "messageError": MessageLookupByLibrary.simpleMessage("Ошибка !"),
        "messageErrorAddingLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Ошибка добавления локального пароля"),
        "messageErrorAddingSecureStorge": MessageLookupByLibrary.simpleMessage(
            "Ошибка добавления локального пароля"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "Произошла ошибка при авторизации по биометрии. Пожалуйста, попробуйте снова"),
        "messageErrorChangingLocalPassword":
            MessageLookupByLibrary.simpleMessage(
                "Ошибка изменения локального пароля"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка при изменении пароля. Пожалуйста, попробуйте снова"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Использование \\ or / не разрешено"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Ошибка при создании хранилища"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Ошибка при генерации токена для раздачи."),
        "messageErrorCurrentPathMissing": m5,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Что-то пошло не так. Пожалуйста, повторите попытку."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Ошибка."),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("запись не найдена"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage("Введите верное имя."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "Не удалось загрузить содержимое папки. Попробуйте ещё."),
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "Новый пароль такой же как старый"),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Ошибка при открытии хранилища"),
        "messageErrorOpeningRepoDescription": m7,
        "messageErrorPathNotEmpty": m8,
        "messageErrorRemovingPassword":
            MessageLookupByLibrary.simpleMessage("Ошибка удаления пароля"),
        "messageErrorRemovingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Ошибка удаления пароля безопасного хранилища"),
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "Хранилище с таким именем уже существует"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("Пожалуйста введите пароль."),
        "messageErrorRetypePassword":
            MessageLookupByLibrary.simpleMessage("Пароли не совпадают."),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Введите токен."),
        "messageErrorTokenInvalid":
            MessageLookupByLibrary.simpleMessage("Токен недействителен."),
        "messageErrorTokenValidator":
            MessageLookupByLibrary.simpleMessage("Введите верный токен."),
        "messageErrorUnhandledState": MessageLookupByLibrary.simpleMessage(
            "Ошибка: состояние не поддерживается"),
        "messageErrorUpdatingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Ошибка обновления пароля в безопасном хранилище"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync":
            MessageLookupByLibrary.simpleMessage("Нажмите снова чтобы выйти."),
        "messageFAQ": MessageLookupByLibrary.simpleMessage("FAQ"),
        "messageFile": MessageLookupByLibrary.simpleMessage("файл"),
        "messageFileAlreadyExist": m10,
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "Файл уже в процессе загрузки"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("Имя файла"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Предпросмотр файла ещё не доступен"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("файлы"),
        "messageFolderDeleted": m11,
        "messageFolderName": MessageLookupByLibrary.simpleMessage("Имя папки"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Сгенерировать пароль"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Разрешено"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Чтобы дать это разрешение, зайдите в настройки\n\nНастройки > Приложения и уведомления"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Позволяет приложению синхронизироваться в фоновом режиме"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Инициализация…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Нажмите кнопку <bold>Разблокировать</bold> и введите пароль чтобы получить доступ к содержимому хранилища."),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("Сохранить оба файла"),
        "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
            "Произошла внутренняя ошибка."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Загрузка…"),
        "messageLocalDiscovery": MessageLookupByLibrary.simpleMessage(
            "Обнаружение по локальной сети"),
        "messageLockOpenRepos": m12,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Это <bold>хранилище</bold> заблокировано."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Блокировка всех открытых хранилищ…"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("Всё"),
        "messageLogLevelErroWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage(
                "Ошибки, предупреждения, информация и отладка"),
        "messageLogLevelError":
            MessageLookupByLibrary.simpleMessage("Только ошибки"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("Ошибки и предупреждения"),
        "messageLogLevelErrorWarnInfo": MessageLookupByLibrary.simpleMessage(
            "Ошибки, предупреждения и информация"),
        "messageLogViewer":
            MessageLookupByLibrary.simpleMessage("Просмотр логов"),
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "Ouisync не имеет авторизации на работу в фоновом режиме, если вы запустите другое приложение, это может помешать синхронизации"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Мобильный"),
        "messageMoveEntryOrigin": m13,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Эта функция недоступна при перемещении файла."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Тип NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Сеть недоступна"),
        "messageNewFileError": m14,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("Новый пароль"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "Новый пароль сохранен в буфер обмена"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("Доступна новая версия."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Перед добавлением файлов вам нужно создать хранилище"),
        "messageNoRepoIsSelected":
            MessageLookupByLibrary.simpleMessage("Хранилище не выбрано"),
        "messageNoRepos": MessageLookupByLibrary.simpleMessage(
            "Не найдено ни одного хранилища"),
        "messageNone": MessageLookupByLibrary.simpleMessage("Ни одного"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Пока что тут пусто!"),
        "messageOpenFileError": m15,
        "messageOr": MessageLookupByLibrary.simpleMessage("Или"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Пароль"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Пароль сохранен у буфер обмена"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Обмен между пирами"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("Это разрешение необходимо"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Это хранилище доступно только для <bold>чтения</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Изменения невозможны, только доступ к контенту"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Не забудьте надежно сохранить ваш пароль; если вы его забудете, восстановить его не удастся."),
        "messageRemovaLocalPassword":
            MessageLookupByLibrary.simpleMessage("Удалить локальный пароль"),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage("Удалить вход по биометрии"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Улалить биометрию"),
        "messageRemoveBiometricsConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Вы уверены что хотите удалить биометрию?"),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("<удалено>"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Переименовать файл"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Переименовать папку"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Переименовать хранилище"),
        "messageReplaceExistingFile":
            MessageLookupByLibrary.simpleMessage("Заменить существующий файл"),
        "messageRepoAuthFailed":
            MessageLookupByLibrary.simpleMessage("Ошибка входа в хранилище"),
        "messageRepoDeletionErrorDescription": m16,
        "messageRepoDeletionFailed":
            MessageLookupByLibrary.simpleMessage("Ошибка удаления хранилища"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "Хранилище тут больше не находится"),
        "messageRepoMissingErrorDescription": m17,
        "messageRepositoryAccessMode": m18,
        "messageRepositoryAlreadyExist": m19,
        "messageRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Текущий пароль"),
        "messageRepositoryIsNotOpen":
            MessageLookupByLibrary.simpleMessage("Хранилище не открыто"),
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Дайте имя хранилищу"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Новое имя хранилища"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("Новый пароль"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Пароль"),
        "messageRepositorySuggestedName": m20,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Скопируйте ссылку сюда"),
        "messageSaveLogFile":
            MessageLookupByLibrary.simpleMessage("Сохранить лог"),
        "messageSaveToLocation":
            MessageLookupByLibrary.simpleMessage("Сохранить файл в эту папку"),
        "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
            "Хотите сохранить текущие изменения?"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Просканируйте это с помощью вашего второго устройства или поделитесь с вашими пирами"),
        "messageSecureUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Защищено биометрией"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Выберите вид доступа чтобы создать ссылку для раздачи"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Выбрать местоположение"),
        "messageSettingsRuntimeID":
            MessageLookupByLibrary.simpleMessage("ID текущей сессии"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "Вы должны сначала выбрать уровень доступа перед созданием ссылки для хранилища"),
        "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
            "Поделиться с помощью QR кода"),
        "messageStorage": MessageLookupByLibrary.simpleMessage("Память"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "Требуется чтобы дать доступ к файлам"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Синхронизировать используя мобильные данные"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Синхронизация выключена при использовании мобильных данных"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Токен хранилища скопирован в буфер обмена."),
        "messageUnlockRepoFailed":
            MessageLookupByLibrary.simpleMessage("Пароль не открыл хранилище"),
        "messageUnlockRepoOk": m21,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Введите пароль чтобы разблокировать"),
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Открыть с помощью биометрии"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "У вас есть несохраненные изменения.\n\nВы хотите отменить их?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("ВПН"),
        "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Подтвердить локальный пароль"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Выбор детализации логов"),
        "messageView": MessageLookupByLibrary.simpleMessage("Посмотреть"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Полный доступ. Вашр пиры могут и просматривать, и изменять содержимое"),
        "messageWritingFileCanceled": m22,
        "messageWritingFileError": m23,
        "messsageFailedAddRepository": m24,
        "messsageFailedCreateRepository": m25,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Изменить пароль"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Скопировать пароль"),
        "replacementAccess": m26,
        "replacementChanges": m27,
        "replacementEntry": m28,
        "replacementName": m29,
        "replacementNumber": m30,
        "replacementPath": m31,
        "replacementStatus": m32,
        "statusSync": MessageLookupByLibrary.simpleMessage("СИНХРОНИЗИРОВАНО"),
        "statusUnspecified": MessageLookupByLibrary.simpleMessage("Не указано"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("О приложении"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Добавить файл в Ouisync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Импортировать хранилище с помощью токена"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Импортировать хранилище"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Требуется разрешение"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Изменить пароль"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Создать папку"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Создать новое хранилище"),
        "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Удалить файл"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Удалить папку"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Удалить не пустую папку"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Удалить хранилище"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Путь загрузок"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Скачать на устройство"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Изменить хранилище"),
        "titleFAQShort": MessageLookupByLibrary.simpleMessage("FAQ"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("Информация о файле"),
        "titleFileExtensionChanged":
            MessageLookupByLibrary.simpleMessage("Изменено расширение файла"),
        "titleFileExtensionMissing":
            MessageLookupByLibrary.simpleMessage("Не хватает расширения файла"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Добавить"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Информация о папке"),
        "titleIssueTracker":
            MessageLookupByLibrary.simpleMessage("Трекер проблем"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Заблокировать все хранилища"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Логи"),
        "titleMovingEntry": MessageLookupByLibrary.simpleMessage("Переместить"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
        "titleOurValues": MessageLookupByLibrary.simpleMessage("Наши ценности"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Удалить биометрию"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Ваши хранилища"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Хранилище"),
        "titleRepositoryName":
            MessageLookupByLibrary.simpleMessage("Название хранилища"),
        "titleRequiredPermission":
            MessageLookupByLibrary.simpleMessage("Требуется разрешение"),
        "titleSaveChanges":
            MessageLookupByLibrary.simpleMessage("Сохранить изменения"),
        "titleScanRepoQR": MessageLookupByLibrary.simpleMessage(
            "Сканировать QR-код хранилища"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Безопасность"),
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("Отправить фидбек"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("Поставить пароль для"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "titleShareRepository": m33,
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Анализ состояния"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Разблокировать хранилише"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Изменения не сохранены"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Папка")
      };
}
