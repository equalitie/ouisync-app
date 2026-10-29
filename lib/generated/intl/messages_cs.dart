// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a cs locale. All the
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
  String get localeName => 'cs';

  static String m0(access) =>
      "Oprávnění nesmí být vyšší než aktuální režim přístupu repozitáře: ${access}.";

  static String m39(totals) => "Kopírovat výběr sem:\n\n\t\t${totals}";

  static String m40(totals) => "Smazat výběr:\n\n\t\t${totals}";

  static String m1(path) => "Soubor stažen do ${path}";

  static String m2(name) => "${name} – stahování zrušeno";

  static String m3(name) => "${name} – stahování se nezdařilo";

  static String m4(entry) => "${entry} už existuje.";

  static String m41(name) => "Chyba při vytváření složky ${name}";

  static String m5(path) =>
      "Aktuální složka „${path}“ chybí. Přechází se do nadřazené složky.";

  static String m6(error) => "Chyba: ${error}";

  static String m7(dokanUrl) => "Dokan chybí.${dokanUrl}";

  static String m8(name) => "Inicializace repozitáře ${name} se nezdařila.";

  static String m9(path) => "Umístění ${path} není prázdné.";

  static String m10(name) => "Nepodařilo se importovat repozitář ${name}";

  static String m11(name) => "";

  static String m12(reason) =>
      "Přístup k repozitářům prostřednictvím Průzkumníka souborů není dostupný: ${reason}";

  static String m13(name) =>
      "${name} už v tomto umístění existuje.\n\nCo chcete udělat?";

  static String m42(name) => "Soubor úspěšně smazán: ${name}";

  static String m43(name) => "Soubor přejmenován na ${name}";

  static String m14(name) => "Složka úspěšně smazána: ${name}";

  static String m44(name) => "Složka přejmenována na ${name}";

  static String m15(number) =>
      "Chcete zamknout všechny otevřené repozitáře?\n\n(Otevřeno: ${number})";

  static String m45(totals) => "Přesunout výběr sem:\n\n\t\t${totals}";

  static String m16(path) => "z ${path}";

  static String m17(name) => "Chyba při vytváření souboru ${name}";

  static String m18(name) => "Chyba při otevírání souboru ${name}";

  static String m19(path) => "Náhled souboru ${path} se nezdařil.";

  static String m20(name) => "Repozitář „${name}“ se nepodařilo smazat.";

  static String m21(name) =>
      "Repozitář „${name}“ se nepodařilo najít v obvyklém umístění.";

  static String m22(access) => "Udělený režim přístupu: ${access}";

  static String m23(name) =>
      "Tento repozitář už v aplikaci existuje pod názvem „${name}“.";

  static String m46(name) => "Repozitář ${name} smazán";

  static String m47(name) => "Repozitář přejmenován na ${name}";

  static String m24(name) =>
      "Návrh: ${name}\n(klepnutím sem tento název použijete)";

  static String m48(totals) => "Uložit výběr:\n\n\t\t${totals}";

  static String m49(path) => "Sdílení souboru ${path} se nezdařilo.";

  static String m25(name) => "Řazení: ${name}";

  static String m26(access) => "Replika odemčena v režimu „${access}“";

  static String m27(name) => "Zadejte heslo k odemčení repozitáře „${name}“";

  static String m28(name) => "Zápis souboru ${name} zrušen";

  static String m29(name) => "${name} – zápis se nezdařil";

  static String m30(access) => "";

  static String m31(changes) => "";

  static String m32(entry) => "${entry}";

  static String m33(error) => "${error}";

  static String m34(name) => "${name}";

  static String m35(number) => "";

  static String m36(path) => "${path}";

  static String m37(status) => "${status}";

  static String m50(storage) =>
      "Chcete přesunout repozitář do úložiště <bold>„${storage}“</bold>?";

  static String m38(name) => "Sdílet repozitář „${name}“";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accessModeBlindLabel": MessageLookupByLibrary.simpleMessage(
      "Bez přístupu",
    ),
    "accessModeReadLabel": MessageLookupByLibrary.simpleMessage("Jen čtení"),
    "accessModeWriteLabel": MessageLookupByLibrary.simpleMessage(
      "Čtení a zápis",
    ),
    "actionAccept": MessageLookupByLibrary.simpleMessage("Potvrdit"),
    "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("Přijmout"),
    "actionAddRepository": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář",
    ),
    "actionAddRepositoryWithToken": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář",
    ),
    "actionAllow": MessageLookupByLibrary.simpleMessage("Povolit"),
    "actionBack": MessageLookupByLibrary.simpleMessage("Zpět"),
    "actionCancel": MessageLookupByLibrary.simpleMessage("Zrušit"),
    "actionCancelCapital": MessageLookupByLibrary.simpleMessage("Zrušit"),
    "actionClear": MessageLookupByLibrary.simpleMessage("Vymazat"),
    "actionCloseCapital": MessageLookupByLibrary.simpleMessage("Zavřít"),
    "actionCopy": MessageLookupByLibrary.simpleMessage("Kopírovat"),
    "actionCreate": MessageLookupByLibrary.simpleMessage("Vytvořit"),
    "actionCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Vytvořit repozitář",
    ),
    "actionDelete": MessageLookupByLibrary.simpleMessage("Smazat"),
    "actionDeleteCapital": MessageLookupByLibrary.simpleMessage("Smazat"),
    "actionDeleteFile": MessageLookupByLibrary.simpleMessage("Smazat soubor"),
    "actionDeleteFolder": MessageLookupByLibrary.simpleMessage("Smazat složku"),
    "actionDeleteRepository": MessageLookupByLibrary.simpleMessage(
      "Smazat repozitář",
    ),
    "actionDiscard": MessageLookupByLibrary.simpleMessage("Zahodit"),
    "actionDone": MessageLookupByLibrary.simpleMessage("Hotovo"),
    "actionDownload": MessageLookupByLibrary.simpleMessage("Stáhnout"),
    "actionEditRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Upravit název",
    ),
    "actionEject": MessageLookupByLibrary.simpleMessage("Vysunout"),
    "actionExit": MessageLookupByLibrary.simpleMessage("Ukončit"),
    "actionGoToSettings": MessageLookupByLibrary.simpleMessage(
      "Přejít do nastavení",
    ),
    "actionHide": MessageLookupByLibrary.simpleMessage("Skrýt"),
    "actionHideCapital": MessageLookupByLibrary.simpleMessage("Skrýt"),
    "actionIAgree": MessageLookupByLibrary.simpleMessage("Souhlasím"),
    "actionIDontAgree": MessageLookupByLibrary.simpleMessage("Nesouhlasím"),
    "actionIDontHaveALocalPassword": MessageLookupByLibrary.simpleMessage(
      "Nemám místní heslo k tomuto repozitáři",
    ),
    "actionImport": MessageLookupByLibrary.simpleMessage("Importovat"),
    "actionImportRepo": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář",
    ),
    "actionInstallDokan": MessageLookupByLibrary.simpleMessage(
      "Nainstalovat Dokan",
    ),
    "actionLockCapital": MessageLookupByLibrary.simpleMessage("Zamknout"),
    "actionMove": MessageLookupByLibrary.simpleMessage("Přesunout"),
    "actionNewFile": MessageLookupByLibrary.simpleMessage("Soubor"),
    "actionNewFolder": MessageLookupByLibrary.simpleMessage("Složka"),
    "actionNewMediaFile": MessageLookupByLibrary.simpleMessage("Média"),
    "actionNewRepo": MessageLookupByLibrary.simpleMessage("Vytvořit repozitář"),
    "actionNext": MessageLookupByLibrary.simpleMessage("Další"),
    "actionNo": MessageLookupByLibrary.simpleMessage("Ne"),
    "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
    "actionPreviewFile": MessageLookupByLibrary.simpleMessage(
      "Zobrazit náhled souboru",
    ),
    "actionReloadContents": MessageLookupByLibrary.simpleMessage(
      "Načíst znovu",
    ),
    "actionReloadRepo": MessageLookupByLibrary.simpleMessage(
      "Znovu načíst repozitář",
    ),
    "actionRemove": MessageLookupByLibrary.simpleMessage("Odebrat"),
    "actionRemoveLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Odstranit místní heslo",
    ),
    "actionRemoveRepo": MessageLookupByLibrary.simpleMessage(
      "Odebrat repozitář",
    ),
    "actionRename": MessageLookupByLibrary.simpleMessage("Přejmenovat"),
    "actionRetry": MessageLookupByLibrary.simpleMessage("Zkusit znovu"),
    "actionSave": MessageLookupByLibrary.simpleMessage("Uložit"),
    "actionSaveChanges": MessageLookupByLibrary.simpleMessage("Uložit změny"),
    "actionScanQR": MessageLookupByLibrary.simpleMessage("Naskenovat QR kód"),
    "actionSelect": MessageLookupByLibrary.simpleMessage("Vybrat"),
    "actionShare": MessageLookupByLibrary.simpleMessage("Sdílet"),
    "actionShareFile": MessageLookupByLibrary.simpleMessage("Sdílet soubor"),
    "actionShow": MessageLookupByLibrary.simpleMessage("Zobrazit"),
    "actionSkip": MessageLookupByLibrary.simpleMessage("Přeskočit"),
    "actionUndo": MessageLookupByLibrary.simpleMessage("Vrátit zpět"),
    "actionUnlock": MessageLookupByLibrary.simpleMessage("Odemknout"),
    "actionUpdate": MessageLookupByLibrary.simpleMessage("Aktualizovat"),
    "actionUpdateDokan": MessageLookupByLibrary.simpleMessage(
      "Aktualizovat Dokan",
    ),
    "actionYes": MessageLookupByLibrary.simpleMessage("Ano"),
    "buttonLocateRepository": MessageLookupByLibrary.simpleMessage("Vybrat"),
    "copyToClipboard": MessageLookupByLibrary.simpleMessage(
      "Kopírovat do schránky",
    ),
    "iconAccessMode": MessageLookupByLibrary.simpleMessage("Režim přístupu"),
    "iconAddExistingRepository": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář",
    ),
    "iconCopy": MessageLookupByLibrary.simpleMessage("Kopírovat"),
    "iconCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Vytvořit nový repozitář",
    ),
    "iconDelete": MessageLookupByLibrary.simpleMessage("Smazat"),
    "iconDownload": MessageLookupByLibrary.simpleMessage("Stáhnout"),
    "iconInformation": MessageLookupByLibrary.simpleMessage("Informace"),
    "iconMove": MessageLookupByLibrary.simpleMessage("Přesunout"),
    "iconPreview": MessageLookupByLibrary.simpleMessage("Zobrazit náhled"),
    "iconRename": MessageLookupByLibrary.simpleMessage("Přejmenovat"),
    "iconShare": MessageLookupByLibrary.simpleMessage("Sdílet"),
    "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
      "Sdílet s protějškem",
    ),
    "labelAppVersion": MessageLookupByLibrary.simpleMessage("Verze aplikace"),
    "labelAttachLogs": MessageLookupByLibrary.simpleMessage(
      "Přiložit protokoly",
    ),
    "labelBitTorrentDHT": MessageLookupByLibrary.simpleMessage(
      "BitTorrent DHT",
    ),
    "labelConnectionType": MessageLookupByLibrary.simpleMessage(
      "Typ připojení",
    ),
    "labelCopyLink": MessageLookupByLibrary.simpleMessage("Kopírovat odkaz"),
    "labelDestination": MessageLookupByLibrary.simpleMessage("Cíl"),
    "labelDownloadedTo": MessageLookupByLibrary.simpleMessage("Staženo do:"),
    "labelEndpoint": MessageLookupByLibrary.simpleMessage("Koncový bod: "),
    "labelExternalIPv4": MessageLookupByLibrary.simpleMessage("Externí IPv4"),
    "labelExternalIPv6": MessageLookupByLibrary.simpleMessage("Externí IPv6"),
    "labelLocalIPv4": MessageLookupByLibrary.simpleMessage("Místní IPv4"),
    "labelLocalIPv6": MessageLookupByLibrary.simpleMessage("Místní IPv6"),
    "labelLocation": MessageLookupByLibrary.simpleMessage("Umístění: "),
    "labelLockAllRepos": MessageLookupByLibrary.simpleMessage("Zamknout vše"),
    "labelName": MessageLookupByLibrary.simpleMessage("Název: "),
    "labelNewName": MessageLookupByLibrary.simpleMessage("Nový název: "),
    "labelPassword": MessageLookupByLibrary.simpleMessage("Heslo: "),
    "labelPeers": MessageLookupByLibrary.simpleMessage("Protějšky"),
    "labelQRCode": MessageLookupByLibrary.simpleMessage("QR kód"),
    "labelQuicListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Naslouchání na QUIC/UDP IPv4",
    ),
    "labelQuicListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Naslouchání na QUIC/UDP IPv6",
    ),
    "labelRememberPassword": MessageLookupByLibrary.simpleMessage(
      "Zapamatovat si heslo",
    ),
    "labelRenameRepository": MessageLookupByLibrary.simpleMessage(
      "Zadejte nový název: ",
    ),
    "labelRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "Současné heslo",
    ),
    "labelRepositoryLink": MessageLookupByLibrary.simpleMessage(
      "Odkaz na repozitář: ",
    ),
    "labelRetypePassword": MessageLookupByLibrary.simpleMessage(
      "Zadejte heslo znovu: ",
    ),
    "labelSelectRepository": MessageLookupByLibrary.simpleMessage(
      "Vyberte repozitář ",
    ),
    "labelSetPermission": MessageLookupByLibrary.simpleMessage(
      "Nastavit oprávnění",
    ),
    "labelShareLink": MessageLookupByLibrary.simpleMessage("Sdílet odkaz"),
    "labelSize": MessageLookupByLibrary.simpleMessage("Velikost: "),
    "labelSyncStatus": MessageLookupByLibrary.simpleMessage(
      "Stav synchronizace: ",
    ),
    "labelSynced": MessageLookupByLibrary.simpleMessage("Synchronizováno"),
    "labelTcpListenerEndpointV4": MessageLookupByLibrary.simpleMessage(
      "Naslouchání na TCP IPv4",
    ),
    "labelTcpListenerEndpointV6": MessageLookupByLibrary.simpleMessage(
      "Naslouchání na TCP IPv6",
    ),
    "labelTokenLink": MessageLookupByLibrary.simpleMessage(
      "Odkaz pro sdílení repozitáře",
    ),
    "labelTypePassword": MessageLookupByLibrary.simpleMessage(
      "Zadejte heslo: ",
    ),
    "languageIsNotAvailable": MessageLookupByLibrary.simpleMessage(
      "není k dispozici",
    ),
    "languageOfTheDevice": MessageLookupByLibrary.simpleMessage(
      "jazyk zařízení",
    ),
    "menuItemAbout": MessageLookupByLibrary.simpleMessage("O aplikaci"),
    "menuItemLogs": MessageLookupByLibrary.simpleMessage("Protokoly"),
    "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Síť"),
    "menuItemRepository": MessageLookupByLibrary.simpleMessage("Repozitář"),
    "messageAccessModeDisabled": m0,
    "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
      "Přístup k zabezpečenému úložišti",
    ),
    "messageAck": MessageLookupByLibrary.simpleMessage("Jejda!"),
    "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Tato možnost není dostupná u repozitářů jen pro čtení.",
    ),
    "messageAddRepoDb": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář ze souborového systému",
    ),
    "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář pomocí odkazu s tokenem",
    ),
    "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář pomocí QR kódu",
    ),
    "messageAddingFileToLockedRepository": MessageLookupByLibrary.simpleMessage(
      "Tento repozitář je zamčený nebo jde o repliku bez přístupu k obsahu.\n\nPokud máte heslo, odemkněte ho a zkuste to znovu.",
    ),
    "messageAddingFileToReadRepository": MessageLookupByLibrary.simpleMessage(
      "Tento repozitář je replika jen pro čtení.",
    ),
    "messageAuthenticate": MessageLookupByLibrary.simpleMessage(
      "Ověřit totožnost",
    ),
    "messageAutomaticUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "Repozitář se nepodařilo odemknout.",
        ),
    "messageAvailableOnMobile": MessageLookupByLibrary.simpleMessage(
      "Dostupné na mobilních zařízeních",
    ),
    "messageAwaitingResult": MessageLookupByLibrary.simpleMessage(
      "Čekání na výsledek…",
    ),
    "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
      "Operační systém vás za chvíli požádá o oprávnění ke spuštění této aplikace na pozadí.\n\nToto oprávnění je vyžadováno, aby synchronizace pokračovala, i když aplikace není v popředí.",
    ),
    "messageBackgroundNotification": MessageLookupByLibrary.simpleMessage(
      "Ouisync běží",
    ),
    "messageBioAuthFailed": MessageLookupByLibrary.simpleMessage(
      "Biometrické ověření se nezdařilo.",
    ),
    "messageBiometricUnlockRepositoryFailed":
        MessageLookupByLibrary.simpleMessage(
          "Odemčení pomocí biometrického ověření se nezdařilo.",
        ),
    "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Váš protějšek nemůže číst ani měnit obsah.",
    ),
    "messageBlindRepository": MessageLookupByLibrary.simpleMessage(
      "Tento repozitář je replikou bez přístupu k obsahu.",
    ),
    "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
      "Zadané <bold>heslo</bold> vám neumožňuje zobrazit obsah tohoto repozitáře.",
    ),
    "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
    "messageBy": MessageLookupByLibrary.simpleMessage("od"),
    "messageCamera": MessageLookupByLibrary.simpleMessage("Kamera"),
    "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
      "Toto oprávnění potřebujeme k použití kamery a načtení QR kódu.",
    ),
    "messageCanadaPrivacyAct": MessageLookupByLibrary.simpleMessage(
      "Privacy Act (Kanada)",
    ),
    "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
      "Změna přípony může způsobit, že soubor nebude použitelný.",
    ),
    "messageChangesToTermsP1": MessageLookupByLibrary.simpleMessage(
      "Naše Podmínky můžeme čas od času aktualizovat. Proto vám doporučujeme tuto stránku pravidelně kontrolovat, zda nedošlo ke změnám",
    ),
    "messageChangesToTermsP2": MessageLookupByLibrary.simpleMessage(
      "Tyto zásady jsou účinné od 2022-03-09",
    ),
    "messageChildrensPolicyP1": MessageLookupByLibrary.simpleMessage(
      "Vědomě neshromažďujeme údaje umožňující osobní identifikaci dětí. Všechny děti vyzýváme, aby prostřednictvím Aplikace a/nebo Služeb nikdy neposkytovaly žádné takové údaje. Rodiče a zákonné zástupce vybízíme, aby sledovali používání internetu svými dětmi a pomáhali prosazovat tyto zásady tím, že dětem vysvětlí, aby prostřednictvím Aplikace a/nebo Služeb nikdy neposkytovaly údaje umožňující osobní identifikaci bez jejich svolení. Máte-li důvod se domnívat, že nám dítě poskytlo takové údaje prostřednictvím Aplikace a/nebo Služeb, kontaktujte nás. Abyste mohli ve své zemi udělit souhlas se zpracováním svých údajů umožňujících osobní identifikaci, musí vám být také alespoň 16 let (v některých zemích můžeme umožnit, aby jej za vás udělil rodič nebo zákonný zástupce)",
    ),
    "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
      "Opravdu chcete smazat tento soubor?",
    ),
    "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "Opravdu chcete smazat tuto složku?",
    ),
    "messageConfirmIrreversibleChange": MessageLookupByLibrary.simpleMessage(
      "Tato akce je nevratná. Chcete pokračovat?",
    ),
    "messageConfirmNotEmptyFolderDeletion": MessageLookupByLibrary.simpleMessage(
      "Tato složka není prázdná.\n\nChcete ji přesto smazat? (Smaže se tím veškerý její obsah.)",
    ),
    "messageConfirmRepositoryDeletion": MessageLookupByLibrary.simpleMessage(
      "Opravdu chcete smazat tento repozitář?",
    ),
    "messageContatUsP1": MessageLookupByLibrary.simpleMessage(
      "Máte-li jakékoli dotazy nebo návrhy k našim Zásadám ochrany soukromí, neváhejte nás kontaktovat na adrese",
    ),
    "messageCookiesP1": MessageLookupByLibrary.simpleMessage(
      "Aplikace Ouisync nepoužívá cookies",
    ),
    "messageCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Zkopírováno do schránky.",
    ),
    "messageCopyEntries": m39,
    "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
      "Vytvořte novou <bold>složku</bold> nebo přidejte <bold>soubor</bold> pomocí <icon></icon>.",
    ),
    "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
      "Vytvořte nový <bold>repozitář</bold> nebo pomocí <bold>tokenu repozitáře</bold> importujte repozitář od přítele.",
    ),
    "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
      "Vytváření sdílecího tokenu…",
    ),
    "messageDataCollectionP1": MessageLookupByLibrary.simpleMessage(
      "Tým Ouisync si váží soukromí uživatelů, a proto neshromažďuje žádné informace o uživatelích",
    ),
    "messageDataCollectionP2": MessageLookupByLibrary.simpleMessage(
      "Aplikace Ouisync je navržena tak, aby mohla poskytovat služby sdílení souborů bez ID uživatele, jména, přezdívky, uživatelského účtu nebo jakékoli jiné formy uživatelských údajů. Nevíme, kdo naši aplikaci používá a s kým synchronizuje nebo sdílí svá data",
    ),
    "messageDataSharingP1": MessageLookupByLibrary.simpleMessage(
      "Ouisync (a eQualit.ie) nesdílí žádná data s žádnými třetími stranami",
    ),
    "messageDeclarationDOS": MessageLookupByLibrary.simpleMessage(
      "Prohlášení o distribuovaných online službách",
    ),
    "messageDeleteEntries": m40,
    "messageDeletionDataServerNote": MessageLookupByLibrary.simpleMessage(
      "Tým Ouisync nemůže z repozitářů mazat jednotlivé soubory, protože je kvůli šifrování nelze identifikovat. Můžeme smazat celé repozitáře, pokud nám pošlete odkaz na repozitář, který je třeba smazat",
    ),
    "messageDeletionDataServerP1": MessageLookupByLibrary.simpleMessage(
      "Nejjednodušší způsob, jak smazat svá data, je smazat soubory nebo repozitáře z vlastního zařízení. Každé smazání souboru se přenese ke všem vašim protějškům – pokud tedy máte k repozitáři přístup pro zápis, můžete v něm smazat libovolné soubory a stejné soubory se smažou i v repozitářích vašich protějšků a na našem serveru Always-On-Peer. Pokud potřebujete smazat repozitáře pouze z našeho serveru Always-On-Peer (a přitom je zachovat ve vlastním repozitáři na vlastním zařízení), kontaktujte nás na níže uvedené adrese",
    ),
    "messageDistributedHashTables": MessageLookupByLibrary.simpleMessage(
      "Distribuované hašovací tabulky",
    ),
    "messageDokan": MessageLookupByLibrary.simpleMessage("Dokan"),
    "messageDokanDifferentMayorP1": MessageLookupByLibrary.simpleMessage(""),
    "messageDokanDifferentMayorP2": MessageLookupByLibrary.simpleMessage(""),
    "messageDokanInstallationFailed": MessageLookupByLibrary.simpleMessage(
      "Instalace Dokanu se nezdařila.",
    ),
    "messageDokanOlderVersionP2": MessageLookupByLibrary.simpleMessage(""),
    "messageDownloadFileCanceled": MessageLookupByLibrary.simpleMessage(
      "Stahování souboru zrušeno",
    ),
    "messageDownloadFileLocation": m1,
    "messageDownloadingFileCanceled": m2,
    "messageDownloadingFileError": m3,
    "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "Tato <bold>složka</bold> je prázdná.",
    ),
    "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
      "Tento <bold>repozitář</bold> je prázdný.",
    ),
    "messageEnterDifferentName": MessageLookupByLibrary.simpleMessage(
      "Zadejte jiný název.",
    ),
    "messageEntryAlreadyExist": m4,
    "messageEntryTypeDefault": MessageLookupByLibrary.simpleMessage("Položka"),
    "messageEntryTypeFile": MessageLookupByLibrary.simpleMessage("Soubor"),
    "messageEntryTypeFolder": MessageLookupByLibrary.simpleMessage("Složka"),
    "messageEqValuesP1": MessageLookupByLibrary.simpleMessage(
      "Základní práva a svobody jsou vrozené, nezcizitelné a náleží všem stejně. Lidská práva jsou univerzální; chrání je mezinárodní právo a jsou zakotvena v dokumentu ",
    ),
    "messageEqValuesP10": MessageLookupByLibrary.simpleMessage(
      "Jako organizace usilujeme o transparentnost našich pravidel a postupů. Náš zdrojový kód je tak často, jak je to možné, otevřený a volně dostupný, chráněný licencemi podporujícími komunitní vývoj, sdílení a šíření těchto zásad.",
    ),
    "messageEqValuesP11": MessageLookupByLibrary.simpleMessage(
      "Možnost svobodně se vyjadřovat a přistupovat k veřejným informacím je páteří skutečné demokracie. Veřejné informace by měly patřit do veřejné domény. Svoboda projevu zahrnuje aktivní a vášnivou debatu, i argumenty, které jsou neobratně formulované, špatně vystavěné a někteří je mohou považovat za urážlivé. Svoboda projevu však není absolutním právem. Důrazně se stavíme proti násilí a podněcování k porušování práv ostatních, zejména proti šíření násilí, nenávisti, diskriminace a zbavování práv jakékoli rozpoznatelné etnické či sociální skupiny",
    ),
    "messageEqValuesP12": MessageLookupByLibrary.simpleMessage(
      "Působíme v různých zemích a pocházíme z různých sociálních prostředí. Společně usilujeme o společnost, která bude respektovat a hájit práva ostatních ve fyzickém i digitálním světě. Mezinárodní listina práv vyjadřuje soubor lidských práv, jimiž se naše práce inspiruje; věříme, že lidé mají právo a povinnost tato práva chránit",
    ),
    "messageEqValuesP13": MessageLookupByLibrary.simpleMessage(
      "Uvědomujeme si, že naše nástroje a služby lze zneužít v rozporu s těmito zásadami a našimi podmínkami poskytování služeb, a takové použití důrazně a aktivně odsuzujeme a zakazujeme. Nedovolujeme, aby náš software a služby napomáhaly nezákonné činnosti, ani nebudeme pomáhat šíření nenávistných projevů nebo podpoře násilí prostřednictvím internetu",
    ),
    "messageEqValuesP14": MessageLookupByLibrary.simpleMessage(
      "Zavedli jsme ochranná opatření ke zmírnění zneužívání našich produktů a služeb. Pokud se dozvíme o použití, které porušuje naše zásady nebo podmínky poskytování služeb, podnikneme kroky k jeho zastavení. V souladu s našimi interními pravidly pečlivě zvažujeme jednání, která by mohla ohrozit naše zásady. Naše postupy se budou dále vyvíjet na základě zkušeností a osvědčené praxe, abychom dosáhli správné rovnováhy mezi otevřeným přístupem k našim produktům a službám a dodržováním našich zásad",
    ),
    "messageEqValuesP2": MessageLookupByLibrary.simpleMessage(
      "Odvážní lidé riskují život a svobodu, aby hájili lidská práva, mobilizovali ostatní, kritizovali a odhalovali pachatele bezpráví. Odvážní lidé vyjadřují podporu ostatním i myšlenkám a sdělují světu své obavy. Tito odvážní lidé uplatňují svá lidská práva na internetu",
    ),
    "messageEqValuesP3": MessageLookupByLibrary.simpleMessage(
      "Internet je platformou pro svobodný projev a sebeurčení. Stejně jako jakýkoli komunikační nástroj ani internet není imunní vůči cenzuře, sledování, útokům a pokusům státních aktérů a zločineckých skupin umlčet nesouhlasné hlasy. Když je demokratický projev kriminalizován a dochází k etnické a politické diskriminaci, stává se internet dalším bojištěm nenásilného odporu",
    ),
    "messageEqValuesP4": MessageLookupByLibrary.simpleMessage(
      "Naším posláním je prosazovat a hájit základní svobody a lidská práva, včetně volného toku informací na internetu. Naším cílem je vytvářet dostupné technologie a zlepšovat dovednosti potřebné k obraně lidských práv a svobod v digitálním věku",
    ),
    "messageEqValuesP5": MessageLookupByLibrary.simpleMessage(
      "Naším cílem je vzdělávat ty, jimž sloužíme, a posilovat jejich schopnost bezpečně působit v digitálním prostředí. Proto vytváříme nástroje, které umožňují a chrání svobodný projev, obcházejí cenzuru, posilují anonymitu a tam, kde je to nutné, chrání před sledováním. Naše nástroje také zlepšují správu informací a analytické funkce",
    ),
    "messageEqValuesP6": MessageLookupByLibrary.simpleMessage(
      "Jsme mezinárodní skupina aktivistů různého původu a přesvědčení, kteří společně hájí sdílené zásady. Jsme vývojáři softwaru, kryptografové, odborníci na bezpečnost, ale také pedagogové, sociologové, historici, antropologové a novináři. Vyvíjíme otevřené a opakovaně použitelné nástroje zaměřené na soukromí, bezpečnost na internetu a lepší správu informací. Svou činnost financujeme z veřejných grantů a poradenství pro soukromý sektor. Věříme v internet bez rušivého a neopodstatněného sledování, cenzury a útlaku",
    ),
    "messageEqValuesP7": MessageLookupByLibrary.simpleMessage(
      "Naše zásady, inspirované Mezinárodní listinou lidských práv, se vztahují na každého jednotlivce, skupinu a složku společnosti, s nimiž spolupracujeme, včetně těch, kdo využívají náš software a služby. Všechny naše projekty jsou navrženy s ohledem na tyto zásady. Naše znalosti, nástroje a služby jsou těmto skupinám a jednotlivcům k dispozici, pokud respektují naše zásady a podmínky poskytování služeb",
    ),
    "messageEqValuesP8": MessageLookupByLibrary.simpleMessage(
      "Právo na soukromí je základní právo, které se snažíme chránit vždy a všude, kde je to možné. Soukromí přímých příjemců naší pomoci je pro naši činnost nedotknutelné. K tomu jsou navrženy naše nástroje, služby a interní pravidla. K ochraně soukromí těchto příjemců využijeme všechny dostupné technické a právní prostředky. Přečtěte si naše Zásady ochrany soukromí a dokument ",
    ),
    "messageEqValuesP9": MessageLookupByLibrary.simpleMessage(
      "Bezpečnost je stálým tématem všech našich projektů vývoje softwaru, poskytování služeb a rozvoje schopností. Naše systémy a procesy navrhujeme tak, aby zlepšovaly informační bezpečnost na internetu i úroveň zabezpečení uživatelů a jejich zkušenosti s ním. Snažíme se jít příkladem tím, že neslevujeme z bezpečnostních vlastností nástroje či systému kvůli rychlosti, použitelnosti nebo nákladům. Nevěříme v bezpečnost založenou na utajení a transparentnost udržujeme otevřeným přístupem ke zdrojovému kódu. Vždy dáváme přednost opatrnosti a snažíme se zavádět osvědčené postupy interní provozní bezpečnosti",
    ),
    "messageEqualitieValues": MessageLookupByLibrary.simpleMessage(
      "je vytvořen v souladu s našimi hodnotami.\n\nJeho používáním souhlasíte s dodržováním těchto zásad a přijímáte naše Podmínky používání a Informace o ochraně soukromí.",
    ),
    "messageError": MessageLookupByLibrary.simpleMessage("Chyba!"),
    "messageErrorAuthenticatingBiometrics":
        MessageLookupByLibrary.simpleMessage(
          "Při biometrickém ověření došlo k chybě. Zkuste to znovu.",
        ),
    "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
      "Při změně hesla došlo k potížím. Zkuste to znovu.",
    ),
    "messageErrorCharactersNotAllowed": MessageLookupByLibrary.simpleMessage(
      "Znaky \\ a / nejsou povoleny.",
    ),
    "messageErrorCreatingFolder": m41,
    "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
      "Chyba při vytváření repozitáře",
    ),
    "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
      "Chyba při vytváření sdílecího tokenu.",
    ),
    "messageErrorCurrentPathMissing": m5,
    "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
      "Něco se pokazilo. Zkuste to znovu.",
    ),
    "messageErrorDefaultShort": MessageLookupByLibrary.simpleMessage(
      "Nezdařilo se.",
    ),
    "messageErrorDetail": m6,
    "messageErrorDokanNotInstalled": m7,
    "messageErrorEntryNotFound": MessageLookupByLibrary.simpleMessage(
      "Položka nebyla nalezena.",
    ),
    "messageErrorFormValidatorNameDefault":
        MessageLookupByLibrary.simpleMessage("Zadejte platný název."),
    "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
      "Obsah této složky se nepodařilo načíst. Zkuste to znovu.",
    ),
    "messageErrorNewPasswordSameOldPassword":
        MessageLookupByLibrary.simpleMessage(
          "Nové heslo je stejné jako dosavadní.",
        ),
    "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
      "Chyba při otevírání repozitáře",
    ),
    "messageErrorOpeningRepoDescription": m8,
    "messageErrorPathNotEmpty": m9,
    "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
      "Repozitář s tímto názvem už existuje.",
    ),
    "messageErrorRepositoryPasswordValidation":
        MessageLookupByLibrary.simpleMessage("Zadejte heslo."),
    "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
      "Hesla se neshodují.",
    ),
    "messageErrorTokenEmpty": MessageLookupByLibrary.simpleMessage(
      "Zadejte token.",
    ),
    "messageErrorTokenInvalid": MessageLookupByLibrary.simpleMessage(
      "Tento token je neplatný.",
    ),
    "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
      "Zadejte platný token.",
    ),
    "messageErrorUnhandledState": MessageLookupByLibrary.simpleMessage(
      "Chyba: neošetřený stav",
    ),
    "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
    "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
      "Aplikaci ukončíte dalším stisknutím tlačítka Zpět.",
    ),
    "messageFAQ": MessageLookupByLibrary.simpleMessage("Časté dotazy"),
    "messageFailedAddRepository": m10,
    "messageFailedCreateRepository": m11,
    "messageFailedToMount": m12,
    "messageFile": MessageLookupByLibrary.simpleMessage("soubor"),
    "messageFileAlreadyExist": m13,
    "messageFileDeleted": m42,
    "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(""),
    "messageFileName": MessageLookupByLibrary.simpleMessage("Název souboru"),
    "messageFilePreviewFailed": MessageLookupByLibrary.simpleMessage(
      "Náhled souboru se nepodařilo spustit.",
    ),
    "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Náhled souboru zatím není dostupný.",
    ),
    "messageFileRenamed": m43,
    "messageFiles": MessageLookupByLibrary.simpleMessage(""),
    "messageFolderDeleted": m14,
    "messageFolderName": MessageLookupByLibrary.simpleMessage("Název složky"),
    "messageFolderRenamed": m44,
    "messageGeneratePassword": MessageLookupByLibrary.simpleMessage(
      "Vygenerovat heslo",
    ),
    "messageGoToMailApp": MessageLookupByLibrary.simpleMessage(
      "Přejít do poštovní aplikace",
    ),
    "messageGoToPeers": MessageLookupByLibrary.simpleMessage(
      "Přejít do části Protějšky",
    ),
    "messageGood": MessageLookupByLibrary.simpleMessage("Dobré"),
    "messageGranted": MessageLookupByLibrary.simpleMessage("Uděleno"),
    "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
      "K udělení tohoto oprávnění je třeba přejít do nastavení:\n\n Nastavení > Aplikace a oznámení",
    ),
    "messageIgnoreBatteryOptimizationsPermission":
        MessageLookupByLibrary.simpleMessage(
          "Umožňuje aplikaci pokračovat v synchronizaci na pozadí.",
        ),
    "messageInfoBittorrentDHT": MessageLookupByLibrary.simpleMessage(
      "Jde o nástroj, který umožňuje protějškům vzájemné vyhledávání v síti P2P (Peer to Peer) bez centrálního serveru.",
    ),
    "messageInfoLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "Vyhledávání protějšků v místní síti umožňuje aplikacím Ouisync sdílet soubory s vašimi protějšky bez využití poskytovatelů internetových služeb, pokud je k dispozici místní Wi‑Fi nebo jiná síť.\n\nPro místní připojení musí být tato volba zapnutá.",
    ),
    "messageInfoNATType": MessageLookupByLibrary.simpleMessage(
      "Tato hodnota závisí na vašem směrovači a/nebo poskytovateli připojení k internetu.\n\nSpojení s protějšky funguje nejlépe, pokud je NAT nezávislý na koncovém bodu.",
    ),
    "messageInfoPeerExchange": MessageLookupByLibrary.simpleMessage(
      "Jde o nástroj pro výměnu seznamu protějšků s protějšky, ke kterým jste připojeni.",
    ),
    "messageInfoRuntimeID": MessageLookupByLibrary.simpleMessage(
      "Jedinečné ID, které Ouisync vygeneruje při každém spuštění.\n\nMůžete ho použít k ověření spojení s ostatními v části Protějšky.",
    ),
    "messageInfoSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "Když je tato volba zapnutá, může vám operátor účtovat data použitá při synchronizaci repozitářů, které sdílíte s protějšky.",
    ),
    "messageInfoUPnP": MessageLookupByLibrary.simpleMessage(
      "Jde o sadu síťových protokolů, které umožní vašim aplikacím Ouisync vzájemně se vyhledat a komunikovat.\n\nPro co nejlepší připojení doporučujeme mít tuto volbu zapnutou.",
    ),
    "messageInitializing": MessageLookupByLibrary.simpleMessage(
      "Inicializace…",
    ),
    "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
      "Klepněte na tlačítko <bold>Odemknout</bold> a zadejte heslo pro přístup k obsahu tohoto repozitáře.",
    ),
    "messageInstallDokanForOuisyncP1": MessageLookupByLibrary.simpleMessage(
      "Ouisync používá",
    ),
    "messageInstallDokanForOuisyncP2": MessageLookupByLibrary.simpleMessage(
      "k přístupu k repozitářům prostřednictvím Průzkumníka souborů.\nNainstalujte Dokan, aby se vám s Ouisync pracovalo lépe.",
    ),
    "messageInternationalBillHumanRights": MessageLookupByLibrary.simpleMessage(
      "Mezinárodní listina lidských práv",
    ),
    "messageKeepBothFiles": MessageLookupByLibrary.simpleMessage(
      "Zachovat oba soubory",
    ),
    "messageKeepBothFolders": MessageLookupByLibrary.simpleMessage(
      "Zachovat obě složky",
    ),
    "messageLanAccessRequired": MessageLookupByLibrary.simpleMessage(
      "K synchronizaci s jinými zařízeními v místní síti je potřeba přístup k místní síti.",
    ),
    "messageLaunchAtStartup": MessageLookupByLibrary.simpleMessage(
      "Spouštět při startu systému",
    ),
    "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
      "Byl zjištěn vnitřní pád.",
    ),
    "messageLinksOtherSitesP1": MessageLookupByLibrary.simpleMessage(
      "Tato Služba může obsahovat odkazy na jiné weby. Pokud kliknete na odkaz třetí strany, budete přesměrováni na příslušný web. Upozorňujeme, že tyto externí weby neprovozujeme. Proto vám důrazně doporučujeme seznámit se s jejich zásadami ochrany soukromí. Nad obsahem, zásadami ochrany soukromí ani postupy webů či služeb třetích stran nemáme kontrolu a nepřebíráme za ně odpovědnost",
    ),
    "messageLoadingDefault": MessageLookupByLibrary.simpleMessage("Načítání…"),
    "messageLocalDiscovery": MessageLookupByLibrary.simpleMessage(
      "Vyhledávání v místní síti",
    ),
    "messageLockOpenRepos": m15,
    "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
      "Tento <bold>repozitář</bold> je zamčený.",
    ),
    "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
      "Zamykání všech otevřených repozitářů…",
    ),
    "messageLogData1": MessageLookupByLibrary.simpleMessage(
      "e-mailovou adresu – pokud se uživatel rozhodl kontaktovat nás e-mailem",
    ),
    "messageLogData2": MessageLookupByLibrary.simpleMessage(
      "informace, které uživatel může poskytnout e-mailem, prostřednictvím požadavků na podporu nebo našeho webu, a související metadata – pro účely technické podpory",
    ),
    "messageLogData3": MessageLookupByLibrary.simpleMessage(
      "IP adresu uživatele – pro účely technické podpory",
    ),
    "messageLogDataP1": MessageLookupByLibrary.simpleMessage(
      "Aplikace Ouisync vytváří soubory protokolů na zařízeních uživatelů. Slouží pouze k zaznamenávání činnosti zařízení, aby usnadnily hledání chyb, pokud má uživatel potíže s připojením k protějškům nebo s jiným používáním aplikace Ouisync. Soubor protokolu zůstává na zařízení uživatele, pokud se jej uživatel nerozhodne odeslat nám za účelem podpory",
    ),
    "messageLogDataP2": MessageLookupByLibrary.simpleMessage(
      "Pokud se uživatel rozhodne nás kontaktovat, můžeme shromažďovat následující údaje umožňující osobní identifikaci:",
    ),
    "messageLogDataP3": MessageLookupByLibrary.simpleMessage(
      "Žádné z těchto údajů nesdílíme s žádnými třetími stranami",
    ),
    "messageMedium": MessageLookupByLibrary.simpleMessage("Střední"),
    "messageMissingBackgroundServicePermission":
        MessageLookupByLibrary.simpleMessage(
          "Ouisync nemá oprávnění ke spuštění na pozadí. Otevření jiné aplikace může zastavit probíhající synchronizaci.",
        ),
    "messageMobile": MessageLookupByLibrary.simpleMessage("Mobilní data"),
    "messageMoveEntries": m45,
    "messageMoveEntryOrigin": m16,
    "messageMovingEntry": MessageLookupByLibrary.simpleMessage(""),
    "messageNATOnWikipedia": MessageLookupByLibrary.simpleMessage(
      "NAT na Wikipedii",
    ),
    "messageNATType": MessageLookupByLibrary.simpleMessage("Typ NAT"),
    "messageNetworkIsUnavailable": MessageLookupByLibrary.simpleMessage(
      "Síť není dostupná.",
    ),
    "messageNetworkNoInternet": MessageLookupByLibrary.simpleMessage(
      "Internet není dostupný. Pokud je zapnutá Wi‑Fi, můžete stále synchronizovat v místní síti.",
    ),
    "messageNewFileError": m17,
    "messageNewPasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "Nové heslo bylo zkopírováno do schránky.",
    ),
    "messageNewVersionIsAvailable": MessageLookupByLibrary.simpleMessage(
      "Je dostupná nová verze.",
    ),
    "messageNoAppsForThisAction": MessageLookupByLibrary.simpleMessage(
      "Tuto akci nemůže provést žádná aplikace.",
    ),
    "messageNoMediaPresent": MessageLookupByLibrary.simpleMessage(
      "Není přítomno žádné médium.",
    ),
    "messageNoRepo": MessageLookupByLibrary.simpleMessage(
      "Před přidáním souborů je potřeba vytvořit repozitář.",
    ),
    "messageNoRepoIsSelected": MessageLookupByLibrary.simpleMessage(
      "Není vybraný žádný repozitář.",
    ),
    "messageNoRepos": MessageLookupByLibrary.simpleMessage(
      "Nebyly nalezeny žádné repozitáře",
    ),
    "messageNone": MessageLookupByLibrary.simpleMessage("Žádné"),
    "messageNote": MessageLookupByLibrary.simpleMessage("Poznámka"),
    "messageNothingHereYet": MessageLookupByLibrary.simpleMessage(
      "Zatím tu nic není!",
    ),
    "messageOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "Sdílejte soubory se všemi svými zařízeními nebo s ostatními a vytvořte si vlastní bezpečný cloud!",
    ),
    "messageOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "Repozitáře lze sdílet pro čtení a zápis, jen pro čtení nebo bez přístupu k obsahu (ukládáte soubory pro ostatní, ale nemůžete k nim přistupovat).",
    ),
    "messageOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "Všechny soubory a složky přidané do Ouisync jsou ve výchozím nastavení bezpečně šifrované při přenosu i při uložení.",
    ),
    "messageOnlyAvailableFiles": MessageLookupByLibrary.simpleMessage(
      "K dispozici pouze pro soubory",
    ),
    "messageOpenFileError": m18,
    "messageOr": MessageLookupByLibrary.simpleMessage("Nebo"),
    "messageOuiSyncDesktopTitle": MessageLookupByLibrary.simpleMessage(
      "Ouisync",
    ),
    "messagePIPEDA": MessageLookupByLibrary.simpleMessage("PIPEDA"),
    "messagePassword": MessageLookupByLibrary.simpleMessage("Heslo"),
    "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
      "Heslo bylo zkopírováno do schránky.",
    ),
    "messagePasswordStrength": MessageLookupByLibrary.simpleMessage(
      "Síla hesla",
    ),
    "messagePeerAdded": MessageLookupByLibrary.simpleMessage(
      "Protějšek přidán",
    ),
    "messagePeerExchange": MessageLookupByLibrary.simpleMessage(
      "Výměna protějšků",
    ),
    "messagePeerExchangeWikipedia": MessageLookupByLibrary.simpleMessage(
      "Výměna protějšků na Wikipedii",
    ),
    "messagePeerRemoved": MessageLookupByLibrary.simpleMessage(
      "Protějšek odebrán",
    ),
    "messagePermissionRequired": MessageLookupByLibrary.simpleMessage(
      "Toto oprávnění je vyžadováno.",
    ),
    "messagePleaseAuthenticate": MessageLookupByLibrary.simpleMessage(
      "Ověřte svou totožnost.",
    ),
    "messagePreviewingFileFailed": m19,
    "messagePrivacyIntro": MessageLookupByLibrary.simpleMessage(
      "Tento oddíl informuje návštěvníky o našich zásadách shromažďování, používání a zpřístupňování osobních údajů v případě, že se rozhodnou používat naši Službu",
    ),
    "messageQuoteMainIsFree": MessageLookupByLibrary.simpleMessage(
      "„Svoboden rodí se každý člověk a přec všude úpí v okovech.“",
    ),
    "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
      "Tento repozitář je <bold>jen pro čtení</bold>.",
    ),
    "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Obsah lze pouze číst, nelze ho měnit.",
    ),
    "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
      "Heslo si bezpečně uložte. Pokud ho ztratíte nebo zapomenete, nelze ho obnovit.",
    ),
    "messageRemoveBiometricValidation": MessageLookupByLibrary.simpleMessage(
      "Odstranit biometrické ověření",
    ),
    "messageRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "Odstranit biometrické ověření",
    ),
    "messageRemoveBiometricsConfirmationMoreInfo":
        MessageLookupByLibrary.simpleMessage(
          "Tím se odstraní heslo repozitáře a k odemykání se použije biometrické ověření.",
        ),
    "messageRemoveLocalPasswordConfirmation": MessageLookupByLibrary.simpleMessage(
      "Odstranit místní heslo tohoto repozitáře?\n\nRepozitář se bude odemykat automaticky, dokud znovu nepřidáte místní heslo.",
    ),
    "messageRemovedInBrackets": MessageLookupByLibrary.simpleMessage(
      "<odstraněno>",
    ),
    "messageRenameFile": MessageLookupByLibrary.simpleMessage(
      "Přejmenovat soubor",
    ),
    "messageRenameFolder": MessageLookupByLibrary.simpleMessage(
      "Přejmenovat složku",
    ),
    "messageRenameRepository": MessageLookupByLibrary.simpleMessage(
      "Přejmenovat repozitář",
    ),
    "messageReplaceExistingFile": MessageLookupByLibrary.simpleMessage(
      "Nahradit existující soubor",
    ),
    "messageReplaceExistingFolder": MessageLookupByLibrary.simpleMessage(
      "Nahradit existující složku",
    ),
    "messageRepoAuthFailed": MessageLookupByLibrary.simpleMessage(
      "Ověření repozitáře se nezdařilo.",
    ),
    "messageRepoDeletionErrorDescription": m20,
    "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
      "Repozitář se nepodařilo smazat.",
    ),
    "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
      "Repozitář už zde není.",
    ),
    "messageRepoMissingErrorDescription": m21,
    "messageRepositoryAccessMode": m22,
    "messageRepositoryAlreadyExist": m23,
    "messageRepositoryCurrentPassword": MessageLookupByLibrary.simpleMessage(
      "Současné heslo",
    ),
    "messageRepositoryDeleted": m46,
    "messageRepositoryIsNotOpen": MessageLookupByLibrary.simpleMessage(
      "Repozitář není otevřený.",
    ),
    "messageRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Zadejte název repozitáře",
    ),
    "messageRepositoryNewName": MessageLookupByLibrary.simpleMessage(
      "Nový název repozitáře",
    ),
    "messageRepositoryNewPassword": MessageLookupByLibrary.simpleMessage(
      "Nové heslo",
    ),
    "messageRepositoryNotMounted": MessageLookupByLibrary.simpleMessage(
      "Repozitář není připojený. ",
    ),
    "messageRepositoryPassword": MessageLookupByLibrary.simpleMessage("Heslo"),
    "messageRepositoryRenamed": m47,
    "messageRepositorySuggestedName": m24,
    "messageRepositoryToken": MessageLookupByLibrary.simpleMessage(
      "Vložte sem odkaz",
    ),
    "messageResetLocalSecret": MessageLookupByLibrary.simpleMessage(
      "Resetovat místní tajný údaj",
    ),
    "messageRousseau": MessageLookupByLibrary.simpleMessage(
      "Jean-Jacques Rousseau",
    ),
    "messageSaveEntriesToDevice": m48,
    "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
      "Uložit soubor do této složky",
    ),
    "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
      "Chcete uložit současné změny?",
    ),
    "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
      "Naskenujte tento kód jiným svým zařízením nebo ho sdílejte se svými protějšky.",
    ),
    "messageSecureUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Zabezpečit biometrickým ověřením",
    ),
    "messageSecurityOptionsNotAvailableBlind": MessageLookupByLibrary.simpleMessage(
      "Možnosti zabezpečení nejsou dostupné u repozitářů bez přístupu k obsahu.",
    ),
    "messageSecurityPracticesP1": MessageLookupByLibrary.simpleMessage(
      "Data, která uživatel nahraje do repozitářů Ouisync, jsou koncově šifrována při přenosu i při uložení. To zahrnuje i metadata, například názvy a velikosti souborů, strukturu složek atd. V Ouisync může data číst pouze osoba, která je nahrála, a osoby, s nimiž sdílela své repozitáře",
    ),
    "messageSecurityPracticesP2": MessageLookupByLibrary.simpleMessage(
      "Více o použitých šifrovacích technikách se dozvíte v naší dokumentaci",
    ),
    "messageSecurityPracticesP3": MessageLookupByLibrary.simpleMessage(
      "Aplikace Ouisync ukládá data uživatelů na „Always-On Peer“, což je server umístěný v Kanadě. Všechna data jsou uložena jako šifrované bloky a server ani jeho provozovatelé je nemohou číst. Účelem tohoto serveru je pouze překlenout dobu, kdy protějšky nejsou online současně. Všechna data se ze serveru pravidelně odstraňují – jeho účelem není trvalé ukládání dat, ale jen usnadnění jejich synchronizace mezi protějšky",
    ),
    "messageSecurityPracticesP4": MessageLookupByLibrary.simpleMessage(
      "Máte-li důvod se domnívat, že vaše osobní údaje nezákonně získali a sdíleli jiní uživatelé Ouisync, kontaktujte nás na níže uvedené adrese",
    ),
    "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
      "Vyberte oprávnění pro vytvoření odkazu pro sdílení.",
    ),
    "messageSelectLocation": MessageLookupByLibrary.simpleMessage(
      "Vyberte umístění",
    ),
    "messageSettingsRuntimeID": MessageLookupByLibrary.simpleMessage(
      "ID spuštění",
    ),
    "messageSettingsVersionNewerThanCurrent": MessageLookupByLibrary.simpleMessage(
      "Nastavení nalezená na tomto zařízení byla vytvořena novější verzí Ouisync a nelze je migrovat.",
    ),
    "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
      "Nejprve vyberte oprávnění pro vytvoření odkazu na repozitář.",
    ),
    "messageShareWithWR": MessageLookupByLibrary.simpleMessage(
      "Sdílet pomocí QR kódu",
    ),
    "messageSharingFileFailed": m49,
    "messageSortBy": m25,
    "messageStorage": MessageLookupByLibrary.simpleMessage("Úložiště"),
    "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
      "Potřebné pro přístup k souborům",
    ),
    "messageStrong": MessageLookupByLibrary.simpleMessage("Silné"),
    "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
      "Synchronizovat při používání mobilních dat",
    ),
    "messageSyncingIsDisabledOnMobileInternet":
        MessageLookupByLibrary.simpleMessage(
          "Při používání mobilních dat je synchronizace přes internet vypnutá.",
        ),
    "messageTapForTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "Klepnutím sem si přečtete naše Podmínky používání a Informace o ochraně soukromí",
    ),
    "messageTapForValues": MessageLookupByLibrary.simpleMessage(
      "Klepnutím sem si přečtete naše hodnoty",
    ),
    "messageTerms1_1": MessageLookupByLibrary.simpleMessage(
      "porušuje práva na ochranu osobních údajů, včetně základních hodnot nebo znění předpisů ",
    ),
    "messageTerms1_2": MessageLookupByLibrary.simpleMessage(
      "(zákon o ochraně osobních údajů a elektronických dokumentech)",
    ),
    "messageTerms2": MessageLookupByLibrary.simpleMessage(
      "představuje materiál sexuálně vykořisťující děti (včetně materiálu, který nemusí být nezákonným materiálem zobrazujícím sexuální zneužívání dětí, ale přesto nezletilé sexuálně vykořisťuje nebo jejich sexuální vykořisťování propaguje), nezákonnou pornografii nebo je jinak nemravný",
    ),
    "messageTerms3": MessageLookupByLibrary.simpleMessage(
      "obsahuje nebo propaguje extrémní násilné činy či teroristickou činnost, včetně teroristické propagandy nebo propagandy násilného extremismu",
    ),
    "messageTerms4": MessageLookupByLibrary.simpleMessage(
      "prosazuje nesnášenlivost, nenávist nebo podněcování k násilí vůči jakékoli osobě či skupině osob na základě rasy, náboženství, etnicity, národního původu, pohlaví, genderové identity, sexuální orientace, zdravotního postižení, zdravotního omezení nebo jakýchkoli dalších charakteristik spojených se systémovou diskriminací či marginalizací",
    ),
    "messageTerms5": MessageLookupByLibrary.simpleMessage(
      "má podobu souborů obsahujících viry, trojské koně, červy, logické bomby nebo jiný škodlivý či technicky nebezpečný materiál",
    ),
    "messageTermsPrivacyP1": MessageLookupByLibrary.simpleMessage(
      "Tyto Podmínky používání Ouisync (dále jen „Smlouva“) spolu s našimi Informacemi o ochraně soukromí (společně dále jen „Podmínky“) upravují vaše používání Ouisync – protokolu a softwaru pro online synchronizaci souborů.",
    ),
    "messageTermsPrivacyP2": MessageLookupByLibrary.simpleMessage(
      "Instalací a spuštěním aplikace Ouisync vyjadřujete souhlas s tím, že budete vázáni touto Smlouvou mezi vámi a eQualitie inc. (dále jen „eQualitie“ nebo „my“) a budete ji dodržovat. Používání aplikace Ouisync a sítě Ouisync (dále jen „Služba“) umožňuje eQualitie bezplatně. Služba je určena k používání v podobě, v jaké je poskytována",
    ),
    "messageTermsPrivacyP3": MessageLookupByLibrary.simpleMessage(
      "Aplikace Ouisync je vytvořena v souladu s hodnotami eQualitie. Používáním tohoto softwaru souhlasíte s tím, že nebudete Ouisync používat ke zveřejňování, sdílení ani ukládání materiálů, které odporují základním hodnotám nebo znění zákonů Québecu či Kanady nebo Mezinárodní listiny lidských práv, včetně obsahu, který:",
    ),
    "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
      "Token repozitáře byl zkopírován do schránky.",
    ),
    "messageUnknownFileExtension": MessageLookupByLibrary.simpleMessage(
      "Neznámá přípona souboru",
    ),
    "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
      "Heslo repozitář neodemklo.",
    ),
    "messageUnlockRepoOk": m26,
    "messageUnlockRepository": m27,
    "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
      "Odemknout pomocí biometrického ověření",
    ),
    "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "Máte neuložené změny.\n\nChcete je zahodit?",
    ),
    "messageUpdateLocalPasswordConfirmation":
        MessageLookupByLibrary.simpleMessage(
          "Aktualizovat místní heslo tohoto repozitáře?",
        ),
    "messageUpdateLocalSecretFailed": MessageLookupByLibrary.simpleMessage(
      "Nastavení zabezpečení repozitáře se nepodařilo aktualizovat.",
    ),
    "messageUpdateLocalSecretOk": MessageLookupByLibrary.simpleMessage(
      "Nastavení zabezpečení repozitáře bylo aktualizováno.",
    ),
    "messageUseCacheServers": MessageLookupByLibrary.simpleMessage(
      "Používat servery mezipaměti",
    ),
    "messageUseLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Použít místní heslo",
    ),
    "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
    "messageValidateLocalPassword": MessageLookupByLibrary.simpleMessage(
      "Ověřit místní heslo",
    ),
    "messageView": MessageLookupByLibrary.simpleMessage("Zobrazit"),
    "messageWeak": MessageLookupByLibrary.simpleMessage("Slabé"),
    "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi‑Fi"),
    "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
      "Plný přístup. Váš protějšek může číst i zapisovat.",
    ),
    "messageWritingFileCanceled": m28,
    "messageWritingFileError": m29,
    "openFolder": MessageLookupByLibrary.simpleMessage("Otevřít složku"),
    "popupMenuItemChangePassword": MessageLookupByLibrary.simpleMessage(
      "Změnit heslo",
    ),
    "popupMenuItemCopyPassword": MessageLookupByLibrary.simpleMessage(
      "Kopírovat heslo",
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
        MessageLookupByLibrary.simpleMessage("Bez přístupu nebo zamčeno"),
    "repoResetAccessTypeInfoRead": MessageLookupByLibrary.simpleMessage(
      "Jen čtení",
    ),
    "repoResetAccessTypeInfoWrite": MessageLookupByLibrary.simpleMessage(
      "Čtení a zápis",
    ),
    "repoResetAccessTypeLabel": MessageLookupByLibrary.simpleMessage(
      "Typ přístupu k repozitáři",
    ),
    "repoResetActionAnyToWrite": MessageLookupByLibrary.simpleMessage(
      "Repozitář získá přístup pro zápis.",
    ),
    "repoResetActionBlindToBlind": MessageLookupByLibrary.simpleMessage(
      "Repozitář bude bez přístupu k obsahu.",
    ),
    "repoResetActionBlindToBlindWarn": MessageLookupByLibrary.simpleMessage(
      "Tento repozitář může mít přístup pro čtení nebo zápis zamčený místním heslem. Pokud tomu tak je, po provedení této akce ho již nebude možné odemknout.",
    ),
    "repoResetActionBlindToRead": MessageLookupByLibrary.simpleMessage(
      "Repozitář bude přístupný jen pro čtení.",
    ),
    "repoResetActionBlindToReadWarn": MessageLookupByLibrary.simpleMessage(
      "Tento repozitář může mít přístup pro zápis zamčený místním heslem. Pokud tomu tak je, po provedení této akce ho již nebude možné odemknout pro zápis.",
    ),
    "repoResetActionInfoLabel": MessageLookupByLibrary.simpleMessage(
      "Akce k provedení",
    ),
    "repoResetActionReadToBlind": MessageLookupByLibrary.simpleMessage(
      "Repozitář ztratí přístup pro čtení.",
    ),
    "repoResetActionReadToBlindWarn": MessageLookupByLibrary.simpleMessage(
      "Bez odkazu s tokenem pro čtení nebo zápis je tato akce nevratná.",
    ),
    "repoResetActionSame": MessageLookupByLibrary.simpleMessage(
      "Žádná akce se neprovede, protože token a repozitář mají stejný režim přístupu.",
    ),
    "repoResetActionWriteToBlind": MessageLookupByLibrary.simpleMessage(
      "Repozitář ztratí přístup pro čtení i zápis.",
    ),
    "repoResetActionWriteToBlindWarn": MessageLookupByLibrary.simpleMessage(
      "Bez odkazu s tokenem pro zápis je tato akce nevratná.",
    ),
    "repoResetActionWriteToRead": MessageLookupByLibrary.simpleMessage(
      "Repozitář ztratí přístup pro zápis.",
    ),
    "repoResetActionWriteToReadWarn": MessageLookupByLibrary.simpleMessage(
      "Bez odkazu s tokenem pro zápis je tato akce nevratná.",
    ),
    "repoResetAuthInfoBlindOrLocked": MessageLookupByLibrary.simpleMessage(
      "Repozitář je buď bez přístupu k obsahu, nebo je zamčený místním heslem.",
    ),
    "repoResetAuthInfoBlindOrLockedWarn": MessageLookupByLibrary.simpleMessage(
      "Aplikace tyto možnosti nedokáže rozlišit.",
    ),
    "repoResetAuthInfoKeyIsStored": MessageLookupByLibrary.simpleMessage(
      "Klíč je uložený na tomto zařízení.",
    ),
    "repoResetAuthInfoKeyIsStoredAndProtected":
        MessageLookupByLibrary.simpleMessage(
          "Klíč je uložený na tomto zařízení a k otevření repozitáře je potřeba další ověření.",
        ),
    "repoResetAuthInfoLabel": MessageLookupByLibrary.simpleMessage(
      "Způsob ověření",
    ),
    "repoResetAuthInfoLocked": MessageLookupByLibrary.simpleMessage(
      "Chráněno místním heslem.",
    ),
    "repoResetAuthInfoPasswordIsStored": MessageLookupByLibrary.simpleMessage(
      "Heslo je uložené na tomto zařízení.",
    ),
    "repoResetConfirmUpdateMessage": MessageLookupByLibrary.simpleMessage(
      "Opravdu chcete provést akci Aktualizovat?",
    ),
    "repoResetConfirmUpdateTitle": MessageLookupByLibrary.simpleMessage(
      "Potvrzení",
    ),
    "repoResetRepoNameLabel": MessageLookupByLibrary.simpleMessage(
      "Název repozitáře",
    ),
    "repoResetTitle": MessageLookupByLibrary.simpleMessage(
      "Obnovit přístup k repozitáři",
    ),
    "repoResetTokenAlreadySubmitted": MessageLookupByLibrary.simpleMessage(
      "Žádná akce se neprovede, protože tento token již byl použit.",
    ),
    "repoResetTokenEmptyInfo": MessageLookupByLibrary.simpleMessage(
      "Vložte platný odkaz s tokenem, aby bylo možné určit akci.",
    ),
    "repoResetTokenInvalid": MessageLookupByLibrary.simpleMessage("Neplatný"),
    "repoResetTokenInvalidInfo": MessageLookupByLibrary.simpleMessage(
      "Odkaz s tokenem je neplatný.",
    ),
    "repoResetTokenNonMatching": MessageLookupByLibrary.simpleMessage(
      "Nelze provést žádnou akci, protože token nepatří k tomuto repozitáři.",
    ),
    "repoResetTokenTypeLabel": MessageLookupByLibrary.simpleMessage(
      "Typ přístupu tokenu",
    ),
    "repoStorageLocation": MessageLookupByLibrary.simpleMessage("Umístění"),
    "repoStorageMovePrompt": m50,
    "repoStorageMoveTitle": MessageLookupByLibrary.simpleMessage(
      "Přesunout repozitář",
    ),
    "repositoryIsAlreadyImported": MessageLookupByLibrary.simpleMessage(
      "Repozitář už je importovaný.",
    ),
    "sortByNameLabel": MessageLookupByLibrary.simpleMessage("Název"),
    "sortBySizeLabel": MessageLookupByLibrary.simpleMessage("Velikost"),
    "sortByTypeLabel": MessageLookupByLibrary.simpleMessage("Typ"),
    "statusSync": MessageLookupByLibrary.simpleMessage("Synchronizováno"),
    "statusUnspecified": MessageLookupByLibrary.simpleMessage("Neuvedeno"),
    "titleAbout": MessageLookupByLibrary.simpleMessage("O aplikaci"),
    "titleAddFile": MessageLookupByLibrary.simpleMessage(
      "Přidat soubor do Ouisync",
    ),
    "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář pomocí tokenu",
    ),
    "titleAddRepository": MessageLookupByLibrary.simpleMessage(
      "Importovat repozitář",
    ),
    "titleAppTitle": MessageLookupByLibrary.simpleMessage("Ouisync"),
    "titleApplicationLanguage": MessageLookupByLibrary.simpleMessage(
      "Jazyk aplikace",
    ),
    "titleBackgroundAndroidPermissionsTitle":
        MessageLookupByLibrary.simpleMessage("Potřebná oprávnění"),
    "titleChangePassword": MessageLookupByLibrary.simpleMessage("Změnit heslo"),
    "titleChangesToTerms": MessageLookupByLibrary.simpleMessage(
      "Změny těchto podmínek",
    ),
    "titleChildrensPrivacy": MessageLookupByLibrary.simpleMessage(
      "Soukromí dětí",
    ),
    "titleContactUs": MessageLookupByLibrary.simpleMessage("Kontaktujte nás"),
    "titleCookies": MessageLookupByLibrary.simpleMessage("Cookies"),
    "titleCopyEntries": MessageLookupByLibrary.simpleMessage("Kopírovat"),
    "titleCopyingEntry": MessageLookupByLibrary.simpleMessage(
      "Kopírování položky",
    ),
    "titleCreateFolder": MessageLookupByLibrary.simpleMessage(
      "Vytvořit složku",
    ),
    "titleCreateRepository": MessageLookupByLibrary.simpleMessage(
      "Vytvořit nový repozitář",
    ),
    "titleDataCollection": MessageLookupByLibrary.simpleMessage(
      "3.1 Shromažďování údajů",
    ),
    "titleDataSharing": MessageLookupByLibrary.simpleMessage(
      "3.2 Sdílení údajů",
    ),
    "titleDeleteEntries": MessageLookupByLibrary.simpleMessage("Smazat"),
    "titleDeleteFile": MessageLookupByLibrary.simpleMessage("Smazat soubor"),
    "titleDeleteFolder": MessageLookupByLibrary.simpleMessage("Smazat složku"),
    "titleDeleteNotEmptyFolder": MessageLookupByLibrary.simpleMessage(
      "Smazat neprázdnou složku",
    ),
    "titleDeleteRepository": MessageLookupByLibrary.simpleMessage(
      "Smazat repozitář",
    ),
    "titleDeletionDataServer": MessageLookupByLibrary.simpleMessage(
      "3.4 Smazání vašich dat z našeho serveru Always-On-Peer",
    ),
    "titleDigitalSecurity": MessageLookupByLibrary.simpleMessage(
      "Digitální bezpečnost",
    ),
    "titleDokanInstallation": MessageLookupByLibrary.simpleMessage(
      "Instalace Dokanu",
    ),
    "titleDokanInstallationFound": MessageLookupByLibrary.simpleMessage(
      "Nalezena instalace Dokanu",
    ),
    "titleDokanMissing": MessageLookupByLibrary.simpleMessage("Dokan chybí"),
    "titleDownloadLocation": MessageLookupByLibrary.simpleMessage(
      "Umístění pro stahování",
    ),
    "titleDownloadToDevice": MessageLookupByLibrary.simpleMessage(
      "Stáhnout do zařízení",
    ),
    "titleEditRepository": MessageLookupByLibrary.simpleMessage(
      "Upravit repozitář",
    ),
    "titleEqualitiesValues": MessageLookupByLibrary.simpleMessage(
      "Hodnoty eQualitie",
    ),
    "titleFAQShort": MessageLookupByLibrary.simpleMessage("FAQ"),
    "titleFileDetails": MessageLookupByLibrary.simpleMessage(
      "Podrobnosti o souboru",
    ),
    "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
      "Změna přípony souboru",
    ),
    "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
      "Chybějící přípona souboru",
    ),
    "titleFolderActions": MessageLookupByLibrary.simpleMessage("Přidat"),
    "titleFolderDetails": MessageLookupByLibrary.simpleMessage(
      "Podrobnosti o složce",
    ),
    "titleFreedomExpressionAccessInfo": MessageLookupByLibrary.simpleMessage(
      "Svoboda projevu a přístup k informacím",
    ),
    "titleIssueTracker": MessageLookupByLibrary.simpleMessage(
      "Přehled hlášení",
    ),
    "titleJustLegalSociety": MessageLookupByLibrary.simpleMessage(
      "Spravedlivá společnost založená na právu",
    ),
    "titleLanAccessDenied": MessageLookupByLibrary.simpleMessage(
      "Přístup k místní síti není povolený",
    ),
    "titleLinksOtherSites": MessageLookupByLibrary.simpleMessage(
      "Odkazy na jiné weby",
    ),
    "titleLockAllRepos": MessageLookupByLibrary.simpleMessage(
      "Zamknout všechny repozitáře",
    ),
    "titleLogData": MessageLookupByLibrary.simpleMessage("Údaje v protokolech"),
    "titleLogs": MessageLookupByLibrary.simpleMessage("Protokoly"),
    "titleMoveEntries": MessageLookupByLibrary.simpleMessage("Přesunout"),
    "titleMovingEntry": MessageLookupByLibrary.simpleMessage(""),
    "titleNetwork": MessageLookupByLibrary.simpleMessage("Síť"),
    "titleOnboardingAccess": MessageLookupByLibrary.simpleMessage(
      "Přistupujte k souborům z více zařízení",
    ),
    "titleOnboardingPermissions": MessageLookupByLibrary.simpleMessage(
      "Nastavte oprávnění pro spolupráci, šíření nebo pouhé ukládání",
    ),
    "titleOnboardingShare": MessageLookupByLibrary.simpleMessage(
      "Bezpečně odesílejte a přijímejte soubory",
    ),
    "titleOpennessTransparency": MessageLookupByLibrary.simpleMessage(
      "Otevřenost a transparentnost",
    ),
    "titleOurMission": MessageLookupByLibrary.simpleMessage("Naše poslání"),
    "titleOurPrinciples": MessageLookupByLibrary.simpleMessage("Naše zásady"),
    "titleOurValues": MessageLookupByLibrary.simpleMessage("Naše hodnoty"),
    "titleOverview": MessageLookupByLibrary.simpleMessage("1. Přehled"),
    "titlePIPEDA": MessageLookupByLibrary.simpleMessage(
      "Zákon o ochraně osobních údajů a elektronických dokumentech (PIPEDA)",
    ),
    "titlePrivacy": MessageLookupByLibrary.simpleMessage("Soukromí"),
    "titlePrivacyNotice": MessageLookupByLibrary.simpleMessage(
      "3. Informace o ochraně soukromí",
    ),
    "titlePrivacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Zásady ochrany soukromí",
    ),
    "titleRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
      "Odstranit biometrické ověření",
    ),
    "titleRepositoriesList": MessageLookupByLibrary.simpleMessage(
      "Moje repozitáře",
    ),
    "titleRepository": MessageLookupByLibrary.simpleMessage("Repozitář"),
    "titleRepositoryName": MessageLookupByLibrary.simpleMessage(
      "Název repozitáře",
    ),
    "titleRequiredPermission": MessageLookupByLibrary.simpleMessage(
      "Požadované oprávnění",
    ),
    "titleSaveChanges": MessageLookupByLibrary.simpleMessage("Uložit změny"),
    "titleSaveEntriesToDevice": MessageLookupByLibrary.simpleMessage(
      "Uložit do zařízení",
    ),
    "titleScanRepoQR": MessageLookupByLibrary.simpleMessage(
      "Naskenovat QR kód repozitáře",
    ),
    "titleSecurity": MessageLookupByLibrary.simpleMessage("Zabezpečení"),
    "titleSecurityPractices": MessageLookupByLibrary.simpleMessage(
      "3.3 Bezpečnostní postupy",
    ),
    "titleSendFeedback": MessageLookupByLibrary.simpleMessage(
      "Odeslat zpětnou vazbu",
    ),
    "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
      "Nastavit heslo pro",
    ),
    "titleSettings": MessageLookupByLibrary.simpleMessage("Nastavení"),
    "titleShareRepository": m38,
    "titleSortBy": MessageLookupByLibrary.simpleMessage("Seřadit podle"),
    "titleStateMonitor": MessageLookupByLibrary.simpleMessage(
      "Sledování stavu",
    ),
    "titleTermsOfUse": MessageLookupByLibrary.simpleMessage(
      "2. Podmínky používání",
    ),
    "titleTermsPrivacy": MessageLookupByLibrary.simpleMessage(
      "Podmínky používání Ouisync a informace o ochraně soukromí",
    ),
    "titleUPnP": MessageLookupByLibrary.simpleMessage(
      "Universal Plug and Play (UPnP)",
    ),
    "titleUnlockRepository": MessageLookupByLibrary.simpleMessage(
      "Odemknout repozitář",
    ),
    "titleUnsavedChanges": MessageLookupByLibrary.simpleMessage(
      "Neuložené změny",
    ),
    "titleUserProvidedPeers": MessageLookupByLibrary.simpleMessage(
      "Ručně zadané protějšky",
    ),
    "titleWeAreEq": MessageLookupByLibrary.simpleMessage("Jsme eQualit.ie"),
    "typeFile": MessageLookupByLibrary.simpleMessage("Soubor"),
    "typeFolder": MessageLookupByLibrary.simpleMessage("Složka"),
  };
}
