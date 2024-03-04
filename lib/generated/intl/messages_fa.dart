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
      "مجوز موردنظر نمی تواند بیشتر از حالت دسترسی فعلی مخزن باشد: ${access}";

  static String m1(name) => "احرازهویت بیومتریکی برای مخزن اضافه شد";

  static String m2(name) => "${name} - دانلود لغو شد";

  static String m3(name) => "${name} - ناموفق در دانلود";

  static String m4(entry) => "${entry} در حال حاضر موجود است.";

  static String m5(path) => "پوشه فعلی موجود نیست، به بخش اصلی بروید: ${path}";

  static String m6(dokanUrl) =>
      "نصب دوکان (Dokan) پیدا نشد . لطفا آن را از این لینک نصب کنید. ${dokanUrl}";

  static String m7(name) => "آماده‌سازی اولیه مخزن ${name} ناموفق بود";

  static String m8(path) => "${path} خالی نیست";

  static String m9(reason) => "نصب نشد: ${reason}";

  static String m10(name) =>
      "${name} از قبل در این‌جا وجود دارد.\n\nچه‌کاری قصد دارید انجام دهید؟";

  static String m11(name) => "پوشه با موفقیت حذف شد: ${name}";

  static String m12(number) =>
      "آیا می‌خواهید تمام مخازنی که باز هستند را قفل کنید؟\n\n(${number} باز)";

  static String m13(path) => "از ${path}";

  static String m14(name) => "خطا در ایجاد فایل ${name}";

  static String m15(name) => "خطا در بازکردن فایل ${name}";

  static String m16(path) => "فرآیند پیش‌نمایش فایل ${path} انجام نشد";

  static String m17(name) => "ما نتوانستیم مخزن را حذف کنیم \"${name}\"";

  static String m18(name) =>
      "ما نتوانستیم مخزن را در مکانی که معمولا هست، پیدا کنیم \"${name}\"";

  static String m19(access) => "اجازه «دسترسی» داده شد: ${access}";

  static String m20(name) =>
      "این مخزن از قبل در برنامه با این نام وجود دارد \"${name}\".";

  static String m21(name) =>
      "پیشنهاد: ${name}\n(برای استفاده از این نام این‌جا ضربه بزنید)";

  static String m22(access) => "به‌عنوان کپی ${access} باز شد";

  static String m23(name) => "${name} نوشتن لغو شد";

  static String m24(name) => "${name} - ناموفق در نوشتن";

  static String m25(name) => "خطا در واردکردن مخزن ${name}";

  static String m26(name) => "ایجاد مخزن ناموفق بود ${name}";

  static String m27(access) => "[دسترسی]";

  static String m28(changes) => "${changes}";

  static String m29(entry) => "${entry}";

  static String m30(name) => "${name}";

  static String m31(number) => "[شماره]";

  static String m32(path) => "${path}";

  static String m33(status) => "${status}";

  static String m34(name) => "به‌اشتراک‌گذاری مخزن \"${name}\"";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("تایید"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("تایید"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("وارد کردن یک مخزن"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("وارد کردن مخزن"),
        "actionBack": MessageLookupByLibrary.simpleMessage("بازگشت"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("لغو"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("لغو"),
        "actionClear": MessageLookupByLibrary.simpleMessage("پاک‌ کردن"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("بستن"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("ایجاد"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("ایجاد مخزن"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("حذف"),
        "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("حذف"),
        "actionDeleteFile": MessageLookupByLibrary.simpleMessage("حذف فایل"),
        "actionDeleteFolder": MessageLookupByLibrary.simpleMessage("حذف پوشه"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("حذف مخزن"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("نادیده‌ گرفتن"),
        "actionDone": MessageLookupByLibrary.simpleMessage("انجام شد"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("ویرایش نام"),
        "actionExit": MessageLookupByLibrary.simpleMessage("خروج"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("به بخش تنظیمات بروید"),
        "actionHide": MessageLookupByLibrary.simpleMessage("پنهان‌سازی"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("پنهان‌سازی"),
        "actionIAgree": MessageLookupByLibrary.simpleMessage("موافقم"),
        "actionIDontAgree": MessageLookupByLibrary.simpleMessage("موافق نیستم"),
        "actionImport": MessageLookupByLibrary.simpleMessage("وارد کردن"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("وارد کردن مخزن"),
        "actionLockCapital": MessageLookupByLibrary.simpleMessage("قفل کردن"),
        "actionMove":
            MessageLookupByLibrary.simpleMessage("حرکت دادن (انتقال)"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("فایل"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("پوشه"),
        "actionNewRepo": MessageLookupByLibrary.simpleMessage("ایجاد مخزن"),
        "actionNext": MessageLookupByLibrary.simpleMessage("بعدی"),
        "actionNo": MessageLookupByLibrary.simpleMessage("خیر"),
        "actionOK": MessageLookupByLibrary.simpleMessage("اوکی"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("پیش‌نمایش فایل"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("بارگذاری مجدد"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("بارگذاری مجدد مخزن"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("حذف"),
        "actionRemoveLocalPassword":
            MessageLookupByLibrary.simpleMessage("حذف رمز عبور محلی"),
        "actionRemoveRepo": MessageLookupByLibrary.simpleMessage("حذف مخزن"),
        "actionRename": MessageLookupByLibrary.simpleMessage("تغییر نام"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("دوباره سعی کنید"),
        "actionSave": MessageLookupByLibrary.simpleMessage("ذخیره کردن"),
        "actionSaveChanges":
            MessageLookupByLibrary.simpleMessage("ذخیره تغییرات"),
        "actionScanQR":
            MessageLookupByLibrary.simpleMessage("یک کد QR اسکن کنید"),
        "actionShare": MessageLookupByLibrary.simpleMessage("به‌اشتراک‌گذاری"),
        "actionShareFile":
            MessageLookupByLibrary.simpleMessage("به‌اشتراک‌گذاری فایل"),
        "actionShow": MessageLookupByLibrary.simpleMessage("نمایش"),
        "actionSkip": MessageLookupByLibrary.simpleMessage("پرش"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("واگرد"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("بازکردن قفل"),
        "actionUpdate": MessageLookupByLibrary.simpleMessage("به‌روزرسانی"),
        "actionYes": MessageLookupByLibrary.simpleMessage("بله"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("حالت دسترسی"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("وارد کردن یک مخزن"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("ایجاد یک مخزن جدید"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("حذف"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("دانلود"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("اطلاعات"),
        "iconMove": MessageLookupByLibrary.simpleMessage("حرکت دادن (انتقال)"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
        "iconRename": MessageLookupByLibrary.simpleMessage("تغییر نام"),
        "iconShare": MessageLookupByLibrary.simpleMessage("به‌اشتراک‌گذاری"),
        "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
            "این را با همتایان خود به‌‌اشتراک بگذارید"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("نسخه اپلیکیشن"),
        "labelAttachLogs":
            MessageLookupByLibrary.simpleMessage("ضمیمه فایل ثبت رویدادها"),
        "labelBitTorrentDHT": MessageLookupByLibrary.simpleMessage(
            "جدول درهم‌سازی توزیع‌شده (DHT) بیت‌تورنت"),
        "labelConnectionType":
            MessageLookupByLibrary.simpleMessage("نوع اتصال"),
        "labelCopyLink":
            MessageLookupByLibrary.simpleMessage("لینک را کپی کنید"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("مقصد"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("دانلود شده در:"),
        "labelEndpoint": MessageLookupByLibrary.simpleMessage("گرهِ انتهایی "),
        "labelExternalIPv4": MessageLookupByLibrary.simpleMessage("IPv4 خارجی"),
        "labelExternalIPv6": MessageLookupByLibrary.simpleMessage("IPv6 خارجی"),
        "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("IPv4 محلی"),
        "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("IPv6 محلی"),
        "labelLocation": MessageLookupByLibrary.simpleMessage("موقعیت مکانی: "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("قفل‌کردن تمام مخزن‌ها"),
        "labelName": MessageLookupByLibrary.simpleMessage("نام: "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("نام جدید "),
        "labelPassword": MessageLookupByLibrary.simpleMessage("رمز عبور: "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("همتاها"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("کد QR"),
        "labelQuicListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("گوش‌دادن به QUIC/UDP IPv4"),
        "labelQuicListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("گوش‌دادن به QUIC/UDP IPv6"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("نام جدید را وارد کنید: "),
        "labelRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("رمز عبور حال حاضر"),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("لینک مخزن: "),
        "labelRetypePassword":
            MessageLookupByLibrary.simpleMessage("تایپ دوباره رمز عبور: "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("انتخاب مخزن: "),
        "labelSetPermission":
            MessageLookupByLibrary.simpleMessage("تنظیم مجوز"),
        "labelShareLink":
            MessageLookupByLibrary.simpleMessage("لینک را به‌اشتراک‌ بگذارید"),
        "labelSize": MessageLookupByLibrary.simpleMessage("سایز: "),
        "labelSyncStatus":
            MessageLookupByLibrary.simpleMessage("وضعیت همگام‌سازی: "),
        "labelTcpListenerEndpointV4":
            MessageLookupByLibrary.simpleMessage("گوش‌دادن به TCP IPv4"),
        "labelTcpListenerEndpointV6":
            MessageLookupByLibrary.simpleMessage("گوش‌دادن به TCP IPv6"),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("لینک به‌اشتراک‌گذاری مخزن"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("رمز عبور را بنویسید: "),
        "labelUseExternalStorage":
            MessageLookupByLibrary.simpleMessage("استفاده از حافظه خارجی"),
        "menuItemAbout": MessageLookupByLibrary.simpleMessage("درباره ما"),
        "menuItemLogs":
            MessageLookupByLibrary.simpleMessage("ثبت رویدادها (لاگ)"),
        "menuItemNetwork": MessageLookupByLibrary.simpleMessage("شبکه"),
        "menuItemRepository": MessageLookupByLibrary.simpleMessage("مخزن"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("هیچ رسانه‌ای وجود ندارد."),
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "دسترسی به فضای ذخیره‌سازی امن"),
        "messageAck": MessageLookupByLibrary.simpleMessage(
            "زمانی استفاده خواهد شد که مشکلی بروز کند. سورپرایز شدن یا واکنش منفی به چیزی که طبق انتظار عمل نمی‌کند.\nدر گفتگوی مرتبط با خطاها استفاده می‌شود."),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "این گزینه در مخازنی که فقط قابل هستند، موجود نیست"),
        "messageAddLocalPassword":
            MessageLookupByLibrary.simpleMessage("اضافه‌کردن رمز عبور محلی"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "یک مخزن را با استفاده از پیوند (لینک) توکن وارد کنید"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "یک مخزن را با استفاده از یک کد QR وارد کنید"),
        "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
            "این مخزن قفل شده یا یک مدل کور است.\n\nاگر رمز عبور را دارید، قفل آن را باز کنید و دوباره امتحان کنید."),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "این مخزن یک کپی فقط قابل خواندن است."),
        "messageAutomaticUnlockRepositoryFailed":
            MessageLookupByLibrary.simpleMessage(
                "ما نتوانستیم قفل مخزن را باز کنیم"),
        "messageAvailableOnMobile":
            MessageLookupByLibrary.simpleMessage("در تلفن همراه در دسترس است"),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "به زودی سیستم عامل از شما مجوز اجرای این اپلیکیشن را در پس‌زمینه درخواست می‌کند.\n\nاین (مجوز) برای ادامه همگام‌سازی لازم است در حالتی که اپلیکیشن در پیش‌زمینه اجرا نمی‌شود"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage("در حال اجرا"),
        "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
            "ناموفق در احراز هویت بیومتریک"),
        "messageBiometricUnlockRepositoryFailed":
            MessageLookupByLibrary.simpleMessage(
                "بازکردن قفل بیومتریک ناموفق بود"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage("اعتبارسنجی بیومتریکی حذف شد"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "همتای شما نمی‌تواند محتواها را بنویسد و بخواند"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
            "این مخزن یک کپی با مدل [کور] است."),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "رمز عبور ارائه‌شده به شما امکان دسترسی برای مشاهده محتوای این مخزن را نمی‌دهد."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("بلوتوث"),
        "messageBy": MessageLookupByLibrary.simpleMessage("توسط"),
        "messageCamera": MessageLookupByLibrary.simpleMessage("دوربین"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "برای استفاده از دوربین و خواندن کد QR به این مجوز نیاز داریم"),
        "messageCanadaPrivacyAct":
            MessageLookupByLibrary.simpleMessage("قانون حفظ حریم خصوصی کانادا"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "تغییر پسوند یک فایل می تواند آن‌را غیرقابل استفاده کند"),
        "messageChangeLocalPassword":
            MessageLookupByLibrary.simpleMessage("تغییر رمز عبور محلی"),
        "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
            "ممکن است شرایط استفاده (خدمات) خود را هر از چندگاهی به‌روز کنیم. بنابراین، به شما توصیه می‌شود برای اطلاع از هر‌گونه تغییر، این صفحه را به صورت دوره‌ای مرور کنید"),
        "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
            "این سیاست (خط مشی) از تاریخ ۹ مارس ۲۰۲۲ میلادی قابل اجراست"),
        "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
            "ما آگاهانه اطلاعات قابل شناسایی شخصی از کودکان جمع آوری نمی‌کنیم. ما همه کودکان را تشویق می‌کنیم که هرگز اطلاعات شناسایی شخصی را از طریق اپلیکیشن و/یا خدمات ارائه نکنند. ما والدین و سرپرستان قانونی کودکان را تشویق می‌کنیم که بر استفاده فرزندان خود از اینترنت نظارت داشته باشند و به اجرای این خط‌مشی کمک کنند و به فرزندان خود آموزش دهند که هرگز اطلاعات قابل شناسایی شخصی را از طریق برنامه و/یا خدمات بدون اجازه آن‌ها ارائه نکنند. اگر دلیلی مبنی بر ارائه اطلاعات هویتی شخصی توسط کودکی به برنامه و/یا خدمات به ما دارید، لطفاً با ما تماس بگیرید.\nهمچنین باید حداقل ۱۶ سال سن داشته باشید تا با پردازش اطلاعات شناسایی شخصی خودتان در کشور خود موافقت کنید (در برخی کشورها ممکن است به والدین یا قیم شما اجازه دهیم از طرف شما این کار را انجام دهند)."),
        "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
            "آیا اطمینان دارید که می خواهید این فایل را حذف کنید؟"),
        "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
            "آیا اطمینان دارید که می‌خواهید این پوشه را حذف کنید؟"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "این پوشه خالی نیست\n\nآیا هنوز می‌خواهید آن را حذف کنید؟ (با این کار تمام محتویات آن حذف می‌شود)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage(
                "آیا اطمینان دارید که می خواهید این مخزن را حذف کنید؟"),
        "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
            "در صورتی که در مورد خط مشی حفظ حریم خصوصی ما سؤال یا پیشنهادی دارید، حتما با ما تماس بگیرید"),
        "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
            "اپلیکیشن Ouisync از کوکی‌ها استفاده نمی‌کند"),
        "messageCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "در کلیپ‌بورد(ذخیره موقت) کپی شد."),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "با استفاده از ... یک پوشه جدید ایجاد کنید، یا یک فایل اضافه کنید،"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "یک مخزن ایجاد کنید یا با استفاده از توکن مخزن به یکی از دوستان‌تان لینک شوید"),
        "messageCreatingToken":
            MessageLookupByLibrary.simpleMessage("در حال ایجاد توکن اشتراکی…"),
        "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
            "تیم Ouisync برای حریم خصوصی کاربر ارزش قائل است و بنابراین هیچ اطلاعات کاربری را جمع آوری نمی‌کند."),
        "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
            "اپلیکیشن Ouisync به گونه‌ای طراحی شده که می‌تواند خدمات اشتراک فایل را بدون شناسه کاربر، نام، نام مستعار، حساب کاربری یا هر شکل دیگری از اطلاعات کاربر ارائه دهد. ما نمی‌دانیم چه کسی از برنامه ما استفاده می‌کند و با چه کسی داده‌های خود را همگام‌سازی می‌کند یا به‌اشتراک می‌گذارد"),
        "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
            "Ouisync (و eQualit.ie) هیچ اطلاعاتی را با طرف‌های شخص ثالث به‌اشتراک نمی‌گذارد"),
        "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
            "اعلامیه خدمات آنلاین توزیع‌شده"),
        "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
            "تیم Ouisync نمی تواند فایل‌های شخصی را از مخازن حذف کند، زیرا شناسایی آن‌ها به علت رمزنگاری ممکن نیست. اگر پیوند(لینک) مخزنی که باید حذف شود را برای ما ارسال کنید، می توانیم کل مخازن را حذف کنیم."),
        "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
            "ساده‌ترین راه برای حذف داده‌های خود، حذف فایل‌ها یا مخازن از دستگاه خودتان است. هرگونه حذف فایل به همه همتایان شما اطلاع‌رسانی خواهد شد(منتشر خواهد شد) - به عنوان مثال، اگر به یک مخزن دسترسی نوشتنی دارید، می توانید فایل‌های موجود در آن را حذف کنید و همان فایل‌ها از مخازن همتایان شما و همچنین از همتای همیشه فعال ما Always-On-Peer حذف خواهند شد. \nاگر نیاز دارید که فقط مخازن را از سرور همتای همیشه فعال Always-On-Peer ما حذف کنید (اما همچنان آن‌ها را در مخزن خود در دستگاه خود نگه دارید)، لطفاً با آدرس زیر با ما تماس بگیرید."),
        "messageDistributedHashTables":
            MessageLookupByLibrary.simpleMessage("جداول هش توزیع‌شده"),
        "messageDownloadFileCanceled":
            MessageLookupByLibrary.simpleMessage("دانلود فایل لغو شد"),
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder":
            MessageLookupByLibrary.simpleMessage("این پوشه خالی است"),
        "messageEmptyRepo":
            MessageLookupByLibrary.simpleMessage("این مخزن خالی است"),
        "messageEnterDifferentName":
            MessageLookupByLibrary.simpleMessage("لطفا نام دیگری وارد کنید"),
        "messageEntryAlreadyExist": m4,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("یک ورودی"),
        "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("یک فایل"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("یک پوشه"),
        "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
            "حقوق اساسی و آزادی‌های اساسی، ذاتی، غیرقابل انکار و به‌طور یکسان برای همگان اعمال می‌شود. حقوق بشر امری جهانی است؛ در حقوق بین‌الملل حمایت‌شده و تصریح‌شده در: "),
        "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
            "به عنوان یک سازمان، ما به دنبال شفافیت در سیاست‌ها و رویه‌های خود هستیم. تا آنجا که ممکن است، کد منبع ما باز و آزادانه در دسترس است، و توسط مجوزهایی محافظت می‌شود که توسعه جامعه‌محور، به‌اشتراک‌گذاری و انتشار این اصول و ارزش‌ها را ترغیب و تشویق می‌کنند"),
        "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
            "توانایی بیان و اظهارنظر آزادانه و دسترسی به اطلاعات عمومی، ستون فقرات یک دموکراسی واقعی است. اطلاعات عمومی باید در حوزه عمومی باشد. آزادی بیان شامل بحث‌های فعال و داغ است، حتی بحث و استدلال‌هایی که به‌طور نامطلوب بیان شده‌اند، ساختار ضعیفی دارند و ممکن است برای برخی توهین‌آمیز تلقی شوند. اما آزادی بیان یک حق مطلق نیست. ما قاطعانه برابر خشونت و تحریک برای نقض حقوق دیگران، به‌ویژه ترویج خشونت، نفرت، تبعیض و سلب حق رای از هر گروه قومی یا گروه اجتماعی قابل شناسایی، ایستاده‌ایم"),
        "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
            "ما از داخل کشورهای مختلف فعالیت می‌کنیم و از زمینه‌ها و گروه‌های متفاوت اجتماعی گردهم جمع شده‌ایم. ما به همراه هم برای جامعه‌ای فعالیت می‌کنیم که به حقوق دیگران در دنیای فیزیکی و دیجیتالی احترام بگذارد و از آن دفاع کند. اعلامیه جهانی حقوق بشر مجموعه ای از حقوق انسان را بیان می‌کند که الهام‌بخش کار ماست. ما معتقدیم که مردم حق و وظیفه دارند از این حقوق حمایت کنند."),
        "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
            "ما درک می‌کنیم که ابزارها و خدمات ما می‌توانند برای نقض این اصول و ارزش‌ها و شرایط خدمات ما مورد سوء‌استفاده قرار گیرند، و قاطعانه و فعالانه چنین استفاده‌ای را محکوم و منع می‌کنیم. ما نه اجازه استفاده از نرم‌افزار و خدمات خود را برای پیشبرد فعالیت‌های غیرقانونی می‌دهیم و نه به تبلیغ سخنانی که مشوق نفرت‌پراکنی هستند یا ترویج خشونت می‌کنند، از طریق اینترنت، کمک می‌کنیم."),
        "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
            "ما تدابیری را برای کاهش سوء‌استفاده از محصولات و خدمات خود در نظر گرفته‌ایم. وقتی از هرگونه استفاده‌ای که اصول یا شرایط خدمات ما را نقض می‌کند، آگاه می‌شویم، برای جلوگیری از آن اقدام می‌کنیم. با تکیه بر سیاست‌های داخلی خود، ما به دقت در مورد اقداماتی که ممکن است اصول ما را به خطر بیندازند، بررسی لازم را انجام می‌دهیم. رویه‌های ما بر اساس تجربه و بهترین شیوه‌ها به تکامل خود ادامه خواهند داد تا بتوانیم به تعادل مناسب بین امکان دسترسی آزاد به محصولات و خدمات خود و رعایت اصول و ارزش‌های خود دست یابیم."),
        "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
            "افراد شجاع زندگی و آزادی خود را برای دفاع از حقوق بشر، برای بسیج افکار عمومی، برای انتفاد و برای افشای عاملان فساد و سواستفاده، به خطر می‌اندازند. افراد شجاع از دیگران و ایده‌ها حمایت‌ می‌کنند و نگرانی‌های خود را با دنیا به‌اشتراک می‌گذارند. این افراد شجاع حقوق بشر را به‌طور آنلاین نیز به نمایش می‌گذارند"),
        "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
            "اینترنت بستری برای بیان آزاد و تعیین سرنوشت به دست خود است. مانند هر ابزار ارتباطی، اینترنت از سانسور، نظارت، حمله‌ها و تلاش‌های بازیگران دولتی و گروه‌های جنایتکار برای خاموش‌کردن صدای مخالفان مصون نیست. هنگامی که ارائه نظر و بیان دموکراتیک جرم‌انگاری شود، زمانی که تبعیض قومی و سیاسی وجود داشته باشد، اینترنت به میدان جنگ دیگری برای مقاومت غیرخشونت‌آمیز تبدیل می‌شود"),
        "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
            "ماموریت ما ترویج و دفاع از آزادی‌های اساسی و حقوق بشر، از جمله جریان آزاد اطلاعات به صورت آنلاین است. هدف ما ایجاد فناوری در دسترس و بهبود مجموعه مهارت‌های مورد نیاز برای دفاع از حقوق و آزادی‌های اساسی بشر در عصر دیجیتال است"),
        "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
            "هدف ما آموزش و افزایش ظرفیت افرادی است که برای لذت بردن از فعالیت‌های امن در حوزه دیجیتال، سرویس ما را انتخاب کرده‌اند. ما این کار را با ساختن ابزارهایی انجام می‌دهیم که آزادی بیان را امکان‌پذیر می‌سازد و از آن محافظت می‌کند، سانسور را دور می‌زند، ناشناس‌بودن را قوت می‌بخشد و در صورت لزوم از کاربران برابر نظارت‌ها محافظت می‌کند. ابزارهای ما همچنین مدیریت اطلاعات و عملکردهای تحلیلی را بهبود می‌بخشد"),
        "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
            "ما یک مجموعه بین‌المللی از فعالین با پیشینه‌ها و عقاید مختلف هستیم که در کنار هم برای دفاع از اصول مشترک میان خود ایستاده‌ایم. ما توسعه‌دهندگان نرم‌افزار، رمزنگاران، کارشناسان امنیت، و همچنین مربیان، جامعه‌شناسان، مورخان، انسان‌شناسان و روزنامه‌نگاران هستیم. ما ابزارهای باز (متن‌باز) و قابل استفاده مجدد را با تمرکز بر حریم خصوصی، امنیت آنلاین و مدیریت اطلاعات بهتر توسعه می‌دهیم. ما فعالیت‌های خود را با کمک‌های مالی دولتی و مشاوره با بخش خصوصی تامین می‌کنیم. ما به اینترنت عاری از کنترل و نظارت‌، سانسور و سرکوب اعتقاد داریم"),
        "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
            "با الهام از اعلامیه جهانی حقوق بشر، اصول و ارزش‌های ما برای هر فرد، گروه و نهادی از جامعه که با آ‌ن‌ها همکاری می‌کنیم، از جمله ذی‌نفعان نرم‌افزار و خدماتی که منتشر می‌کنیم، اعمال می‌شود. تمام پروژه‌های ما با در نظر گرفتن اصول و ارزش‌های ما طراحی شده‌اند. دانش، ابزار و خدمات ما تا زمانی که اصول و شرایط‌‌مان رعایت شود، در دسترس این گروه‌ها و افراد است"),
        "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
            "حق «حریم خصوصی» یک حق اساسی است که هدف ما حفظ آن است در هر زمان و هر کجا که امکان دارد. حریم خصوصی ذی‌نفعان مستقیم ما در فعالیتی که می‌کنیم، ارزشمند و مقدس است. ابزارها، خدمات و سیاست‌های داخلی ما به همین منظور طراحی شده‌اند. ما از تمامی منابع فنی و قانونی که در اختیار داریم، برای حفظ حریم خصوصی ذی‌نفعان خود استفاده خواهیم کرد. لطفاً به سند حریم خصوصی ما مراجعه کنید. "),
        "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
            "امنیت یک موضوع ثابت در تمام پروژه‌های توسعه نرم‌افزار، ارائه خدمات و ظرفیت‌سازی ما است. ما سیستم‌ها و فرآیندهای خود را برای بهبود امنیت اطلاعات در فضای اینترنت و افزایش شاخص‌های امنیتی و تجربه کاربر طراحی می‌کنیم. ما سعی می‌کنیم ویژگی‌های امنیتی یک ابزار یا سیستم را به خاطر سرعت، قابلیت استفاده یا هزینه، به خطر نیاندازیم. ما به امنیت مبهم اعتقادی نداریم و از طریق دسترسی آزاد به کدهای منبع ابزارها شفافیت را حفظ می‌کنیم. ما همیشه جانب احتیاط را رعایت می‌کنیم و سعی داریم تا امنیت عملیات‌های داخلی نرم‌افزارها را به‌خوبی اعمال کنیم"),
        "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
            "مطابق با اصول ما ساخته شده است.\n\nبا استفاده از آن، موافقت می‌کنید که از این اصول پیروی کنید و شرایط استفاده و سند حریم خصوصی ما را بپذیرید."),
        "messageError": MessageLookupByLibrary.simpleMessage("خطا!"),
        "messageErrorAddingLocalPassword": MessageLookupByLibrary.simpleMessage(
            "اضافه‌کردن یک رمز عبور محلی ناموفق بود"),
        "messageErrorAddingSecureStorge": MessageLookupByLibrary.simpleMessage(
            "اضافه‌کردن یک رمز عبور محلی ناموفق بود"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "خطایی در احراز‌هویت با استفاده از روش‌های بیومتریک وجود داشت. لطفا دوباره تلاش کنید"),
        "messageErrorChangingLocalPassword":
            MessageLookupByLibrary.simpleMessage(
                "تغییر رمز عبور محلی ناموفق بود"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "در تغییر رمز عبور مشکلی وجود داشت. لطفا دوباره تلاش کنید"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "استفاده از / یا \\ مجاز نیست"),
        "messageErrorCreatingRepository":
            MessageLookupByLibrary.simpleMessage("خطا در ایجاد مخزن"),
        "messageErrorCreatingToken":
            MessageLookupByLibrary.simpleMessage("خطا در ایجاد توکن اشتراکی."),
        "messageErrorCurrentPathMissing": m5,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "اشکالی پیش آمد. لطفا دوباره تلاش کنید."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("ناموفق."),
        "messageErrorDokanNotInstalled": m6,
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("ورودی یافت نشد"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage(
                "لطفا یک نام معتبر وارد کنید."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "ما نتوانستیم محتوای این پوشه را بارگذاری کنیم. لطفا دوباره تلاش کنید."),
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "رمز عبور جدید همان رمز عبور قدیمی است"),
        "messageErrorOpeningRepo":
            MessageLookupByLibrary.simpleMessage("خطا در باز کردن مخزن"),
        "messageErrorOpeningRepoDescription": m7,
        "messageErrorPathNotEmpty": m8,
        "messageErrorRemovingPassword":
            MessageLookupByLibrary.simpleMessage("حذف رمز عبور ناموفق بود"),
        "messageErrorRemovingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "حذف رمز عبور از حافظه امن ناموفق بود"),
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "یک مخزن با این نام وجود دارد"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage("لطفا یک رمز عبور وارد کنید."),
        "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
            "رمز عبورها با هم یکی نیستند."),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("لطفا یک توکن وارد کنید."),
        "messageErrorTokenInvalid":
            MessageLookupByLibrary.simpleMessage("این توکن معتبر نیست."),
        "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
            "لطفاً یک توکن معتبر وارد کنید."),
        "messageErrorUnhandledState":
            MessageLookupByLibrary.simpleMessage("خطا: حالت کنترل‌نشده"),
        "messageErrorUpdatingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "به‌روزرسانی رمز عبور در حافظه امن ناموفق بود"),
        "messageEthernet":
            MessageLookupByLibrary.simpleMessage("شبکه محلی کابلی"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "برای خروج، دوباره دکمه بازگشت را فشار دهید."),
        "messageFAQ": MessageLookupByLibrary.simpleMessage("پرسش‌های متداول"),
        "messageFailedToMount": m9,
        "messageFile": MessageLookupByLibrary.simpleMessage("فایل"),
        "messageFileAlreadyExist": m10,
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "فایل از قبل در حال آپلود است"),
        "messageFileName": MessageLookupByLibrary.simpleMessage("نام فایل"),
        "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
            "ما نتوانستیم فرآیند پیش‌نمایش فایل را آغاز کنیم"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "پیش‌نمایش فایل هنوز در دسترس نیست"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("فایل‌ها"),
        "messageFolderDeleted": m11,
        "messageFolderName": MessageLookupByLibrary.simpleMessage("نام پوشه"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("ایجاد رمز عبور"),
        "messageGoToMailApp":
            MessageLookupByLibrary.simpleMessage("به اپلیکیشن ایمیل بروید"),
        "messageGoToPeers":
            MessageLookupByLibrary.simpleMessage("به (بخش) همتاها بروید"),
        "messageGood": MessageLookupByLibrary.simpleMessage("خوب"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("اعطا شد"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "اعطای این مجوز نیاز به رفتن به بخش تنظیمات دارد:\n\nتنظیمات»»»اپ‌ها و اعلان‌ها"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "به اپلیکیشن اجازه می‌دهد به همگام‌سازی در پس‌زمینه ادامه دهد"),
        "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
            "ابزاری است که به همتایان اجازه می‌دهد بدون سرور متمرکز یکدیگر را در شبکه همتابه‌همتا P2P پیدا کنند"),
        "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
            "سیستم کشف محلی همتا (Local Peer Discovery) به اپلیکیشن‌های Ouisync شما اجازه می‌دهد تا فایل‌ها را بدون مراجعه به ارائه‌دهندگان خدمات اینترنتی، جایی که یک وای‌فای محلی یا شبکه دیگری در دسترس است، با همتایان خود به اشتراک بگذارند.\n\nبرای اتصال محلی، این تنظیمات باید روشن باشد"),
        "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
            "این مقدار توسط ارائه‌دهنده خدمات اینترنت شما تنظیم شده است.\n\nوقتی این تنظیمات غیرمتقارن باشد، ارتباط با همتایان خود در بهترین وجه امکان‌پذیر می‌شود"),
        "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
            "ابزاری است که برای تبادل لیست همتایان با همتاهایی که به آن‌ها متصل هستید، استفاده می‌شود"),
        "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
            "یک شناسه منحصر‌به‌فرد است که هربار هنگام شروع توسط Ouisync تولید می‌شود.\n\nمی‌توانید از آن برای تأیید ارتباط خود با دیگران در بخش مرتبط با همتای (Peer) اپلیکیشن، استفاده کنید"),
        "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "وقتی این تنظیمات روشن است، ارائه‌دهنده خدمات تلفن همراه شما ممکن است برای (انتقال) داده‌هایی که هنگام همگام‌سازی مخزن‌هایی که با همتایان خود به اشتراک می‌گذارید، از شما هزینه دریافت کند"),
        "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
            "مجموعه‌ای از پروتکل‌های شبکه است که به اپلیکیشن‌های Ouisync شما اجازه می‌دهد تا یکدیگر را کشف کرده و با یکدیگر ارتباط برقرار کنند.\n\nبرای بهترین اتصال، توصیه می‌کنیم این تنظیمات روشن باشد"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("در حال راه‌اندازی…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "روی دکمه باز کردن قفل ضربه بزنید و رمز عبور را برای دسترسی به محتوای این مخزن وارد کنید."),
        "messageInternationalBillHumanRights":
            MessageLookupByLibrary.simpleMessage("اعلامیه جهانی حقوق بشر"),
        "messageKeepBothFiles":
            MessageLookupByLibrary.simpleMessage("هر دو فایل را نگه دارید"),
        "messageLaunchAtStartup": MessageLookupByLibrary.simpleMessage(
            "راه‌اندازی هنگام شروع به کار"),
        "messageLibraryPanic":
            MessageLookupByLibrary.simpleMessage("یک مشکل داخلی شناسایی شد."),
        "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
            "این سرویس ممکن است حاوی پیوندهایی (لینک‌هایی) به وب‌سایت‌های دیگر باشد. اگر روی پیوند شخص ثالث کلیک کنید، به آن سایت هدایت خواهید شد. توجه داشته باشید که این وب‌سایت‌های خارجی توسط ما اداره نمی‌شوند. بنابراین، ما قویاً به شما توصیه می‌کنیم که سند حریم خصوصی این وب سایت‌ها را بررسی کنید. ما هیچ کنترلی بر آن نداریم و هیچ مسئولیتی در قبال محتوا، خط‌مشی‌های حفظ حریم خصوصی، یا عملکرد وب‌سایت‌ها یا خدمات شخص ثالث نداریم."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("در حال بارگذاری…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("کشف محلی"),
        "messageLockOpenRepos": m12,
        "messageLockedRepository":
            MessageLookupByLibrary.simpleMessage("این مخزن قفل شده است."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "در حال قفل کردن تمام مخازنی که باز هستند…"),
        "messageLogData1": MessageLookupByLibrary.simpleMessage(
            "آدرس ایمیل - اگر کاربر تصمیم گرفت از طریق ایمیل با ما تماس بگیرد"),
        "messageLogData2": MessageLookupByLibrary.simpleMessage(
            "اطلاعاتی که کاربر ممکن است از طریق ایمیل، از طریق برگه‌های راهنما، یا از طریق وب‌سایت ما، و ابرداده‌های مرتبط - به منظور دریافت پشتیبانی فنی ارائه دهد"),
        "messageLogData3": MessageLookupByLibrary.simpleMessage(
            "آدرس آی‌پی کاربر - به منظور ارائه پشتیبانی فنی"),
        "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
            "اپلیکیشن Ouisync فایل‌های مرتبط با ثبت رویدادها (لاگ) را در دستگاه‌های کاربران ایجاد می‌کند. هدف آن‌ها فقط ثبت فعالیت دستگاه برای تسهیل فرآیند رفع اشکال در صورتی است که کاربر در برقراری ارتباط با همتایان خود یا در موارد دیگر در استفاده از Ouisync با مشکل مواجه شود. فایل ثبت رویدادها (لاگ) در دستگاه کاربر باقی می‌ماند، مگر اینکه کاربر تصمیم بگیرد، آن‌را برای اهداف پشتیبانی برای ما ارسال کند."),
        "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
            "اگر کاربر تصمیم بگیرد با ما تماس بگیرد، اطلاعات غیرقابل شناسایی شخصی که ممکن است جمع‌آوری کنیم عبارتند از:"),
        "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
            "هیچ‌یک از این اطلاعات با هیچ طرف شخص ثالثی به‌اشتراک گذاشته نمی‌شود"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("همه"),
        "messageLogLevelErroWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage(
                "خطا، هشدار، اطلاعات و رفع اشکال"),
        "messageLogLevelError": MessageLookupByLibrary.simpleMessage("فقط خطا"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("خطا و هشدار"),
        "messageLogLevelErrorWarnInfo":
            MessageLookupByLibrary.simpleMessage("خطا، هشدار و اطلاعات"),
        "messageLogViewer":
            MessageLookupByLibrary.simpleMessage("نمایشگر ثبت رویدادها"),
        "messageMedium": MessageLookupByLibrary.simpleMessage("متوسط"),
        "messageMissingBackgroundServicePermission":
            MessageLookupByLibrary.simpleMessage(
                "اپلیکیشن Ouisync مجوز اجراشدن در پس‌زمینه را ندارد، باز کردن یک اپلیکیشن دیگر ممکن است، روند همگام‌سازی را متوقف کند"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("موبایل"),
        "messageMoveEntryOrigin": m13,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "این ویژگی هنگام جابجایی «ورودی» در دسترس نیست."),
        "messageNATOnWikipedia": MessageLookupByLibrary.simpleMessage(
            "ترجمه آدرس شبکه (NAT) در ویکی‌پدیا"),
        "messageNATType": MessageLookupByLibrary.simpleMessage("نوع NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("شبکه در دسترس نیست"),
        "messageNewFileError": m14,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("رمز عبور جدید"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "رمز عبور جدید در حافظه کوتاه‌مدت کپی شد"),
        "messageNewVersionIsAvailable":
            MessageLookupByLibrary.simpleMessage("یک نسخه جدید در دسترس است."),
        "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
            "هیچ اپلیکیشنی نمی‌تواند این عمل را انجام دهد"),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "قبل از اضافه‌کردن فایل ها، باید یک مخزن ایجاد کنید"),
        "messageNoRepoIsSelected":
            MessageLookupByLibrary.simpleMessage("هیچ مخزنی انتخاب نشده‌ است"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("هیچ مخزنی یافت نشد"),
        "messageNone": MessageLookupByLibrary.simpleMessage("هیچ‌کدام"),
        "messageNote": MessageLookupByLibrary.simpleMessage("توجه"),
        "messageNothingHereYet":
            MessageLookupByLibrary.simpleMessage("اینجا هنوز چیزی وجود ندارد!"),
        "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "فایل‌ها را در همه دستگاه‌های خود یا با دیگران به اشتراک بگذارید و فضای ذخیره سازی ابری امن خود را بسازید!"),
        "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "مخازن را می‌توان به صورت خواندنی-نوشتنی، فقط خواندنی یا «کور» (شما فایل‌ها را برای دیگران ذخیره می‌کنید، اما نمی‌توانید به آن‌ها دسترسی داشته باشید) به اشتراک گذاشت"),
        "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "همه فایل‌ها و پوشه‌های اضافه‌شده به Ouisync به‌طور پیش‌فرض هم در حالت انتقال و هم در حالت استراحت، به‌صورت امن رمزنگاری شده‌اند."),
        "messageOpenFileError": m15,
        "messageOr": MessageLookupByLibrary.simpleMessage("یا"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("Ouisync"),
        "messagePIPEDA": MessageLookupByLibrary.simpleMessage(
            "قانون حفاظت اطلاعات شخصی و اسناد الکترونیکی (PIPEDA)"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("رمز عبور"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "رمز عبور در حافظه کوتاه‌مدت کپی شد"),
        "messagePasswordStrength":
            MessageLookupByLibrary.simpleMessage("میزان قدرتمندی رمز عبور"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("تبادل همتا"),
        "messagePeerExchangeWikipedia":
            MessageLookupByLibrary.simpleMessage("تبادل همتا در ویکی‌پدیا"),
        "messagePermissionRequired":
            MessageLookupByLibrary.simpleMessage("این مجوز لازم است"),
        "messagePreviewingFileFailed": m16,
        "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
            "این بخش برای اطلاع رسانی به بازدیدکنندگان در مورد سیاست‌های ما در مورد جمع‌آوری، استفاده و افشای اطلاعات شخصی در صورتی که کسی تصمیم به استفاده از سرویس ما داشته باشد، استفاده می شود"),
        "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
            "«انسان آزاد به دنیا می‌آید و همه‌جا در زنجیر است»"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "در این مخزن فقط مجوز خواندن وجود دارد"),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "امکان تغییر وجود ندارد، فقط دسترسی به محتوا مجاز است"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "به‌یاد داشته باشید که رمز عبور را به‌طور ایمن ذخیره کنید. اگر آن را فراموش کردید، راهی برای بازیابی آن وجود ندارد."),
        "messageRemovaLocalPassword":
            MessageLookupByLibrary.simpleMessage("حذف رمز عبور محلی"),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage("حذف اعتبارسنجی بیومتریکی"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("حذف روش‌های بیومتریکی"),
        "messageRemoveBiometricsConfirmationMoreInfo":
            MessageLookupByLibrary.simpleMessage(
                "با این عمل رمز مخزن حذف می‌شود و از اعتبارسنجی بیومتریک برای باز‌کردن قفل استفاده می‌شود"),
        "messageRemoveLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "این رمز عبور محلی مخزن حذف شود؟\n\nمخزن به‌طور خودکار باز می‌شود، مگر اینکه یک رمز عبور محلی مجدد اضافه شود"),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("حذف شد"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("تغییر نام فایل"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("تغییر نام پوشه"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("تغییر نام مخزن"),
        "messageReplaceExistingFile":
            MessageLookupByLibrary.simpleMessage("فایل موجود را جایگزین کنید"),
        "messageRepoAuthFailed":
            MessageLookupByLibrary.simpleMessage("خطا در احراز هویت مخزن"),
        "messageRepoDeletionErrorDescription": m17,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "(درخواست) حذف مخزن ناموفق بود"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "مخزن موردنظر دیگر آن‌جا نیست"),
        "messageRepoMissingErrorDescription": m18,
        "messageRepositoryAccessMode": m19,
        "messageRepositoryAlreadyExist": m20,
        "messageRepositoryCurrentPassword":
            MessageLookupByLibrary.simpleMessage("رمز عبور کنونی"),
        "messageRepositoryIsNotOpen":
            MessageLookupByLibrary.simpleMessage("هیچ مخزنی باز نیست"),
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("به مخزن یک نام اختصاص دهید"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("نام جدید مخزن"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("رمز عبور جدید"),
        "messageRepositoryNotMounted":
            MessageLookupByLibrary.simpleMessage("مخرن موردنظر نصب نشده است "),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("رمز عبور"),
        "messageRepositorySuggestedName": m21,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("لینک را این‌جا قرار دهید"),
        "messageRousseau": MessageLookupByLibrary.simpleMessage("ژان ژاک روسو"),
        "messageSaveLogFile": MessageLookupByLibrary.simpleMessage(
            "ذخیره‌سازی فایل مرتبط با ثبت رویدادها"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "فایل موردنظر را در این پوشه ذخیره کنید"),
        "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
            "آیا می‌خواهید تغییرات فعلی را ذخیره کنید؟"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "این (کد QR) را با دستگاه دیگر خود اسکن کنید یا با همتایان خود به اشتراک بگذارید"),
        "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "با استفاده از بیومتریک ایمن شوید"),
        "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
            "داده‌هایی که کاربر در مخازن Ouisync آپلود می‌کند، در حین انتقال و همچنین در حالت استراحت رمزنگاری شده‌اند. این شامل ابرداده‌هایی مانند نام فایل، اندازه، ساختار پوشه و غیره می‌شود. در Ouisync، داده‌ها فقط توسط شخصی که داده‌ها را آپلود کرده و افرادی که مخازن خود را با آن‌ها به اشتراک گذاشته‌اند، قابل خواندن است."),
        "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
            "درباره تکنیک‌های رمزنگاری مورد استفاده در اسناد ما می‌توانید اطلاعات بیشتری کسب کنید"),
        "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
            "اپلیکیشن Ouisync داده‌های کاربران را روی یک همتای همیشه فعال [Always-On Peer] که سروری در کشور کانادا است، ذخیره می‌کند. همه داده‌ها به صورت تکه‌های رمزنگاری‌شده ذخیره می‌شوند و توسط سرور یا اپراتورهای آن قابل خواندن نیستند. هدف این سرور صرفاً پر کردن شکاف بین همتایان خود است که هم‌زمان آنلاین نیستند. تمام داده‌ها به صورت دوره‌ای از این سرور پاک می شوند - هدف آن ارائه ذخیره‌سازی دائمی داده نیست، بلکه همگام‌سازی داده‌ها توسط همتایان را تسهیل می‌کند."),
        "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
            "اگر دلیلی مبنی بر به‌اشتراک‌گذاری و نشت اطلاعات شخصی خودتان به‌طور غیرقانونی توسط سایر کاربران Ouisync دارید، لطفاً با آدرس زیر با ما تماس بگیرید."),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "یک مجوز برای ایجاد پیوند (لینک) به‌اشتراک‌گذاری انتخاب کنید"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("مکان را انتخاب کنید"),
        "messageSettingsRuntimeID":
            MessageLookupByLibrary.simpleMessage("شناسه زمان اجرا"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "برای ایجاد پیوند مخزن ابتدا باید یک مجوز انتخاب کنید"),
        "messageShareWithWR":
            MessageLookupByLibrary.simpleMessage("کد QR را به‌ اشتراک بگذارید"),
        "messageStorage":
            MessageLookupByLibrary.simpleMessage("فضای ذخیره‌سازی"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "برای دسترسی به فایل‌ها مورد نیاز است"),
        "messageStrong": MessageLookupByLibrary.simpleMessage("قوی"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "همگام‌سازی هنگام استفاده از اینترنت همراه"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "هنگام استفاده از اینترنت همراه، همگام‌سازی غیرفعال است"),
        "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "برای خواندن شرایط استفاده و سند حریم خصوصی، این‌جا ضربه بزنید"),
        "messageTapForValues": MessageLookupByLibrary.simpleMessage(
            "برای خواندن اصول (ارزش‌ها) ما این‌جا ضربه بزنید"),
        "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
            "حقوق مرتبط با حفاظت از اطلاعات شخصی، از جمله اصول و ارزش‌های اساسی یا قانون: [] را نقض می‌کنند "),
        "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
            "(قانون حفاظت از اطلاعات شخصی و اسناد الکترونیکی)"),
        "messageTerms2": MessageLookupByLibrary.simpleMessage(
            "شامل مطالب استثمار جنسی کودکان (از جمله مطالبی که ممکن است موارد مرتبط با سوءاستفاده جنسی غیرقانونی از کودکان نباشد، اما با این وجود سوءاستفاده جنسی از خردسالان را ترویج می کند)، پورنوگرافی غیرقانونی یا در غیر این‌صورت ناشایست هستند."),
        "messageTerms3": MessageLookupByLibrary.simpleMessage(
            "حاوی یا ترویج‌کننده اعمال شدید خشونت‌آمیز یا فعالیت های تروریستی، از جمله ترور یا تبلیغات خشونت‌آمیز افراطی"),
        "messageTerms4": MessageLookupByLibrary.simpleMessage(
            "دفاع از تعصب، نفرت‌پراکنی، یا تحریک خشونت علیه هر فرد یا گروهی از مردم بر اساس نژاد، مذهب، قومیت، ملیت، جنسیت، هویت جنسیتی، گرایش جنسی، ناتوانی، نقص یا هر ویژگی دیگر مرتبط با آن‌ها است. تبعیض یا به حاشیه‌راندن سیستماتیک"),
        "messageTerms5": MessageLookupByLibrary.simpleMessage(
            "فایل‌هایی که حاوی ویروس‌ها، تروجان‌ها، کرم‌ها، بمب‌های منطقی یا موارد دیگری که مخرب یا از نظر فناوری مضر هستند"),
        "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
            "این شرایط استفاده از Ouisync «توافقنامه»، همراه با سند حریم خصوصی ما (مجموعاً «شرایط»)، بر استفاده شما از Ouisync - یک پروتکل و نرم‌افزار همگام‌سازی فایل به‌طور آنلاین، حاکم است."),
        "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
            "با نصب و اجرای اپلیکیشن Ouisync، موافقت خود را برای تعهد و رعایت این توافق‌نامه میان شما و eQualitie inc اعلام می‌کنید. («eQualitie»، «ما» یا «ما»). استفاده از اپلیکیشن Ouisync و شبکه Ouisync (خدمات) توسط eQualitie بدون هیچ هزینه‌ای ارائه می‌شود و برای استفاده همانطور که هست، در نظر گرفته شده است."),
        "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
            "اپلیکیشن Ouisync مطابق با اصول و ارزش‌های eQuality ساخته شده است. با استفاده از این نرم‌افزار، موافقت می‌کنید که از Ouisync برای انتشار، به‌اشتراک‌گذاری یا ذخیره مطالبی که مغایر با ارزش‌های اساسی یا قوانین ایالت کبک یا کشور کانادا یا اعلامیه جهانی حقوق بشر است، از جمله محتوایی که:"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "توکن مخزن در حافظه موقت کپی شد."),
        "messageUnknownFileExtension":
            MessageLookupByLibrary.simpleMessage("فرمت فایل ناشناخته است"),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "رمز عبور موردنظر مخزن را باز نکرد"),
        "messageUnlockRepoOk": m22,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "رمز عبور را برای باز کردن قفل وارد کنید"),
        "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "با استفاده از بیومتریک قفل را باز کنید"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "شما تغییرات ذخیره‌نشده‌ای دارید\n\nآیا می خواهید آن‌ها را نادیده بگیرید؟"),
        "messageUpdateLocalPasswordConfirmation":
            MessageLookupByLibrary.simpleMessage(
                "رمز عبور محلی این مخزن به‌روز شود؟"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("وی‌پی‌ان"),
        "messageValidateLocalPassword":
            MessageLookupByLibrary.simpleMessage("تایید رمز عبور محلی"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("درازنویسی ثبت رویدادها"),
        "messageView": MessageLookupByLibrary.simpleMessage("بازدید"),
        "messageWeak": MessageLookupByLibrary.simpleMessage("ضعیف"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("وای‌فای"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "دسترسی کامل. همتاهای شما امکان خواندن و نوشتن دارند"),
        "messageWritingFileCanceled": m23,
        "messageWritingFileError": m24,
        "messsageFailedAddRepository": m25,
        "messsageFailedCreateRepository": m26,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("تغییر رمز عبور"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("کپی‌کردن رمز عبور"),
        "replacementAccess": m27,
        "replacementChanges": m28,
        "replacementEntry": m29,
        "replacementName": m30,
        "replacementNumber": m31,
        "replacementPath": m32,
        "replacementStatus": m33,
        "statusSync": MessageLookupByLibrary.simpleMessage("همگام‌سازی شد"),
        "statusUnspecified": MessageLookupByLibrary.simpleMessage("نامشخص"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("درباره ما"),
        "titleAddFile":
            MessageLookupByLibrary.simpleMessage("اضافه‌کردن فایل به Ouisync"),
        "titleAddRepoToken":
            MessageLookupByLibrary.simpleMessage("واردکردن یک مخزن با توکن"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("وارد‌کردن یک مخزن"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("مجوزهای مورد نیاز"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("تغییر رمز عبور"),
        "titleChangesToTerms":
            MessageLookupByLibrary.simpleMessage("تغییرات به این شرایط"),
        "titleChildrensPrivacy":
            MessageLookupByLibrary.simpleMessage("حریم خصوصی کودکان"),
        "titleContactUs": MessageLookupByLibrary.simpleMessage("تماس با ما"),
        "titleCookies": MessageLookupByLibrary.simpleMessage("کوکی‌ها"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("ایجاد یک پوشه"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("ایجاد یک مخزن جدید"),
        "titleDataCollection":
            MessageLookupByLibrary.simpleMessage("۳.۱ جمع‌آوری اطلاعات"),
        "titleDataSharing":
            MessageLookupByLibrary.simpleMessage("۳.۲ به‌اشتراک‌گذاری اطلاعات"),
        "titleDeleteFile": MessageLookupByLibrary.simpleMessage("حذف فایل"),
        "titleDeleteFolder": MessageLookupByLibrary.simpleMessage("حذف پوشه"),
        "titleDeleteNotEmptyFolder":
            MessageLookupByLibrary.simpleMessage("حذف پوشه‌ غیر خالی"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("حذف مخزن"),
        "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
            "۳.۴ حذف اطلاعات شما از سرور [Always-On-Peer] ما"),
        "titleDigitalSecurity":
            MessageLookupByLibrary.simpleMessage("امنیت دیجیتال"),
        "titleDownloadLocation":
            MessageLookupByLibrary.simpleMessage("محل دانلود"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("دانلود در دستگاه"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("ویرایش مخزن"),
        "titleEqualitiesValues":
            MessageLookupByLibrary.simpleMessage("ارزش‌های سازمان eQualitie"),
        "titleFAQShort":
            MessageLookupByLibrary.simpleMessage("پرسش‌های متداول"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("جزییات فایل‌"),
        "titleFileExtensionChanged":
            MessageLookupByLibrary.simpleMessage("تغییر پسوند فایل"),
        "titleFileExtensionMissing":
            MessageLookupByLibrary.simpleMessage("پسوند فایل موجود نیست"),
        "titleFolderActions":
            MessageLookupByLibrary.simpleMessage("اضافه‌ کردن"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("جزییات پوشه"),
        "titleFreedomExpresionAccessInfo": MessageLookupByLibrary.simpleMessage(
            "آزادی بیان و دسترسی به اطلاعات"),
        "titleIssueTracker":
            MessageLookupByLibrary.simpleMessage("ردیاب اشکالات"),
        "titleJustLegalSociety":
            MessageLookupByLibrary.simpleMessage("جامعه عدالت‌محور و قانونی"),
        "titleLinksOtherSites":
            MessageLookupByLibrary.simpleMessage("لینک به سایت‌های دیگر"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("قفل‌کردن تمام مخزن‌ها"),
        "titleLogData": MessageLookupByLibrary.simpleMessage("ثبت اطلاعات"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("ثبت رویدادها"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("(مقدار) ورودی در حال انتقال"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("شبکه"),
        "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
            "دسترسی به فایل‌ها از دستگاه‌های مختلف"),
        "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
            "تنظیم مجوزهایی برای همکاری، پخش و ذخیره‌سازی به‌طور ساده"),
        "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
            "ارسال و دریافت فایل‌ها به‌طور امن"),
        "titleOpennessTransparency":
            MessageLookupByLibrary.simpleMessage("صداقت و شفافیت"),
        "titleOurMission": MessageLookupByLibrary.simpleMessage("ماموریت ما"),
        "titleOurPrinciples": MessageLookupByLibrary.simpleMessage("اصول ما"),
        "titleOurValues": MessageLookupByLibrary.simpleMessage("ارزش‌های ما"),
        "titleOverview":
            MessageLookupByLibrary.simpleMessage("۱. بررسی اجمالی"),
        "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
            "قانون حفاظت از اطلاعات شخصی و اسناد الکترونیکی (PIPEDA)"),
        "titlePrivacy": MessageLookupByLibrary.simpleMessage("حریم خصوصی"),
        "titlePrivacyNotice":
            MessageLookupByLibrary.simpleMessage("۳. سند حریم خصوصی"),
        "titlePrivacyPolicy":
            MessageLookupByLibrary.simpleMessage("سند حریم خصوصی"),
        "titleRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("مشخصات بیومتریک را حذف کنید"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("مخزن‌های من"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("مخزن"),
        "titleRepositoryName": MessageLookupByLibrary.simpleMessage("نام مخزن"),
        "titleRequiredPermission":
            MessageLookupByLibrary.simpleMessage("مجوز مورد نیاز"),
        "titleSaveChanges":
            MessageLookupByLibrary.simpleMessage("ذخیره تغییرات"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("اسکن کد QR مخزن"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("امنیت"),
        "titleSecurityPractices":
            MessageLookupByLibrary.simpleMessage("۳.۳ تمرینات امنیتی"),
        "titleSendFeedback":
            MessageLookupByLibrary.simpleMessage("ارسال نظرات"),
        "titleSetPasswordFor":
            MessageLookupByLibrary.simpleMessage("انتخاب رمز عبور"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
        "titleShareRepository": m34,
        "titleSortBy":
            MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس"),
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("نظارت بر وضعیت"),
        "titleTermsOfUse":
            MessageLookupByLibrary.simpleMessage("۲. شرایط استفاده"),
        "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
            "شرایط استفاده و سند حریم خصوصی Ouisync"),
        "titleUPnP":
            MessageLookupByLibrary.simpleMessage("معیار اجرا و اتصال همگانی"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("بازکردن قفل مخزن"),
        "titleUnsavedChanges":
            MessageLookupByLibrary.simpleMessage("تغییرات ذخیره‌ نشده"),
        "titleWeAreEq":
            MessageLookupByLibrary.simpleMessage("ما eQualit.ie هستیم"),
        "typeFile": MessageLookupByLibrary.simpleMessage("فایل"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("پوشه")
      };
}
