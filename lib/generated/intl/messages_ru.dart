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

  static String m39(totals) => "Выбор копии здесь:\n\n\t\t${totals}";

  static String m40(totals) => "Удалить выбор:\n\n\t\t${totals}";

  static String m1(path) => "Файл загружен по адресу ${path}";

  static String m2(name) => "${name} - загрузка отменена";

  static String m3(name) => "${name} - ошибка скачивания";

  static String m4(entry) => "${entry} уже существует.";

  static String m41(name) => "Ошибка при создании папки ${name}";

  static String m5(path) =>
      "Текущая папка отсутствует, переходим в вышестоящую: ${path}";

  static String m6(error) => "Ошибка: ${error}";

  static String m7(dokanUrl) => "Dokan отсутствует.${dokanUrl}";

  static String m8(name) => "Ошибка инициализации хранилища ${name}";

  static String m9(path) => "${path} не пустой";

  static String m10(name) => "Ошибка импортирования хранилища ${name}";

  static String m11(name) => "Ошибка создания хранилища ${name}";

  static String m12(reason) =>
      "Доступ к хранилищам через File Explorer недоступен: ${reason}";

  static String m13(name) =>
      "${name} уже существует в этой локации\n\nЧто вы хотите делать?";

  static String m42(name) => "Файл успешно удален: ${name}";

  static String m43(name) => "Файл переименован в ${name}";

  static String m14(name) => "Папка успешно удалена: ${name}";

  static String m44(name) => "Папка переименована в ${name}";

  static String m15(number) =>
      "Хотите закрыть все открытые хранилища?\n\n(${number}открыто)";

  static String m45(totals) => "Переместите выбор сюда:\n\n\t\t${totals}";

  static String m16(path) => "от ${path}";

  static String m17(name) => "Ошибка при создании файла ${name}";

  static String m18(name) => "Ошибка при открытии файла ${name}";

  static String m19(path) => "Ошибка предварительного просмотра файла ${path}";

  static String m20(name) => "Мы не смогли удалить хранилище \"${name}\"";

  static String m21(name) =>
      "Хранилище \"${name}\" не найдено в привычной локации";

  static String m22(access) => "Доступ дан: ${access}";

  static String m23(name) =>
      "Это хранилище уже существует в приложеним под именем \"${name}\".";

  static String m46(name) => "Репозиторий ${name} удален";

  static String m47(name) => "Репозиторий переименован в ${name}";

  static String m24(name) =>
      "Рекомендация: ${name}\n(нажмите сюда чтобы использовать это имя)";

  static String m48(totals) => "Сохранить выбор:\n\n\t\t${totals}";

  static String m49(path) => "Не удалось поделиться файлом ${path}";

  static String m25(name) => "Сортировать по: ${name}";

  static String m26(access) => "Открыт в качестве ${access} копии";

  static String m27(name) => "Введите пароль для разблокировки \"${name}\"";

  static String m28(name) => "Запись ${name} отменена";

  static String m29(name) => "${name} - ошибка записи";

  static String m30(access) => "${access}";

  static String m31(changes) => "${changes}";

  static String m32(entry) => "${entry}";

  static String m33(error) => "${error}";

  static String m34(name) => "${name}";

  static String m35(number) => "${number}";

  static String m36(path) => "${path}";

  static String m37(status) => "${status}";

  static String m50(storage) =>
      "Вы хотите переместить репозиторий в <bold>${storage}</bold>?";

  static String m38(name) => "Поделиться хранилищем \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accessModeBlindLabel": MessageLookupByLibrary.simpleMessage("слепой"),
    "accessModeReadLabel": MessageLookupByLibrary.simpleMessage("читать"),
    "accessModeWriteLabel": MessageLookupByLibrary.simpleMessage("писать"),
    "actionAccept": MessageLookupByLibrary.simpleMessage("Принять"),
    "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ПРИНЯТЬ"),
    "actionAddRepository": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище",
    ),
    "actionAddRepositoryWithToken": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище",
    ),
    "actionAllow": MessageLookupByLibrary.simpleMessage("Разрешить"),
    "actionBack": MessageLookupByLibrary.simpleMessage("Назад"),
    "actionCancel": MessageLookupByLibrary.simpleMessage("Отменить"),
    "actionCancelCapital": MessageLookupByLibrary.simpleMessage("ОТМЕНИТЬ"),
    "actionClear": MessageLookupByLibrary.simpleMessage("Стереть"),
    "actionCloseCapital": MessageLookupByLibrary.simpleMessage("ЗАКРЫТЬ"),
    "actionCopy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "actionCreate": MessageLookupByLibrary.simpleMessage("Создать"),
    "actionCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Создать хранилище",
    ),
    "actionDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("УДАЛИТЬ"),
    "actionDeleteFile": MessageLookupByLibrary.simpleMessage("Удалить файл"),
    "actionDeleteFolder": MessageLookupByLibrary.simpleMessage("Удалить папку"),
    "actionDeleteRepository": MessageLookupByLibrary.simpleMessage(
      "Удалить хранилище",
    ),
    "actionDiscard": MessageLookupByLibrary.simpleMessage("Отменить"),
    "actionDone": MessageLookupByLibrary.simpleMessage("Готово"),
    "actionDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
    "actionEditRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Редактировать имя",
    ),
    "actionEject": MessageLookupByLibrary.simpleMessage("Извлечь"),
    "actionExit": MessageLookupByLibrary.simpleMessage("Выйти"),
    "actionGoToSettings": MessageLookupByLibrary.simpleMessage(
      "Перейти в настройки",
    ),
    "actionHide": MessageLookupByLibrary.simpleMessage("Скрыть"),
    "actionHideCapital": MessageLookupByLibrary.simpleMessage("СКРЫТЬ"),
    "actionIAgree": MessageLookupByLibrary.simpleMessage("Я согласен(-на)"),
    "actionIDontAgree": MessageLookupByLibrary.simpleMessage(
      "Я не согласен(а)",
    ),
    "actionIDontHaveALocalPassword": MessageLookupByLibrary.simpleMessage(
      "У меня нет локального пароля для этого репозитория",
    ),
    "actionImport": MessageLookupByLibrary.simpleMessage("Импортировать"),
    "actionImportRepo": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище",
    ),
    "actionInstallDokan": MessageLookupByLibrary.simpleMessage(
      "Установить Dokan",
    ),
    "actionLockCapital": MessageLookupByLibrary.simpleMessage("ЗАБЛОКИРОВАТЬ"),
    "actionMove": MessageLookupByLibrary.simpleMessage("Переместить"),
    "actionNewFile": MessageLookupByLibrary.simpleMessage("Файл"),
    "actionNewFolder": MessageLookupByLibrary.simpleMessage("Папка"),
    "actionNewMediaFile": MessageLookupByLibrary.simpleMessage("Медиа"),
    "actionNewRepo": MessageLookupByLibrary.simpleMessage("Создать хранилище"),
    "actionNext": MessageLookupByLibrary.simpleMessage("Далее"),
    "actionNo": MessageLookupByLibrary.simpleMessage("Нет"),
    "actionOK": MessageLookupByLibrary.simpleMessage("ОК"),
    "actionPreviewFile": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр файла",
    ),
    "actionReloadContents": MessageLookupByLibrary.simpleMessage("Обновить"),
    "actionReloadRepo": MessageLookupByLibrary.simpleMessage(
      "Обновить хранилище",
    ),
    "actionRemove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "actionRemoveLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Удалить локальный пароль",
    ),
    "actionRemoveRepo": MessageLookupByLibrary.simpleMessage(
      "Удалить хранилище",
    ),
    "actionRename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "actionRetry": MessageLookupByLibrary.simpleMessage("Попробовать снова"),
    "actionSave": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "actionSaveChanges": MessageLookupByLibrary.simpleMessage(
      "Сохранить изменения",
    ),
    "actionScanQR": MessageLookupByLibrary.simpleMessage("Сканировать QR код"),
    "actionSelect": MessageLookupByLibrary.simpleMessage("Выбрать"),
    "actionShare": MessageLookupByLibrary.simpleMessage("Поделиться"),
    "actionShareFile": MessageLookupByLibrary.simpleMessage(
      "Поделиться файлом",
    ),
    "actionShow": MessageLookupByLibrary.simpleMessage("Показать"),
    "actionSkip": MessageLookupByLibrary.simpleMessage("Пропустить"),
    "actionUndo": MessageLookupByLibrary.simpleMessage("Отменить"),
    "actionUnlock": MessageLookupByLibrary.simpleMessage("Разблокировать"),
    "actionUpdate": MessageLookupByLibrary.simpleMessage("Обновить"),
    "actionUpdateDokan": MessageLookupByLibrary.simpleMessage("Обновить Dokan"),
    "actionYes": MessageLookupByLibrary.simpleMessage("Да"),
    "buttonLocateRepository": MessageLookupByLibrary.simpleMessage("Найти"),
    "copyToClipboard": MessageLookupByLibrary.simpleMessage(
      "Скопировать в буфер обмена",
    ),
    "iconAccessMode": MessageLookupByLibrary.simpleMessage("Уровень доступа"),
    "iconAddExistingRepository": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище",
    ),
    "iconCopy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "iconCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Создать новое хранилище",
    ),
    "iconDelete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "iconDownload": MessageLookupByLibrary.simpleMessage("Скачать"),
    "iconInformation": MessageLookupByLibrary.simpleMessage("Информация"),
    "iconMove": MessageLookupByLibrary.simpleMessage("Переместить"),
    "iconPreview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "iconRename": MessageLookupByLibrary.simpleMessage("Переименовать"),
    "iconShare": MessageLookupByLibrary.simpleMessage("Поделиться"),
    "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
      "Поделиться этим с вашими пирами",
    ),
    "labelAppVersion": MessageLookupByLibrary.simpleMessage(
      "Версия приложения",
    ),
    "labelAttachLogs": MessageLookupByLibrary.simpleMessage("Прикрепить логи"),
    "labelBitTorrentDHT": MessageLookupByLibrary.simpleMessage(
      "BitTorrent DHT",
    ),
    "labelConnectionType": MessageLookupByLibrary.simpleMessage(
      "Тип соединения",
    ),
    "labelCopyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "labelDestination": MessageLookupByLibrary.simpleMessage("Назначение"),
    "labelDownloadedTo": MessageLookupByLibrary.simpleMessage("Скачано в:"),
    "labelEndpoint": MessageLookupByLibrary.simpleMessage("Конечный пункт "),
    "labelExternalIPv4": MessageLookupByLibrary.simpleMessage("Внешний IPv4"),
    "labelExternalIPv6": MessageLookupByLibrary.simpleMessage("Внешний IPv6"),
    "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("Локальный IPv4"),
    "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("Локальный IPv6"),
    "labelLocation": MessageLookupByLibrary.simpleMessage("Локация: "),
    "labelLockAllRepos": MessageLookupByLibrary.simpleMessage(
      "Всё заблокировать",
    ),
    "labelName": MessageLookupByLibrary.simpleMessage("Имя: "),
    "labelNewName": MessageLookupByLibrary.simpleMessage("Новое имя "),
    "labelPassword": MessageLookupByLibrary.simpleMessage("Пароль: "),
    "labelPeers": MessageLookupByLibrary.simpleMessage("Пиры"),
    "labelQRCode": MessageLookupByLibrary.simpleMessage("QR код"),
    "labelQuicListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Слушаю на QUIC/UDP IPv4",
    ),
    "labelQuicListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Слушаю на QUIC/UDP IPv6",
    ),
    "labelRememberPassword": MessageLookupByLibrary.simpleMessage(
      "Запомнить пароль",
    ),
    "labelRenameRepository": MessageLookupByLibrary.simpleMessage(
      "Ввести новое имя: ",
    ),
    "labelRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "Текущий пароль",
    ),
    "labelRepositoryLink": MessageLookupByLibrary.simpleMessage(
      "Ссылка на хранилище: ",
    ),
    "labelRetypePassword": MessageLookupByLibrary.simpleMessage(
      "Подтвердите пароль: ",
    ),
    "labelSelectRepository": MessageLookupByLibrary.simpleMessage(
      "Выбрать хранилище ",
    ),
    "labelSetPermission": MessageLookupByLibrary.simpleMessage(
      "Дать разрешение",
    ),
    "labelShareLink": MessageLookupByLibrary.simpleMessage(
      "Поделиться ссылкой",
    ),
    "labelSize": MessageLookupByLibrary.simpleMessage("Размер: "),
    "labelSyncStatus": MessageLookupByLibrary.simpleMessage(
      "Статус синхронизации: ",
    ),
    "labelSynced": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "labelTcpListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Слушаю на TCP IPv4",
    ),
    "labelTcpListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Слушаю на TCP IPv6",
    ),
    "labelTokenLink": MessageLookupByLibrary.simpleMessage(
      "Ссылка на хранилище",
    ),
    "labelTypePassword": MessageLookupByLibrary.simpleMessage(
      "Введите пароль: ",
    ),
    "languageIsNotAvailable": MessageLookupByLibrary.simpleMessage(
      "недоступно",
    ),
    "languageOfTheDevice": MessageLookupByLibrary.simpleMessage(
      "язык устройства",
    ),
    "menuItemAbout": MessageLookupByLibrary.simpleMessage("О программе"),
    "menuItemLogs": MessageLookupByLibrary.simpleMessage("Логи"),
    "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
    "menuItemRepository": MessageLookupByLibrary.simpleMessage("Хранилище"),
    "messageAccessModeDisabled": m0,
    "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
      "Получить доступ к безопасному хранилищу",
    ),
    "messageAck": MessageLookupByLibrary.simpleMessage("Ой!"),
    "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Эта опция недоступна в хранилищах только для чтения",
    ),
    "messageAddRepoDb": MessageLookupByLibrary.simpleMessage(
      "Импорт репозитория из файловой системы",
    ),
    "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище используя ссылку-токен",
    ),
    "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище используя QR код",
    ),
    "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
      "Это хранилище заблокировано или в слепом доступе.\n\nЕсли у вас есть пароль, разблокируйте его и попробуйте снова.",
    ),
    "messageAddingFileToReadRepository": MessageLookupByLibrary.simpleMessage(
      "Это хранилище доступно только для чтения.",
    ),
    "messageAuthenticate": MessageLookupByLibrary.simpleMessage(
      "Аутентификация",
    ),
    "messageAutomaticUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "Мы не смогли разблокировать хранилище",
        ),
    "messageAvailableOnMobile": MessageLookupByLibrary.simpleMessage(
      "Доступно на мобильных устройствах",
    ),
    "messageAwaitingResult": MessageLookupByLibrary.simpleMessage(
      "Жду результата...",
    ),
    "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
      "Скоро ваша операционная система попросит вас разрешения на работу приложения в фоновом режиме.\n\nЭто нужно чтобы продолжать синхронизацию когда приложение свернуто",
    ),
    "messageBackgroundNotification": MessageLookupByLibrary.simpleMessage(
      "Ouisync запущен",
    ),
    "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка аутентификации по биометрии",
    ),
    "messageBiometricUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "Биометрическая разблокировка не удалась",
        ),
    "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Ваш пир не сможет читать и изменять контент",
    ),
    "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
      "Это слепая копия хранилища.",
    ),
    "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
      "Введенный <bold>пароль</bold> не дает вам доступа к контенту хранилища.",
    ),
    "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
    "messageBy": MessageLookupByLibrary.simpleMessage("от"),
    "messageCamera": MessageLookupByLibrary.simpleMessage("Камера"),
    "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
      "Это разрешение требуется для использования камеры и чтения QR-кода",
    ),
    "messageCanadaPrivacyAct": MessageLookupByLibrary.simpleMessage(
      "Закон Канады о конфиденциальности",
    ),
    "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
      "Изменение расширения файла может помешать его дальнейшему использованию",
    ),
    "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
      "Мы можем время от времени обновлять наши Условия. Таким образом, Вам рекомендуется периодически просматривать эту страницу на предмет любых изменений",
    ),
    "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
      "Эта политика эффективна с 2022-03-09",
    ),
    "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
      "Мы сознательно не собираем персональную информацию о детях. Мы рекомендуем всем детям никогда не предоставлять никакой персональной информации через Приложение и/или Услуги. Мы призываем родителей и законных опекунов следить за использованием Интернета их детьми и способствовать соблюдению данной Политики, инструктируя своих детей никогда не предоставлять информацию, идентифицирующую личность, через Приложение и/или Услуги без их разрешения. Если у вас есть основания полагать, что ребенок предоставил нам персональную информацию через Приложение и/или Услуги, пожалуйста, свяжитесь с нами. Вы также должны быть не моложе 16 лет, чтобы дать согласие на обработку вашей персональной информации в вашей стране (в некоторых странах мы можем разрешить вашему родителю или опекуну сделать это от вашего имени)",
    ),
    "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
      "Вы уверены что хотите удалить этот файл?",
    ),
    "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "Вы уверены что хотите удалить эту папку?",
    ),
    "messageConfirmIrreversibleChange": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо, вы хотите продолжить?",
    ),
    "messageConfirmNotEmptyFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "Эта папка не пустая.\n\nВы все еще хотите ее удалить? (Это удалит все ее содержимое)",
    ),
    "messageConfirmRepositoryDeletion": MessageLookupByLibrary.simpleMessage(
      "Вы уверены что хотите удалить это хранилище?",
    ),
    "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
      "Если у вас есть какие-либо вопросы или предложения о нашей Политике конфиденциальности, не стесняйтесь связаться с нами",
    ),
    "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
      "Приложение Ouisync не использует cookies",
    ),
    "messageCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Скопировано в буфер обмена.",
    ),
    "messageCopyEntries": m39,
    "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
      "Создайте новую <bold>папку</bold>, или добавьте <bold>файл</bold> используя <icon></icon>",
    ),
    "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
      "Создать новое <bold>хранилище</bold> или импортировать хранилище другв используя <bold>токен хранилища</bold>",
    ),
    "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
      "Генерация токена для раздачи…",
    ),
    "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
      "Команда Ouisync ценит конфиденциальность пользователей и, таким образом, не собирает никакой пользовательской информации",
    ),
    "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
      "Приложение Ouisync разработано таким образом, чтобы предоставлять услуги по обмену файлами без ID пользователя, имени, псевдонима, учетной записи или любой другой формы данных о пользователе. Мы не знаем, кто использует наше приложение и с кем они синхронизируют или обмениваются своими данными",
    ),
    "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
      "Ouisync (и eQualit.ie) не передает никаких данных третьим лицам",
    ),
    "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
      "Декларация о Распределенных Онлайн-Сервисах",
    ),
    "messageDeleteEntries": m40,
    "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
      "Команда Ouisync не может удалить отдельные файлы из хранилищ, так как их невозможно идентифицировать, потому что они зашифрованы. Мы можем удалить целые хранилища, если вы отправите нам ссылку на репозиторий, которая должна быть удалена",
    ),
    "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
      "Самый простой способ удаления данных - это удаление файлов или хранилищ с вашего собственного устройства. Любое удаление файла будет передано всем вашим коллегам - то есть, если у вас есть доступ к хранилищу на запись, вы можете удалить любые файлы в нем, и те же файлы будут удалены из хранилищ ваших коллег, а также из нашего Always-On-Peer. Если вам нужно удалить только репозитории из Always-On-Peer (но при этом сохранить их в собственном репозитории на своем устройстве), свяжитесь с нами по следующему адресу",
    ),
    "messageDistributedHashTables": MessageLookupByLibrary.simpleMessage(
      "Распределенные хэш-таблицы",
    ),
    "messageDokan": MessageLookupByLibrary.simpleMessage("Dokan"),
    "messageDokanDifferentMayorP1": MessageLookupByLibrary.simpleMessage(
      "Установленный",
    ),
    "messageDokanDifferentMayorP2": MessageLookupByLibrary.simpleMessage(
      "устарела. Пожалуйста, обновите его до последней версии.",
    ),
    "messageDokanInstallationFailed": MessageLookupByLibrary.simpleMessage(
      "Установка Dokan не удалась.",
    ),
    "messageDokanOlderVersionP2": MessageLookupByLibrary.simpleMessage(
      "устарела.\n\nПожалуйста, удалите существующую версию Dokan, перезагрузите систему и запустите Ouisync снова.",
    ),
    "messageDownloadFileCanceled": MessageLookupByLibrary.simpleMessage(
      "Скачивание файла отменено",
    ),
    "messageDownloadFileLocation": m1,
    "messageDownloadingFileCanceled": m2,
    "messageDownloadingFileError": m3,
    "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "Эта <bold>папка</bold> пуста",
    ),
    "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
      "Это <bold>хранилище</bold> пусто",
    ),
    "messageEnterDifferentName": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, введите другое имя",
    ),
    "messageEntryAlreadyExist": m4,
    "messageEntryTypeDefault": MessageLookupByLibrary.simpleMessage("Запись"),
    "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("Файл"),
    "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage("Папка"),
    "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
      "Основные права и свободы являются неотъемлемыми и в равной степени применяются ко всем. Права человека универсальны; защищены международным правом и закреплены в ",
    ),
    "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
      "Как организация, мы стремимся быть прозрачными с нашей политикой и процедурами. Как можно чаще, наш исходный код открыт и свободно доступен, защищен лицензиями, которые поощряют развитие, совместное использование и распространение этих принципов",
    ),
    "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
      "Возможность свободно выражать свое мнение и получать доступ к общественной информации является основой истинной демократии. Публичная информация должна быть в открытом доступе. Свобода выражения мнений включает в себя активные и горячие дебаты, даже аргументы, которые неэлегантно сформулированы, плохо построены и которые могут быть сочтены некоторыми оскорбительными. Однако свобода выражения мнений не является абсолютным правом. Мы решительно выступаем против насилия и подстрекательства к нарушению прав других, особенно против пропаганды насилия, ненависти, дискриминации и лишения избирательных прав любой идентифицируемой этнической или социальной группы",
    ),
    "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
      "Мы работаем из разных стран и приходим из различных социальных слоев. Мы вместе работаем над обществом, которое будет уважать и защищать права других людей в физическом и цифровом мире. Международный билль о правах формулирует свод прав человека, который вдохновляет нашу работу; мы считаем, что люди имеют право и обязанность защищать эти права",
    ),
    "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
      "Мы понимаем, что нашими инструментами и услугами можно злоупотреблять в нарушение этих принципов и наших условий обслуживания, и мы решительно и активно осуждаем и запрещаем такое использование. Мы не разрешаем использовать наше программное обеспечение и услуги для совершения противозаконных действий, а также не будем способствовать распространению языка ненависти или пропаганде насилия через Интернет",
    ),
    "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
      "Мы внедрили меры безопасности для предотвращения неправомерного использования наших продуктов и услуг. Когда нам становится известно о любом использовании, которое нарушает наши принципы или условия обслуживания, мы принимаем меры, чтобы остановить это. Руководствуясь нашей внутренней политикой, мы тщательно обдумываем действия, которые могут поставить под угрозу наши принципы. Наши процедуры будут продолжать развиваться на основе опыта и лучших практик, чтобы мы могли достичь правильного баланса между предоставлением открытого доступа к нашим продуктам и услугам и соблюдением наших принципов",
    ),
    "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
      "Смелые люди рискуют жизнью и свободой, защищая права человека, мобилизуясь, критикуя и разоблачая виновных в жестоком обращении. Смелые люди выражают поддержку другим, идеям и сообщают миру о своих проблемах. Эти храбрые люди осуществляют свои права человека в Интернете",
    ),
    "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
      "Интернет является платформой для свободного выражения мнений и самоопределения. Как и любой коммуникационный инструмент, Интернет не застрахован от цензуры, наблюдения, нападений и попыток государственных субъектов и преступных групп заставить замолчать голоса диссидентов. Когда демократическое выражение криминализируется, когда существует этническая и политическая дискриминация, Интернет становится еще одним полигоном для ненасильственного сопротивления",
    ),
    "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
      "Наша миссия заключается в поощрении и защите основных свобод и прав человека, включая свободный поток информации в Интернете. Наша цель - создать доступные технологии и улучшить набор навыков, необходимых для защиты прав и свобод человека в эпоху цифровых технологий",
    ),
    "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
      "Мы стремимся обучать и повышать способность наших участников пользоваться безопасными операциями в цифровой сфере. Мы делаем это, создавая инструменты, которые обеспечивают и защищают свободу выражения мнений, обходят цензуру, обеспечивают анонимность и защищают от слежки там, где и когда это необходимо. Наши инструменты также улучшают управление информацией и аналитические функции",
    ),
    "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
      "Мы — международная группа активистов разного происхождения и убеждений, которые вместе защищают общие для нас принципы. Мы разработчики программного обеспечения, криптографы, специалисты по безопасности, а также преподаватели, социологи, историки, антропологи и журналисты. Мы разрабатываем открытые и многоразовые инструменты, уделяя особое внимание конфиденциальности, онлайн-безопасности и лучшему управлению информацией. Мы финансируем нашу деятельность за счет государственных грантов и консультаций с частным сектором. Мы верим в Интернет, свободный от навязчивого и неоправданного наблюдения, цензуры и притеснений",
    ),
    "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
      "Вдохновленные Международным Биллем о правах человека, наши принципы распространяются на каждого человека, группу и орган общества, с которым мы работаем, включая бенефициаров программного обеспечения и услуг, которые мы выпускаем. Все наши проекты разработаны с учетом наших принципов. Наши знания, инструменты и услуги доступны для этих групп и отдельных лиц до тех пор, пока наши принципы и условия службы соблюдаются",
    ),
    "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
      "Право на неприкосновенность частной жизни является основополагающим правом, которое мы стремимся защищать, когда это возможно и когда это возможно. Неприкосновенность частной жизни наших непосредственных бенефициаров священна для наших операций. Для этого разработаны наши инструменты, услуги и внутренняя политика. Мы будем использовать все технические и юридические ресурсы в нашем распоряжении для защиты конфиденциальности наших бенефициаров. Пожалуйста, обратитесь к нашей Политике конфиденциальности и к нашей ",
    ),
    "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
      "Безопасность является постоянной темой всех наших проектов по разработке программного обеспечения, предоставлению услуг и наращиванию потенциала. Мы разрабатываем наши системы и процессы для улучшения информационной безопасности в Интернете, а также повышения профиля безопасности и удобства пользователей. Мы стараемся подавать пример, не ставя под угрозу свойства безопасности инструмента или системы ради скорости, удобства использования или стоимости. Мы не верим в безопасность через неизвестность и поддерживаем прозрачность благодаря открытому доступу к нашей базе кода. Мы всегда проявляем осторожность и стараемся обеспечить хорошую внутреннюю операционную безопасность",
    ),
    "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
      "Это приложение разработано в соответствии с нашими ценностями.\n\nИспользуя Ouisync, вы соглашаетесь с этими приницами, и принимаете Условия Использования и Политику Конфиденциальности.",
    ),
    "messageError": MessageLookupByLibrary.simpleMessage("Ошибка !"),
    "messageErrorAuthenticatingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при авторизации по биометрии. Пожалуйста, попробуйте снова",
    ),
    "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
      "Произошла ошибка при изменении пароля. Пожалуйста, попробуйте снова",
    ),
    "messageErrorCharactersNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Использование \\ or / не разрешено",
    ),
    "messageErrorCreatingFolder": m41,
    "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
      "Ошибка при создании хранилища",
    ),
    "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
      "Ошибка при генерации токена для раздачи.",
    ),
    "messageErrorCurrentPathMissing": m5,
    "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
      "Что-то пошло не так. Пожалуйста, повторите попытку.",
    ),
    "messageErrorDefaultShort": MessageLookupByLibrary.simpleMessage("Ошибка."),
    "messageErrorDetail": m6,
    "messageErrorDokanNotInstalled": m7,
    "messageErrorEntryNotFound": MessageLookupByLibrary.simpleMessage(
      "запись не найдена",
    ),
    "messageErrorFormValidatorNameDefault":
        MessageLookupByLibrary.simpleMessage("Введите верное имя."),
    "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
      "Мы не смогли загрузить содержимое этой папки. Пожалуйста, попробуйте еще раз.",
    ),
    "messageErrorNewPasswordSameOldPassword":
        MessageLookupByLibrary.simpleMessage(
          "Новый пароль такой же как старый",
        ),
    "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
      "Ошибка при открытии хранилища",
    ),
    "messageErrorOpeningRepoDescription": m8,
    "messageErrorPathNotEmpty": m9,
    "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
      "Хранилище с таким именем уже существует",
    ),
    "messageErrorRepositoryPasswordValidation":
        MessageLookupByLibrary.simpleMessage("Пожалуйста введите пароль."),
    "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
      "Пароли не совпадают.",
    ),
    "messageErrorTokenEmpty": MessageLookupByLibrary.simpleMessage(
      "Введите токен.",
    ),
    "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
      "Токен недействителен.",
    ),
    "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
      "Введите верный токен.",
    ),
    "messageErrorUnhandledState": MessageLookupByLibrary.simpleMessage(
      "Ошибка: состояние не поддерживается",
    ),
    "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
    "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
      "Нажмите снова чтобы выйти.",
    ),
    "messageFAQ": MessageLookupByLibrary.simpleMessage("FAQ"),
    "messageFailedAddRepository": m10,
    "messageFailedCreateRepository": m11,
    "messageFailedToMount": m12,
    "messageFile": MessageLookupByLibrary.simpleMessage("файл"),
    "messageFileAlreadyExist": m13,
    "messageFileDeleted": m42,
    "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
      "Файл уже в процессе загрузки",
    ),
    "messageFileName": MessageLookupByLibrary.simpleMessage("Имя файла"),
    "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Мы не смогли запустить пред. просмотр файла",
    ),
    "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Предпросмотр файла ещё не доступен",
    ),
    "messageFileRenamed": m43,
    "messageFiles": MessageLookupByLibrary.simpleMessage("файлы"),
    "messageFolderDeleted": m14,
    "messageFolderName": MessageLookupByLibrary.simpleMessage("Имя папки"),
    "messageFolderRenamed": m44,
    "messageGeneratePassword": MessageLookupByLibrary.simpleMessage(
      "Сгенерировать пароль",
    ),
    "messageGoToMailApp": MessageLookupByLibrary.simpleMessage(
      "Перейдите в почтовое приложение",
    ),
    "messageGoToPeers": MessageLookupByLibrary.simpleMessage(
      "Перейти к коллегам",
    ),
    "messageGood": MessageLookupByLibrary.simpleMessage("Хорошо"),
    "messageGranted": MessageLookupByLibrary.simpleMessage("Разрешено"),
    "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
      "Чтобы дать это разрешение, зайдите в настройки\n\nНастройки > Приложения и уведомления",
    ),
    "messageIgnoreBatteryOptimizationsPermission":
        MessageLookupByLibrary.simpleMessage(
          "Позволяет приложению синхронизироваться в фоновом режиме",
        ),
    "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
      "Это инструмент, который позволяет одноранговым узлам находить друг друга в P2P (одноранговой) сети без централизованного сервера",
    ),
    "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "Функция Local Peer Discovery позволяет вашим приложениям Ouisync обмениваться файлами с Вашими коллегами, минуя интернет-провайдеров в местах, где доступен локальный Wi-Fi или другая сеть.\n\nДля локального подключения этот параметр должен быть включен",
    ),
    "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
      "Это значение зависит от Вашего маршрутизатора и/или Вашего интернет-провайдера.\n\nСвязь с Вашими партнёрами лучше всего достигается, когда для этого параметра установлено значение «Endpoint Independent»",
    ),
    "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
      "Это инструмент, используемый для обмена списком одноранговых узлов с одноранговыми узлами, к которым Вы подключены",
    ),
    "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
      "Это уникальный идентификатор, генерируемый Ouisync при каждом запуске.\n\nВы можете использовать его для подтверждения своего соединения с другими пользователями в разделе Peer приложения",
    ),
    "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "Если этот параметр включен, Ваш оператор мобильной связи может взимать с Вас плату за данные, используемые при синхронизации хранилищ, которыми Вы делитесь со своими коллегами",
    ),
    "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
      "Это набор сетевых протоколов, которые позволят Вашим приложениям Ouisync обнаруживать друг друга и взаимодействовать друг с другом.\n\nДля наилучшего подключения мы рекомендуем включить этот параметр",
    ),
    "messageInitializing": MessageLookupByLibrary.simpleMessage(
      "Инициализация…",
    ),
    "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
      "Нажмите кнопку <bold>Разблокировать</bold> и введите пароль чтобы получить доступ к содержимому хранилища.",
    ),
    "messageInstallDokanForOuisyncP1": MessageLookupByLibrary.simpleMessage(
      "Ouisync использует",
    ),
    "messageInstallDokanForOuisyncP2": MessageLookupByLibrary.simpleMessage(
      "для доступа к хранилищам через проводник файлов.\nУстановите Dokan, чтобы расширить возможности Ouisync.",
    ),
    "messageInternationalBillHumanRights": MessageLookupByLibrary.simpleMessage(
      "Международный билль о правах человека",
    ),
    "messageKeepBothFiles": MessageLookupByLibrary.simpleMessage(
      "Сохранить оба файла",
    ),
    "messageKeepBothFolders": MessageLookupByLibrary.simpleMessage(
      "Сохраните обе папки",
    ),
    "messageLanAccessRequired": MessageLookupByLibrary.simpleMessage(
      "Для синхронизации с другими устройствами в локальной сети требуется доступ к локальной сети.",
    ),
    "messageLaunchAtStartup": MessageLookupByLibrary.simpleMessage(
      "Запускать при старте системы",
    ),
    "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
      "Произошла внутренняя ошибка.",
    ),
    "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
      "Этот Сервис может содержать ссылки на другие сайты. Если вы нажмете на стороннюю ссылку, Вы будете перенаправлены на тот сайт. Обратите внимание, что мы не управляем этими внешними сайтами. Поэтому мы настоятельно рекомендуем вам ознакомиться с Политикой конфиденциальности этих веб-сайтов. Мы не контролируем и не несем никакой ответственности за содержание, политику конфиденциальности или методы работы любых сторонних сайтов или сервисов",
    ),
    "messageLoadingDefault": MessageLookupByLibrary.simpleMessage("Загрузка…"),
    "messageLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "Обнаружение по локальной сети",
    ),
    "messageLockOpenRepos": m15,
    "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
      "Это <bold>хранилище</bold> заблокировано.",
    ),
    "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
      "Блокировка всех открытых хранилищ…",
    ),
    "messageLogData1": MessageLookupByLibrary.simpleMessage(
      "Адрес электронной почты - если пользователь решил связаться с нами по электронной почте",
    ),
    "messageLogData2": MessageLookupByLibrary.simpleMessage(
      "Информация, которую пользователь может предоставить по электронной почте, через запросы помощи или через наш веб-сайт, а также соответствующие метаданные - в целях предоставления технической поддержки",
    ),
    "messageLogData3": MessageLookupByLibrary.simpleMessage(
      "IP-адрес пользователя - для целей оказания технической поддержки",
    ),
    "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
      "Приложение Ouisync создает лог-файлы на устройствах пользователей. Они предназначены только для регистрации активности устройства, чтобы облегчить процесс отладки в случае, если пользователь испытывает трудности при соединении с коллегами или при использовании приложения Ouisync. Лог-файл остается на устройстве пользователя до тех пор, пока пользователь не решит отправить его нам в целях поддержки",
    ),
    "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
      "Если пользователь все же решит связаться с нами, мы можем собрать следующие персональные данные:",
    ),
    "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
      "Никакие из этих данных не передаются третьим лицам",
    ),
    "messageMedium": MessageLookupByLibrary.simpleMessage("Нормально"),
    "messageMissingBackgroundServicePermission":
        MessageLookupByLibrary.simpleMessage(
          "Ouisync не имеет авторизации на работу в фоновом режиме, если вы запустите другое приложение, это может помешать синхронизации",
        ),
    "messageMobile": MessageLookupByLibrary.simpleMessage("Мобильный"),
    "messageMoveEntries": m45,
    "messageMoveEntryOrigin": m16,
    "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
      "Эта функция недоступна при перемещении файла.",
    ),
    "messageNATOnWikipedia": MessageLookupByLibrary.simpleMessage(
      "NAT в Википедии",
    ),
    "messageNATType": MessageLookupByLibrary.simpleMessage("Тип NAT"),
    "messageNetworkIsUnavailable": MessageLookupByLibrary.simpleMessage(
      "Сеть недоступна",
    ),
    "messageNetworkNoInternet": MessageLookupByLibrary.simpleMessage(
      "Нет интернета; вы всё ещё можете синхронизироваться локально, если Wi-Fi включён",
    ),
    "messageNewFileError": m17,
    "messageNewPasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "Новый пароль сохранен в буфер обмена",
    ),
    "messageNewVersionIsAvailable": MessageLookupByLibrary.simpleMessage(
      "Доступна новая версия.",
    ),
    "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
      "Ни одно приложение не может выполнить это действие",
    ),
    "messageNoMediaPresent": MessageLookupByLibrary.simpleMessage(
      "Медиафайлов не обнаружено.",
    ),
    "messageNoRepo": MessageLookupByLibrary.simpleMessage(
      "Перед добавлением файлов вам нужно создать хранилище",
    ),
    "messageNoRepoIsSelected": MessageLookupByLibrary.simpleMessage(
      "Хранилище не выбрано",
    ),
    "messageNoRepos": MessageLookupByLibrary.simpleMessage(
      "Не найдено ни одного хранилища",
    ),
    "messageNone": MessageLookupByLibrary.simpleMessage("Ни одного"),
    "messageNote": MessageLookupByLibrary.simpleMessage("Заметка"),
    "messageNothingHereYet": MessageLookupByLibrary.simpleMessage(
      "Пока что тут пусто!",
    ),
    "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "Делитесь файлами со всеми своими устройствами или с другими и постройке своё защищённое облако!",
    ),
    "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "Репозиториями можно делится как на чтение-запись, только чтения, или слепо (вы можете добавить файлы для других, но не можете их просматривать)",
    ),
    "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "Все файлы и папки, добавленные в Ouisync, зашифрованны по умолчанию - и при передаче, и при хранении.",
    ),
    "messageOnlyAvailableFiles": MessageLookupByLibrary.simpleMessage(
      "Доступно только для файлов",
    ),
    "messageOpenFileError": m18,
    "messageOr": MessageLookupByLibrary.simpleMessage("Или"),
    "messageOuiSyncDesktopTitle": MessageLookupByLibrary.simpleMessage(
      "Ouisync",
    ),
    "messagePIPEDA": MessageLookupByLibrary.simpleMessage("PIPEDA"),
    "messagePassword": MessageLookupByLibrary.simpleMessage("Пароль"),
    "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "Пароль сохранен у буфер обмена",
    ),
    "messagePasswordStrength": MessageLookupByLibrary.simpleMessage(
      "Безопасность пароля",
    ),
    "messagePeerAdded": MessageLookupByLibrary.simpleMessage("Добавлена пара"),
    "messagePeerExchange": MessageLookupByLibrary.simpleMessage(
      "Обмен между пирами",
    ),
    "messagePeerExchangeWikipedia": MessageLookupByLibrary.simpleMessage(
      "Пиринговый обмен в Википедии",
    ),
    "messagePeerRemoved": MessageLookupByLibrary.simpleMessage("Пара удалена"),
    "messagePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Это разрешение необходимо",
    ),
    "messagePleaseAuthenticate": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, проверьте подлинность",
    ),
    "messagePreviewingFileFailed": m19,
    "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
      "Этот раздел используется для информирования посетителей о нашей политике в отношении сбора, использования и раскрытия личной информации, если кто-либо решит использовать наш Сервис",
    ),
    "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
      "\"Человек рождается свободным, и везде он в цепях\"",
    ),
    "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
      "Это хранилище доступно только для <bold>чтения</bold>.",
    ),
    "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Изменения невозможны, только доступ к контенту",
    ),
    "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
      "Не забывайте надежно хранить пароль. Его невозможно восстановить, если он потерян или забыт.",
    ),
    "messageRemoveBiometricValidation": MessageLookupByLibrary.simpleMessage(
      "Удалить вход по биометрии",
    ),
    "messageRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "Улалить биометрию",
    ),
    "messageRemoveBiometricsConfirmationMoreInfo":
        MessageLookupByLibrary.simpleMessage(
          "Это позволит удалить пароль хранилища и использовать биометрическую проверку для разблокировки",
        ),
    "messageRemoveLocalPasswordConfirmation": MessageLookupByLibrary.simpleMessage(
      "Удалить локальный пароль этого хранилища?\n\nХранилище разблокируется автоматически, если только локальный пароль не будет добавлен повторно",
    ),
    "messageRemovedInBrackets": MessageLookupByLibrary.simpleMessage(
      "<удалено>",
    ),
    "messageRenameFile": MessageLookupByLibrary.simpleMessage(
      "Переименовать файл",
    ),
    "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
      "Переименовать папку",
    ),
    "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
      "Переименовать хранилище",
    ),
    "messageReplaceExistingFile": MessageLookupByLibrary.simpleMessage(
      "Заменить существующий файл",
    ),
    "messageReplaceExistingFolder": MessageLookupByLibrary.simpleMessage(
      "Замените существующую папку",
    ),
    "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка входа в хранилище",
    ),
    "messageRepoDeletionErrorDescription": m20,
    "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
      "Ошибка удаления хранилища",
    ),
    "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
      "Хранилище тут больше не находится",
    ),
    "messageRepoMissingErrorDescription": m21,
    "messageRepositoryAccessMode": m22,
    "messageRepositoryAlreadyExist": m23,
    "messageRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "Текущий пароль",
    ),
    "messageRepositoryDeleted": m46,
    "messageRepositoryIsNotOpen": MessageLookupByLibrary.simpleMessage(
      "Хранилище не открыто",
    ),
    "messageRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Дайте имя хранилищу",
    ),
    "messageRepositoryNewName": MessageLookupByLibrary.simpleMessage(
      "Новое имя хранилища",
    ),
    "messageRepositoryNewPassword": MessageLookupByLibrary.simpleMessage(
      "Новый пароль",
    ),
    "messageRepositoryNotMounted": MessageLookupByLibrary.simpleMessage(
      "Хранилище не смонтировано ",
    ),
    "messageRepositoryPassword": MessageLookupByLibrary.simpleMessage("Пароль"),
    "messageRepositoryRenamed": m47,
    "messageRepositorySuggestedName": m24,
    "messageRepositoryToken": MessageLookupByLibrary.simpleMessage(
      "Скопируйте ссылку сюда",
    ),
    "messageResetLocalSecret": MessageLookupByLibrary.simpleMessage(
      "Сброс локального секрета",
    ),
    "messageRousseau": MessageLookupByLibrary.simpleMessage("Жан-Жак Руссо"),
    "messageSaveEntriesToDevice": m48,
    "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
      "Сохранить файл в эту папку",
    ),
    "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
      "Хотите сохранить текущие изменения?",
    ),
    "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
      "Просканируйте это с помощью вашего второго устройства или поделитесь с вашими пирами",
    ),
    "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Защищено биометрией",
    ),
    "messageSecurityOptionsNotAvailableBlind":
        MessageLookupByLibrary.simpleMessage(
          "Параметры безопасности недоступны для слепых репозиториев",
        ),
    "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
      "Данные, которые пользователь загружает в хранилища Ouisync, подвергаются сквозному шифрованию как при передаче, так и при хранении. Сюда входят метаданные, такие как имена файлов, размеры, структура папок и т.д. В Ouisync данные доступны для чтения только человеку, который загрузил данные, и тем людям, с которыми они поделились своими хранилищами",
    ),
    "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
      "Вы можете узнать больше об используемых методах шифрования в нашей документации",
    ),
    "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
      "Приложение Ouisync хранит данные пользователей на \"Always-On Peer\", который представляет собой сервер, расположенный в Канаде. Все данные хранятся в виде зашифрованных фрагментов и не могут быть прочитаны сервером или его операторами. Задача этого сервера - просто устранить разрыв между пользователями, которые не находятся в сети одновременно. Все данные периодически удаляются с этого сервера - его цель не обеспечить постоянное хранение данных, а просто облегчить синхронизацию данных между пирами",
    ),
    "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
      "Если у вас есть основания полагать, что ваши личные данные были незаконно получены и переданы другим пользователям Ouisync, свяжитесь с нами по следующему адресу",
    ),
    "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
      "Выберите вид доступа чтобы создать ссылку для раздачи",
    ),
    "messageSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Выбрать местоположение",
    ),
    "messageSettingsRuntimeID": MessageLookupByLibrary.simpleMessage(
      "ID текущей сессии",
    ),
    "messageSettingsVersionNewerThanCurrent": MessageLookupByLibrary.simpleMessage(
      "Настройки этого устройства были созданы в более новой версии Ouisync и не могут быть перенесены.",
    ),
    "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
      "Вы должны сначала выбрать уровень доступа перед созданием ссылки для хранилища",
    ),
    "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
      "Поделиться с помощью QR кода",
    ),
    "messageSharingFileFailed": m49,
    "messageSortBy": m25,
    "messageStorage": MessageLookupByLibrary.simpleMessage("Память"),
    "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
      "Требуется чтобы дать доступ к файлам",
    ),
    "messageStrong": MessageLookupByLibrary.simpleMessage("Отлично"),
    "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "Синхронизировать используя мобильные данные",
    ),
    "messageSyncingIsDisabledOnMobileInternet":
        MessageLookupByLibrary.simpleMessage(
          "Синхронизация через интернет отключена при использовании мобильных данных",
        ),
    "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "Нажмите здесь, чтобы прочитать Условия Использования и Политику Конфиденциальности",
    ),
    "messageTapForValues": MessageLookupByLibrary.simpleMessage(
      "Нажмите здесь, чтобы прочитать наши ценности",
    ),
    "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
      "Нарушает права на защиту личной информации, включая основополагающие ценности или письмо ",
    ),
    "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
      "(Закон о защите личной информации и электронных документах)",
    ),
    "messageTerms2": MessageLookupByLibrary.simpleMessage(
      "Содержит материалы, сексуально эксплуатирующие детей (включая материалы, которые не являются незаконными материалами о сексуальном насилии над детьми, но которые, тем не менее, сексуально эксплуатируют или пропагандируют сексуальную эксплуатацию несовершеннолетних), незаконную порнографию или иным образом непристойны",
    ),
    "messageTerms3": MessageLookupByLibrary.simpleMessage(
      "Содержит или поощряет крайние акты насилия или террористической деятельности, в том числе террор или агрессивную экстремистскую пропаганду",
    ),
    "messageTerms4": MessageLookupByLibrary.simpleMessage(
      "Пропагандирует фанатизм, ненависть или подстрекательство к насилию в отношении любого лица или группы людей на основе их расы, религии, этнической принадлежности, национального происхождения, пола, гендерной идентичности, сексуальной ориентации, инвалидности, неполноценности или любых других характеристик, связанных с системной дискриминацией или маргинализацией",
    ),
    "messageTerms5": MessageLookupByLibrary.simpleMessage(
      "Файлы, которые содержат вирусы, трояны, черви, логические бомбы или другие материалы, которые являются вредоносными или технологически вредными",
    ),
    "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
      "Настоящие Условия использования Ouisync («Соглашение»), а также наше Уведомление о конфиденциальности (совместно именуемые «Условия») регулируют использование Вами Ouisync — протокола и программного обеспечения для онлайн-синхронизации файлов.",
    ),
    "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
      "Устанавливая и запуская приложение Ouisync, Вы выражаете свое согласие соблюдать настоящее Соглашение между Вами и eQualitie Inc. («eQualitie», «мы» или «нас»). Использование приложения Ouisync и сети Ouisync (Сервиса) предоставляется компанией eQualitie бесплатно и предназначено для использования как есть",
    ),
    "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
      "Приложение Ouisync создано в соответствии с ценностями eQualitie. Используя это программное обеспечение, Вы соглашаетесь, что не будете использовать Ouisync для публикации, обмена или хранения материалов, которые противоречат основным ценностям, букве законов Квебека или Канады или Международному биллю о правах человека, включая контент, который:",
    ),
    "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Токен хранилища скопирован в буфер обмена.",
    ),
    "messageUnknownFileExtension": MessageLookupByLibrary.simpleMessage(
      "Неизвестное расширение файла",
    ),
    "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
      "Пароль не открыл хранилище",
    ),
    "messageUnlockRepoOk": m26,
    "messageUnlockRepository": m27,
    "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Открыть с помощью биометрии",
    ),
    "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "У вас есть несохраненные изменения.\n\nХотите их отменить?",
    ),
    "messageUpdateLocalPasswordConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "Обновить локальный пароль этого хранилища?",
        ),
    "messageUpdateLocalSecretFailed": MessageLookupByLibrary.simpleMessage(
      "Обновление свойств безопасности хранилища не удалось.",
    ),
    "messageUpdateLocalSecretOk": MessageLookupByLibrary.simpleMessage(
      "Обновлены свойства безопасности хранилища.",
    ),
    "messageUseCacheServers": MessageLookupByLibrary.simpleMessage(
      "Используйте кэш-серверы",
    ),
    "messageUseLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Использовать локальный пароль",
    ),
    "messageVPN": MessageLookupByLibrary.simpleMessage("ВПН"),
    "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Подтвердить локальный пароль",
    ),
    "messageView": MessageLookupByLibrary.simpleMessage("Посмотреть"),
    "messageWeak": MessageLookupByLibrary.simpleMessage("Слабо"),
    "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
    "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Полный доступ. Вашр пиры могут и просматривать, и изменять содержимое",
    ),
    "messageWritingFileCanceled": m28,
    "messageWritingFileError": m29,
    "openFolder": MessageLookupByLibrary.simpleMessage("Открыть папку"),
    "popupMenuItemChangePassword": MessageLookupByLibrary.simpleMessage(
      "Изменить пароль",
    ),
    "popupMenuItemCopyPassword": MessageLookupByLibrary.simpleMessage(
      "Скопировать пароль",
    ),
    "replacementAccess": m30,
    "replacementChanges": m31,
    "replacementEntry": m32,
    "replacementError": m33,
    "replacementName": m34,
    "replacementNumber": m35,
    "replacementPath": m36,
    "replacementStatus": m37,
    "repoResetAccessTypeInfoBlindOrLocked":
        MessageLookupByLibrary.simpleMessage("Слепой или запертый"),
    "repoResetAccessTypeInfoRead": MessageLookupByLibrary.simpleMessage(
      "Читать",
    ),
    "repoResetAccessTypeInfoWrite": MessageLookupByLibrary.simpleMessage(
      "Писать",
    ),
    "repoResetAccessTypeLabel": MessageLookupByLibrary.simpleMessage(
      "Тип доступа к репозиторию",
    ),
    "repoResetActionAnyToWrite": MessageLookupByLibrary.simpleMessage(
      "Хранилище получит доступ на запись.",
    ),
    "repoResetActionBlindToBlind": MessageLookupByLibrary.simpleMessage(
      "Хранилище станет слепым.",
    ),
    "repoResetActionBlindToBlindWarn": MessageLookupByLibrary.simpleMessage(
      "Доступ к этому хранилищу на чтение или запись может быть заблокирован локальным паролем. Если это так, то после выполнения этого действия разблокировка будет невозможна.",
    ),
    "repoResetActionBlindToRead": MessageLookupByLibrary.simpleMessage(
      "Хранилище станет доступным только для чтения.",
    ),
    "repoResetActionBlindToReadWarn": MessageLookupByLibrary.simpleMessage(
      "Доступ к записи в этом хранилище может быть заблокирован локальным паролем. Если это так, то разблокировка для записи будет невозможна после выполнения этого действия.",
    ),
    "repoResetActionInfoLabel": MessageLookupByLibrary.simpleMessage(
      "Действия, которые должны быть представлены",
    ),
    "repoResetActionReadToBlind": MessageLookupByLibrary.simpleMessage(
      "Хранилище потеряет доступ на чтение.",
    ),
    "repoResetActionReadToBlindWarn": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо без токена на чтение или запись.",
    ),
    "repoResetActionSame": MessageLookupByLibrary.simpleMessage(
      "Никаких действий не будет выполнено, поскольку токен и доступ к хранилищу одинаковы.",
    ),
    "repoResetActionWriteToBlind": MessageLookupByLibrary.simpleMessage(
      "Хранилище потеряет доступ на чтение и запись.",
    ),
    "repoResetActionWriteToBlindWarn": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо без токена записи.",
    ),
    "repoResetActionWriteToRead": MessageLookupByLibrary.simpleMessage(
      "Хранилище потеряет доступ на запись.",
    ),
    "repoResetActionWriteToReadWarn": MessageLookupByLibrary.simpleMessage(
      "Это действие необратимо без токена.",
    ),
    "repoResetAuthInfoBlindOrLocked": MessageLookupByLibrary.simpleMessage(
      "Репозиторий либо анонимен, либо заблокирован локальным паролем",
    ),
    "repoResetAuthInfoBlindOrLockedWarn": MessageLookupByLibrary.simpleMessage(
      "Приложение не видит разницы.",
    ),
    "repoResetAuthInfoKeyIsStored": MessageLookupByLibrary.simpleMessage(
      "Ключ хранится на этом устройстве.",
    ),
    "repoResetAuthInfoKeyIsStoredAndProtected":
        MessageLookupByLibrary.simpleMessage(
          "Ключ хранится на этом устройстве, и для открытия хранилища требуется дополнительная проверка.",
        ),
    "repoResetAuthInfoLabel": MessageLookupByLibrary.simpleMessage(
      "Метод аутентификации",
    ),
    "repoResetAuthInfoLocked": MessageLookupByLibrary.simpleMessage(
      "Заблокирован локальным паролем.",
    ),
    "repoResetAuthInfoPasswordIsStored": MessageLookupByLibrary.simpleMessage(
      "Пароль хранится на этом устройстве.",
    ),
    "repoResetConfirmUpdateMessage": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите продолжить действие \"Обновить\"?",
    ),
    "repoResetConfirmUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Пожалуйста, подтвердите",
    ),
    "repoResetRepoNameLabel": MessageLookupByLibrary.simpleMessage(
      "Имя репозитория",
    ),
    "repoResetTitle": MessageLookupByLibrary.simpleMessage(
      "Сброс доступа к хранилищу",
    ),
    "repoResetTokenAlreadySubmitted": MessageLookupByLibrary.simpleMessage(
      "Действие не будет выполнено, поскольку токен уже отправлен.",
    ),
    "repoResetTokenEmptyInfo": MessageLookupByLibrary.simpleMessage(
      "Укажите действительную ссылку на маркер для определения действия.",
    ),
    "repoResetTokenInvalid": MessageLookupByLibrary.simpleMessage("Неверный"),
    "repoResetTokenInvalidInfo": MessageLookupByLibrary.simpleMessage(
      "Ссылка на токен недействительна.",
    ),
    "repoResetTokenNonMatching": MessageLookupByLibrary.simpleMessage(
      "Действие не может быть выполнено, поскольку токен не соответствует данному хранилищу.",
    ),
    "repoResetTokenTypeLabel": MessageLookupByLibrary.simpleMessage(
      "Тип доступа к токену",
    ),
    "repoStorageLocation": MessageLookupByLibrary.simpleMessage("Расположение"),
    "repoStorageMovePrompt": m50,
    "repoStorageMoveTitle": MessageLookupByLibrary.simpleMessage(
      "Переместить репозиторий",
    ),
    "repositoryIsAlreadyImported": MessageLookupByLibrary.simpleMessage(
      "Хранилище уже импортируется",
    ),
    "sortByNameLabel": MessageLookupByLibrary.simpleMessage("Имя"),
    "sortBySizeLabel": MessageLookupByLibrary.simpleMessage("Размер"),
    "sortByTypeLabel": MessageLookupByLibrary.simpleMessage("Тип"),
    "statusSync": MessageLookupByLibrary.simpleMessage("СИНХРОНИЗИРОВАНО"),
    "statusUnspecified": MessageLookupByLibrary.simpleMessage("Не указано"),
    "titleAbout": MessageLookupByLibrary.simpleMessage("О приложении"),
    "titleAddFile": MessageLookupByLibrary.simpleMessage(
      "Добавить файл в Ouisync",
    ),
    "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище с помощью токена",
    ),
    "titleAddRepository": MessageLookupByLibrary.simpleMessage(
      "Импортировать хранилище",
    ),
    "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
    "titleApplicationLanguage": MessageLookupByLibrary.simpleMessage(
      "Язык приложения",
    ),
    "titleBackgroundAndroidPermissionsTitle":
        MessageLookupByLibrary.simpleMessage("Требуется разрешение"),
    "titleChangePassword": MessageLookupByLibrary.simpleMessage(
      "Изменить пароль",
    ),
    "titleChangesToTerms": MessageLookupByLibrary.simpleMessage(
      "Правки в данные Условия",
    ),
    "titleChildrensPrivacy": MessageLookupByLibrary.simpleMessage(
      "Конфиденциальность детей",
    ),
    "titleContactUs": MessageLookupByLibrary.simpleMessage("Свяжитесь с нами"),
    "titleCookies": MessageLookupByLibrary.simpleMessage("Куки (Cookies)"),
    "titleCopyEntries": MessageLookupByLibrary.simpleMessage("Копировать"),
    "titleCopyingEntry": MessageLookupByLibrary.simpleMessage(
      "Копирование записи",
    ),
    "titleCreateFolder": MessageLookupByLibrary.simpleMessage("Создать папку"),
    "titleCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Создать новое хранилище",
    ),
    "titleDataCollection": MessageLookupByLibrary.simpleMessage(
      "3.1 Сбор данных",
    ),
    "titleDataSharing": MessageLookupByLibrary.simpleMessage(
      "3.2 Передача данных",
    ),
    "titleDeleteEntries": MessageLookupByLibrary.simpleMessage("Удалить"),
    "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Удалить файл"),
    "titleDeleteFolder": MessageLookupByLibrary.simpleMessage("Удалить папку"),
    "titleDeleteNotEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "Удалить не пустую папку",
    ),
    "titleDeleteRepository": MessageLookupByLibrary.simpleMessage(
      "Удалить хранилище",
    ),
    "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
      "3.4 Удаление ваших данных с нашего Always-On-Peer сервера",
    ),
    "titleDigitalSecurity": MessageLookupByLibrary.simpleMessage(
      "Цифровая Безопасность",
    ),
    "titleDokanInstallation": MessageLookupByLibrary.simpleMessage(
      "Установка Dokan",
    ),
    "titleDokanInstallationFound": MessageLookupByLibrary.simpleMessage(
      "Установка Dokan найдена",
    ),
    "titleDokanMissing": MessageLookupByLibrary.simpleMessage("Dokan пропал"),
    "titleDownloadLocation": MessageLookupByLibrary.simpleMessage(
      "Путь загрузок",
    ),
    "titleDownloadToDevice": MessageLookupByLibrary.simpleMessage(
      "Скачать на устройство",
    ),
    "titleEditRepository": MessageLookupByLibrary.simpleMessage(
      "Изменить хранилище",
    ),
    "titleEqualitiesValues": MessageLookupByLibrary.simpleMessage(
      "Ценности eQualitie",
    ),
    "titleFAQShort": MessageLookupByLibrary.simpleMessage("FAQ"),
    "titleFileDetails": MessageLookupByLibrary.simpleMessage(
      "Информация о файле",
    ),
    "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
      "Изменено расширение файла",
    ),
    "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
      "Не хватает расширения файла",
    ),
    "titleFolderActions": MessageLookupByLibrary.simpleMessage("Добавить"),
    "titleFolderDetails": MessageLookupByLibrary.simpleMessage(
      "Информация о папке",
    ),
    "titleFreedomExpressionAccessInfo": MessageLookupByLibrary.simpleMessage(
      "Свобода выражения и доступа к информации",
    ),
    "titleIssueTracker": MessageLookupByLibrary.simpleMessage("Трекер проблем"),
    "titleJustLegalSociety": MessageLookupByLibrary.simpleMessage(
      "Справедливое и правовое общество",
    ),
    "titleLanAccessDenied": MessageLookupByLibrary.simpleMessage(
      "Доступ к локальной сети запрещён",
    ),
    "titleLinksOtherSites": MessageLookupByLibrary.simpleMessage(
      "Ссылки на Другие сайты",
    ),
    "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
      "Заблокировать все хранилища",
    ),
    "titleLogData": MessageLookupByLibrary.simpleMessage("Логи данных"),
    "titleLogs": MessageLookupByLibrary.simpleMessage("Логи"),
    "titleMoveEntries": MessageLookupByLibrary.simpleMessage("Переместить"),
    "titleMovingEntry": MessageLookupByLibrary.simpleMessage("Переместить"),
    "titleNetwork": MessageLookupByLibrary.simpleMessage("Сеть"),
    "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "Доступ к файлам с нескольких устройств",
    ),
    "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "Установите разрешения для совместной работы, передачи или просто хранения",
    ),
    "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "Отправляйте и получайте файлы безопасно",
    ),
    "titleOpennessTransparency": MessageLookupByLibrary.simpleMessage(
      "Открытость и Прозрачность",
    ),
    "titleOurMission": MessageLookupByLibrary.simpleMessage("Наша миссия"),
    "titleOurPrinciples": MessageLookupByLibrary.simpleMessage("Наши Принципы"),
    "titleOurValues": MessageLookupByLibrary.simpleMessage("Наши ценности"),
    "titleOverview": MessageLookupByLibrary.simpleMessage("1. Обзор"),
    "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
      "Закон о защите личных сведений и электронных документов",
    ),
    "titlePrivacy": MessageLookupByLibrary.simpleMessage("Приватность"),
    "titlePrivacyNotice": MessageLookupByLibrary.simpleMessage(
      "3. Политика приватности",
    ),
    "titlePrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика конфиденциальности",
    ),
    "titleRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "Удалить биометрию",
    ),
    "titleRepositoriesList": MessageLookupByLibrary.simpleMessage(
      "Мои репозитории",
    ),
    "titleRepository": MessageLookupByLibrary.simpleMessage("Хранилище"),
    "titleRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Название хранилища",
    ),
    "titleRequiredPermission": MessageLookupByLibrary.simpleMessage(
      "Требуется разрешение",
    ),
    "titleSaveChanges": MessageLookupByLibrary.simpleMessage(
      "Сохранить изменения",
    ),
    "titleSaveEntriesToDevice": MessageLookupByLibrary.simpleMessage(
      "Сохранить на устройстве",
    ),
    "titleScanRepoQR": MessageLookupByLibrary.simpleMessage(
      "Сканировать QR-код хранилища",
    ),
    "titleSecurity": MessageLookupByLibrary.simpleMessage("Безопасность"),
    "titleSecurityPractices": MessageLookupByLibrary.simpleMessage(
      "3.3 Методы обеспечения безопасности",
    ),
    "titleSendFeedback": MessageLookupByLibrary.simpleMessage(
      "Отправить фидбек",
    ),
    "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
      "Поставить пароль для",
    ),
    "titleSettings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "titleShareRepository": m38,
    "titleSortBy": MessageLookupByLibrary.simpleMessage("Отсортировать по"),
    "titleStateMonitor": MessageLookupByLibrary.simpleMessage(
      "Анализ состояния",
    ),
    "titleTermsOfUse": MessageLookupByLibrary.simpleMessage(
      "2. Условия использования",
    ),
    "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "Условия использования и Уведомление о приватности Ouisync",
    ),
    "titleUPnP": MessageLookupByLibrary.simpleMessage(
      "Универсальный Plug and Play (UPnP)",
    ),
    "titleUnlockRepository": MessageLookupByLibrary.simpleMessage(
      "Разблокировать хранилише",
    ),
    "titleUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "Изменения не сохранены",
    ),
    "titleUserProvidedPeers": MessageLookupByLibrary.simpleMessage(
      "Предоставленные пользователем сверстники",
    ),
    "titleWeAreEq": MessageLookupByLibrary.simpleMessage("Мы — eQualit.ie"),
    "typeFile": MessageLookupByLibrary.simpleMessage("Файл"),
    "typeFolder": MessageLookupByLibrary.simpleMessage("Папка"),
  };
}
