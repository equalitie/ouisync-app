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
      "Уровень доступа не может быть выше того, что уже установлен для данного хранилища: ${access}";

  static String m4(name) => "${name} - загрузка отменена";

  static String m5(name) => "${name} - ошибка скачивания";

  static String m6(entry) => "${entry} уже существует.";

  static String m8(path) =>
      "Текущая папка отсутствует, переходим в вышестоящую: ${path}";

  static String m10(dokanUrl) =>
      "Dokan не установлен. Пожалуйста, установите его с ${dokanUrl}";

  static String m11(name) => "Ошибка инициализации хранилища ${name}";

  static String m12(path) => "${path} не пустой";

  static String m13(name) => "Ошибка импортирования хранилища ${name}";

  static String m14(name) => "Ошибка создания хранилища ${name}";

  static String m15(reason) => "Не удалось смонтировать: ${reason}";

  static String m16(name) =>
      "${name} уже существует в этой локации\n\nЧто вы хотите делать?";

  static String m18(name) => "Папка успешно удалена: ${name}";

  static String m20(number) =>
      "Хотите закрыть все открытые хранилища?\n\n(${number}открыто)";

  static String m22(path) => "от ${path}";

  static String m23(name) => "Ошибка при создании файла ${name}";

  static String m24(name) => "Ошибка при открытии файла ${name}";

  static String m25(path) => "Ошибка предварительного просмотра файла ${path}";

  static String m26(name) => "Мы не смогли удалить хранилище \"${name}\"";

  static String m27(name) =>
      "Хранилище \"${name}\" не найдено в привычной локации";

  static String m28(access) => "Доступ дан: ${access}";

  static String m29(name) =>
      "Это хранилище уже существует в приложеним под именем \"${name}\".";

  static String m32(name) =>
      "Рекомендация: ${name}\n(нажмите сюда чтобы использовать это имя)";

  static String m35(access) => "Открыт в качестве ${access} копии";

  static String m36(name) => "Введите пароль чтобы разблокировать";

  static String m37(name) => "Запись ${name} отменена";

  static String m38(name) => "${name} - ошибка записи";

  static String m39(access) => "${access}";

  static String m40(changes) => "${changes}";

  static String m41(entry) => "${entry}";

  static String m43(name) => "${name}";

  static String m44(number) => "${number}";

  static String m45(path) => "${path}";

  static String m46(status) => "${status}";

  static String m47(name) => "Поделиться хранилищем \"${name}\"";

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
        "actionDone": MessageLookupByLibrary.simpleMessage("Готово"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Редактировать имя"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Выйти"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Перейти в настройки"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Скрыть"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("СКРЫТЬ"),
        "actionIAgree": MessageLookupByLibrary.simpleMessage("Я согласен(-на)"),
        "actionIDontAgree":
            MessageLookupByLibrary.simpleMessage("Я не согласен(-на)"),
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
        "actionNext": MessageLookupByLibrary.simpleMessage("Далее"),
        "actionNo": MessageLookupByLibrary.simpleMessage("Нет"),
        "actionOK": MessageLookupByLibrary.simpleMessage("ОК"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Предпросмотр файла"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Обновить"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Обновить хранилище"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Удалить"),
        "actionRemoveLocalPassword":
            MessageLookupByLibrary.simpleMessage("Удалить локальный пароль"),
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
        "actionSkip": MessageLookupByLibrary.simpleMessage("Пропустить"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Отменить"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Разблокировать"),
        "actionUpdate": MessageLookupByLibrary.simpleMessage("Обновить"),
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
        "labelConnectionType":
            MessageLookupByLibrary.simpleMessage("Тип соединения"),
        "labelCopyLink":
            MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Назначение"),
        "labelDownloadedTo": MessageLookupByLibrary.simpleMessage("Скачано в:"),
        "labelEndpoint":
            MessageLookupByLibrary.simpleMessage("Конечный пункт "),
        "labelExternalIPv4":
            MessageLookupByLibrary.simpleMessage("Внешний IPv4"),
        "labelExternalIPv6":
            MessageLookupByLibrary.simpleMessage("Внешний IPv6"),
        "labelLocalIPv4":
            MessageLookupByLibrary.simpleMessage("Локальный IPv4"),
        "labelLocalIPv6":
            MessageLookupByLibrary.simpleMessage("Локальный IPv6"),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Локация: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Всё заблокировать"),
        "labelName": MessageLookupByLibrary.simpleMessage("Имя: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Новое имя "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("Пароль: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Пиры"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("QR код"),
        "labelQuicListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("Слушаю на QUIC/UDP IPv4"),
        "labelQuicListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("Слушаю на QUIC/UDP IPv6"),
        "labelRememberPassword":
            MessageLookupByLibrary.simpleMessage("Запомнить пароль"),
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
        "labelTcpListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("Слушаю на TCP IPv4"),
        "labelTcpListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("Слушаю на TCP IPv6"),
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
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "Получить доступ к безопасному хранилищу"),
        "messageAck": MessageLookupByLibrary.simpleMessage("Ой!"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Эта опция недоступна в хранилищах только для чтения"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Импортировать хранилище используя ссылку-токен"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Импортировать хранилище используя QR код"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Это хранилище заблокировано или в слепом доступе.\n\nЕсли у вас есть пароль, разблокируйте его и попробуйте снова."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Это хранилище доступно только для чтения."),
        "messageAutomaticUnlockRepositoryFailed":
            MessageLookupByLibrary.simpleMessage(
                "Мы не могли разблокировать хранилище"),
        "messageAvailableOnMobile": MessageLookupByLibrary.simpleMessage(
            "Доступно на мобильных устройствах"),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Скоро ваша операционная система попросит вас разрешения на работу приложения в фоновом режиме.\n\nЭто нужно чтобы продолжать синхронизацию когда приложение свернуто"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("Работает"),
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "Ошибка аутентификации по биометрии"),
        "messageBiometricUnlockRepositoryFailed":
            MessageLookupByLibrary.simpleMessage(
                "Биометрическая разблокировка не удалась"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Ваш пир не сможет читать и изменять контент"),
        "messageBlindRepository":
            MessageLookupByLibrary.simpleMessage("Это слепая копия хранилища."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "Введенный <bold>пароль</bold> не дает вам доступа к контенту хранилища."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
        "messageBy": MessageLookupByLibrary.simpleMessage("от"),
        "messageCamera": MessageLookupByLibrary.simpleMessage("Камера"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "Это разрешение требуется для использования камеры и чтения QR-кода"),
        "messageCanadaPrivacyAct": MessageLookupByLibrary.simpleMessage(
            "Закон Канады о конфиденциальности"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Изменение расширения файла может помешать его дальнейшему использованию"),
        "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
            "Мы можем время от времени обновлять наши Условия. Таким образом, Вам рекомендуется периодически просматривать эту страницу на предмет любых изменений"),
        "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
            "Эта политика эффективна с 2022-03-09"),
        "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
            "Мы сознательно не собираем личную информацию от детей. Мы призываем всех детей никогда не предоставлять какую-либо личную информацию через Приложение и/или Сервисы. Мы призываем родителей и законных опекунов следить за использованием Интернета своими детьми и способствовать обеспечению соблюдения настоящей Политики, инструктируя своих детей никогда не предоставлять личную информацию через Приложение и/или Сервисы без их разрешения. Если у вас есть основания полагать, что ребёнок предоставил нам личную информацию через Приложение и/или Сервисы, свяжитесь с нами. Вам также должно быть не менее 16 лет, чтобы дать согласие на обработку Вашей личной информации в Вашей стране (в некоторых странах мы можем разрешить Вашему родителю или опекуну делать это от Вашего имени)"),
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
        "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
            "Если у вас есть какие-либо вопросы или предложения о нашей Политике конфиденциальности, не стесняйтесь связаться с нами"),
        "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
            "Приложение Ouisync не использует cookies"),
        "messageCopiedToClipboard":
            MessageLookupByLibrary.simpleMessage("Скопировано в буфер обмена."),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Создайте новую <bold>папку</bold>, или добавьте <bold>файл</bold> используя <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Создать новое <bold>хранилище</bold> или импортировать хранилище другв используя <bold>токен хранилища</bold>"),
        "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Генерация токена для раздачи…"),
        "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
            "Команда Ouisync ценит конфиденциальность пользователей и, таким образом, не собирает никакой пользовательской информации"),
        "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
            "Приложение Ouisync предназначено для предоставления услуг обмена файлами без указания идентификатора пользователя, имени, псевдонима, учетной записи пользователя или любой другой формы пользовательских данных. Мы не знаем, кто использует наше приложение и с кем они синхронизируют или делятся своими данными"),
        "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
            "Ouisync (и eQualit.ie) не передает никаких данных третьим лицам"),
        "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
            "Декларация о Распределенных Онлайн-Сервисах"),
        "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
            "Команда Ouisync не может удалить отдельные файлы из хранилищ, так как их невозможно идентифицировать, потому что они зашифрованы. Мы можем удалить целые хранилища, если вы отправите нам ссылку на репозиторий, которая должна быть удалена"),
        "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
            "Самый простой способ удалить Ваши данные — удалить файлы или хранилища с Вашего собственного устройства. Любое удаление файла будет распространено на все копии Вашего хранилища — т. е., если у Вас есть доступ на запись к хранилищу, Вы можете удалить любые файлы в нём, и те же файлы будут удалены из хранилищ Ваших коллег, а также из нашего Always-On-хранилища. Если Вам нужно удалить хранилища только из нашего Always-On-Peer (но при этом сохранить их в своем хранилище на своем устройстве), свяжитесь с нами по указанному ниже адресу"),
        "messageDistributedHashTables":
            MessageLookupByLibrary.simpleMessage("Распределенные хэш-таблицы"),
        "messageDownloadFileCanceled":
            MessageLookupByLibrary.simpleMessage("Скачивание файла отменено"),
        "messageDownloadingFileCanceled": m4,
        "messageDownloadingFileError": m5,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Эта <bold>папка</bold> пуста"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "Это <bold>хранилище</bold> пусто"),
        "messageEnterDifferentName": MessageLookupByLibrary.simpleMessage(
            "Пожалуйста, введите другое имя"),
        "messageEntryAlreadyExist": m6,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("Запись"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage("Папка"),
        "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
            "Основные права и свободы являются неотъемлемыми и в равной степени применяются ко всем. Права человека универсальны; защищены международным правом и закреплены в "),
        "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
            "Как организация, мы стремимся быть прозрачными с нашей политикой и процедурами. Как можно чаще, наш исходный код открыт и свободно доступен, защищен лицензиями, которые поощряют развитие, совместное использование и распространение этих принципов"),
        "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
            "Возможность свободно выражать свое мнение и получать доступ к общественной информации является основой истинной демократии. Публичная информация должна быть в открытом доступе. Свобода выражения мнений включает в себя активные и горячие дебаты, даже аргументы, которые неэлегантно сформулированы, плохо построены и которые могут быть сочтены некоторыми оскорбительными. Однако свобода выражения мнений не является абсолютным правом. Мы решительно выступаем против насилия и подстрекательства к нарушению прав других, особенно против пропаганды насилия, ненависти, дискриминации и лишения избирательных прав любой идентифицируемой этнической или социальной группы"),
        "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
            "Мы работаем из разных стран и приходим из различных социальных слоев. Мы вместе работаем над обществом, которое будет уважать и защищать права других людей в физическом и цифровом мире. Международный билль о правах формулирует свод прав человека, который вдохновляет нашу работу; мы считаем, что люди имеют право и обязанность защищать эти права"),
        "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
            "Мы понимаем, что нашими инструментами и услугами можно злоупотреблять в нарушение этих принципов и наших условий обслуживания, и мы решительно и активно осуждаем и запрещаем такое использование. Мы не разрешаем использовать наше программное обеспечение и услуги для совершения противозаконных действий, а также не будем способствовать распространению языка ненависти или пропаганде насилия через Интернет"),
        "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
            "Мы внедрили меры безопасности для предотвращения неправомерного использования наших продуктов и услуг. Когда нам становится известно о любом использовании, которое нарушает наши принципы или условия обслуживания, мы принимаем меры, чтобы остановить это. Руководствуясь нашей внутренней политикой, мы тщательно обдумываем действия, которые могут поставить под угрозу наши принципы. Наши процедуры будут продолжать развиваться на основе опыта и лучших практик, чтобы мы могли достичь правильного баланса между предоставлением открытого доступа к нашим продуктам и услугам и соблюдением наших принципов"),
        "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
            "Смелые люди рискуют жизнью и свободой, защищая права человека, мобилизуясь, критикуя и разоблачая виновных в жестоком обращении. Смелые люди выражают поддержку другим, идеям и сообщают миру о своих проблемах. Эти храбрые люди осуществляют свои права человека в Интернете"),
        "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
            "Интернет является платформой для свободного выражения мнений и самоопределения. Как и любой коммуникационный инструмент, Интернет не застрахован от цензуры, наблюдения, нападений и попыток государственных субъектов и преступных групп заставить замолчать голоса диссидентов. Когда демократическое выражение криминализируется, когда существует этническая и политическая дискриминация, Интернет становится еще одним полигоном для ненасильственного сопротивления"),
        "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
            "Наша миссия заключается в поощрении и защите основных свобод и прав человека, включая свободный поток информации в Интернете. Наша цель - создать доступные технологии и улучшить набор навыков, необходимых для защиты прав и свобод человека в эпоху цифровых технологий"),
        "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
            "Мы стремимся обучать и повышать способность наших участников пользоваться безопасными операциями в цифровой сфере. Мы делаем это, создавая инструменты, которые обеспечивают и защищают свободу выражения мнений, обходят цензуру, обеспечивают анонимность и защищают от слежки там, где и когда это необходимо. Наши инструменты также улучшают управление информацией и аналитические функции"),
        "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
            "Мы — международная группа активистов разного происхождения и убеждений, которые вместе защищают общие для нас принципы. Мы разработчики программного обеспечения, криптографы, специалисты по безопасности, а также преподаватели, социологи, историки, антропологи и журналисты. Мы разрабатываем открытые и многоразовые инструменты, уделяя особое внимание конфиденциальности, онлайн-безопасности и лучшему управлению информацией. Мы финансируем нашу деятельность за счет государственных грантов и консультаций с частным сектором. Мы верим в Интернет, свободный от навязчивого и неоправданного наблюдения, цензуры и притеснений"),
        "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
            "Вдохновленные Международным Биллем о правах человека, наши принципы распространяются на каждого человека, группу и орган общества, с которым мы работаем, включая бенефициаров программного обеспечения и услуг, которые мы выпускаем. Все наши проекты разработаны с учетом наших принципов. Наши знания, инструменты и услуги доступны для этих групп и отдельных лиц до тех пор, пока наши принципы и условия службы соблюдаются"),
        "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
            "Право на неприкосновенность частной жизни является основополагающим правом, которое мы стремимся защищать, когда это возможно и когда это возможно. Неприкосновенность частной жизни наших непосредственных бенефициаров священна для наших операций. Для этого разработаны наши инструменты, услуги и внутренняя политика. Мы будем использовать все технические и юридические ресурсы в нашем распоряжении для защиты конфиденциальности наших бенефициаров. Пожалуйста, обратитесь к нашей Политике конфиденциальности и к нашей "),
        "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
            "Безопасность является постоянной темой всех наших проектов по разработке программного обеспечения, предоставлению услуг и наращиванию потенциала. Мы разрабатываем наши системы и процессы для улучшения информационной безопасности в Интернете, а также повышения профиля безопасности и удобства пользователей. Мы стараемся подавать пример, не ставя под угрозу свойства безопасности инструмента или системы ради скорости, удобства использования или стоимости. Мы не верим в безопасность через неизвестность и поддерживаем прозрачность благодаря открытому доступу к нашей базе кода. Мы всегда проявляем осторожность и стараемся обеспечить хорошую внутреннюю операционную безопасность"),
        "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
            "Это приложение разработано в соответствии с нашими ценностями.\n\nИспользуя Ouisync, вы соглашаетесь с этими приницами, и принимаете Условия Использования и Политику Конфиденциальности."),
        "messageError": MessageLookupByLibrary.simpleMessage("Ошибка !"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "Произошла ошибка при авторизации по биометрии. Пожалуйста, попробуйте снова"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "Произошла ошибка при изменении пароля. Пожалуйста, попробуйте снова"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "Использование \\ or / не разрешено"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Ошибка при создании хранилища"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Ошибка при генерации токена для раздачи."),
        "messageErrorCurrentPathMissing": m8,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Что-то пошло не так. Пожалуйста, повторите попытку."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Ошибка."),
        "messageErrorDokanNotInstalled": m10,
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
        "messageErrorOpeningRepoDescription": m11,
        "messageErrorPathNotEmpty": m12,
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
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync":
            MessageLookupByLibrary.simpleMessage("Нажмите снова чтобы выйти."),
        "messageFAQ": MessageLookupByLibrary.simpleMessage("FAQ"),
        "messageFailedAddRepository": m13,
        "messageFailedCreateRepository": m14,
        "messageFailedToMount": m15,
        "messageFile": MessageLookupByLibrary.simpleMessage("файл"),
        "messageFileAlreadyExist": m16,
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "Файл уже в процессе загрузки"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("Имя файла"),
        "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
            "Мы не смогли запустить предварительный просмотр файла"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Предпросмотр файла ещё не доступен"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("файлы"),
        "messageFolderDeleted": m18,
        "messageFolderName": MessageLookupByLibrary.simpleMessage("Имя папки"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Сгенерировать пароль"),
        "messageGoToMailApp": MessageLookupByLibrary.simpleMessage(
            "Перейдите в почтовое приложение"),
        "messageGoToPeers":
            MessageLookupByLibrary.simpleMessage("Перейти к коллегам"),
        "messageGood": MessageLookupByLibrary.simpleMessage("Хорошо"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Разрешено"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Чтобы дать это разрешение, зайдите в настройки\n\nНастройки > Приложения и уведомления"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Позволяет приложению синхронизироваться в фоновом режиме"),
        "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
            "Это инструмент, который позволяет одноранговым узлам находить друг друга в P2P (одноранговой) сети без централизованного сервера"),
        "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
            "Функция Local Peer Discovery позволяет вашим приложениям Ouisync обмениваться файлами с Вашими коллегами, минуя интернет-провайдеров в местах, где доступен локальный Wi-Fi или другая сеть.\n\nДля локального подключения этот параметр должен быть включен"),
        "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
            "Это значение зависит от Вашего маршрутизатора и/или Вашего интернет-провайдера.\n\nСвязь с Вашими партнёрами лучше всего достигается, когда для этого параметра установлено значение «Endpoint Independent»"),
        "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
            "Это инструмент, используемый для обмена списком одноранговых узлов с одноранговыми узлами, к которым Вы подключены"),
        "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
            "Это уникальный идентификатор, генерируемый Ouisync при каждом запуске.\n\nВы можете использовать его для подтверждения своего соединения с другими пользователями в разделе Peer приложения"),
        "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Если этот параметр включен, Ваш оператор мобильной связи может взимать с Вас плату за данные, используемые при синхронизации хранилищ, которыми Вы делитесь со своими коллегами"),
        "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
            "Это набор сетевых протоколов, которые позволят Вашим приложениям Ouisync обнаруживать друг друга и взаимодействовать друг с другом.\n\nДля наилучшего подключения мы рекомендуем включить этот параметр"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Инициализация…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Нажмите кнопку <bold>Разблокировать</bold> и введите пароль чтобы получить доступ к содержимому хранилища."),
        "messageInternationalBillHumanRights":
            MessageLookupByLibrary.simpleMessage(
                "Международный билль о правах человека"),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("Сохранить оба файла"),
        "messageLaunchAtStartup": MessageLookupByLibrary.simpleMessage(
            "Запускать при старте системы"),
        "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
            "Произошла внутренняя ошибка."),
        "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
            "Этот Сервис может содержать ссылки на другие сайты. Если вы нажмете на стороннюю ссылку, Вы будете перенаправлены на тот сайт. Обратите внимание, что мы не управляем этими внешними сайтами. Поэтому мы настоятельно рекомендуем вам ознакомиться с Политикой конфиденциальности этих веб-сайтов. Мы не контролируем и не несем никакой ответственности за содержание, политику конфиденциальности или методы работы любых сторонних сайтов или сервисов"),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Загрузка…"),
        "messageLocalDiscovery": MessageLookupByLibrary.simpleMessage(
            "Обнаружение по локальной сети"),
        "messageLockOpenRepos": m20,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Это <bold>хранилище</bold> заблокировано."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Блокировка всех открытых хранилищ…"),
        "messageLogData1": MessageLookupByLibrary.simpleMessage(
            "Адрес электронной почты - если пользователь решил связаться с нами по электронной почте"),
        "messageLogData2": MessageLookupByLibrary.simpleMessage(
            "Информация, которую пользователь может предоставить по электронной почте, через запросы помощи или через наш веб-сайт, а также соответствующие метаданные - в целях предоставления технической поддержки"),
        "messageLogData3": MessageLookupByLibrary.simpleMessage(
            "IP-адрес пользователя - для целей оказания технической поддержки"),
        "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
            "Приложение Ouisync создает лог-файлы на устройствах пользователей. Их цель состоит только в том, чтобы регистрировать активность устройства, чтобы облегчить процесс отладки в случае, если пользователь испытывает трудности при подключении к своим коллегам или иным образом при использовании приложения Ouisync. Лог-файл остается на устройстве пользователя, если пользователь не решит отправить его нам для целей поддержки"),
        "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
            "Если пользователь решит связаться с нами, мы можем собрать следующие персональные данные:"),
        "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
            "Никакие из этих данных не передаются третьим лицам"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("Всё"),
        "messageLogLevelError":
            MessageLookupByLibrary.simpleMessage("Только ошибки"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("Ошибки и предупреждения"),
        "messageLogLevelErrorWarnInfo": MessageLookupByLibrary.simpleMessage(
            "Ошибки, предупреждения и информация"),
        "messageLogLevelErrorWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage(
                "Ошибки, предупреждения, информация и отладка"),
        "messageLogViewer":
            MessageLookupByLibrary.simpleMessage("Просмотр логов"),
        "messageMedium": MessageLookupByLibrary.simpleMessage("Нормально"),
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "Ouisync не имеет авторизации на работу в фоновом режиме, если вы запустите другое приложение, это может помешать синхронизации"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Мобильный"),
        "messageMoveEntryOrigin": m22,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Эта функция недоступна при перемещении файла."),
        "messageNATOnWikipedia":
            MessageLookupByLibrary.simpleMessage("NAT в Википедии"),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Тип NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Сеть недоступна"),
        "messageNewFileError": m23,
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "Новый пароль сохранен в буфер обмена"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("Доступна новая версия."),
        "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
            "Не найдено установленных приложений для этого действия"),
        "messageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("Медиафайлов не обнаружено."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Перед добавлением файлов вам нужно создать хранилище"),
        "messageNoRepoIsSelected":
            MessageLookupByLibrary.simpleMessage("Хранилище не выбрано"),
        "messageNoRepos": MessageLookupByLibrary.simpleMessage(
            "Не найдено ни одного хранилища"),
        "messageNone": MessageLookupByLibrary.simpleMessage("Ни одного"),
        "messageNote": MessageLookupByLibrary.simpleMessage("Заметка"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("Пока что тут пусто!"),
        "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Делитесь файлами со всеми своими устройствами или с другими и постройке своё защищённое облако!"),
        "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Репозиториями можно делится как на чтение-запись, только чтения, или слепо (вы можете добавить файлы для других, но не можете их просматривать)"),
        "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Все файлы и папки, добавленные в Ouisync, зашифрованны по умолчанию - и при передаче, и при хранении."),
        "messageOpenFileError": m24,
        "messageOr": MessageLookupByLibrary.simpleMessage("Или"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePIPEDA": MessageLookupByLibrary.simpleMessage("PIPEDA"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Пароль"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Пароль сохранен у буфер обмена"),
        "messagePasswordStrength":
            MessageLookupByLibrary.simpleMessage("Безопасность пароля"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Обмен между пирами"),
        "messagePeerExchangeWikipedia": MessageLookupByLibrary.simpleMessage(
            "Пиринговый обмен в Википедии"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("Это разрешение необходимо"),
        "messagePreviewingFileFailed": m25,
        "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
            "Этот раздел используется для информирования посетителей о нашей политике в отношении сбора, использования и раскрытия личной информации, если кто-либо решит использовать наш Сервис"),
        "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
            "\"Человек рождается свободным, и везде он в цепях\""),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Это хранилище доступно только для <bold>чтения</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Изменения невозможны, только доступ к контенту"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "Не забудьте надежно сохранить ваш пароль; если вы его забудете, восстановить его не удастся."),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage("Удалить вход по биометрии"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Улалить биометрию"),
        "messageRemoveBiometricsConfirmationMoreInfo":
            MessageLookupByLibrary.simpleMessage(
                "Это позволит удалить пароль хранилища и использовать биометрическую проверку для разблокировки"),
        "messageRemoveLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Удалить локальный пароль этого хранилища?\n\nХранилище разблокируется автоматически, если только локальный пароль не будет добавлен повторно"),
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
        "messageRepoDeletionErrorDescription": m26,
        "messageRepoDeletionFailed":
            MessageLookupByLibrary.simpleMessage("Ошибка удаления хранилища"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "Хранилище тут больше не находится"),
        "messageRepoMissingErrorDescription": m27,
        "messageRepositoryAccessMode": m28,
        "messageRepositoryAlreadyExist": m29,
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
        "messageRepositoryNotMounted":
            MessageLookupByLibrary.simpleMessage("Хранилище не смонтировано "),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Пароль"),
        "messageRepositorySuggestedName": m32,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Скопируйте ссылку сюда"),
        "messageRousseau":
            MessageLookupByLibrary.simpleMessage("Жан-Жак Руссо"),
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
        "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
            "Данные, которые пользователь загружает в хранилища Ouisync, подвергаются сквозному шифрованию как при передаче, так и при хранении. Сюда входят метаданные, такие как имена файлов, размеры, структура папок и т.д. В Ouisync данные доступны для чтения только человеку, который загрузил данные, и тем людям, с которыми они поделились своими хранилищами"),
        "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
            "Вы можете узнать больше об используемых методах шифрования в нашей документации"),
        "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
            "Приложение Ouisync хранит данные пользователей на \'Постоянно включенном узле\', который представляет собой сервер, расположенный в Канаде. Все данные хранятся в виде зашифрованных фрагментов и недоступны для чтения сервером или его операторами. Назначение этого сервера - просто преодолеть разрывы между узлами (пользователями), которые не находятся в сети одновременно. Все данные периодически удаляются с этого сервера - его целью является не обеспечение постоянного хранения данных, а просто облегчение синхронизации данных между узлами"),
        "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
            "Если у вас есть основания полагать, что ваши персональные данные были незаконно получены и переданы другими пользователями Ouisync, пожалуйста, свяжитесь с нами по адресу ниже"),
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
        "messageStrong": MessageLookupByLibrary.simpleMessage("Отлично"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Синхронизировать используя мобильные данные"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "Синхронизация выключена при использовании мобильных данных"),
        "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Нажмите здесь, чтобы прочитать Условия Использования и Политику Конфиденциальности"),
        "messageTapForValues": MessageLookupByLibrary.simpleMessage(
            "Нажмите здесь, чтобы прочитать наши ценности"),
        "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
            "Нарушает права на защиту личной информации, включая основополагающие ценности или письмо "),
        "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
            "(Закон о защите личной информации и электронных документах)"),
        "messageTerms2": MessageLookupByLibrary.simpleMessage(
            "Содержит материалы, сексуально эксплуатирующие детей (включая материалы, которые не являются незаконными материалами о сексуальном насилии над детьми, но которые, тем не менее, сексуально эксплуатируют или пропагандируют сексуальную эксплуатацию несовершеннолетних), незаконную порнографию или иным образом непристойны"),
        "messageTerms3": MessageLookupByLibrary.simpleMessage(
            "Содержит или поощряет крайние акты насилия или террористической деятельности, в том числе террор или агрессивную экстремистскую пропаганду"),
        "messageTerms4": MessageLookupByLibrary.simpleMessage(
            "Пропагандирует фанатизм, ненависть или подстрекательство к насилию в отношении любого лица или группы людей на основе их расы, религии, этнической принадлежности, национального происхождения, пола, гендерной идентичности, сексуальной ориентации, инвалидности, неполноценности или любых других характеристик, связанных с системной дискриминацией или маргинализацией"),
        "messageTerms5": MessageLookupByLibrary.simpleMessage(
            "Файлы, которые содержат вирусы, трояны, черви, логические бомбы или другие материалы, которые являются вредоносными или технологически вредными"),
        "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
            "Настоящие Условия использования Ouisync («Соглашение»), а также наше Уведомление о конфиденциальности (совместно именуемые «Условия») регулируют использование Вами Ouisync — протокола и программного обеспечения для онлайн-синхронизации файлов."),
        "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
            "Устанавливая и запуская приложение Ouisync, Вы выражаете свое согласие соблюдать настоящее Соглашение между Вами и eQualitie Inc. («eQualitie», «мы» или «нас»). Использование приложения Ouisync и сети Ouisync (Сервиса) предоставляется компанией eQualitie бесплатно и предназначено для использования как есть"),
        "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
            "Приложение Ouisync создано в соответствии с ценностями eQualitie. Используя это программное обеспечение, Вы соглашаетесь, что не будете использовать Ouisync для публикации, обмена или хранения материалов, которые противоречат основным ценностям, букве законов Квебека или Канады или Международному биллю о правах человека, включая контент, который:"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Токен хранилища скопирован в буфер обмена."),
        "messageUnknownFileExtension": MessageLookupByLibrary.simpleMessage(
            "Неизвестное расширение файла"),
        "messageUnlockRepoFailed":
            MessageLookupByLibrary.simpleMessage("Пароль не открыл хранилище"),
        "messageUnlockRepoOk": m35,
        "messageUnlockRepository": m36,
        "messageUnlockUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Открыть с помощью биометрии"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "У вас есть несохраненные изменения.\n\nВы хотите отменить их?"),
        "messageUpdateLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "Обновить локальный пароль этого хранилища?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("ВПН"),
        "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Подтвердить локальный пароль"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Выбор детализации логов"),
        "messageView": MessageLookupByLibrary.simpleMessage("Посмотреть"),
        "messageWeak": MessageLookupByLibrary.simpleMessage("Слабо"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Полный доступ. Вашр пиры могут и просматривать, и изменять содержимое"),
        "messageWritingFileCanceled": m37,
        "messageWritingFileError": m38,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Изменить пароль"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Скопировать пароль"),
        "replacementAccess": m39,
        "replacementChanges": m40,
        "replacementEntry": m41,
        "replacementName": m43,
        "replacementNumber": m44,
        "replacementPath": m45,
        "replacementStatus": m46,
        "repositoryIsAlreadyImported":
            MessageLookupByLibrary.simpleMessage("Хранилище уже импортируется"),
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
        "titleChangesToTerms":
            MessageLookupByLibrary.simpleMessage("Правки в данные Условия"),
        "titleChildrensPrivacy":
            MessageLookupByLibrary.simpleMessage("Конфиденциальность детей"),
        "titleContactUs":
            MessageLookupByLibrary.simpleMessage("Свяжитесь с нами"),
        "titleCookies": MessageLookupByLibrary.simpleMessage("Куки (Cookies)"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Создать папку"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Создать новое хранилище"),
        "titleDataCollection":
            MessageLookupByLibrary.simpleMessage("3.1 Сбор данных"),
        "titleDataSharing":
            MessageLookupByLibrary.simpleMessage("3.2 Передача данных"),
        "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Удалить файл"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Удалить папку"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("Удалить не пустую папку"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Удалить хранилище"),
        "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
            "3.4 Удаление ваших данных с нашего Always-On-Peer сервера"),
        "titleDigitalSecurity":
            MessageLookupByLibrary.simpleMessage("Цифровая Безопасность"),
        "titleDokanInstallation":
            MessageLookupByLibrary.simpleMessage("Установка Dokan"),
        "titleDokanInstallationFound":
            MessageLookupByLibrary.simpleMessage("Установка Dokan найдена"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("Путь загрузок"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Скачать на устройство"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Изменить хранилище"),
        "titleEqualitiesValues":
            MessageLookupByLibrary.simpleMessage("Ценности eQualitie"),
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
        "titleFreedomExpressionAccessInfo":
            MessageLookupByLibrary.simpleMessage(
                "Свобода выражения и доступа к информации"),
        "titleIssueTracker":
            MessageLookupByLibrary.simpleMessage("Трекер проблем"),
        "titleJustLegalSociety": MessageLookupByLibrary.simpleMessage(
            "Справедливое и правовое общество"),
        "titleLinksOtherSites":
            MessageLookupByLibrary.simpleMessage("Ссылки на Другие сайты"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Заблокировать все хранилища"),
        "titleLogData": MessageLookupByLibrary.simpleMessage("Логи данных"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Логи"),
        "titleMovingEntry": MessageLookupByLibrary.simpleMessage("Переместить"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
        "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "Доступ к файлам с нескольких устройств"),
        "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "Установите разрешения для совместной работы, передачи или просто хранения"),
        "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "Отправляйте и получайте файлы безопасно"),
        "titleOpennessTransparency":
            MessageLookupByLibrary.simpleMessage("Открытость и Прозрачность"),
        "titleOurMission": MessageLookupByLibrary.simpleMessage("Наша миссия"),
        "titleOurPrinciples":
            MessageLookupByLibrary.simpleMessage("Наши Принципы"),
        "titleOurValues": MessageLookupByLibrary.simpleMessage("Наши ценности"),
        "titleOverview": MessageLookupByLibrary.simpleMessage("1. Обзор"),
        "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
            "Закон о защите личных сведений и электронных документов"),
        "titlePrivacy": MessageLookupByLibrary.simpleMessage("Приватность"),
        "titlePrivacyNotice":
            MessageLookupByLibrary.simpleMessage("3. Политика приватности"),
        "titlePrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("Политика конфиденциальности"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Удалить биометрию"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Мои репозитории"),
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
        "titleSecurityPractices": MessageLookupByLibrary.simpleMessage(
            "3.3 Методы обеспечения безопасности"),
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("Отправить фидбек"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("Поставить пароль для"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "titleShareRepository": m47,
        "titleSortBy": MessageLookupByLibrary.simpleMessage("Отсортировать по"),
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Анализ состояния"),
        "titleTermsOfUse":
            MessageLookupByLibrary.simpleMessage("2. Условия использования"),
        "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "Условия использования и Уведомление о приватности Ouisync"),
        "titleUPnP": MessageLookupByLibrary.simpleMessage(
            "Универсальный Plug and Play (UPnP)"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Разблокировать хранилише"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("Изменения не сохранены"),
        "titleWeAreEq": MessageLookupByLibrary.simpleMessage("Мы — eQualit.ie"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Файл"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Папка")
      };
}
