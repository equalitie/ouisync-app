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

  static String m6(dokanUrl) =>
      "Відсутня інсталяція Dokan. Будь ласка, встановіть його з ${dokanUrl}";

  static String m7(name) => "Не вдалося ініціалізувати репозиторій ${name}";

  static String m8(path) => "${path} не порожній";

  static String m9(reason) => "Не вдалося встановити: ${reason}";

  static String m10(name) =>
      "${name} вже існують у цій локації.\n\nЩо ви хочете зробити?";

  static String m11(name) => "Теку успішно видалено: ${name}";

  static String m12(number) =>
      "Ви хочете заблокувати всі відкриті репозиторії?\n\n(${number} відкритих)";

  static String m13(path) => "з ${path}";

  static String m14(name) => "Помилка створення файлу ${name}";

  static String m15(name) => "Помилка відкриття файлу ${name}";

  static String m17(name) => "Ми не змогли видалити репозиторій \"${name}\"";

  static String m18(name) =>
      "Не вдалося знайти репозиторій \"${name}\" за звичним місцем розташування";

  static String m19(access) => "Режим доступу: ${access}";

  static String m20(name) =>
      "Цей репозиторій вже існує в застосунку під назвою \"${name}\".";

  static String m21(name) =>
      "Запропоновано: ${name}\n(натисніть тут, щоб використовувати цю назву)";

  static String m22(access) => "Розблоковано як ${access} копія";

  static String m23(name) => "${name} запис скасовано";

  static String m24(name) => "${name} - не вдалося записати";

  static String m25(name) => "Не вдалося імпортувати репозиторій ${name}";

  static String m26(name) => "Не вдалося створити репозиторій ${name}";

  static String m27(access) => "${access}";

  static String m28(changes) => "${changes}";

  static String m29(entry) => "${entry}";

  static String m30(name) => "${name}";

  static String m31(number) => "${number}";

  static String m32(path) => "${path}";

  static String m33(status) => "${status}";

  static String m34(name) => "Поділитися репозиторієм \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Прийняти"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ПРИЙНЯТИ"),
        "actionAdd": MessageLookupByLibrary.simpleMessage("Додати"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Імпортувати репозиторій"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Імпортувати репозиторій"),
        "actionBack": MessageLookupByLibrary.simpleMessage("Повернутися"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Відмінити"),
        "actionCancelCapital":
            MessageLookupByLibrary.simpleMessage("СКАСУВАТИ"),
        "actionClear": MessageLookupByLibrary.simpleMessage("Очистити"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("ЗАКРИТИ"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Створити"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Створити репозиторій"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Видалити"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("ВИДАЛИТИ"),
        "actionDeleteFile":
            MessageLookupByLibrary.simpleMessage("Видалити файл"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Видалити теку"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Видалити репозиторій"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("Відхилити"),
        "actionDone": MessageLookupByLibrary.simpleMessage("Завершено"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Змінити назву"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Вихід"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Перейти до налаштувань"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Сховати"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("ПРИХОВАТИ"),
        "actionIAgree": MessageLookupByLibrary.simpleMessage("Я згоден/згодна"),
        "actionIDontAgree":
            MessageLookupByLibrary.simpleMessage("Я не згодний/згодна"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Імпортувати"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Імпортувати репозиторій"),
        "actionLockCapital":
            MessageLookupByLibrary.simpleMessage("ЗАБЛОКУВАТИ"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Перемістити"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Папка"),
        "actionNewRepo":
            MessageLookupByLibrary.simpleMessage("Створити репозиторій"),
        "actionNext": MessageLookupByLibrary.simpleMessage("Наступний"),
        "actionNo": MessageLookupByLibrary.simpleMessage("Ні"),
        "actionOK": MessageLookupByLibrary.simpleMessage("ОК"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Попередній перегляд файлу"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Перезавантажити"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Перезавантажити репозиторій"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Видалити"),
        "actionRemoveLocalPassword":
            MessageLookupByLibrary.simpleMessage("Видалити локальний пароль"),
        "actionRemoveRepo":
            MessageLookupByLibrary.simpleMessage("Видалити репозиторій"),
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
        "actionSkip": MessageLookupByLibrary.simpleMessage("Пропустити"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Відмінити"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Розблокувати"),
        "actionUpdate": MessageLookupByLibrary.simpleMessage("Оновити"),
        "actionYes": MessageLookupByLibrary.simpleMessage("Так"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Режим доступу"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Імпортувати репозиторій"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Створити новий репозиторій"),
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
            MessageLookupByLibrary.simpleMessage("Версія застосунку"),
        "labelAttachLogs": MessageLookupByLibrary.simpleMessage("Додайте логи"),
        "labelBitTorrentDHT":
            MessageLookupByLibrary.simpleMessage("BitTorrent DHT"),
        "labelConnectionType":
            MessageLookupByLibrary.simpleMessage("Тип підключення"),
        "labelCopyLink":
            MessageLookupByLibrary.simpleMessage("Скопіювати посилання"),
        "labelDestination":
            MessageLookupByLibrary.simpleMessage("Місце призначення"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Завантажено в:"),
        "labelEndpoint":
            MessageLookupByLibrary.simpleMessage("Кінцева точка: "),
        "labelInternalIP":
            MessageLookupByLibrary.simpleMessage("Внутрішня ІP-адреса"),
        "labelLocalIPv4":
            MessageLookupByLibrary.simpleMessage("Локальний IPv4"),
        "labelLocalIPv6":
            MessageLookupByLibrary.simpleMessage("Локальний IPv6"),
        "labelLocation":
            MessageLookupByLibrary.simpleMessage("Місце розташування: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Заблокувати все"),
        "labelName": MessageLookupByLibrary.simpleMessage("Назва: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Нова назва: "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Пароль: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Вузли"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("QR-код"),
        "labelQuicListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
            "Прослуховування за протоколом QUIC/UDP IPv4"),
        "labelQuicListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
            "Прослуховування за протоколом QUIC/UDP IPv6"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Введіть нову назву: "),
        "labelRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Поточний пароль"),
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
        "labelTcpListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
            "Прослуховування за протоколом TCP IPv4"),
        "labelTcpListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
            "Прослуховування за протоколом TCP IPv6"),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("Посилання на репозиторій"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Введіть пароль: "),
        "labelUseExternalStorage": MessageLookupByLibrary.simpleMessage(
            "Використовувати зовнішній накопичувач"),
        "menuItemAbout": MessageLookupByLibrary.simpleMessage("Про нас"),
        "menuItemLogs": MessageLookupByLibrary.simpleMessage("Журнали"),
        "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Мережа"),
        "menuItemRepository":
            MessageLookupByLibrary.simpleMessage("Репозиторій"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("Не маж медіа файлів."),
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "Доступ до захищеного сховища"),
        "messageAck": MessageLookupByLibrary.simpleMessage("Ак!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Не доступно для сховищ в режимі читання"),
        "messageAddLocalPassword":
            MessageLookupByLibrary.simpleMessage("Додати локальний пароль"),
        "messageAddLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Додати локальний пароль до цього сховища?"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Імпортувати репозиторій за допомогою токен-посилання"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Імпортувати репозиторій за допомогою QR-коду"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Цей репозиторій заблоковано або є сліпою копією.\n\nЯкщо у вас є пароль, розблокуйте його та спробуйте ще раз."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Цей репозиторій доступний тільки для читання."),
        "messageAvailableOnMobile": MessageLookupByLibrary.simpleMessage(
            "Доступно на мобільних пристроях"),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Незабаром операційна система запитає у вас дозвіл на виконання цієї програми у фоновому режимі.\n\nЦе необхідно для того, щоб продовжувати синхронізацію, коли програма не знаходиться на передньому плані"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("працює"),
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Не вдалося виконати біометричну аутентифікацію"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Біометричну перевірку скасовано"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Ваш вузол не може ні писати, ні читати зміст"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "Цей репозиторій є сліпою копією."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "Наданий <bold>пароль</bold> не надає вам доступу до перегляду вмісту цього репозиторію."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
        "messageBy": MessageLookupByLibrary.simpleMessage("надано"),
        "messageCamera": MessageLookupByLibrary.simpleMessage("Камера"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "Нам потрібен цей дозвіл для використання камери та зчитування QR-коду"),
        "messageCanadaPrivacyAct": MessageLookupByLibrary.simpleMessage(
            "Закон Канади про конфіденційність"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Зміна розширення файлу може зробити його непридатним для використання"),
        "messageChangeLocalPassword":
            MessageLookupByLibrary.simpleMessage("Змінити локальний пароль"),
        "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
            "Ми можемо час від часу оновлювати наші Умови. Тому радимо вам періодично переглядати цю сторінку на предмет будь-яких змін"),
        "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
            "Поточна версія політики конфідеційності діє з 09 березня 2022 року"),
        "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
            "Ми свідомо не збираємо особисту інформацію від дітей. Ми закликаємо всіх дітей ніколи не надавати будь-яку особисту інформацію через Застосунок та/або Сервіси. Ми закликаємо батьків та законних опікунів контролювати використання інтернету їхніми дітьми та сприяти дотриманню цієї Політики, проінструктувавши своїх дітей ніколи не надавати особисту інформацію через Застосунок та/або Сервіси без їхнього дозволу. Якщо у вас є підстави вважати, що дитина надала нам особисту інформацію через Застосунок та/або Сервіси, будь ласка, зв\'яжіться з нами. Ви також повинні бути не молодше 16 років, щоб дати згоду на обробку вашої особистої інформації у вашій країні (у деяких країнах ми можемо дозволити вашим батькам або опікунам зробити це від вашого імені)"),
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
        "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
            "Якщо у вас виникли запитання або пропозиції щодо нашої Політики конфіденційності, будь ласка, зв\'яжіться з нами за адресою"),
        "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
            "Застосунок Ouisync не використовує файли-куки"),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Створіть нову <bold>папку</bold>, або додайте <bold>файл</bold>, використовуючи <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Створіть новий <bold>репозиторій</bold>, або посилайтеся на репозиторій друга за допомогою <bold>токена репозиторію</bold>"),
        "messageCreatingToken":
            MessageLookupByLibrary.simpleMessage("Створення токену…"),
        "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
            "Команда Ouisync цінує конфіденційність користувачів і тому не збирає жодної інформації про користувачів"),
        "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
            "Застосунок Ouisync розроблений таким чином, щоб надавати послуги обміну файлами без ідентифікатора користувача, імені, псевдоніма, облікового запису користувача або будь-якої іншої форми даних користувача. Ми не знаємо, хто саме користується нашим застосунком і з ким вони синхронізуються або обмінюються своїми даними"),
        "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
            "Ouisync (та eQualit.ie) не передають жодних даних третім особам"),
        "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
            "Декларацією про розподілені онлайн-послуги"),
        "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
            "Команда Ouisync не може видаляти окремі файли зі сховищ, оскільки їх неможливо ідентифікувати, оскільки вони зашифровані. Ми можемо видаляти цілі сховища, якщо ви надішлете нам посилання на сховище, яке потрібно видалити"),
        "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
            "Найпростіший спосіб видалити дані - це видалити файли або сховища зі свого пристрою. Будь-яке видалення файлів буде поширене на всіх ваших колег - тобто, якщо ви маєте доступ на запис до сховища, ви можете видалити будь-які файли в ньому, і ті ж самі файли будуть видалені зі сховищ ваших колег, а також з нашого серверу Always-On-Peer. Якщо вам потрібно видалити лише репозиторії з нашого сервера Always-On-Peer (але зберегти їх у вашому власному репозиторії на вашому пристрої), будь ласка, зв\'яжіться з нами за вказаною нижче адресою"),
        "messageDistributedHashTables":
            MessageLookupByLibrary.simpleMessage("Розподілені хеш-таблиці"),
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
        "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
            "Основні права та основоположні свободи є невід\'ємними, невідчужуваними і застосовуються однаково до всіх. Права людини є універсальними; вони захищені міжнародним правом і закріплені в "),
        "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
            "Як організація, ми прагнемо бути прозорими у своїй політиці та процедурах. Наскільки це можливо, наш вихідний код є відкритим і у вільному доступі, з відповідними ліцензіями, які заохочують розробку, обмін і поширення цих принципів, якими керує спільнота"),
        "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
            "Можливість вільно висловлювати свою думку та мати доступ до публічної інформації є основою дієвої демократії. Публічна інформація має бути суспільним надбанням. Свобода вираження поглядів передбачає активні дебати, навіть аргументи, які невміло сформульовані, погано побудовані та можуть вважатися образливими для когось. Однак свобода вираження поглядів не є абсолютним правом. Ми рішуче виступаємо проти насильства та підбурювання до порушення прав інших, особливо проти пропаганди насильства, ненависті, дискримінації та безправ\'я будь-якої ідентифікованої етнічної чи соціальної групи"),
        "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
            "Ми працюємо в різних країнах і походимо з різних соціальних верств. Ми об\'єднуємо свої зусилля аби створити суспільство, де будуть поважати та захищати права інших у фізичному та цифровому світі. Всесвітня декларація прав людини формулює перелік прав людини, що заохочує нас в роботі; ми віримо, що люди мають право та обов\'язок захищати ці права"),
        "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
            "Ми розуміємо, що наші інструменти та послуги можуть бути використані всупереч цим принципам і нашим умовам надання послуг, і ми рішуче й активно засуджуємо та забороняємо таке використання. Ми не дозволяємо використовувати наше програмне забезпечення та послуги для сприяння здійсненню незаконної діяльності, а також не будемо сприяти поширенню мови ненависті або пропаганді насильства в інтернеті"),
        "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
            "Ми запровадили заходи безпеки, щоб запобігти неправомірному використанню наших продуктів і послуг. Коли нам стає відомо про будь-яке використання, що порушує наші принципи або умови надання послуг, ми вживаємо заходів для припинення надання цих послуг. Керуючись нашими внутрішніми правилами, ми ретельно обмірковуємо дії, які можуть скомпрометувати наші принципи. Наші процедури й надалі будуть розвиватися на основі досвіду та найкращих практик, щоб ми могли досягти правильного балансу між забезпеченням відкритого доступу до наших продуктів і послуг та дотриманням наших принципів"),
        "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
            "Сміливі люди ризикують життям і свободою, щоб захищати права людини, мобілізувати, критикувати і викривати винуватців зловживань. Сміливі люди висловлюють підтримку іншим, ідеям та розповідають про свої проблеми світові. Ці відважні люди реалізують свої права людини онлайн"),
        "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
            "Інтернет - це платформа для вільного вираження поглядів і самовизначення. Як і будь-який інструмент комунікації, інтернет не застрахований від цензури, стеження, атак і спроб державних суб\'єктів і злочинних угруповань змусити замовкнути голоси дисидентів. Коли демократичне вираження поглядів криміналізується, коли існує етнічна та політична дискримінація, Інтернет стає ще одним полем битви для ненасильницького опору"),
        "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
            "Наша місія полягає у просуванні та захисті фундаментальних свобод і прав людини, включаючи вільне поширення інформації в інтернеті. Наша мета - створити доступні технології та вдосконалити навички користувачів, необхідні для захисту прав і свобод людини в цифрову епоху"),
        "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
            "Ми прагнемо навчати та підвищувати спроможність наших цільових аудиторій безпечною взаємодіяти в цифровому просторі. Ми досягаємо цієї мети через створення інструментів, які уможливлюють і захищають свободу вираження поглядів, обходять цензуру, розширюють можливості анонімності та захищають від стеження. Наші інструменти також покращують управління інформацією та передбачають аналітичні функції"),
        "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
            "Ми є міжнародною спільнотою активістів різного походження та переконань, які об\'єдналися, щоб захищати спільні для нас принципи. Ми – розробники програмного забезпечення, криптографи, фахівці з безпеки, а також педагоги, соціологи, історики, антропологи та журналісти. Ми розробляємо відкриті та багаторазові інструменти з акцентом на конфіденційності, безпеці в Інтернеті та кращому управлінні інформацією. Ми фінансуємо нашу діяльність за рахунок державних грантів та консультацій з приватним сектором. Ми віримо в інтернет, що є вільним від невиправданого стеження, цензури та утисків"),
        "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
            "Спираючись на Загальну декларацію прав людини, наші принципи поширюються на кожну людину, групу та суспільний інститут, з якими ми працюємо, включно з користувачами програмного забезпечення та послуг, які ми випускаємо. Всі наші проекти розробляються з урахуванням наших принципів. Наші знання, інструменти та послуги доступні цим групам та окремим особам за умови дотримання наших принципів та умов надання послуг"),
        "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
            "Право на недоторканність приватного життя є основоположним правом, яке ми прагнемо захищати завжди і всюди. Конфіденційність даних наших безпосередніх бенефіціарів є основою нашої діяльності. Наші інструменти, послуги та внутрішні політики розроблені з урахуванням принципу конфідеційності даних. Ми використовуємо всі технічні та юридичні ресурси, які є в нашому розпорядженні, аби захистити конфіденційность даних наших бенефіціарів. Будь ласка, ознайомтеся з нашою Політикою конфіденційності та нашими "),
        "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
            "Безпека є постійною складовою усіх наших проектів з розробки програмного забезпечення, надання послуг та розбудови спроможностей організацій. Ми розробляємо наші системи та процеси, щоб покращити інформаційну безпеку в інтернеті та підвищити рівень захищеності користувачів. Ми намагаємося подавати приклад, не ставлячи під загрозу безпеку інструментів заради швидкості, зручності використання або вартості. Ми не віримо в безпеку через невизначеність і підтримуємо прозорість через відкритий доступ до нашого коду. Ми завжди діємо з обережністю і намагаємося впровадити досконалу внутрішню операційну безпеку"),
        "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
            "створений відповідно до наших цінностей.\n\nВикористовуючи його, ви погоджуєтеся дотримуватися цих принципів і приймаєте наші Умови використання та Політику конфіденційності."),
        "messageError": MessageLookupByLibrary.simpleMessage("Помилка!"),
        "messageErrorAddingLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Не вдалося додати локальний пароль"),
        "messageErrorAddingSecureStorge": MessageLookupByLibrary.simpleMessage(
            "Не вдалося додати локальний пароль"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "Виникла помилка автентифікації за допомогою біометричних даних. Будь ласка, спробуйте ще раз"),
        "messageErrorChangingLocalPassword":
            MessageLookupByLibrary.simpleMessage(
                "Не вдалося змінити локальний пароль"),
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
        "messageErrorDokanNotInstalled": m6,
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
        "messageErrorOpeningRepoDescription": m7,
        "messageErrorPathNotEmpty": m8,
        "messageErrorRemovingPassword":
            MessageLookupByLibrary.simpleMessage("Не вдалося видалити пароль"),
        "messageErrorRemovingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Не вдалося видалити пароль із захищеного сховища"),
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
        "messageErrorUpdatingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "Не вдалося оновити пароль у захищеному сховищі"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "Натисніть ще раз, щоб вийти."),
        "messageFAQ":
            MessageLookupByLibrary.simpleMessage("Поширені запитання"),
        "messageFailedToMount": m9,
        "messageFile": MessageLookupByLibrary.simpleMessage("файл"),
        "messageFileAlreadyExist": m10,
        "messageFileIsDownloading":
            MessageLookupByLibrary.simpleMessage("Файл завантажується"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("Назва файлу"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Попередній перегляд файлу ще не доступний"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("файли"),
        "messageFolderDeleted": m11,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Назва папки"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Згенерувати пароль"),
        "messageGoToMailApp": MessageLookupByLibrary.simpleMessage(
            "Перейдіть до поштового застосунку"),
        "messageGoToPeers":
            MessageLookupByLibrary.simpleMessage("Перейдіть до колег (peers)"),
        "messageGood": MessageLookupByLibrary.simpleMessage("Хороший"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Дозволено"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Для надання цього дозволу потрібно перейти до налаштувань:\n\n Налаштування > Програми та сповіщення"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Дозволяє програмі продовжувати синхронізацію у фоновому режимі"),
        "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
            "Це інструмент, який дозволяє одноранговим користувачам знаходити один одного в мережі P2P (Peer to Peer) без централізованого сервера"),
        "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
            "Локальне виявлення однорангових мереж дозволяє вашим програмам Ouisync обмінюватися файлами з одноранговими програмами, не звертаючись до інтернет-провайдерів, якщо доступна локальна мережа Wi-Fi або інша мережа.\n\nДля локального підключення цей параметр має бути увімкнено"),
        "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
            "Це значення встановлюється вашим інтернет-провайдером.\n\nНайкращий зв\'язок з одноранговими користувачами досягається, коли для цього параметра вибрано значення Несиметричний"),
        "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
            "Інструмент, який використовується для обміну списком однорангових користувачів з одноранговими користувачами, до яких ви підключені"),
        "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
            "Унікальний ідентифікатор, який генерується Ouisync щоразу під час запуску.\n\nВи можете використовувати його для підтвердження вашого з\'єднання з іншими користувачами в розділі Peer у застосунку"),
        "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Якщо цей параметр увімкнено, ваш мобільний оператор може стягувати плату за дані, використані під час синхронізації сховищ, до яких ви надаєте спільний доступ своїм колегам"),
        "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
            "Це перелік мережевих протоколів, які дозволять вашим програмам Ouisync знаходити один одного та спілкуватися між собою.\n\nДля найкращого зв\'язку рекомендуємо залишити цей параметр увімкненим"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Ініціалізація…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Натисніть на кнопку <bold>Розблокувати</bold> та введіть пароль для доступу до контенту в цьому репозиторію."),
        "messageInternationalBillHumanRights":
            MessageLookupByLibrary.simpleMessage(
                "Загальній декларації прав людини"),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("Зберегти обидва файли"),
        "messageLaunchAtStartup":
            MessageLookupByLibrary.simpleMessage("Початок дії при запуску"),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("Виявлено внутрішній збій."),
        "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
            "Цей Сервіс може містити посилання на інші сайти. Якщо ви натиснете на посилання третьої сторони, вас буде перенаправлено на цей сайт. Зверніть увагу, що ми не керуємо цими зовнішніми сайтами. Тому ми наполегливо рекомендуємо вам ознайомитися з політикою конфіденційності цих сайтів. Ми не контролюємо і не несемо відповідальності за зміст, політику конфіденційності або функціонування будь-яких сторонніх сайтів або послуг"),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Завантаження…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Локальне відкриття"),
        "messageLockOpenRepos": m12,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Цей <bold>репозиторій</bold> заблоковано."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Блокування всіх відкритих сховищ…"),
        "messageLogData1": MessageLookupByLibrary.simpleMessage(
            "Адреса електронної пошти - якщо користувач вирішив зв\'язатися з нами електронною поштою"),
        "messageLogData2": MessageLookupByLibrary.simpleMessage(
            "Інформація, яку користувач може надати електронною поштою, через тікети допомоги або через наш веб-сайт, а також пов\'язані з ним метаданими – з метою надання технічної підтримки"),
        "messageLogData3": MessageLookupByLibrary.simpleMessage(
            "IP-адреса користувача - для надання технічної підтримки"),
        "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
            "Застосунок Ouisync створює лог-файли на пристроях користувачів. Їхньою метою є лише реєстрація активності пристрою для полегшення процесу налагодження (дебагінг), якщо у користувача виникнуть труднощі з підключенням до мережі або інші проблеми з використанням програми Ouisync. Лог-файл залишається на пристрої користувача, якщо користувач не вирішить надіслати його нам для цілей технічної підтримки"),
        "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
            "Якщо користувач вирішить зв\'язатися з нами, ми можемо збирати персональні дані, які не можуть бути визначені:"),
        "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
            "Жодні з цих даних не передаються третім особам"),
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
        "messageMedium":
            MessageLookupByLibrary.simpleMessage("Середньої складності"),
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "Ouisync не має дозволу на роботу у фоновому режимі, відкриття іншої програми може зупинити поточну синхронізацію"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Телефон"),
        "messageMoveEntryOrigin": m13,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Ця функція недоступна при переміщенні запису."),
        "messageNATOnWikipedia": MessageLookupByLibrary.simpleMessage(
            "NAT (переклад мережевих адрес) у Вікіпедії"),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Тип NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Мережа недоступна"),
        "messageNewFileError": m14,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("Новий пароль"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "Новий пароль скопійовано до буфера обміну"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("Доступна нова версія."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Перед додаванням файлів, вам необхідно створити репозиторій"),
        "messageNoRepoIsSelected": MessageLookupByLibrary.simpleMessage(
            "Жодний репозиторій не вибрано"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("Репозиторії не знайдено"),
        "messageNone": MessageLookupByLibrary.simpleMessage("Немає"),
        "messageNote": MessageLookupByLibrary.simpleMessage("Примітка"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Тут ще нічого немає!"),
        "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Діліться файлами на всіх своїх пристроях або з іншими користувачами та створіть власну захищену хмару!"),
        "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Сховища можуть бути доступними для читання і запису, лише для читання або невидимими (ви зберігаєте файли для інших, але не маєте до них доступу)"),
        "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Усі файли та папки, додані до Ouisync, за замовчуванням надійно зашифровані, як під час передачі, так і в режимі очікування."),
        "messageOpenFileError": m15,
        "messageOr": MessageLookupByLibrary.simpleMessage("Або"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePIPEDA": MessageLookupByLibrary.simpleMessage(
            "Закон про захист персональних даних та електронні документи"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Пароль"),
        "messagePasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage("Пароль скопійовано"),
        "messagePasswordStrength":
            MessageLookupByLibrary.simpleMessage("Надійність пароля"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Обмін вузлів"),
        "messagePeerExchangeWikipedia": MessageLookupByLibrary.simpleMessage(
            "Пірінговий обмін у Вікіпедії"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("Цей дозвіл є обов\'язковим"),
        "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
            "Цей розділ призначений для інформування відвідувачів про нашу політику щодо збору, використання та розкриття персональних даних під час використання нашого Сервісу"),
        "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
            "\"Людина народжується вільною, і всюди вона в кайданах\"."),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Цей репозиторій <bold>тільки для читання</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Не можна змінювати, тільки доступ до вмісту"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Не забувайте надійно зберігати пароль, адже якщо ви його забудете, відновити його буде неможливо."),
        "messageRemovaLocalPassword":
            MessageLookupByLibrary.simpleMessage("Видалити локальний пароль"),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage(
                "Прибрати біометричну перевірку"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Видалити біометричні дані"),
        "messageRemoveBiometricsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Видалити перевірку біометричних даних для цього сховища?\n\nСховище буде розблоковано автоматично, якщо не буде додано локальний пароль."),
        "messageRemoveBiometricsConfirmationMoreInfo":
            MessageLookupByLibrary.simpleMessage(
                "Це видалить пароль сховища і використовуватиме біометричну перевірку для розблокування"),
        "messageRemoveLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Видалити локальний пароль цього сховища?\n\nСховище буде розблоковано автоматично, якщо локальний пароль не буде додано знову"),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("<видалено>"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Перейменувати файл"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Перейменувати папку"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Перейменувати репозиторій"),
        "messageReplaceExistingFile":
            MessageLookupByLibrary.simpleMessage("Замінити існуючий файл"),
        "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Не вдалося виконати аутентифікацію сховища"),
        "messageRepoDeletionErrorDescription": m17,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "Видалення сховища не вдалося"),
        "messageRepoMissing":
            MessageLookupByLibrary.simpleMessage("Сховища більше не існує"),
        "messageRepoMissingErrorDescription": m18,
        "messageRepositoryAccessMode": m19,
        "messageRepositoryAlreadyExist": m20,
        "messageRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("Поточний пароль"),
        "messageRepositoryIsNotOpen":
            MessageLookupByLibrary.simpleMessage("Репозиторій не відкритий"),
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Дайте репозиторію назву"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Нова назва репозиторію"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("Новий пароль"),
        "messageRepositoryNotMounted":
            MessageLookupByLibrary.simpleMessage("Репозиторій не змонтовано "),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Пароль"),
        "messageRepositorySuggestedName": m21,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Вставте посилання сюди"),
        "messageRousseau":
            MessageLookupByLibrary.simpleMessage("Жан-Жак Руссо"),
        "messageSaveLogFile":
            MessageLookupByLibrary.simpleMessage("Зберегти файл журналу"),
        "messageSaveToLocation":
            MessageLookupByLibrary.simpleMessage("Зберегти файл в цю папку"),
        "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
            "Ви хочете зберегти поточні зміни?"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Відскануйте його на іншому пристрої або поділіться ним з вузлами"),
        "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "Безпека за допомогою біометрії"),
        "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
            "Дані, які користувач завантажує до сховищ Ouisync, наскрізно шифруються як під час передачі, так і за замовчуванням. Йдеться про метадані, зокрема імена файлів, розміри, структура папок тощо. В Ouisync дані можуть читати лише той, хто їх завантажив, і ті, з ким він поділився своїми сховищами"),
        "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
            "Ви можете дізнатися більше про методи шифрування, що використовуються в нашій документації"),
        "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
            "Додаток Ouisync зберігає дані користувачів на \"Always-On Peer\" - сервері, розташованому в Канаді. Всі дані зберігаються у зашифрованому вигляді і не можуть бути прочитані ні сервером, ні його операторами. Мета цього сервера - просто подолати розриви між одноранговими користувачами, які не перебувають в мережі одночасно. Всі дані періодично видаляються з цього сервера - його метою не є забезпечення постійного зберігання даних, а лише полегшення синхронізації даних між користувачами"),
        "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
            "Якщо у вас є підстави вважати, що ваші персональні дані були незаконно отримані та передані іншим користувачам Ouisync, будь ласка, зв\'яжіться з нами за вказаною нижче адресою"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Виберіть дозвіл на створення спільного посилання"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Виберіть шлях"),
        "messageSettingsRuntimeID":
            MessageLookupByLibrary.simpleMessage("Ідентифікатор виконання"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "Для створення посилання на репозиторій спочатку потрібно вибрати один дозвіл"),
        "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
            "Поширити за допомогою QR коду"),
        "messageStorage": MessageLookupByLibrary.simpleMessage("Сховище"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "Потрібно для отримання доступу до файлів"),
        "messageStrong": MessageLookupByLibrary.simpleMessage("Надійний"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Синхронізація під час використання мобільних даних"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Синхронізація вимкнена під час користування мобільним інтернетом"),
        "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Натисніть тут, щоб прочитати наші Умови використання та Політику конфіденційності"),
        "messageTapForValues": MessageLookupByLibrary.simpleMessage(
            "Натисніть тут, щоб ознайомитися з нашими цінностями"),
        "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
            "Порушує права на захист персональних даних, включаючи основні цінності або "),
        "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
            "(Закон про захист персональних даних та електронних документів)"),
        "messageTerms2": MessageLookupByLibrary.simpleMessage(
            "Містить матеріали, що пропагують сексуальну експлуатацію дітей (включно з матеріалами, які можуть не бути незаконними та не пропагують сексуальне насильство над дітьми, однак при цьому сексуально експлуатують або пропагують сексуальну експлуатацію неповнолітніх), нелегальну порнографію або є непристойними в інший спосіб"),
        "messageTerms3": MessageLookupByLibrary.simpleMessage(
            "Містить або пропагує екстремальні акти насильства або терористичну діяльність, включаючи терор або пропаганду насильницького екстремізму"),
        "messageTerms4": MessageLookupByLibrary.simpleMessage(
            "Пропагує фанатизм, ненависть або підбурювання до насильства щодо будь-якої особи чи групи осіб на підставі їхньої раси, релігії, етнічної приналежності, національного походження, статі, гендерної ідентичності, сексуальної орієнтації, інвалідності, обмежених можливостей або будь-якої іншої ознаки (ознак), пов\'язаної з системною дискримінацією або маргіналізацією"),
        "messageTerms5": MessageLookupByLibrary.simpleMessage(
            "Файли, що містять віруси, трояни, хробаки, логічні бомби або інші шкідливі або технологічно шкідливі матеріали"),
        "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
            "Ці Умови використання Ouisync (\"Угода\") разом з нашою Політикою конфіденційності (разом - \"Умови\") регулюють використання вами Ouisync - протоколу і програмного забезпечення для синхронізації файлів в інтернеті."),
        "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
            "Встановлюючи та запускаючи застосунок Ouisync, ви підтверджуєте свою згоду дотримуватися цієї Угоди між вами та eQualitie inc. (\"eQualitie\", \"ми\" або \"нас\"). Використання додатку Ouisync та мережі Ouisync (Послуга) надається eQualitie безкоштовно і призначене для використання як є"),
        "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
            "Застосунок Ouisync створено відповідно до цінностей eQualitie. Використовуючи це програмне забезпечення, ви погоджуєтеся, що не будете використовувати Ouisync для публікації, обміну або зберігання матеріалів, які суперечать основним цінностям або законам Квебеку або Канади, або Всесвітній декларації прав людини, включно з контентом, який:"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Токен репозиторію скопійовано в буфер обміну."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "Пароль не розблокував репозиторій"),
        "messageUnlockRepoOk": m22,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Введіть пароль для розблокування"),
        "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "Розблокувати за допомогою біометричних даних"),
        "messageUnlockUsingBiometricsConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Розблокувати цей репозиторій за допомогою біометрії?"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "У вас є незбережені зміни.\n\nВи хочете їх скасувати?"),
        "messageUpdateLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Оновити локальний пароль для цього сховища?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("ВПН"),
        "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Підтвердити локальний пароль"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Багатослівність журналу"),
        "messageView": MessageLookupByLibrary.simpleMessage("Переглянути"),
        "messageWeak": MessageLookupByLibrary.simpleMessage("Cлабкий"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Повний доступ. Ваш вузол може читати і писати"),
        "messageWritingFileCanceled": m23,
        "messageWritingFileError": m24,
        "messsageFailedAddRepository": m25,
        "messsageFailedCreateRepository": m26,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Змінити пароль"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Скопіювати пароль"),
        "replacementAccess": m27,
        "replacementChanges": m28,
        "replacementEntry": m29,
        "replacementName": m30,
        "replacementNumber": m31,
        "replacementPath": m32,
        "replacementStatus": m33,
        "statusSync": MessageLookupByLibrary.simpleMessage("СИНХРОНІЗОВАНО"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("Не визначено"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("Про нас"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("Додати файл до Ouisync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Імпортувати репозиторій з токеном"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Імпортувати репозиторій"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Необхідні дозволи"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Змінити пароль"),
        "titleChangesToTerms":
            MessageLookupByLibrary.simpleMessage("Зміни цих політик"),
        "titleChildrensPrivacy":
            MessageLookupByLibrary.simpleMessage("Конфідеційність щодо дітей"),
        "titleContactUs":
            MessageLookupByLibrary.simpleMessage("Зв\'яжіться з нами"),
        "titleCookies": MessageLookupByLibrary.simpleMessage("Куки"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Створити папку"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Створити новий репозиторій"),
        "titleDataCollection":
            MessageLookupByLibrary.simpleMessage("3.1 Як ми збираємо дані"),
        "titleDataSharing":
            MessageLookupByLibrary.simpleMessage("3.2 Як ми ділимося даними"),
        "titleDeleteFile":
            MessageLookupByLibrary.simpleMessage("Видалити файл"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Видалити папку"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Видалити непорожню папку"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Видалити репозиторій"),
        "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
            "3.4 Видалення ваших даних з нашого \"постійно однорангового\" сервера"),
        "titleDigitalSecurity":
            MessageLookupByLibrary.simpleMessage("Цифрова безпека"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Розташування завантаження"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Завантажити на пристрій"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Редагувати репозиторій"),
        "titleEqualitiesValues":
            MessageLookupByLibrary.simpleMessage("Цінності eQualitie"),
        "titleFAQShort":
            MessageLookupByLibrary.simpleMessage("Поширені питання"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("Подробиці файлу"),
        "titleFileExtensionChanged":
            MessageLookupByLibrary.simpleMessage("Розширення файлу змінено"),
        "titleFileExtensionMissing":
            MessageLookupByLibrary.simpleMessage("Розширення файлу відсутнє"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Додати"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Подробиці папки"),
        "titleFreedomExpresionAccessInfo": MessageLookupByLibrary.simpleMessage(
            "Свобода вираження та доступ до інформації"),
        "titleIssueTracker":
            MessageLookupByLibrary.simpleMessage("Відстеження проблем"),
        "titleJustLegalSociety": MessageLookupByLibrary.simpleMessage(
            "Справедливе і правове суспільство"),
        "titleLinksOtherSites":
            MessageLookupByLibrary.simpleMessage("Посилання на інші сайти"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Заблокувати всі репозиторії"),
        "titleLogData":
            MessageLookupByLibrary.simpleMessage("Дані логів (журналу)"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Журнали"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Переміщення входу"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Мережа"),
        "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Доступ до файлів із кількох пристроїв"),
        "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Налаштуйте дозволи на співпрацю, трансляцію чи просто зберігання"),
        "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Надіслати та отримати файли безпечно"),
        "titleOpennessTransparency":
            MessageLookupByLibrary.simpleMessage("Відритість та прозорість"),
        "titleOurMission": MessageLookupByLibrary.simpleMessage("Наша місія"),
        "titleOurPrinciples":
            MessageLookupByLibrary.simpleMessage("Наші принципи"),
        "titleOurValues": MessageLookupByLibrary.simpleMessage("Наші цінності"),
        "titleOverview": MessageLookupByLibrary.simpleMessage("1. Огляд"),
        "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
            "Закон про захист персональних даних та електронних документів (PIPEDA)"),
        "titlePrivacy": MessageLookupByLibrary.simpleMessage("Конфідеційність"),
        "titlePrivacyNotice": MessageLookupByLibrary.simpleMessage(
            "3. Угода про конфідеційність"),
        "titlePrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("Політика конфідеційності"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Видалити біометричні дані"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Мої репозиторії"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Репозиторій"),
        "titleRepositoryName":
            MessageLookupByLibrary.simpleMessage("Ім\'я репозиторію"),
        "titleRequiredPermission":
            MessageLookupByLibrary.simpleMessage("Необхідний дозвіл"),
        "titleSaveChanges":
            MessageLookupByLibrary.simpleMessage("Зберегти зміни"),
        "titleScanRepoQR": MessageLookupByLibrary.simpleMessage(
            "Сканувати QR-код Репозиторію"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Безпека"),
        "titleSecurityPractices":
            MessageLookupByLibrary.simpleMessage("3.3 Практика безпеки"),
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("Надішліть відгук"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("Встановіть пароль для"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Налаштування"),
        "titleShareRepository": m34,
        "titleSortBy": MessageLookupByLibrary.simpleMessage("Відсортовано"),
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Моніторинг статусу"),
        "titleTermsOfUse":
            MessageLookupByLibrary.simpleMessage("2. Умови використання"),
        "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Умови використання та угода про конфіденційність Ouisync"),
        "titleUPnP": MessageLookupByLibrary.simpleMessage(
            "Універсальне автоматичне налаштування мережевих пристроїв (UPnP)"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Розблокувати репозиторій"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Незбережені зміни"),
        "titleWeAreEq":
            MessageLookupByLibrary.simpleMessage("Ми – це eQualit.ie"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Папка")
      };
}
