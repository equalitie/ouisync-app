// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fa locale. All the
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
  String get localeName => 'fa';

  static String m0(access) =>
      "مجوز مورد نظر نمی‌تواند بالاتر از حالت دسترسی فعلی مخزن باشد: ${access}";

  static String m3(path) => "فایل دانلود شد در ${path}";

  static String m4(name) => "${name} - دانلود لغو شد";

  static String m5(name) => "${name} - ناموفق در دانلود";

  static String m6(entry) => "${entry} در حال حاضر موجود است.";

  static String m8(path) => "پوشه فعلی موجود نیست، به بخش اصلی بروید: ${path}";

  static String m9(error) => "خطا: ${error}";

  static String m10(dokanUrl) =>
      "فایل نصب رابط کاربری Dokan پیدا نشد. ${dokanUrl}";

  static String m11(name) => "آماده‌سازی اولیه مخزن ${name} ناموفق بود";

  static String m12(path) => "${path} خالی نیست";

  static String m15(reason) =>
      "دسترسی به مخازن از طریق بخش جست‌وجوگر فایل در دسترس نیست: ${reason}";

  static String m16(name) =>
      "${name} از قبل در این‌جا وجود دارد.\n\nمی‌خواهید چه کاری بکنید؟";

  static String m19(name) => "پوشه با موفقیت حذف شد: ${name}";

  static String m21(number) =>
      "آیا می‌خواهید تمام مخازنی را که باز هستند قفل کنید؟\n\n(${number} باز)";

  static String m23(path) => "از ${path}";

  static String m24(name) => "خطا در ایجاد فایل ${name}";

  static String m25(name) => "خطا در باز کردن فایل ${name}";

  static String m26(path) => "فرآیند پیش‌نمایش فایل ${path} انجام نشد";

  static String m27(name) => "نتوانستیم این مخزن را حذف کنیم: \"${name}\"";

  static String m28(name) =>
      "نتوانستیم این مخزن را در مکانی که معمولا هست، بیابیم: \"${name}\"";

  static String m29(access) => "اجازه دسترسی داده شد: ${access}";

  static String m30(name) =>
      "این مخزن از قبل در برنامه با نامِ \"${name}\" وجود دارد.";

  static String m33(name) =>
      "پیشنهاد: ${name}\n(برای استفاده از این نام این‌جا ضربه بزنید)";

  static String m35(name) => "‌مرتب‌سازی بر اساس:${name}";

  static String m36(access) => "به‌عنوان یک کپیِ ${access} باز شد";

  static String m37(name) => "رمز عبور را برای باز کردن قفل وارد کنید. ${name}";

  static String m38(name) => "${name} نوشتن لغو شد";

  static String m39(name) => "${name} - ناموفق در نوشتن";

  static String m40(access) => "[دسترسی]";

  static String m41(changes) => "${changes}";

  static String m42(entry) => "${entry}";

  static String m43(error) => "خطا ${error}";

  static String m44(name) => "${name}";

  static String m45(number) => "[شماره]";

  static String m46(path) => "${path}";

  static String m47(status) => "${status}";

  static String m48(name) => "اشتراک‌گذاری مخزن \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accessModeBlindLabel": MessageLookupByLibrary.simpleMessage("کور"),
    "accessModeReadLabel": MessageLookupByLibrary.simpleMessage("نوشتنی"),
    "accessModeWriteLabel": MessageLookupByLibrary.simpleMessage("خواندنی"),
    "actionAccept": MessageLookupByLibrary.simpleMessage("تایید"),
    "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("تایید"),
    "actionAddRepository": MessageLookupByLibrary.simpleMessage(
      "وارد کردن یک مخزن",
    ),
    "actionAddRepositoryWithToken": MessageLookupByLibrary.simpleMessage(
      "وارد کردن مخزن",
    ),
    "actionBack": MessageLookupByLibrary.simpleMessage("بازگشت"),
    "actionCancel": MessageLookupByLibrary.simpleMessage("لغو"),
    "actionCancelCapital": MessageLookupByLibrary.simpleMessage("لغو"),
    "actionClear": MessageLookupByLibrary.simpleMessage("پاک‌ کردن"),
    "actionCloseCapital": MessageLookupByLibrary.simpleMessage("بستن"),
    "actionCreate": MessageLookupByLibrary.simpleMessage("ایجاد"),
    "actionCreateRepository": MessageLookupByLibrary.simpleMessage(
      "ایجاد مخزن",
    ),
    "actionDelete": MessageLookupByLibrary.simpleMessage("حذف"),
    "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("حذف"),
    "actionDeleteFile": MessageLookupByLibrary.simpleMessage("حذف فایل"),
    "actionDeleteFolder": MessageLookupByLibrary.simpleMessage("حذف پوشه"),
    "actionDeleteRepository": MessageLookupByLibrary.simpleMessage("حذف مخزن"),
    "actionDiscard": MessageLookupByLibrary.simpleMessage("نادیده‌ گرفتن"),
    "actionDone": MessageLookupByLibrary.simpleMessage("انجام شد"),
    "actionEditRepositoryName": MessageLookupByLibrary.simpleMessage(
      "ویرایش نام",
    ),
    "actionEject": MessageLookupByLibrary.simpleMessage("خروج"),
    "actionExit": MessageLookupByLibrary.simpleMessage("خروج"),
    "actionGoToSettings": MessageLookupByLibrary.simpleMessage(
      "به بخش تنظیمات بروید",
    ),
    "actionHide": MessageLookupByLibrary.simpleMessage("پنهان‌سازی"),
    "actionHideCapital": MessageLookupByLibrary.simpleMessage("پنهان‌سازی"),
    "actionIAgree": MessageLookupByLibrary.simpleMessage("موافقم"),
    "actionIDontAgree": MessageLookupByLibrary.simpleMessage("موافق نیستم"),
    "actionImport": MessageLookupByLibrary.simpleMessage("وارد کردن"),
    "actionImportRepo": MessageLookupByLibrary.simpleMessage("وارد کردن مخزن"),
    "actionInstallDokan": MessageLookupByLibrary.simpleMessage(
      "نصب رابط کاربری Dokan",
    ),
    "actionLocateRepo": MessageLookupByLibrary.simpleMessage(
      "موقعیت‌یابی مخزن",
    ),
    "actionLockCapital": MessageLookupByLibrary.simpleMessage("قفل کردن"),
    "actionMove": MessageLookupByLibrary.simpleMessage("انتقال"),
    "actionNewFile": MessageLookupByLibrary.simpleMessage("فایل"),
    "actionNewFolder": MessageLookupByLibrary.simpleMessage("پوشه"),
    "actionNewMediaFile": MessageLookupByLibrary.simpleMessage("رسانه"),
    "actionNewRepo": MessageLookupByLibrary.simpleMessage("ایجاد مخزن"),
    "actionNext": MessageLookupByLibrary.simpleMessage("بعدی"),
    "actionNo": MessageLookupByLibrary.simpleMessage("خیر"),
    "actionOK": MessageLookupByLibrary.simpleMessage("اوکی"),
    "actionPreviewFile": MessageLookupByLibrary.simpleMessage("پیش‌نمایش فایل"),
    "actionReloadContents": MessageLookupByLibrary.simpleMessage(
      "بارگذاری مجدد",
    ),
    "actionReloadRepo": MessageLookupByLibrary.simpleMessage(
      "بارگذاری مجدد مخزن",
    ),
    "actionRemove": MessageLookupByLibrary.simpleMessage("حذف"),
    "actionRemoveLocalPassword": MessageLookupByLibrary.simpleMessage(
      "حذف رمز عبور محلی",
    ),
    "actionRemoveRepo": MessageLookupByLibrary.simpleMessage("حذف مخزن"),
    "actionRename": MessageLookupByLibrary.simpleMessage("تغییر نام"),
    "actionRetry": MessageLookupByLibrary.simpleMessage("دوباره سعی کنید"),
    "actionSave": MessageLookupByLibrary.simpleMessage("ذخیره"),
    "actionSaveChanges": MessageLookupByLibrary.simpleMessage("ذخیره تغییرات"),
    "actionScanQR": MessageLookupByLibrary.simpleMessage("کد QR را اسکن کنید"),
    "actionShare": MessageLookupByLibrary.simpleMessage("اشتراک‌گذاری‌"),
    "actionShareFile": MessageLookupByLibrary.simpleMessage(
      "به‌اشتراک‌گذاری فایل",
    ),
    "actionShow": MessageLookupByLibrary.simpleMessage("نمایش"),
    "actionSkip": MessageLookupByLibrary.simpleMessage("صرف نظر"),
    "actionUndo": MessageLookupByLibrary.simpleMessage("بازگرداندن"),
    "actionUnlock": MessageLookupByLibrary.simpleMessage("باز کردن قفل"),
    "actionUpdate": MessageLookupByLibrary.simpleMessage("به‌روزرسانی"),
    "actionUpdateDokan": MessageLookupByLibrary.simpleMessage(
      "به‌روزرسانی Dokan",
    ),
    "actionYes": MessageLookupByLibrary.simpleMessage("بله"),
    "buttonLocateRepository": MessageLookupByLibrary.simpleMessage(
      "موقعیت‌یابی",
    ),
    "iconAccessMode": MessageLookupByLibrary.simpleMessage("حالت دسترسی"),
    "iconAddExistingRepository": MessageLookupByLibrary.simpleMessage(
      "وارد کردن یک مخزن",
    ),
    "iconCreateRepository": MessageLookupByLibrary.simpleMessage(
      "ایجاد مخزن جدید",
    ),
    "iconDelete": MessageLookupByLibrary.simpleMessage("حذف"),
    "iconDownload": MessageLookupByLibrary.simpleMessage("دانلود"),
    "iconInformation": MessageLookupByLibrary.simpleMessage("اطلاعات"),
    "iconMove": MessageLookupByLibrary.simpleMessage("انتقال"),
    "iconPreview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
    "iconRename": MessageLookupByLibrary.simpleMessage("تغییر نام"),
    "iconShare": MessageLookupByLibrary.simpleMessage("اشتراک‌گذاری‌"),
    "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
      "این را با همتاهای خود به‌‌اشتراک بگذارید",
    ),
    "labelAppVersion": MessageLookupByLibrary.simpleMessage("نسخه اپلیکیشن"),
    "labelAttachLogs": MessageLookupByLibrary.simpleMessage(
      "ضمیمه کردن فایل گزارش‌ها",
    ),
    "labelBitTorrentDHT": MessageLookupByLibrary.simpleMessage(
      "جدول درهم‌سازی توزیع‌شده (DHT) بیت‌تورنت",
    ),
    "labelConnectionType": MessageLookupByLibrary.simpleMessage("نوع اتصال"),
    "labelCopyLink": MessageLookupByLibrary.simpleMessage("کپی کردن لینک"),
    "labelDestination": MessageLookupByLibrary.simpleMessage("مقصد"),
    "labelDownloadedTo": MessageLookupByLibrary.simpleMessage("دانلود شده در:"),
    "labelEndpoint": MessageLookupByLibrary.simpleMessage("گرهِ انتهایی "),
    "labelExternalIPv4": MessageLookupByLibrary.simpleMessage("External IPv4‌"),
    "labelExternalIPv6": MessageLookupByLibrary.simpleMessage("External IPv6‌"),
    "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("Local IPv4‌"),
    "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("Local IPv6‌"),
    "labelLocation": MessageLookupByLibrary.simpleMessage("موقعیت مکانی: "),
    "labelLockAllRepos": MessageLookupByLibrary.simpleMessage("قفل‌ کردن همگی"),
    "labelName": MessageLookupByLibrary.simpleMessage("نام: "),
    "labelNewName": MessageLookupByLibrary.simpleMessage("نام جدید "),
    "labelPassword": MessageLookupByLibrary.simpleMessage("رمز عبور: "),
    "labelPeers": MessageLookupByLibrary.simpleMessage("همتاها"),
    "labelQRCode": MessageLookupByLibrary.simpleMessage("کد QR"),
    "labelQuicListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Listening on QUIC/UDP IPv4‌",
    ),
    "labelQuicListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Listening on QUIC/UDP IPv6‌",
    ),
    "labelRememberPassword": MessageLookupByLibrary.simpleMessage(
      "به‌خاطر سپردن رمز عبور",
    ),
    "labelRenameRepository": MessageLookupByLibrary.simpleMessage(
      "نام جدید را وارد کنید: ",
    ),
    "labelRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "رمز عبور فعلی",
    ),
    "labelRepositoryLink": MessageLookupByLibrary.simpleMessage("لینک مخزن: "),
    "labelRetypePassword": MessageLookupByLibrary.simpleMessage(
      "تایپ دوباره رمز عبور: ",
    ),
    "labelSelectRepository": MessageLookupByLibrary.simpleMessage(
      "انتخاب مخزن: ",
    ),
    "labelSetPermission": MessageLookupByLibrary.simpleMessage("تنظیم مجوز"),
    "labelShareLink": MessageLookupByLibrary.simpleMessage("اشتراک‌گذاری لینک"),
    "labelSize": MessageLookupByLibrary.simpleMessage("سایز: "),
    "labelSyncStatus": MessageLookupByLibrary.simpleMessage(
      "وضعیت همگام‌سازی: ",
    ),
    "labelSynced": MessageLookupByLibrary.simpleMessage("همگام‌سازی‌شده"),
    "labelTcpListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Listening on TCP IPv4‌",
    ),
    "labelTcpListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Listening on TCP IPv6‌",
    ),
    "labelTokenLink": MessageLookupByLibrary.simpleMessage(
      "لینک اشتراک‌گذاری مخزن",
    ),
    "labelTypePassword": MessageLookupByLibrary.simpleMessage(
      "رمز عبور را بنویسید: ",
    ),
    "labelUseExternalStorage": MessageLookupByLibrary.simpleMessage(
      "استفاده از حافظه خارجی",
    ),
    "languageIsNotAvailable": MessageLookupByLibrary.simpleMessage(
      "در دسترس نیست",
    ),
    "languageOfTheDevice": MessageLookupByLibrary.simpleMessage("زبان دستگاه"),
    "menuItemAbout": MessageLookupByLibrary.simpleMessage("درباره ما"),
    "menuItemLogs": MessageLookupByLibrary.simpleMessage("گزارش‌ها"),
    "menuItemNetwork": MessageLookupByLibrary.simpleMessage("شبکه"),
    "menuItemRepository": MessageLookupByLibrary.simpleMessage("مخزن"),
    "messageAccessModeDisabled": m0,
    "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
      "دسترسی به فضای ذخیره‌سازی امن",
    ),
    "messageAck": MessageLookupByLibrary.simpleMessage("ای بابا!"),
    "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "این گزینه در مخازن فقط خواندنی موجود نیست",
    ),
    "messageAddRepoDb": MessageLookupByLibrary.simpleMessage(
      "وارد کردن مخزن از فایل سیستم",
    ),
    "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
      "یک مخزن را با استفاده از لینک توکن وارد کنید",
    ),
    "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
      "یک مخزن را با استفاده از یک کد QR وارد کنید",
    ),
    "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
      "این مخزن قفل شده یا دارای مجوز کور است.\n\nاگر رمز عبور را دارید، قفل آن را باز کنید و دوباره امتحان کنید.",
    ),
    "messageAddingFileToReadRepository": MessageLookupByLibrary.simpleMessage(
      "این مخزن یک کپی فقط خواندنی است.",
    ),
    "messageAuthenticate": MessageLookupByLibrary.simpleMessage("احراز هویت"),
    "messageAutomaticUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage("نتوانستیم قفل مخزن را باز کنیم"),
    "messageAvailableOnMobile": MessageLookupByLibrary.simpleMessage(
      "در موبایل در دسترس است",
    ),
    "messageAwaitingResult": MessageLookupByLibrary.simpleMessage(
      "در انتظار نتیجه...",
    ),
    "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
      "به‌زودی سیستم‌عامل از شما اجازه می‌خواهد تا این برنامه را در پس‌زمینه اجرا کند.\n\nاین کار برای ادامه همگام‌سازی هنگامی که برنامه در پیش‌زمینه فعال نیست، ضروری است",
    ),
    "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
      "ناموفق در احراز هویت بیومتریک",
    ),
    "messageBiometricUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "باز کردن قفل بیومتریک ناموفق بود",
        ),
    "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "همتای شما نمی‌تواند محتواها را بنویسد و بخواند",
    ),
    "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
      "این مخزن یک کپی با مجوز کور است.",
    ),
    "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
      "<bold>رمز عبور</bold> ارائه‌شده امکان مشاهده محتوای این مخزن را به شما نمی‌دهد.",
    ),
    "messageBluetooth": MessageLookupByLibrary.simpleMessage("بلوتوث"),
    "messageBy": MessageLookupByLibrary.simpleMessage("توسط"),
    "messageCamera": MessageLookupByLibrary.simpleMessage("دوربین"),
    "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
      "برای استفاده از دوربین و خواندن کد QR به این مجوز نیاز داریم",
    ),
    "messageCanadaPrivacyAct": MessageLookupByLibrary.simpleMessage(
      "قانون حفظ حریم خصوصی کانادا",
    ),
    "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
      "تغییر پسوند یک فایل می تواند آن‌را غیرقابل استفاده کند",
    ),
    "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
      "ممکن است شرایط استفاده (خدمات) خود را هر از چندگاهی به‌روز کنیم. بنابراین، به شما توصیه می‌شود برای اطلاع از هر‌گونه تغییر، این صفحه را به صورت دوره‌ای مرور کنید",
    ),
    "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
      "این سیاست (خط مشی) از تاریخ ۹ مارس ۲۰۲۲ میلادی قابل اجراست",
    ),
    "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
      "ما به طور آگاهانه اطلاعات شخصی قابل شناسایی از کودکان جمع‌آوری نمی‌کنیم. از تمامی کودکان می‌خواهیم که هیچ‌گاه اطلاعات شخصی قابل شناسایی خود را از طریق برنامه و/یا خدمات ارسال نکنند. همچنین به والدین و سرپرستان قانونی توصیه می‌کنیم تا بر استفاده فرزندانشان از اینترنت نظارت کنند و با راهنمایی فرزندانشان در این زمینه که بدون اجازه آن‌ها هیچ‌گونه اطلاعات شخصی قابل شناسایی را از طریق برنامه و/یا خدمات ارائه ندهند، به اجرای این سیاست کمک کنند. اگر دلیلی دارید که باور کنید کودکی از طریق برنامه و/یا خدمات اطلاعات شخصی قابل شناسایی را برای ما ارسال کرده است، لطفا با ما تماس بگیرید. همچنین شما باید حداقل ۱۶ سال سن داشته باشید تا بتوانید با پردازش اطلاعات شخصی قابل شناسایی خود در کشور خود موافقت کنید (در برخی کشورها ممکن است والدین یا سرپرستان قانونی شما بتوانند این کار را از طرف شما انجام دهند)",
    ),
    "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
      "مطمئنید که می‌خواهید این فایل را حذف کنید؟",
    ),
    "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "مطمئنید که می‌خواهید این پوشه را حذف کنید؟",
    ),
    "messageConfirmIrreversibleChange": MessageLookupByLibrary.simpleMessage(
      "این اقدام بازگشت‌ناپذیر خواهد بود، مایلید ادامه دهید؟",
    ),
    "messageConfirmNotEmptyFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "این پوشه خالی نیست\n\nهنوز می‌خواهید حذفش کنید؟ (با این کار تمام محتویاتش حذف می‌شود)",
    ),
    "messageConfirmRepositoryDeletion": MessageLookupByLibrary.simpleMessage(
      "مطمئنید که می‌خواهید این مخزن را حذف کنید؟",
    ),
    "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
      "در صورتی که در مورد خط مشی حفظ حریم خصوصی ما سؤال یا پیشنهادی دارید، حتما با ما تماس بگیرید",
    ),
    "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
      "اپلیکیشن وی‌سینک از کوکی‌ها استفاده نمی‌کند",
    ),
    "messageCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "در کلیپ‌بورد کپی شد.",
    ),
    "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
      "با استفاده از <icon></icon> یک <bold>پوشه</bold> جدید ایجاد کنید، یا یک <bold>فایل</bold> اضافه کنید",
    ),
    "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
      "یک <bold>مخزن</bold> ایجاد کنید یا با استفاده از <bold>توکن مخزن</bold> به یکی از دوستان‌تان لینک شوید",
    ),
    "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
      "در حال ایجاد توکن اشتراکی…",
    ),
    "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
      "تیم وی‌سینک برای حریم خصوصی کاربر ارزش قائل است و بنابراین هیچ اطلاعات کاربری را جمع آوری نمی‌کند",
    ),
    "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
      "اپلیکیشن وی‌سینک به گونه‌ای طراحی شده که می‌تواند خدمات اشتراک فایل را بدون شناسه کاربر، نام، نام مستعار، حساب کاربری یا هر شکل دیگری از اطلاعات کاربر ارائه دهد. ما نمی‌دانیم چه کسی از برنامه ما استفاده می‌کند و با چه کسی داده‌های خود را همگام‌سازی می‌کند یا به‌اشتراک می‌گذارد",
    ),
    "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
      "وی‌سینک (و eQualit.ie) هیچ اطلاعاتی را با طرف‌های ثالث به‌اشتراک نمی‌گذارد",
    ),
    "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
      "اعلامیه خدمات آنلاین توزیع‌شده",
    ),
    "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
      "تیم وی‌سینک نمی تواند فایل‌های شخصی را از مخازن حذف کند، زیرا شناسایی آن‌ها به علت رمزنگاری ممکن نیست. اگر لینک مخزنی که باید حذف شود را برای ما ارسال کنید، می توانیم کل مخازن را حذف کنیم",
    ),
    "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
      "ساده‌ترین راه برای حذف داده‌های خود، حذف فایل‌ها یا مخازن از دستگاه خودتان است. هرگونه حذف فایل به همه همتایان شما اطلاع‌رسانی خواهد شد(منتشر خواهد شد) - به عنوان مثال، اگر به یک مخزن دسترسی نوشتنی دارید، می توانید فایل‌های موجود در آن را حذف کنید و همان فایل‌ها از مخازن همتایان شما و همچنین از همتای همیشه فعال ما حذف خواهند شد. اگر نیاز دارید که فقط مخازن را از سرور همتای همیشه فعال Always-On-Peer ما حذف کنید (اما همچنان آن‌ها را در مخزن خود در دستگاه خود نگه دارید)، لطفا با آدرس زیر با ما تماس بگیرید",
    ),
    "messageDistributedHashTables": MessageLookupByLibrary.simpleMessage(
      "جداول هش توزیع‌شده",
    ),
    "messageDokan": MessageLookupByLibrary.simpleMessage(
      "رابط نرم‌افزاری دکان (Dokan)",
    ),
    "messageDokanDifferentMayorP1": MessageLookupByLibrary.simpleMessage(
      "نصب‌شده",
    ),
    "messageDokanDifferentMayorP2": MessageLookupByLibrary.simpleMessage(
      "قدیمی است. لطفا آن را به آخرین نسخه به‌روزرسانی کنید.",
    ),
    "messageDokanInstallationFailed": MessageLookupByLibrary.simpleMessage(
      "نصب رابط کاربری Dokan موفقیت‌آمیز نبود.",
    ),
    "messageDokanOlderVersionP2": MessageLookupByLibrary.simpleMessage(
      "قدیمی است.\n\nلطفا نسخه موجود رابط کاربری Dokan را حذف کنید، سیستم را مجدد راه‌اندازی و وی‌سینک را دوباره اجرا کنید.",
    ),
    "messageDownloadFileCanceled": MessageLookupByLibrary.simpleMessage(
      "دانلود فایل لغو شد",
    ),
    "messageDownloadFileLocation": m3,
    "messageDownloadingFileCanceled": m4,
    "messageDownloadingFileError": m5,
    "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "این <bold>پوشه</bold> خالی است",
    ),
    "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
      "این <bold>مخزن</bold> خالی است",
    ),
    "messageEnterDifferentName": MessageLookupByLibrary.simpleMessage(
      "لطفا نام دیگری وارد کنید",
    ),
    "messageEntryAlreadyExist": m6,
    "messageEntryTypeDefault": MessageLookupByLibrary.simpleMessage("یک ورودی"),
    "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("یک فایل"),
    "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage("یک پوشه"),
    "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
      "حقوق اساسی و آزادی‌های اساسی ذاتی و سلب‌نشدنی‌اند و به‌طور برابر برای همگان اعمال می‌شوند. حقوق بشر جهانی است؛ در قوانین بین‌الملل محافظت شده و در: ",
    ),
    "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
      "به عنوان یک سازمان، ما به دنبال شفافیت در سیاست‌ها و رویه‌های خود هستیم. تا آنجا که ممکن است، کد منبع ما باز و آزادانه در دسترس است، و توسط مجوزهایی محافظت می‌شود که توسعه جامعه‌محور، به‌اشتراک‌گذاری و انتشار این اصول و ارزش‌ها را ترغیب و تشویق می‌کنند",
    ),
    "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
      "توانایی بیان و اظهارنظر آزادانه و دسترسی به اطلاعات عمومی، ستون فقرات یک دموکراسی واقعی است. اطلاعات عمومی باید در حوزه عمومی باشد. آزادی بیان شامل بحث‌های فعال و داغ است، حتی بحث و استدلال‌هایی که به‌طور نامطلوب بیان شده‌اند، ساختار ضعیفی دارند و ممکن است برای برخی توهین‌آمیز تلقی شوند. اما آزادی بیان یک حق مطلق نیست. ما قاطعانه برابر خشونت و تحریک برای نقض حقوق دیگران، به‌ویژه ترویج خشونت، نفرت، تبعیض و سلب حق رای از هر گروه قومی یا گروه اجتماعی قابل شناسایی، ایستاده‌ایم",
    ),
    "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
      "ما از داخل کشورهای مختلف فعالیت می‌کنیم و از زمینه‌ها و گروه‌های متفاوت اجتماعی گردهم جمع شده‌ایم. ما به همراه هم برای جامعه‌ای فعالیت می‌کنیم که به حقوق دیگران در دنیای فیزیکی و دیجیتالی احترام بگذارد و از آن دفاع کند. اعلامیه جهانی حقوق بشر مجموعه ای از حقوق انسان را بیان می‌کند که الهام‌بخش کار ماست. ما معتقدیم که مردم حق و وظیفه دارند از این حقوق حمایت کنند",
    ),
    "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
      "ما درک می‌کنیم که ابزارها و خدمات ما می‌توانند برای نقض این اصول و ارزش‌ها و شرایط خدمات ما مورد سوء‌استفاده قرار گیرند، و قاطعانه و فعالانه چنین استفاده‌ای را محکوم و منع می‌کنیم. ما نه اجازه استفاده از نرم‌افزار و خدمات خود را برای پیشبرد فعالیت‌های غیرقانونی می‌دهیم و نه به تبلیغ سخنانی که مشوق نفرت‌پراکنی هستند یا ترویج خشونت می‌کنند، از طریق اینترنت، کمک می‌کنیم",
    ),
    "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
      "ما تدابیری را برای کاهش سوء‌استفاده از محصولات و خدمات خود در نظر گرفته‌ایم. وقتی از هرگونه استفاده‌ای که اصول یا شرایط خدمات ما را نقض می‌کند، آگاه می‌شویم، برای جلوگیری از آن اقدام می‌کنیم. با تکیه بر سیاست‌های داخلی خود، ما به دقت در مورد اقداماتی که ممکن است اصول ما را به خطر بیندازند، بررسی لازم را انجام می‌دهیم. رویه‌های ما بر اساس تجربه و بهترین شیوه‌ها به تکامل خود ادامه خواهند داد تا بتوانیم به تعادل مناسب بین امکان دسترسی آزاد به محصولات و خدمات خود و رعایت اصول و ارزش‌های خود دست یابیم",
    ),
    "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
      "افراد شجاع زندگی و آزادی خود را برای دفاع از حقوق بشر، برای بسیج افکار عمومی، برای انتفاد و برای افشای عاملان فساد و سوءاستفاده، به خطر می‌اندازند. افراد شجاع از دیگران و ایده‌ها حمایت‌ می‌کنند و نگرانی‌های خود را با دنیا به‌اشتراک می‌گذارند. این افراد شجاع حقوق بشر را به‌طور آنلاین نیز به نمایش می‌گذارند",
    ),
    "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
      "اینترنت بستری برای بیان آزاد و تعیین سرنوشت به دست خود است. مانند هر ابزار ارتباطی، اینترنت از سانسور، نظارت، حمله‌ها و تلاش‌های بازیگران دولتی و گروه‌های جنایتکار برای خاموش‌کردن صدای مخالفان مصون نیست. هنگامی که ارائه نظر و بیان دموکراتیک جرم‌انگاری شود، زمانی که تبعیض قومی و سیاسی وجود داشته باشد، اینترنت به میدان جنگ دیگری برای مقاومت غیرخشونت‌آمیز تبدیل می‌شود",
    ),
    "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
      "ماموریت ما ترویج و دفاع از آزادی‌های اساسی و حقوق بشر، از جمله جریان آزاد اطلاعات به صورت آنلاین است. هدف ما ایجاد فناوری در دسترس و بهبود مجموعه مهارت‌های مورد نیاز برای دفاع از حقوق و آزادی‌های اساسی بشر در عصر دیجیتال است",
    ),
    "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
      "هدف ما آموزش و افزایش ظرفیت افرادی است که برای لذت بردن از فعالیت‌های امن در حوزه دیجیتال، سرویس ما را انتخاب کرده‌اند. ما این کار را با ساختن ابزارهایی انجام می‌دهیم که آزادی بیان را امکان‌پذیر می‌سازد و از آن محافظت می‌کند، سانسور را دور می‌زند، ناشناس‌بودن را قوت می‌بخشد و در صورت لزوم از کاربران برابر نظارت‌ها محافظت می‌کند. ابزارهای ما همچنین مدیریت اطلاعات و عملکردهای تحلیلی را بهبود می‌بخشد",
    ),
    "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
      "ما یک مجموعه بین‌المللی از فعالین با پیشینه‌ها و عقاید مختلف هستیم که در کنار هم برای دفاع از اصول مشترک میان خود ایستاده‌ایم. ما توسعه‌دهندگان نرم‌افزار، رمزنگاران، کارشناسان امنیت، و همچنین مربیان، جامعه‌شناسان، مورخان، انسان‌شناسان و روزنامه‌نگاران هستیم. ما ابزارهای باز (متن‌باز) و قابل استفاده مجدد را با تمرکز بر حریم خصوصی، امنیت آنلاین و مدیریت اطلاعات بهتر توسعه می‌دهیم. ما فعالیت‌های خود را با کمک‌های مالی دولتی و مشاوره با بخش خصوصی تامین می‌کنیم. ما به اینترنت عاری از کنترل و نظارت‌، سانسور و سرکوب اعتقاد داریم",
    ),
    "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
      "با الهام از اعلامیه جهانی حقوق بشر، اصول و ارزش‌های ما برای هر فرد، گروه و نهادی از جامعه که با آ‌ن‌ها همکاری می‌کنیم، از جمله ذی‌نفعان نرم‌افزار و خدماتی که منتشر می‌کنیم، اعمال می‌شود. تمام پروژه‌های ما با در نظر گرفتن اصول و ارزش‌های ما طراحی شده‌اند. دانش، ابزار و خدمات ما تا زمانی که اصول و شرایط‌‌مان رعایت شود، در دسترس این گروه‌ها و افراد است",
    ),
    "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
      "حق «حریم خصوصی» یک حق اساسی است که هدف ما حفظ آن است در هر زمان و هر کجا که امکان دارد. حریم خصوصی ذی‌نفعان مستقیم ما در فعالیتی که می‌کنیم، ارزشمند و مقدس است. ابزارها، خدمات و سیاست‌های داخلی ما به همین منظور طراحی شده‌اند. ما از تمامی منابع فنی و قانونی که در اختیار داریم، برای حفظ حریم خصوصی ذی‌نفعان خود استفاده خواهیم کرد. لطفا به سند حریم خصوصی ما مراجعه کنید. ",
    ),
    "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
      "امنیت یک موضوع ثابت در تمام پروژه‌های توسعه نرم‌افزار، ارائه خدمات و ظرفیت‌سازی ما است. ما سیستم‌ها و فرآیندهای خود را برای بهبود امنیت اطلاعات در فضای اینترنت و افزایش شاخص‌های امنیتی و تجربه کاربر طراحی می‌کنیم. ما سعی می‌کنیم ویژگی‌های امنیتی یک ابزار یا سیستم را به خاطر سرعت، قابلیت استفاده یا هزینه، به خطر نیاندازیم. ما به امنیت مبهم اعتقادی نداریم و از طریق دسترسی آزاد به کدهای منبع ابزارها شفافیت را حفظ می‌کنیم. ما همیشه جانب احتیاط را رعایت می‌کنیم و سعی داریم تا امنیت عملیات‌های داخلی نرم‌افزارها را به‌خوبی اعمال کنیم",
    ),
    "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
      "مطابق با اصول ما ساخته شده است.\n\nبا استفاده از آن، موافقت می‌کنید که از این اصول پیروی کنید و شرایط استفاده و سند حریم خصوصی ما را بپذیرید.",
    ),
    "messageError": MessageLookupByLibrary.simpleMessage("خطا!"),
    "messageErrorAuthenticatingBiometrics":
        MessageLookupByLibrary.simpleMessage(
          "خطایی در احراز‌هویت با روش بیومتریک پیش آمد. لطفا دوباره تلاش کنید",
        ),
    "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
      "در تغییر رمز عبور مشکلی پیش آمد. لطفا دوباره تلاش کنید",
    ),
    "messageErrorCharactersNotAllowed": MessageLookupByLibrary.simpleMessage(
      "استفاده از / یا \\ مجاز نیست",
    ),
    "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
      "خطا در ایجاد مخزن",
    ),
    "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
      "خطا در ایجاد توکن اشتراکی.",
    ),
    "messageErrorCurrentPathMissing": m8,
    "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
      "اشکالی پیش آمده. لطفا دوباره تلاش کنید.",
    ),
    "messageErrorDefaultShort": MessageLookupByLibrary.simpleMessage("ناموفق."),
    "messageErrorDetail": m9,
    "messageErrorDokanNotInstalled": m10,
    "messageErrorEntryNotFound": MessageLookupByLibrary.simpleMessage(
      "ورودی یافت نشد",
    ),
    "messageErrorFormValidatorNameDefault":
        MessageLookupByLibrary.simpleMessage("لطفا یک نام معتبر وارد کنید."),
    "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
      "نتوانستیم محتوای این پوشه را بارگذاری کنیم. لطفا دوباره تلاش کنید.",
    ),
    "messageErrorNewPasswordSameOldPassword":
        MessageLookupByLibrary.simpleMessage(
          "رمز عبور جدید همان رمز عبور قدیمی است",
        ),
    "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
      "خطا در باز کردن مخزن",
    ),
    "messageErrorOpeningRepoDescription": m11,
    "messageErrorPathNotEmpty": m12,
    "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
      "مخزنی با این نام وجود دارد",
    ),
    "messageErrorRepositoryPasswordValidation":
        MessageLookupByLibrary.simpleMessage("لطفا یک رمز عبور وارد کنید."),
    "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
      "رمز عبورها با هم یکی نیستند.",
    ),
    "messageErrorTokenEmpty": MessageLookupByLibrary.simpleMessage(
      "لطفا یک توکن وارد کنید.",
    ),
    "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
      "این توکن معتبر نیست.",
    ),
    "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
      "لطفا یک توکن معتبر وارد کنید.",
    ),
    "messageErrorUnhandledState": MessageLookupByLibrary.simpleMessage(
      "خطا: وضعیت غیر قابل کنترل",
    ),
    "messageEthernet": MessageLookupByLibrary.simpleMessage("شبکه محلی کابلی"),
    "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
      "برای خروج، دوباره دکمه بازگشت را بزنید.",
    ),
    "messageFAQ": MessageLookupByLibrary.simpleMessage("پرسش‌های متداول"),
    "messageFailedToMount": m15,
    "messageFile": MessageLookupByLibrary.simpleMessage("فایل"),
    "messageFileAlreadyExist": m16,
    "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
      "فایل از قبل در حال آپلود است",
    ),
    "messageFileName": MessageLookupByLibrary.simpleMessage("نام فایل"),
    "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
      "ما نتوانستیم فرآیند پیش‌نمایش فایل را آغاز کنیم",
    ),
    "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
      "پیش‌نمایش فایل هنوز در دسترس نیست",
    ),
    "messageFiles": MessageLookupByLibrary.simpleMessage("فایل‌ها"),
    "messageFolderDeleted": m19,
    "messageFolderName": MessageLookupByLibrary.simpleMessage("نام پوشه"),
    "messageGeneratePassword": MessageLookupByLibrary.simpleMessage(
      "ایجاد رمز عبور",
    ),
    "messageGoToMailApp": MessageLookupByLibrary.simpleMessage(
      "به اپلیکیشن ایمیل بروید",
    ),
    "messageGoToPeers": MessageLookupByLibrary.simpleMessage(
      "به (بخش) همتاها بروید",
    ),
    "messageGood": MessageLookupByLibrary.simpleMessage("خوب"),
    "messageGranted": MessageLookupByLibrary.simpleMessage("دسترسی داده شد"),
    "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
      "برای دسترسی این مجوز باید به تنظیمات بروید:\n\nتنظیمات > اپ‌ها و اعلان‌ها",
    ),
    "messageIgnoreBatteryOptimizationsPermission":
        MessageLookupByLibrary.simpleMessage(
          "به اپلیکیشن اجازه می‌دهد به همگام‌سازی در پس‌زمینه ادامه دهد",
        ),
    "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
      "ابزاری است که به همتاها اجازه می‌دهد بدون سرور متمرکز، یکدیگر را در شبکه همتابه‌همتا (P2P) پیدا کنند",
    ),
    "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "سیستم شناسایی محلی همتا (Local Peer Discovery) به اپلیکیشن‌های وی‌سینک شما اجازه می‌دهد تا فایل‌ها را بدون مراجعه به ارائه‌دهندگان خدمات اینترنتی، جایی که یک وای‌فای محلی یا شبکه دیگری در دسترس است، با همتایان خود به اشتراک بگذارند.\n\nبرای اتصال محلی، این تنظیمات باید روشن باشد",
    ),
    "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
      "این مقدار به روتر شما و/یا ارائه‌دهنده خدمات اینترنتی شما بستگی دارد.\n\nاتصال با همتایان شما به بهترین شکل زمانی حاصل می‌شود که مستقل از نقطه انتهایی باشد",
    ),
    "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
      "ابزاری است که برای تبادل لیست همتایان با همتاهایی که به آن‌ها متصل هستید، استفاده می‌شود",
    ),
    "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
      "یک شناسه منحصر‌به‌فرد است که هربار هنگام شروع توسط وی‌سینک تولید می‌شود.\n\nمی‌توانید از آن برای تایید ارتباط خود با دیگران در بخش مرتبط با همتای (Peer) اپلیکیشن، استفاده کنید",
    ),
    "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "وقتی این تنظیمات روشن است، ارائه‌دهنده خدمات تلفن همراه شما ممکن است برای انتقال داده‌هایی که هنگام همگام‌سازی مخزن‌هایی که با همتایان خود به اشتراک می‌گذارید، از شما هزینه دریافت کند",
    ),
    "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
      "مجموعه‌ای از پروتکل‌های شبکه است که به اپلیکیشن‌های وی‌سینک شما اجازه می‌دهد تا یکدیگر را کشف کرده و با یکدیگر ارتباط برقرار کنند.\n\nبرای بهترین اتصال، توصیه می‌کنیم این تنظیمات روشن باشد",
    ),
    "messageInitializing": MessageLookupByLibrary.simpleMessage(
      "در حال راه‌اندازی…",
    ),
    "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
      "روی دکمه <bold>باز کردن قفل</bold> ضربه بزنید و رمز عبور را برای دسترسی به محتوای این مخزن وارد کنید.",
    ),
    "messageInstallDokanForOuisyncP1": MessageLookupByLibrary.simpleMessage(
      "موارد استفاده از وی‌سینک",
    ),
    "messageInstallDokanForOuisyncP2": MessageLookupByLibrary.simpleMessage(
      "برای دسترسی به مخازن از طریق بخش جست‌وجوگر فایل.\nلطفا رابط نرم‌افزاری Dokan را برای بهبود تجربه وی‌سینک خود نصب کنید.",
    ),
    "messageInternationalBillHumanRights": MessageLookupByLibrary.simpleMessage(
      "اعلامیه جهانی حقوق بشر به رسمیت شناخته شده است",
    ),
    "messageKeepBothFiles": MessageLookupByLibrary.simpleMessage(
      "هر دو فایل را نگه دارید",
    ),
    "messageKeepBothFolders": MessageLookupByLibrary.simpleMessage(
      "هر دو پوشه را نگه دارید",
    ),
    "messageLaunchAtStartup": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی هنگام شروع به کار",
    ),
    "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
      "یک مشکل داخلی شناسایی شد.",
    ),
    "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
      "این سرویس ممکن است حاوی لینک‌هایی به وب‌سایت‌های دیگر باشد. اگر روی لینک شخص ثالث کلیک کنید، به آن سایت هدایت خواهید شد. توجه داشته باشید که این وب‌سایت‌های خارجی توسط ما اداره نمی‌شوند. بنابراین، ما قویا به شما توصیه می‌کنیم که سند حریم خصوصی این وب سایت‌ها را بررسی کنید. ما هیچ کنترلی بر آن نداریم و هیچ مسئولیتی در قبال محتوا، خط‌مشی‌های حفظ حریم خصوصی، یا عملکرد وب‌سایت‌ها یا خدمات شخص ثالث نداریم",
    ),
    "messageLoadingDefault": MessageLookupByLibrary.simpleMessage(
      "در حال بارگذاری…",
    ),
    "messageLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "شناسایی شبکه محلی",
    ),
    "messageLockOpenRepos": m21,
    "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
      "این <bold>مخزن</bold> قفل شده است.",
    ),
    "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
      "در حال قفل کردن تمام مخازنی که باز هستند…",
    ),
    "messageLogData1": MessageLookupByLibrary.simpleMessage(
      "آدرس ایمیل - اگر کاربر تصمیم گرفت از طریق ایمیل با ما تماس بگیرد",
    ),
    "messageLogData2": MessageLookupByLibrary.simpleMessage(
      "اطلاعاتی که کاربر ممکن است از طریق ایمیل، از طریق برگه‌های راهنما، یا از طریق وب‌سایت ما، و ابرداده‌های مرتبط - به منظور دریافت پشتیبانی فنی ارائه دهد",
    ),
    "messageLogData3": MessageLookupByLibrary.simpleMessage(
      "آدرس آی‌پی کاربر - به منظور ارائه پشتیبانی فنی",
    ),
    "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
      "اپلیکیشن وی‌سینک فایل‌های مرتبط با ثبت گزارش (لاگ) را در دستگاه‌های کاربران ایجاد می‌کند. هدف آن‌ها فقط ثبت فعالیت دستگاه برای تسهیل فرآیند رفع اشکال در صورتی است که کاربر در برقراری ارتباط با همتایان خود یا در موارد دیگر در استفاده از وی‌سینک با مشکل مواجه شود. فایل گزارش (لاگ) در دستگاه کاربر باقی می‌ماند، مگر این که کاربر تصمیم بگیرد آن‌را برای اهداف پشتیبانی برای ما ارسال کند",
    ),
    "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
      "اگر کاربر تصمیم بگیرد با ما تماس بگیرد، اطلاعات غیرقابل شناسایی شخصی که ممکن است جمع‌آوری کنیم عبارتند از:",
    ),
    "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
      "هیچ‌یک از این اطلاعات با هیچ طرف شخص ثالثی به‌اشتراک گذاشته نمی‌شود",
    ),
    "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("همه"),
    "messageLogLevelError": MessageLookupByLibrary.simpleMessage("فقط خطا"),
    "messageLogLevelErrorWarn": MessageLookupByLibrary.simpleMessage(
      "خطا و هشدار",
    ),
    "messageLogLevelErrorWarnInfo": MessageLookupByLibrary.simpleMessage(
      "خطا، هشدار و اطلاعات",
    ),
    "messageLogViewer": MessageLookupByLibrary.simpleMessage(
      "نمایشگر ثبت گزارش",
    ),
    "messageMedium": MessageLookupByLibrary.simpleMessage("متوسط"),
    "messageMissingBackgroundServicePermission":
        MessageLookupByLibrary.simpleMessage(
          "اپلیکیشن وی‌سینک مجوز اجرا در پس‌زمینه را ندارد، باز کردن یک اپلیکیشن دیگر ممکن است روند همگام‌سازی را متوقف کند",
        ),
    "messageMobile": MessageLookupByLibrary.simpleMessage("موبایل"),
    "messageMoveEntryOrigin": m23,
    "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
      "این ویژگی هنگام انتقال «ورودی» در دسترس نیست.",
    ),
    "messageNATOnWikipedia": MessageLookupByLibrary.simpleMessage(
      "ترجمه آدرس شبکه (NAT) در ویکی‌پدیا",
    ),
    "messageNATType": MessageLookupByLibrary.simpleMessage("NAT type‌"),
    "messageNetworkIsUnavailable": MessageLookupByLibrary.simpleMessage(
      "شبکه در دسترس نیست",
    ),
    "messageNewFileError": m24,
    "messageNewPasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "رمز عبور جدید در کلیپ‌بورد کپی شد",
    ),
    "messageNewVersionIsAvailable": MessageLookupByLibrary.simpleMessage(
      "نسخه جدید موجود است.",
    ),
    "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
      "هیچ اپلیکیشنی نمی‌تواند این عمل را انجام دهد",
    ),
    "messageNoMediaPresent": MessageLookupByLibrary.simpleMessage(
      "هیچ رسانه‌ای وجود ندارد.",
    ),
    "messageNoRepo": MessageLookupByLibrary.simpleMessage(
      "قبل از اضافه‌ کردن فایل‌ها، باید یک مخزن ایجاد کنید",
    ),
    "messageNoRepoIsSelected": MessageLookupByLibrary.simpleMessage(
      "هیچ مخزنی انتخاب نشده‌",
    ),
    "messageNoRepos": MessageLookupByLibrary.simpleMessage(
      "هیچ مخزنی یافت نشد",
    ),
    "messageNone": MessageLookupByLibrary.simpleMessage("هیچ کدام"),
    "messageNote": MessageLookupByLibrary.simpleMessage("توجه"),
    "messageNothingHereYet": MessageLookupByLibrary.simpleMessage(
      "هنوز چیزی این‌جا نیست!",
    ),
    "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "فایل‌ها را با تمامی دستگاه‌های خود یا با دیگران به اشتراک بگذارید و فضای ذخیره‌سازی ابری امن خود را بسازید!",
    ),
    "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "مخازن می‌توانند به صورت خواندنی-نوشتنی، فقط خواندنی یا کور به اشتراک گذاشته شوند (در این حالت فایل‌ها را برای دیگران ذخیره می‌کنید، اما به آن‌ها دسترسی ندارید)",
    ),
    "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "همه فایل‌ها و پوشه‌های اضافه‌شده به وی‌سینک به‌طور پیش‌فرض هم در حالت انتقال و هم در حالت استراحت، به‌صورت امن رمزنگاری شده‌اند.",
    ),
    "messageOnlyAvailableFiles": MessageLookupByLibrary.simpleMessage(
      "فقط برای فایل‌ها در دسترس است",
    ),
    "messageOpenFileError": m25,
    "messageOr": MessageLookupByLibrary.simpleMessage("یا"),
    "messageOuiSyncDesktopTitle": MessageLookupByLibrary.simpleMessage(
      "وی‌سینک",
    ),
    "messagePIPEDA": MessageLookupByLibrary.simpleMessage(
      "قانون حفاظت اطلاعات شخصی و اسناد الکترونیکی (PIPEDA)",
    ),
    "messagePassword": MessageLookupByLibrary.simpleMessage("رمز عبور"),
    "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "رمز عبور در کلیپ‌بورد کپی شد",
    ),
    "messagePasswordStrength": MessageLookupByLibrary.simpleMessage(
      "قدرت رمز عبور",
    ),
    "messagePeerAdded": MessageLookupByLibrary.simpleMessage(
      "یک همتا افزوده شد",
    ),
    "messagePeerExchange": MessageLookupByLibrary.simpleMessage(
      "تبادل با همتا",
    ),
    "messagePeerExchangeWikipedia": MessageLookupByLibrary.simpleMessage(
      "تبادل همتا در ویکی‌پدیا",
    ),
    "messagePeerRemoved": MessageLookupByLibrary.simpleMessage(
      "یک همتا حذف شد",
    ),
    "messagePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "این مجوز لازم است",
    ),
    "messagePreviewingFileFailed": m26,
    "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
      "این بخش برای اطلاع رسانی به بازدیدکنندگان در مورد سیاست‌های ما در مورد جمع‌آوری، استفاده و افشای اطلاعات شخصی در صورتی که کسی تصمیم به استفاده از سرویس ما داشته باشد، استفاده می شود",
    ),
    "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
      "«انسان آزاد زاده می‌شود، اما همه جا در زنجیر است.»",
    ),
    "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
      "این مخزن <bold>فقط خواندنی</bold> است.",
    ),
    "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "امکان تغییر وجود ندارد، فقط دسترسی به محتوا مجاز است",
    ),
    "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
      "به‌یاد داشته باشید که رمز عبور را به‌طور ایمن ذخیره کنید. در صورت فراموشی، راهی برای بازیابی وجود ندارد.",
    ),
    "messageRemoveBiometricValidation": MessageLookupByLibrary.simpleMessage(
      "حذف اعتبارسنجی بیومتریکی",
    ),
    "messageRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "حذف روش‌های بیومتریکی",
    ),
    "messageRemoveBiometricsConfirmationMoreInfo":
        MessageLookupByLibrary.simpleMessage(
          "با این عمل رمز مخزن حذف می‌شود و از اعتبارسنجی بیومتریک برای باز‌کردن قفل استفاده می‌شود",
        ),
    "messageRemoveLocalPasswordConfirmation": MessageLookupByLibrary.simpleMessage(
      "این رمز عبور محلی مخزن حذف شود؟\n\nمخزن به‌طور خودکار باز می‌شود، مگر این که یک رمز عبور محلی مجدد اضافه شود",
    ),
    "messageRemovedInBrackets": MessageLookupByLibrary.simpleMessage("حذف شد"),
    "messageRenameFile": MessageLookupByLibrary.simpleMessage("تغییر نام فایل"),
    "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
      "تغییر نام پوشه",
    ),
    "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
      "تغییر نام مخزن",
    ),
    "messageReplaceExistingFile": MessageLookupByLibrary.simpleMessage(
      "فایل موجود را جایگزین کنید",
    ),
    "messageReplaceExistingFolder": MessageLookupByLibrary.simpleMessage(
      "پوشه موجود را جایگزین کنید",
    ),
    "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
      "خطا در احراز هویت مخزن",
    ),
    "messageRepoDeletionErrorDescription": m27,
    "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
      "حذف مخزن ناموفق بود",
    ),
    "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
      "مخزن مورد نظر دیگر آن‌جا نیست",
    ),
    "messageRepoMissingErrorDescription": m28,
    "messageRepositoryAccessMode": m29,
    "messageRepositoryAlreadyExist": m30,
    "messageRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "رمز عبور کنونی",
    ),
    "messageRepositoryIsNotOpen": MessageLookupByLibrary.simpleMessage(
      "هیچ مخزنی باز نیست",
    ),
    "messageRepositoryName": MessageLookupByLibrary.simpleMessage(
      "نامی برای مخزن انتخاب کنید",
    ),
    "messageRepositoryNewName": MessageLookupByLibrary.simpleMessage(
      "نام جدید مخزن",
    ),
    "messageRepositoryNewPassword": MessageLookupByLibrary.simpleMessage(
      "رمز عبور جدید",
    ),
    "messageRepositoryNotMounted": MessageLookupByLibrary.simpleMessage(
      "مخرن موردنظر نصب نشده است ",
    ),
    "messageRepositoryPassword": MessageLookupByLibrary.simpleMessage(
      "رمز عبور",
    ),
    "messageRepositorySuggestedName": m33,
    "messageRepositoryToken": MessageLookupByLibrary.simpleMessage(
      "لینک را این‌جا قرار دهید",
    ),
    "messageResetLocalSecret": MessageLookupByLibrary.simpleMessage(
      "بازنشانی رمز محلی",
    ),
    "messageRousseau": MessageLookupByLibrary.simpleMessage("ژان ژاک روسو"),
    "messageSaveLogFile": MessageLookupByLibrary.simpleMessage(
      "ذخیره فایل گزارش",
    ),
    "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
      "فایل مورد نظر را در این پوشه ذخیره کنید",
    ),
    "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
      "می‌خواهید تغییرات فعلی را ذخیره کنید؟",
    ),
    "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
      "این کد را با دستگاه دیگر خود اسکن کنید یا با همتاهای خود به اشتراک بگذارید",
    ),
    "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "محافظت با استفاده از بیومتریک",
    ),
    "messageSecurityOptionsNotAvailableBlind":
        MessageLookupByLibrary.simpleMessage(
          "گزینه‌های امنیت برای مخازن کور در دسترس نیستند",
        ),
    "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
      "داده‌هایی که کاربر در مخازن وی‌سینک آپلود می‌کند، در حین انتقال و همچنین در حالت استراحت رمزنگاری شده‌اند. این شامل ابرداده‌هایی مانند نام فایل، اندازه، ساختار پوشه و غیره می‌شود. در وی‌سینک، داده‌ها فقط توسط شخصی که داده‌ها را آپلود کرده و افرادی که مخازن خود را با آن‌ها به اشتراک گذاشته‌اند، قابل خواندن است",
    ),
    "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
      "درباره تکنیک‌های رمزنگاری مورد استفاده در اسناد ما می‌توانید اطلاعات بیشتری کسب کنید",
    ),
    "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
      "اپلیکیشن وی‌سینک داده‌های کاربران را روی یک همتای همیشه فعال [Always-On Peer] که سروری در کشور کانادا است، ذخیره می‌کند. همه داده‌ها به صورت تکه‌های رمزنگاری‌شده ذخیره می‌شوند و توسط سرور یا اپراتورهای آن قابل خواندن نیستند. هدف این سرور صرفاً پر کردن شکاف بین همتایان خود است که هم‌زمان آنلاین نیستند. تمام داده‌ها به صورت دوره‌ای از این سرور پاک می شوند - هدف آن ارائه ذخیره‌سازی دائمی داده نیست، بلکه همگام‌سازی داده‌ها توسط همتایان را تسهیل می‌کند",
    ),
    "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
      "اگر دلیلی مبنی بر به‌اشتراک‌گذاری و نشت اطلاعات شخصی خودتان به‌طور غیرقانونی توسط سایر کاربران وی‌سینک دارید، لطفا با آدرس زیر با ما تماس بگیرید",
    ),
    "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
      "یک مجوز برای ایجاد لینک اشتراک‌گذاری انتخاب کنید",
    ),
    "messageSelectLocation": MessageLookupByLibrary.simpleMessage(
      "مکان را انتخاب کنید",
    ),
    "messageSettingsRuntimeID": MessageLookupByLibrary.simpleMessage(
      "شناسه زمان اجرا (Runtime ID)",
    ),
    "messageSettingsVersionNewerThanCurrent": MessageLookupByLibrary.simpleMessage(
      "تنظیمات موجود در این دستگاه با نسخه جدیدتری از وی‌سینک ایجاد شده‌اند و قابل انتقال نیستند.",
    ),
    "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
      "برای ایجاد لینک مخزن ابتدا باید یک مجوز انتخاب کنید",
    ),
    "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
      "کد QR را به‌ اشتراک بگذارید",
    ),
    "messageSortBy": m35,
    "messageStorage": MessageLookupByLibrary.simpleMessage("فضای ذخیره‌سازی"),
    "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
      "برای دسترسی به فایل‌ها مورد نیاز است",
    ),
    "messageStrong": MessageLookupByLibrary.simpleMessage("قوی"),
    "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی هنگام استفاده از دیتای موبایل",
    ),
    "messageSyncingIsDisabledOnMobileInternet":
        MessageLookupByLibrary.simpleMessage(
          "هنگام استفاده از دیتای موبایل، همگام‌سازی اینترنتی غیرفعال است",
        ),
    "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "برای خواندن شرایط استفاده و سند حریم خصوصی، این‌جا ضربه بزنید",
    ),
    "messageTapForValues": MessageLookupByLibrary.simpleMessage(
      "برای خواندن ارزش‌های ما این‌جا ضربه بزنید",
    ),
    "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
      "حقوق حفاظت از اطلاعات شخصی را نقض می‌کند، از جمله ارزش‌های بنیادین یا مفاد ",
    ),
    "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
      "(قانون حفاظت از اطلاعات شخصی و اسناد الکترونیکی)",
    ),
    "messageTerms2": MessageLookupByLibrary.simpleMessage(
      "شامل محتوای استثمار جنسی کودکان (از جمله محتوایی که ممکن است به لحاظ قانونی سوءاستفاده جنسی از کودکان محسوب نشود اما همچنان استثمار جنسی کودکان را ترویج می‌کند)، پورنوگرافی غیرقانونی، یا هرگونه محتوای غیر اخلاقی باشد",
    ),
    "messageTerms3": MessageLookupByLibrary.simpleMessage(
      "حاوی یا ترویج‌کننده اعمال شدید خشونت‌آمیز یا فعالیت های تروریستی، از جمله ترور یا تبلیغات خشونت‌آمیز افراطی",
    ),
    "messageTerms4": MessageLookupByLibrary.simpleMessage(
      "دفاع از تعصب، نفرت‌پراکنی، یا تحریک خشونت علیه هر فرد یا گروهی از مردم بر اساس نژاد، مذهب، قومیت، ملیت، جنسیت، هویت جنسیتی، گرایش جنسی، ناتوانی، نقص یا هر ویژگی دیگر مرتبط با آن‌ها است. تبعیض یا به حاشیه‌راندن سیستماتیک",
    ),
    "messageTerms5": MessageLookupByLibrary.simpleMessage(
      "فایل‌هایی که حاوی ویروس‌ها، تروجان‌ها، کرم‌ها، بمب‌های منطقی یا موارد دیگری که مخرب یا از نظر فناوری مضر هستند",
    ),
    "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
      "این شرایط استفاده از وی‌سینک (که از این پس «توافق‌نامه» نامیده می‌شود)، به همراه اطلاعیه حریم خصوصی ما (که مجموعا «شرایط» نامیده می‌شوند)، استفاده شما از وی‌سینک - یک پروتکل و نرم‌افزار همگام‌سازی فایل آنلاین - را تعیین می‌کنند.",
    ),
    "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
      "با نصب و اجرای برنامه وی‌سینک، شما موافقت خود را با این توافق‌نامه بین خود و شرکت eQualitie inc. («eQualitie» یا «ما») اعلام می‌کنید و متعهد به رعایت آن می‌شوید. استفاده از برنامه وی‌سینک و شبکه وی‌سینک (که از این پس «سرویس» نامیده می‌شود) توسط eQualitie به صورت رایگان ارائه می‌شود و برای استفاده به همان شکل که هست، در نظر گرفته شده است",
    ),
    "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
      "برنامه وی‌سینک با توجه به ارزش‌های eQualitie ساخته شده است. با استفاده از این نرم‌افزار، شما موافقت می‌کنید که از وی‌سینک برای انتشار، اشتراک‌گذاری یا ذخیره مطالبی که با ارزش‌های بنیادین آن، قوانین استان کبک یا کانادا، یا منشور بین‌المللی حقوق بشر در تضاد باشد، استفاده نخواهید کرد، از جمله محتوایی که:",
    ),
    "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "توکن مخزن در حافظه موقت کپی شد.",
    ),
    "messageUnknownFileExtension": MessageLookupByLibrary.simpleMessage(
      "فرمت فایل ناشناخته است",
    ),
    "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
      "رمز عبور، مخزن را باز نکرد",
    ),
    "messageUnlockRepoOk": m36,
    "messageUnlockRepository": m37,
    "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "با استفاده از بیومتریک قفل را باز کنید",
    ),
    "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "تغییرات ذخیره‌نشده‌ای دارید\n\nمی‌خواهید آن‌ها را نادیده بگیرید؟",
    ),
    "messageUpdateLocalPasswordConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "رمز عبور محلی این مخزن به‌روز شود؟",
        ),
    "messageUpdateLocalSecretFailed": MessageLookupByLibrary.simpleMessage(
      "به‌روزرسانی شاخص‌های امنیتی مخزن انجام نشد.",
    ),
    "messageUpdateLocalSecretOk": MessageLookupByLibrary.simpleMessage(
      "شاخص‌های امنیتی مخزن به‌روزرسانی شده است.",
    ),
    "messageUseCacheServers": MessageLookupByLibrary.simpleMessage(
      "از سرورهای حافظه پنهان (کش) استفاده کنید",
    ),
    "messageUseLocalPassword": MessageLookupByLibrary.simpleMessage(
      "استفاده از رمز عبور محلی",
    ),
    "messageVPN": MessageLookupByLibrary.simpleMessage("وی‌پی‌ان"),
    "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
      "تایید رمز عبور محلی",
    ),
    "messageVerbosity": MessageLookupByLibrary.simpleMessage(
      "سطح جزئیات گزارش",
    ),
    "messageView": MessageLookupByLibrary.simpleMessage("مشاهده"),
    "messageWeak": MessageLookupByLibrary.simpleMessage("ضعیف"),
    "messageWiFi": MessageLookupByLibrary.simpleMessage("وای‌فای"),
    "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "دسترسی کامل. همتای شما امکان خواندن و نوشتن دارد",
    ),
    "messageWritingFileCanceled": m38,
    "messageWritingFileError": m39,
    "popupMenuItemChangePassword": MessageLookupByLibrary.simpleMessage(
      "تغییر رمز عبور",
    ),
    "popupMenuItemCopyPassword": MessageLookupByLibrary.simpleMessage(
      "کپی‌کردن رمز عبور",
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
      "مخزن قبلا وارد شده",
    ),
    "sortByNameLabel": MessageLookupByLibrary.simpleMessage("نام"),
    "sortBySizeLabel": MessageLookupByLibrary.simpleMessage("سایز"),
    "sortByTypeLabel": MessageLookupByLibrary.simpleMessage("نوع"),
    "statusSync": MessageLookupByLibrary.simpleMessage("همگام‌سازی"),
    "statusUnspecified": MessageLookupByLibrary.simpleMessage("نامشخص"),
    "titleAbout": MessageLookupByLibrary.simpleMessage("درباره ما"),
    "titleAddFile": MessageLookupByLibrary.simpleMessage(
      "اضافه‌ کردن فایل به وی‌سینک",
    ),
    "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
      "وارد کردن یک مخزن با توکن",
    ),
    "titleAddRepository": MessageLookupByLibrary.simpleMessage(
      "وارد‌ کردن مخزن",
    ),
    "titleAppTitle": MessageLookupByLibrary.simpleMessage("وی‌سینک"),
    "titleApplicationLanguage": MessageLookupByLibrary.simpleMessage(
      "زبان برنامه",
    ),
    "titleBackgroundAndroidPermissionsTitle":
        MessageLookupByLibrary.simpleMessage("مجوزهای مورد نیاز"),
    "titleChangePassword": MessageLookupByLibrary.simpleMessage(
      "تغییر رمز عبور",
    ),
    "titleChangesToTerms": MessageLookupByLibrary.simpleMessage(
      "تغییرات به این شرایط",
    ),
    "titleChildrensPrivacy": MessageLookupByLibrary.simpleMessage(
      "حریم خصوصی کودکان",
    ),
    "titleContactUs": MessageLookupByLibrary.simpleMessage("تماس با ما"),
    "titleCookies": MessageLookupByLibrary.simpleMessage("کوکی‌ها"),
    "titleCreateFolder": MessageLookupByLibrary.simpleMessage("ایجاد پوشه"),
    "titleCreateRepository": MessageLookupByLibrary.simpleMessage(
      "ایجاد مخزن جدید",
    ),
    "titleDataCollection": MessageLookupByLibrary.simpleMessage(
      "۳.۱. جمع‌آوری اطلاعات",
    ),
    "titleDataSharing": MessageLookupByLibrary.simpleMessage(
      "۳.۲. به‌اشتراک‌گذاری اطلاعات",
    ),
    "titleDeleteFile": MessageLookupByLibrary.simpleMessage("حذف فایل"),
    "titleDeleteFolder": MessageLookupByLibrary.simpleMessage("حذف پوشه"),
    "titleDeleteNotEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "حذف پوشه‌ غیر خالی",
    ),
    "titleDeleteRepository": MessageLookupByLibrary.simpleMessage("حذف مخزن"),
    "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
      "۳.۴. حذف اطلاعات شما از سرورِ همیشه همتابه‌همتای ما",
    ),
    "titleDigitalSecurity": MessageLookupByLibrary.simpleMessage(
      "امنیت دیجیتال",
    ),
    "titleDokanInstallation": MessageLookupByLibrary.simpleMessage(
      "نصب رابط نرم‌افزاری (Dokan)",
    ),
    "titleDokanInstallationFound": MessageLookupByLibrary.simpleMessage(
      "نصب رابط نرم‌افزاری (Dokan) پیدا شد",
    ),
    "titleDokanMissing": MessageLookupByLibrary.simpleMessage(
      "رابط نرم‌افزاری (Dokan) موجود نیست",
    ),
    "titleDownloadLocation": MessageLookupByLibrary.simpleMessage("محل دانلود"),
    "titleDownloadToDevice": MessageLookupByLibrary.simpleMessage(
      "دانلود در دستگاه",
    ),
    "titleEditRepository": MessageLookupByLibrary.simpleMessage("ویرایش مخزن"),
    "titleEqualitiesValues": MessageLookupByLibrary.simpleMessage(
      "ارزش‌های سازمان eQualitie",
    ),
    "titleFAQShort": MessageLookupByLibrary.simpleMessage("پرسش‌های متداول"),
    "titleFileDetails": MessageLookupByLibrary.simpleMessage("جزییات فایل‌"),
    "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
      "تغییر پسوند فایل",
    ),
    "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
      "پسوند فایل موجود نیست",
    ),
    "titleFolderActions": MessageLookupByLibrary.simpleMessage("اضافه‌ کردن"),
    "titleFolderDetails": MessageLookupByLibrary.simpleMessage("جزییات پوشه"),
    "titleFreedomExpressionAccessInfo": MessageLookupByLibrary.simpleMessage(
      "آزادی بیان و دسترسی به اطلاعات",
    ),
    "titleIssueTracker": MessageLookupByLibrary.simpleMessage("ردیاب اشکالات"),
    "titleJustLegalSociety": MessageLookupByLibrary.simpleMessage(
      "جامعه عدالت‌محور و قانونی",
    ),
    "titleLinksOtherSites": MessageLookupByLibrary.simpleMessage(
      "لینک به سایت‌های دیگر",
    ),
    "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
      "قفل‌ کردن تمام مخزن‌ها",
    ),
    "titleLogData": MessageLookupByLibrary.simpleMessage("ثبت اطلاعات"),
    "titleLogs": MessageLookupByLibrary.simpleMessage("گزارش‌ها"),
    "titleMovingEntry": MessageLookupByLibrary.simpleMessage(
      "در حال انتقال (مقدار) ورودی",
    ),
    "titleNetwork": MessageLookupByLibrary.simpleMessage("شبکه"),
    "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "دسترسی به فایل‌ها از دستگاه‌های مختلف",
    ),
    "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "تنظیم مجوزها برای همکاری، پخش یا صرفا ذخیره‌سازی",
    ),
    "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "ارسال و دریافت فایل‌ها به‌طور امن",
    ),
    "titleOpennessTransparency": MessageLookupByLibrary.simpleMessage(
      "صداقت و شفافیت",
    ),
    "titleOurMission": MessageLookupByLibrary.simpleMessage("ماموریت ما"),
    "titleOurPrinciples": MessageLookupByLibrary.simpleMessage("اصول ما"),
    "titleOurValues": MessageLookupByLibrary.simpleMessage("ارزش‌های ما"),
    "titleOverview": MessageLookupByLibrary.simpleMessage("۱. بررسی اجمالی"),
    "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
      "قانون حفاظت از اطلاعات شخصی و اسناد الکترونیکی (PIPEDA)",
    ),
    "titlePrivacy": MessageLookupByLibrary.simpleMessage("حریم خصوصی"),
    "titlePrivacyNotice": MessageLookupByLibrary.simpleMessage(
      "۳. سند حریم خصوصی",
    ),
    "titlePrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "سند حریم خصوصی",
    ),
    "titleRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "مشخصات بیومتریک را حذف کنید",
    ),
    "titleRepositoriesList": MessageLookupByLibrary.simpleMessage(
      "مخزن‌های من",
    ),
    "titleRepository": MessageLookupByLibrary.simpleMessage("مخزن"),
    "titleRepositoryName": MessageLookupByLibrary.simpleMessage("نام مخزن"),
    "titleRequiredPermission": MessageLookupByLibrary.simpleMessage(
      "مجوز مورد نیاز",
    ),
    "titleSaveChanges": MessageLookupByLibrary.simpleMessage("ذخیره تغییرات"),
    "titleScanRepoQR": MessageLookupByLibrary.simpleMessage("اسکن کد QR مخزن"),
    "titleSecurity": MessageLookupByLibrary.simpleMessage("امنیت"),
    "titleSecurityPractices": MessageLookupByLibrary.simpleMessage(
      "۳.۳. تمرینات امنیتی",
    ),
    "titleSendFeedback": MessageLookupByLibrary.simpleMessage("ارسال نظرات"),
    "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
      "انتخاب رمز عبور",
    ),
    "titleSettings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
    "titleShareRepository": m48,
    "titleSortBy": MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس"),
    "titleStateMonitor": MessageLookupByLibrary.simpleMessage("نظارت بر وضعیت"),
    "titleTermsOfUse": MessageLookupByLibrary.simpleMessage("۲. شرایط استفاده"),
    "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "شرایط استفاده و سند حریم خصوصی وی‌سینک",
    ),
    "titleUPnP": MessageLookupByLibrary.simpleMessage(
      "معیار اجرا و اتصال همگانی (UPnP)",
    ),
    "titleUnlockRepository": MessageLookupByLibrary.simpleMessage(
      "باز کردن قفل مخزن",
    ),
    "titleUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "تغییرات ذخیره‌‌نشده",
    ),
    "titleUserProvidedPeers": MessageLookupByLibrary.simpleMessage(
      "همتا‌های ارائه‌شده توسط کاربر",
    ),
    "titleWeAreEq": MessageLookupByLibrary.simpleMessage("ما eQualit.ie هستیم"),
    "typeFile": MessageLookupByLibrary.simpleMessage("فایل"),
    "typeFolder": MessageLookupByLibrary.simpleMessage("پوشه"),
  };
}
