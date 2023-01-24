// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uk locale. All the
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
  String get localeName => 'uk';

  static String m0(access) =>
      "Дозвіл не може бути вищим за поточний режим доступу до сховища: ${access}";

  static String m1(name) =>
      "Додано біометричну валідацію для репозиторію \"${name}\"";

  static String m2(name) => "${name} - завантаження скасовано";

  static String m3(name) => "${name} - не вдалося завантажити";

  static String m4(entry) => "${entry} вже існує.";

  static String m5(path) =>
      "Поточна папка відсутня, перехід до її батьківської: ${path}";

  static String m6(name) => "Не вдалося ініціалізувати сховище ${name}";

  static String m7(path) => "${path} не порожній";

  static String m8(name) => "Теку успішно видалено: ${name}";

  static String m9(number) =>
      "Ви хочете заблокувати всі відкриті репозиторії?\n\n(${number} відкритих)";

  static String m10(path) => "з ${path}";

  static String m11(name) => "Помилка створення файлу ${name}";

  static String m12(name) => "Ми не змогли видалити репозиторій \"${name}\"";

  static String m13(name) =>
      "Не вдалося знайти репозиторій \"${name}\" за звичним місцем розташування";

  static String m14(access) => "Режим доступу: ${access}";

  static String m15(name) =>
      "Цей репозиторій вже існує в додатку під назвою \"${name}\".";

  static String m16(name) =>
      "Запропоновано: ${name}\n(натисніть тут, щоб використовувати цю назву)";

  static String m17(changes) => "Збереження наступних змін:\n\n${changes}";

  static String m18(access) => "Розблоковано як ${access} копія";

  static String m19(name) => "${name} запис скасовано";

  static String m20(name) => "${name} - не вдалося записати";

  static String m21(name) => "Не вдалося додати репозиторій ${name}";

  static String m22(name) => "Не вдалося створити репозиторій ${name}";

  static String m23(access) => "${access}";

  static String m24(changes) => "${changes}";

  static String m25(entry) => "${entry}";

  static String m26(name) => "${name}";

  static String m27(number) => "${number}";

  static String m28(path) => "${path}";

  static String m29(status) => "${status}";

  static String m30(name) => "Поділитися репозиторієм \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Прийняти"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ПРИЙНЯТИ"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Додати сховище"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Додати поширене сховище"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Відмінити"),
        "actionCancelCapital":
            MessageLookupByLibrary.simpleMessage("СКАСУВАТИ"),
        "actionClear": MessageLookupByLibrary.simpleMessage("Очистити"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("ЗАКРИТИ"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Створити"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Створити нове сховище"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Видалити"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("ВИДАЛИТИ"),
        "actionDeleteFile":
            MessageLookupByLibrary.simpleMessage("Видалити файл"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Видалити теку"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Видалити сховище"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("Відхилити"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Змінити назву"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Вихід"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Сховати"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("ПРИХОВАТИ"),
        "actionLockCapital":
            MessageLookupByLibrary.simpleMessage("ЗАБЛОКУВАТИ"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Перемістити"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Додати файл"),
        "actionNewFolder":
            MessageLookupByLibrary.simpleMessage("Створити теку"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Створити сховище"),
        "actionOK": MessageLookupByLibrary.simpleMessage("ОК"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Попередній перегляд файлу"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Перезавантажити"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Перезавантажити сховище"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Видалити"),
        "actionRemoveRepo":
            MessageLookupByLibrary.simpleMessage("Видалити сховище"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Перейменувати"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Повторити спробу"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Зберегти"),
        "actionSaveChanges":
            MessageLookupByLibrary.simpleMessage("Зберегти зміни"),
        "actionScanQR":
            MessageLookupByLibrary.simpleMessage("Сканувати QR-код"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Поділитися"),
        "actionShareFile":
            MessageLookupByLibrary.simpleMessage("Поділитися файлом"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Показати"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Розблокувати"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Режим доступу"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Додати існуюче сховище"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Створити нове сховище"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Видалити"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("Завантажити"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Інформація"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Перемістити"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Перегляд"),
        "iconRename": MessageLookupByLibrary.simpleMessage("Перейменувати"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Поділитися"),
        "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
            "Поділіться цим зі своїм вузлом"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("Версія додатка"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelCopyLink":
            MessageLookupByLibrary.simpleMessage("Скопіювати посилання"),
        "labelDestination":
            MessageLookupByLibrary.simpleMessage("Місце призначення"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Завантажено в:"),
        "labelEndpoint":
            MessageLookupByLibrary.simpleMessage("Кінцева точка: "),
        "labelLocation":
            MessageLookupByLibrary.simpleMessage("Місце розташування: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Заблокувати все"),
        "labelName": MessageLookupByLibrary.simpleMessage("Назва: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Нова назва: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Пароль: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Вузли"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("QR-код"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Введіть нову назву: "),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("Посилання на репозиторій: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("Повторіть пароль: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("Вибрати репозиторій "),
        "labelSetPermission":
            MessageLookupByLibrary.simpleMessage("Встановити дозвіл"),
        "labelShareLink":
            MessageLookupByLibrary.simpleMessage("Поділіться посиланням"),
        "labelSize": MessageLookupByLibrary.simpleMessage("Розмір: "),
        "labelSyncStatus":
            MessageLookupByLibrary.simpleMessage("Стан Синхронізації: "),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("Посилання на репозиторій"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Введіть пароль: "),
        "labelUseExternalStorage": MessageLookupByLibrary.simpleMessage(
            "Використовувати зовнішній накопичувач"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("Не маж медіа файлів."),
        "messageAccessModeDisabled": m0,
        "messageAck": MessageLookupByLibrary.simpleMessage("Ак!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Не доступно для сховищ в режимі читання"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Додати сховище за допомогою токен-посилання"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Додати сховище за допомогою QR-коду"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Це сховище заблоковано або є сліпою копією.\n\nЯкщо у вас є пароль, розблокуйте його та спробуйте ще раз."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Цей репозиторій доступний тільки для читання."),
        "messageAlertSaveCopyPassword": MessageLookupByLibrary.simpleMessage(
            "Якщо ви знімете біометричну перевірку, після виходу з цього екрану ви більше не зможете побачити або скопіювати пароль; будь ласка, збережіть його в надійному місці."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Незабаром операційна система запитає у вас дозвіл на виконання цієї програми у фоновому режимі.\n\nЦе необхідно для того, щоб продовжувати синхронізацію, коли програма не знаходиться на передньому плані"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("OuiSync працює"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Біометричну перевірку скасовано"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Ваш вузол не може ні писати, ні читати зміст"),
        "messageBlindRepository":
            MessageLookupByLibrary.simpleMessage("Це сховище є сліпою копією."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "Наданий <bold>пароль</bold> не надає вам доступу до перегляду вмісту цього репозиторію."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Зміна розширення файлу може зробити його непридатним для використання"),
        "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
            "Ви дійсно хочете видалити цей файл?"),
        "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
            "Ви впевнені, що хочете видалити цю папку?"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Ця папка не порожня.\n\nВи все ще хочете її видалити? (при цьому буде видалено весь її вміст)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Ви впевнені, що хочете видалити цей репозиторій?"),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Створіть нову <bold>папку</bold>, або додайте <bold>файл</bold>, використовуючи <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Створіть новий <bold>репозиторій</bold>, або посилайтеся на репозиторій друга за допомогою <bold>токена репозиторію</bold>"),
        "messageCreatingToken":
            MessageLookupByLibrary.simpleMessage("Створення токену…"),
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Ця <bold>папка</bold> порожня"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "Цей <bold>репозиторій</bold> порожній"),
        "messageEntryAlreadyExist": m4,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("Запис"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage("Папка"),
        "messageError": MessageLookupByLibrary.simpleMessage("Помилка!"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "Виникла помилка автентифікації за допомогою біометричних даних. Будь ласка, спробуйте ще раз"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "Виникла проблема зі зміною пароля. Будь ласка, спробуйте ще раз"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Використання \\ або / не допускається"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Помилка при створенні репозиторію"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Помилка при створенні токена."),
        "messageErrorCurrentPathMissing": m5,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Щось пішло не так. Будь ласка, спробуйте ще раз."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Невдало."),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("запис не знайдено"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage(
                "Будь ласка, введіть дійсну назву."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "Не вдалося завантажити вміст цієї папки. Будь ласка, спробуйте ще раз."),
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "Новий пароль збігається зі старим паролем"),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Помилка при відкритті сховища"),
        "messageErrorOpeningRepoDescription": m6,
        "messageErrorPathNotEmpty": m7,
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "Репозиторій з такою назвою вже існує"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("Будь ласка, введіть пароль."),
        "messageErrorRetypePassword":
            MessageLookupByLibrary.simpleMessage("Паролі не збігаються."),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Будь ласка, введіть токен."),
        "messageErrorTokenInvalid":
            MessageLookupByLibrary.simpleMessage("Цей токен недійсний."),
        "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
            "Будь ласка, введіть дійсний токен."),
        "messageErrorUnhandledState":
            MessageLookupByLibrary.simpleMessage("Помилка: необроблений стан"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "Натисніть ще раз, щоб вийти."),
        "messageFile": MessageLookupByLibrary.simpleMessage("файл"),
        "messageFileIsDownloading":
            MessageLookupByLibrary.simpleMessage("Файл завантажується"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("Назва файлу"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Попередній перегляд файлу ще не доступний"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("файли"),
        "messageFolderDeleted": m8,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Назва папки"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Згенерувати пароль"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Ініціалізація…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Натисніть на кнопку <bold>Розблокувати</bold> та введіть пароль для доступу до контенту в цьому репозиторію."),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Виявлено внутрішній збій."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Завантаження…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Локальне відкриття"),
        "messageLockOpenRepos": m9,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Цей <bold>репозиторій</bold> заблоковано."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Блокування всіх відкритих сховищ…"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("Все"),
        "messageLogLevelErroWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage(
                "Помилки, попередження, інформація та дебаг"),
        "messageLogLevelError":
            MessageLookupByLibrary.simpleMessage("Тільки помилки"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("Помилки та попередження"),
        "messageLogLevelErrorWarnInfo": MessageLookupByLibrary.simpleMessage(
            "Помилки, попередження та інформація"),
        "messageLogViewer":
            MessageLookupByLibrary.simpleMessage("Перегляд логів"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Телефон"),
        "messageMoveEntryOrigin": m10,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Ця функція недоступна при переміщенні запису."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Тип NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Мережа недоступна"),
        "messageNewFileError": m11,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("Новий пароль"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "Новий пароль скопійовано до буфера обміну"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("Доступна нова версія."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Перед додаванням файлів, вам необхідно створити репозиторій"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("Репозиторії не знайдено"),
        "messageNone": MessageLookupByLibrary.simpleMessage("Немає"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Тут ще нічого немає!"),
        "messageOr": MessageLookupByLibrary.simpleMessage("Або"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Пароль"),
        "messagePasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage("Пароль скопійовано"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Обмін вузлів"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Цей репозиторій <bold>тільки для читання</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Не можна змінювати, тільки доступ до вмісту"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Не забувайте надійно зберігати пароль, адже якщо ви його забудете, відновити його буде неможливо."),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage(
                "Прибрати біометричну перевірку"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Видалити біометричні дані"),
        "messageRemoveBiometricsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Ви впевнені, що хочете видалити біометричні дані з цього сховища?"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Перейменувати файл"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Перейменувати папку"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Перейменувати репозиторій"),
        "messageRepoDeletionErrorDescription": m12,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "Видалення сховища не вдалося"),
        "messageRepoMissing":
            MessageLookupByLibrary.simpleMessage("Сховища більше не існує"),
        "messageRepoMissingErrorDescription": m13,
        "messageRepositoryAccessMode": m14,
        "messageRepositoryAlreadyExist": m15,
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Дайте репозиторію назву"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Нова назва репозиторію"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("Новий пароль"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Пароль"),
        "messageRepositorySuggestedName": m16,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Вставте посилання сюди"),
        "messageSaveToLocation":
            MessageLookupByLibrary.simpleMessage("Зберегти файл в цю папку"),
        "messageSavingChanges": m17,
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Відскануйте його на іншому пристрої або поділіться ним з вузлами"),
        "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "Безпека за допомогою біометрії"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Виберіть дозвіл на створення спільного посилання"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Виберіть шлях"),
        "messageSettingsRuntimeID":
            MessageLookupByLibrary.simpleMessage("Ідентифікатор виконання"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "Для створення посилання на сховище спочатку потрібно вибрати один дозвіл"),
        "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
            "Поширити за допомогою QR коду"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Синхронізація під час використання мобільних даних"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Синхронізація вимкнена під час користування мобільним інтернетом"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Токен репозиторію скопійовано в буфер обміну."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "Пароль не розблокував сховище"),
        "messageUnlockRepoOk": m18,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Введіть пароль для розблокування"),
        "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "Розблокувати за допомогою біометричних даних"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "У вас є незбережені зміни.\n\nВи хочете їх скасувати?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("ВПН"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Багатослівність журналу"),
        "messageView": MessageLookupByLibrary.simpleMessage("Переглянути"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Повний доступ. Ваш вузол може читати і писати"),
        "messageWritingFileCanceled": m19,
        "messageWritingFileError": m20,
        "messsageFailedAddRepository": m21,
        "messsageFailedCreateRepository": m22,
        "replacementAccess": m23,
        "replacementChanges": m24,
        "replacementEntry": m25,
        "replacementName": m26,
        "replacementNumber": m27,
        "replacementPath": m28,
        "replacementStatus": m29,
        "statusSync": MessageLookupByLibrary.simpleMessage("СИНХРОНІЗОВАНО"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("Не визначено"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("Про нас"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Додати файл до OuiSync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Додати репозиторій з токеном"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Додати репозиторій"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Необхідні дозволи"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Змінити пароль"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Створити папку"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Створити новий репозиторій"),
        "titleDeleteFile":
            MessageLookupByLibrary.simpleMessage("Видалити файл"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Видалити папку"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Видалити непорожню папку"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Видалити репозиторій"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Розташування завантаження"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Завантажити на пристрій"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Редагувати репозиторій"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("Подробиці файлу"),
        "titleFileExtensionChanged":
            MessageLookupByLibrary.simpleMessage("Розширення файлу змінено"),
        "titleFileExtensionMissing":
            MessageLookupByLibrary.simpleMessage("Розширення файлу відсутнє"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Створити"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Подробиці папки"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Заблокувати всі репозиторії"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Журнали"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Переміщення входу"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Мережа"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Видалити біометричні дані"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Ваші репозиторії"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Репозиторій"),
        "titleRepositoryName":
            MessageLookupByLibrary.simpleMessage("Ім\'я репозиторію"),
        "titleSaveChanges":
            MessageLookupByLibrary.simpleMessage("Зберегти зміни"),
        "titleScanRepoQR": MessageLookupByLibrary.simpleMessage(
            "Сканувати QR-код Репозиторію"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Безпека"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("Встановіть пароль для"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Налаштування"),
        "titleShareRepository": m30,
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Моніторинг статусу"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Розблокувати репозиторій"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Незбережені зміни"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Папка")
      };
}
