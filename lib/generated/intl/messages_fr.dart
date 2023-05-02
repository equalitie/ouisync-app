// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(access) =>
      "La permission ne peut pas être plus élevée que le mode d\'accès du dépôt courant : ${access}";

  static String m1(name) =>
      "Validation biométrique ajoutée au dépôt « ${name} »";

  static String m2(name) => "${name} - téléchargement annulé";

  static String m3(name) => "${name} - échec du téléchargement";

  static String m4(entry) => "${entry} existe déjà.";

  static String m5(path) =>
      "Le dossier courant est manquant, navigation vers le dossier parent : ${path}";

  static String m6(name) => "L\'initialisation du dépôt ${name} a échoué";

  static String m7(path) => "${path} n\'est pas vide";

  static String m9(name) => "Le dossier a bien été supprimé : ${name}";

  static String m10(number) =>
      "Voulez-vous verrouiller tous les dépôts ouverts ?\n\n(${number} ouverts)";

  static String m11(path) => "de ${path}";

  static String m12(name) => "Erreur lors de la création du fichier ${name}";

  static String m14(name) =>
      "Nous n\'avons pas pu supprimer le dépôt « ${name} »";

  static String m15(name) =>
      "Nous n\'avons pas pu trouver le dépôt « ${name} » à l\'emplacement habituel";

  static String m16(access) => "Mode d\'accès accordé : ${access}";

  static String m17(name) =>
      "Ce dépôt existe déjà dans l\'application avec le nom « ${name} ».";

  static String m18(name) =>
      "Suggéré : ${name}\n(appuyez ici pour utiliser ce nom)";

  static String m19(access) => "";

  static String m20(name) => "Écriture de ${name} annulée";

  static String m21(name) => "${name} - échec de l\'écriture";

  static String m22(name) => "Échec de l\'import du dépôt ${name}";

  static String m23(name) => "Échec de la création du dépôt ${name}";

  static String m24(access) => "${access}";

  static String m25(changes) => "${changes}";

  static String m26(entry) => "${entry}";

  static String m27(name) => "${name}";

  static String m28(number) => "${number}";

  static String m29(path) => "${path}";

  static String m30(status) => "${status}";

  static String m31(name) => "Partager le dépôt « ${name} »";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "actionAccept": MessageLookupByLibrary.simpleMessage("Accepter"),
        "actionAcceptCapital": MessageLookupByLibrary.simpleMessage("ACCEPTER"),
        "actionAddRepository":
            MessageLookupByLibrary.simpleMessage("Importer un dépôt"),
        "actionAddRepositoryWithToken":
            MessageLookupByLibrary.simpleMessage("Importer le dépôt"),
        "actionBack": MessageLookupByLibrary.simpleMessage("Retour"),
        "actionCancel": MessageLookupByLibrary.simpleMessage("Annuler"),
        "actionCancelCapital": MessageLookupByLibrary.simpleMessage("ANNULER"),
        "actionClear": MessageLookupByLibrary.simpleMessage("Effacer"),
        "actionCloseCapital": MessageLookupByLibrary.simpleMessage("FERMER"),
        "actionCreate": MessageLookupByLibrary.simpleMessage("Créer"),
        "actionCreateRepository":
            MessageLookupByLibrary.simpleMessage("Créer un dépôt"),
        "actionDelete": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "actionDeleteCapital":
            MessageLookupByLibrary.simpleMessage("SUPPRIMER"),
        "actionDeleteFile":
            MessageLookupByLibrary.simpleMessage("Supprimer le fichier"),
        "actionDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Supprimer le dossier"),
        "actionDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Supprimer le dépôt"),
        "actionDiscard": MessageLookupByLibrary.simpleMessage("Annuler"),
        "actionEditRepositoryName":
            MessageLookupByLibrary.simpleMessage("Modifier le nom"),
        "actionExit": MessageLookupByLibrary.simpleMessage("Quitter"),
        "actionGoToSettings":
            MessageLookupByLibrary.simpleMessage("Aller aux paramètres"),
        "actionHide": MessageLookupByLibrary.simpleMessage("Masquer"),
        "actionHideCapital": MessageLookupByLibrary.simpleMessage("MASQUER"),
        "actionImport": MessageLookupByLibrary.simpleMessage("Importer"),
        "actionImportRepo":
            MessageLookupByLibrary.simpleMessage("Importer le dépôt"),
        "actionLockCapital":
            MessageLookupByLibrary.simpleMessage("VERROUILLER"),
        "actionMove": MessageLookupByLibrary.simpleMessage("Déplacer"),
        "actionNewFile": MessageLookupByLibrary.simpleMessage("Fichier"),
        "actionNewFolder": MessageLookupByLibrary.simpleMessage("Dossier"),
        "actionNewRepo": MessageLookupByLibrary.simpleMessage("Créer le dépôt"),
        "actionOK": MessageLookupByLibrary.simpleMessage("OK"),
        "actionPreviewFile":
            MessageLookupByLibrary.simpleMessage("Aperçu du fichier"),
        "actionReloadContents":
            MessageLookupByLibrary.simpleMessage("Actualiser"),
        "actionReloadRepo":
            MessageLookupByLibrary.simpleMessage("Actualiser le dépôt"),
        "actionRemove": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "actionRemoveRepo":
            MessageLookupByLibrary.simpleMessage("Supprimer le dépôt"),
        "actionRename": MessageLookupByLibrary.simpleMessage("Renommer"),
        "actionRetry": MessageLookupByLibrary.simpleMessage("Réessayer"),
        "actionSave": MessageLookupByLibrary.simpleMessage("Enregistrer"),
        "actionSaveChanges": MessageLookupByLibrary.simpleMessage(
            "Enregistrer les modifications"),
        "actionScanQR":
            MessageLookupByLibrary.simpleMessage("Scanner un code QR"),
        "actionShare": MessageLookupByLibrary.simpleMessage("Partager"),
        "actionShareFile":
            MessageLookupByLibrary.simpleMessage("Partager le fichier"),
        "actionShow": MessageLookupByLibrary.simpleMessage("Afficher"),
        "actionUndo": MessageLookupByLibrary.simpleMessage("Annuler"),
        "actionUnlock": MessageLookupByLibrary.simpleMessage("Déverrouiller"),
        "iconAccessMode": MessageLookupByLibrary.simpleMessage("Mode d\'accès"),
        "iconAddExistingRepository":
            MessageLookupByLibrary.simpleMessage("Importer un dépôt"),
        "iconCreateRepository":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau dépôt"),
        "iconDelete": MessageLookupByLibrary.simpleMessage("Supprimer"),
        "iconDownload": MessageLookupByLibrary.simpleMessage("Télécharger"),
        "iconInformation": MessageLookupByLibrary.simpleMessage("Information"),
        "iconMove": MessageLookupByLibrary.simpleMessage("Déplacer"),
        "iconPreview": MessageLookupByLibrary.simpleMessage("Aperçu"),
        "iconRename": MessageLookupByLibrary.simpleMessage("Renommer"),
        "iconShare": MessageLookupByLibrary.simpleMessage("Partager"),
        "iconShareTokenWithPeer": MessageLookupByLibrary.simpleMessage(
            "Partager ceci avec vos pairs"),
        "labelAppVersion":
            MessageLookupByLibrary.simpleMessage("Version de l\'application"),
        "labelBitTorrentDHT": MessageLookupByLibrary.simpleMessage(""),
        "labelCopyLink": MessageLookupByLibrary.simpleMessage("Copier le lien"),
        "labelDestination": MessageLookupByLibrary.simpleMessage("Destination"),
        "labelDownloadedTo":
            MessageLookupByLibrary.simpleMessage("Téléchargé vers :"),
        "labelEndpoint":
            MessageLookupByLibrary.simpleMessage("Point de terminaison : "),
        "labelLocation": MessageLookupByLibrary.simpleMessage("Emplacement : "),
        "labelLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Tout verrouiller"),
        "labelName": MessageLookupByLibrary.simpleMessage("Nom : "),
        "labelNewName": MessageLookupByLibrary.simpleMessage("Nouveau nom : "),
        "labelPassword":
            MessageLookupByLibrary.simpleMessage("Mot de passe : "),
        "labelPeers": MessageLookupByLibrary.simpleMessage("Pairs"),
        "labelQRCode": MessageLookupByLibrary.simpleMessage("Code QR"),
        "labelRenameRepository":
            MessageLookupByLibrary.simpleMessage("Entrez le nouveau nom : "),
        "labelRepositoryLink":
            MessageLookupByLibrary.simpleMessage("Lien du dépôt : "),
        "labelRetypePassword": MessageLookupByLibrary.simpleMessage(
            "Confirmez le mot de passe : "),
        "labelSelectRepository":
            MessageLookupByLibrary.simpleMessage("Sélectionner un dépôt : "),
        "labelSetPermission":
            MessageLookupByLibrary.simpleMessage("Accorder la permission"),
        "labelShareLink":
            MessageLookupByLibrary.simpleMessage("Partager le lien"),
        "labelSize": MessageLookupByLibrary.simpleMessage("Taille : "),
        "labelSyncStatus":
            MessageLookupByLibrary.simpleMessage("État de synchronisation : "),
        "labelTokenLink":
            MessageLookupByLibrary.simpleMessage("Lien de partage du dépôt"),
        "labelTypePassword":
            MessageLookupByLibrary.simpleMessage("Entrez le mot de passe : "),
        "labelUseExternalStorage": MessageLookupByLibrary.simpleMessage(
            "Utiliser le stockage externe"),
        "menuItemAbout": MessageLookupByLibrary.simpleMessage("À propos"),
        "menuItemLogs": MessageLookupByLibrary.simpleMessage("Journaux"),
        "menuItemNetwork": MessageLookupByLibrary.simpleMessage("Réseau"),
        "menuItemRepository": MessageLookupByLibrary.simpleMessage("Dépôt"),
        "mesageNoMediaPresent":
            MessageLookupByLibrary.simpleMessage("Il n\'y a aucun média."),
        "messageAccessModeDisabled": m0,
        "messageAccessingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "Accéder au stockage sécurisé"),
        "messageAck": MessageLookupByLibrary.simpleMessage("Oups !"),
        "messageActionNotAvailable": MessageLookupByLibrary.simpleMessage(
            "Cette option n\'est pas disponible sur le dépôts en lecture seule"),
        "messageAddLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Ajouter un mot de passe local"),
        "messageAddRepoLink": MessageLookupByLibrary.simpleMessage(
            "Importer un dépôt en utilisant un lien de jeton"),
        "messageAddRepoQR": MessageLookupByLibrary.simpleMessage(
            "Importer un dépôt en utilisant un code QR"),
        "messageAddingFileToLockedRepository":
            MessageLookupByLibrary.simpleMessage(""),
        "messageAddingFileToReadRepository":
            MessageLookupByLibrary.simpleMessage(
                "Ce dépôt est une copie en lecture seule."),
        "messageAlertSaveCopyPassword": MessageLookupByLibrary.simpleMessage(
            "Si vous supprimez la validation par biométrie, une fois que vous aurez quitté cet écran, vous ne pourrez plus voir ou copier le mot de passe ; veuillez l\'enregistrer dans un endroit sûr."),
        "messageBackgroundAndroidPermissions": MessageLookupByLibrary.simpleMessage(
            "Le système d\'exploitation vous demandera bientôt l\'autorisation d\'exécuter cette application en arrière-plan.\n\nCette autorisation est nécessaire pour poursuivre la synchronisation lorsque l\'application n\'est pas ouverte"),
        "messageBackgroundNotificationAndroid":
            MessageLookupByLibrary.simpleMessage(
                "OuiSync est en cours d\'exécution"),
        "messageBiometricValidationAdded": m1,
        "messageBiometricValidationRemoved":
            MessageLookupByLibrary.simpleMessage(
                "Validation biométrique supprimée"),
        "messageBlindReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Votre pair ne peut ni écrire ni lire le contenu"),
        "messageBlindRepository": MessageLookupByLibrary.simpleMessage(""),
        "messageBlindRepositoryContent": MessageLookupByLibrary.simpleMessage(
            "Le <bold>mot de passe</bold> fourni ne vous donne pas accès au contenu de ce dépôt."),
        "messageBluetooth": MessageLookupByLibrary.simpleMessage("Bluetooth"),
        "messageCamera": MessageLookupByLibrary.simpleMessage("Appareil photo"),
        "messageCameraPermission": MessageLookupByLibrary.simpleMessage(
            "Nous avons besoin de cette permission pour utiliser l\'appareil photo et lire le code QR"),
        "messageChangeExtensionAlert": MessageLookupByLibrary.simpleMessage(
            "Modifier l\'extension d\'un fichier peut le rendre inutilisable"),
        "messageChangeLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Modifier le mot de passe local"),
        "messageConfirmFileDeletion": MessageLookupByLibrary.simpleMessage(
            "Voulez-vous vraiment supprimer ce fichier ?"),
        "messageConfirmFolderDeletion": MessageLookupByLibrary.simpleMessage(
            "Voulez-vous vraiment supprimer ce dossier ?"),
        "messageConfirmNotEmptyFolderDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Ce dossier n\'est pas vide.\n\nVoulez-vous vraiment le supprimer ? (Cela supprimera l\'intégralité de son contenu)"),
        "messageConfirmRepositoryDeletion":
            MessageLookupByLibrary.simpleMessage(
                "Voulez-vous vraiment supprimer ce dépôt ?"),
        "messageCreateAddNewItem": MessageLookupByLibrary.simpleMessage(
            "Créez un nouveau <bold>dossier</bold> ou ajoutez un <bold>fichier</bold> en utilisant <icon></icon>"),
        "messageCreateNewRepo": MessageLookupByLibrary.simpleMessage(
            "Créez un nouveau <bold>dépôt</bold>, ou associez celui d\'un ami en utilisant le <bold>jeton du dépôt</bold>"),
        "messageCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Création du jeton de partage…"),
        "messageDownloadingFileCanceled": m2,
        "messageDownloadingFileError": m3,
        "messageEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Ce <bold>dossier</bold> est vide"),
        "messageEmptyRepo": MessageLookupByLibrary.simpleMessage(
            "Ce <bold>dépôt</bold> est vide"),
        "messageEntryAlreadyExist": m4,
        "messageEntryTypeDefault":
            MessageLookupByLibrary.simpleMessage("Une entrée"),
        "messageEntryTypeFile":
            MessageLookupByLibrary.simpleMessage("Un fichier"),
        "messageEntryTypeFolder":
            MessageLookupByLibrary.simpleMessage("Un dossier"),
        "messageError": MessageLookupByLibrary.simpleMessage("Erreur !"),
        "messageErrorAddingLocalPassword": MessageLookupByLibrary.simpleMessage(
            "L\'ajout d\'un mot de passe local a échoué"),
        "messageErrorAddingSecureStorge": MessageLookupByLibrary.simpleMessage(
            "L\'ajout d\'un mot de passe local a échoué"),
        "messageErrorAuthenticatingBiometrics":
            MessageLookupByLibrary.simpleMessage(
                "Une erreur s\'est produite lors de l\'authentification biométrique. Veuillez réessayer"),
        "messageErrorChangingLocalPassword":
            MessageLookupByLibrary.simpleMessage(
                "La modification du mot de passe local a échoué"),
        "messageErrorChangingPassword": MessageLookupByLibrary.simpleMessage(
            "Une erreur s\'est produite lors de la modification du mot de passe. Veuillez réessayer"),
        "messageErrorCharactersNotAllowed":
            MessageLookupByLibrary.simpleMessage(
                "L\'utilisation de \\ ou / n\'est pas autorisée"),
        "messageErrorCreatingRepository": MessageLookupByLibrary.simpleMessage(
            "Erreur lors de la création du dépôt"),
        "messageErrorCreatingToken": MessageLookupByLibrary.simpleMessage(
            "Erreur lors de la création du jeton de partage."),
        "messageErrorCurrentPathMissing": m5,
        "messageErrorDefault": MessageLookupByLibrary.simpleMessage(
            "Une erreur s\'est produite. Veuillez réessayer."),
        "messageErrorDefaultShort":
            MessageLookupByLibrary.simpleMessage("Échec."),
        "messageErrorEntryNotFound":
            MessageLookupByLibrary.simpleMessage("entrée non trouvée"),
        "messageErrorFormValidatorNameDefault":
            MessageLookupByLibrary.simpleMessage(
                "Veuillez entrer un nom valide."),
        "messageErrorLoadingContents": MessageLookupByLibrary.simpleMessage(
            "Nous n\'avons pas pu charger le contenu de ce dossier. Veuillez réessayer."),
        "messageErrorNewPasswordSameOldPassword":
            MessageLookupByLibrary.simpleMessage(
                "Le nouveau mot de passe est identique à l\'ancien"),
        "messageErrorOpeningRepo": MessageLookupByLibrary.simpleMessage(
            "Erreur lors de l\'ouverture du dépôt"),
        "messageErrorOpeningRepoDescription": m6,
        "messageErrorPathNotEmpty": m7,
        "messageErrorRemovingPassword": MessageLookupByLibrary.simpleMessage(
            "La suppression du mot de passe a échoué"),
        "messageErrorRemovingSecureStorage":
            MessageLookupByLibrary.simpleMessage(
                "La suppression du mot de passe du stockage sécurisé a échoué"),
        "messageErrorRepositoryNameExist": MessageLookupByLibrary.simpleMessage(
            "Il y a déjà un dépôt avec ce nom"),
        "messageErrorRepositoryPasswordValidation":
            MessageLookupByLibrary.simpleMessage(
                "Veuillez entrer un mot de passe."),
        "messageErrorRetypePassword": MessageLookupByLibrary.simpleMessage(
            "Les mots de passe ne correspondent pas."),
        "messageErrorTokenEmpty":
            MessageLookupByLibrary.simpleMessage("Veuillez entrer un jeton."),
        "messageErrorTokenInvalid":
            MessageLookupByLibrary.simpleMessage("Ce jeton est invalide."),
        "messageErrorTokenValidator": MessageLookupByLibrary.simpleMessage(
            "Veuillez entrer un jeton valide."),
        "messageErrorUnhandledState":
            MessageLookupByLibrary.simpleMessage("Erreur : État non géré"),
        "messageErrorUpdatingSecureStorage": MessageLookupByLibrary.simpleMessage(
            "La mise à jour du mot de passe dans le stockage local a échoué"),
        "messageEthernet": MessageLookupByLibrary.simpleMessage("Ethernet"),
        "messageExitOuiSync": MessageLookupByLibrary.simpleMessage(
            "Appuyez à nouveau sur retour pour quitter."),
        "messageFile": MessageLookupByLibrary.simpleMessage("fichier"),
        "messageFileIsDownloading": MessageLookupByLibrary.simpleMessage(
            "Le fichier est déjà en cours d\'envoi"),
        "messageFileName":
            MessageLookupByLibrary.simpleMessage("Nom du fichier"),
        "messageFilePreviewNotAvailable": MessageLookupByLibrary.simpleMessage(
            "L\'aperçu du fichier n\'est pas encore disponible"),
        "messageFiles": MessageLookupByLibrary.simpleMessage("fichiers"),
        "messageFolderDeleted": m9,
        "messageFolderName":
            MessageLookupByLibrary.simpleMessage("Nom du dossier"),
        "messageGeneratePassword":
            MessageLookupByLibrary.simpleMessage("Générer un mot de passe"),
        "messageGranted": MessageLookupByLibrary.simpleMessage("Accordé"),
        "messageGrantingRequiresSettings": MessageLookupByLibrary.simpleMessage(
            "Pour accorder cette autorisation, vous devez vous rendre dans les paramètres :\n\n Paramètres > Applications et notifications"),
        "messageIgnoreBatteryOptimizationsPermission":
            MessageLookupByLibrary.simpleMessage(
                "Autorise l\'application à continuer la synchronisation en arrière-plan"),
        "messageInitializing":
            MessageLookupByLibrary.simpleMessage("Initialisation…"),
        "messageInputPasswordToUnlock": MessageLookupByLibrary.simpleMessage(
            "Cliquez sur le bouton <bold>Déverrouiller</bold> et entrez le mot de passe pour accéder au contenu de ce dépôt."),
        "messageLibraryPanic": MessageLookupByLibrary.simpleMessage(
            "Une erreur interne s\'est produite."),
        "messageLoadingDefault":
            MessageLookupByLibrary.simpleMessage("Chargement…"),
        "messageLocalDiscovery":
            MessageLookupByLibrary.simpleMessage("Découverte locale"),
        "messageLockOpenRepos": m10,
        "messageLockedRepository": MessageLookupByLibrary.simpleMessage(
            "Ce <bold>dépôt</bold> est verrouillé."),
        "messageLockingAllRepos": MessageLookupByLibrary.simpleMessage(
            "Verrouillage de tous les dépôts ouverts…"),
        "messageLogLevelAll": MessageLookupByLibrary.simpleMessage("Tout"),
        "messageLogLevelErroWarnInfoDebug":
            MessageLookupByLibrary.simpleMessage(
                "Erreurs, avertissements, informations et débogage"),
        "messageLogLevelError":
            MessageLookupByLibrary.simpleMessage("Erreurs uniquement"),
        "messageLogLevelErrorWarn":
            MessageLookupByLibrary.simpleMessage("Erreurs et avertissements"),
        "messageLogLevelErrorWarnInfo": MessageLookupByLibrary.simpleMessage(
            "Erreurs, avertissements et informations"),
        "messageLogViewer":
            MessageLookupByLibrary.simpleMessage("Visionneuse de journaux"),
        "messageMobile": MessageLookupByLibrary.simpleMessage("Mobile"),
        "messageMoveEntryOrigin": m11,
        "messageMovingEntry": MessageLookupByLibrary.simpleMessage(
            "Cette fonction n\'est pas disponible lors du déplacement d\'une entrée."),
        "messageNATType": MessageLookupByLibrary.simpleMessage("Type NAT"),
        "messageNetworkIsUnavailable":
            MessageLookupByLibrary.simpleMessage("Réseau indisponible"),
        "messageNewFileError": m12,
        "messageNewPassword":
            MessageLookupByLibrary.simpleMessage("Nouveau mot de passe"),
        "messageNewPasswordCopiedClipboard":
            MessageLookupByLibrary.simpleMessage(
                "Nouveau mot de passe copié dans le presse-papiers"),
        "messageNewVersionIsAvailable": MessageLookupByLibrary.simpleMessage(
            "Une nouvelle version est disponible."),
        "messageNoRepo": MessageLookupByLibrary.simpleMessage(
            "Avant d\'ajouter des fichiers, vous devez créer un dépôt"),
        "messageNoRepoIsSelected":
            MessageLookupByLibrary.simpleMessage("Aucun dépôt sélectionné"),
        "messageNoRepos":
            MessageLookupByLibrary.simpleMessage("Aucun dépôt trouvé"),
        "messageNone": MessageLookupByLibrary.simpleMessage("Aucun"),
        "messageNothingHereYet": MessageLookupByLibrary.simpleMessage(
            "Il n\'y a rien ici pour l\'instant !"),
        "messageOr": MessageLookupByLibrary.simpleMessage("Ou"),
        "messageOuiSyncDesktopTitle":
            MessageLookupByLibrary.simpleMessage("OuiSync"),
        "messagePassword": MessageLookupByLibrary.simpleMessage("Mot de passe"),
        "messagePasswordCopiedClipboard": MessageLookupByLibrary.simpleMessage(
            "Mot de passe copié dans le presse-papiers"),
        "messagePeerExchange":
            MessageLookupByLibrary.simpleMessage("Échange des pairs"),
        "messagePermissionRequired": MessageLookupByLibrary.simpleMessage(
            "Cette permission est requise"),
        "messageReadOnlyContents": MessageLookupByLibrary.simpleMessage(
            "Ce dépôt est <bold>en lecture seule</bold>."),
        "messageReadReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Ne peut être modifié, il suffit d\'accéder au contenu"),
        "messageRememberSavePasswordAlert": MessageLookupByLibrary.simpleMessage(
            "N\'oubliez pas de sauvegarder le mot de passe en toute sécurité ; si vous l\'oubliez, il n\'y a aucun moyen de le retrouver."),
        "messageRemovaLocalPassword": MessageLookupByLibrary.simpleMessage(
            "Supprimer le mot de passe local"),
        "messageRemoveBiometricValidation":
            MessageLookupByLibrary.simpleMessage(
                "Validation par biométrie supprimée"),
        "messageRemoveBiometrics":
            MessageLookupByLibrary.simpleMessage("Supprimer la biométrie"),
        "messageRemoveBiometricsConfirmation": MessageLookupByLibrary.simpleMessage(
            "Voulez-vous vraiment supprimer l\'accès par biométrie de ce dépôt ?"),
        "messageRemovedInBrackets":
            MessageLookupByLibrary.simpleMessage("<supprimé>"),
        "messageRenameFile":
            MessageLookupByLibrary.simpleMessage("Renommer le fichier"),
        "messageRenameFolder":
            MessageLookupByLibrary.simpleMessage("Renommer le dossier"),
        "messageRenameRepository":
            MessageLookupByLibrary.simpleMessage("Renommer le dépôt"),
        "messageRepoDeletionErrorDescription": m14,
        "messageRepoDeletionFailed": MessageLookupByLibrary.simpleMessage(
            "La suppression du dépôt a échoué"),
        "messageRepoMissing": MessageLookupByLibrary.simpleMessage(
            "Le dépôt ne se trouve plus ici"),
        "messageRepoMissingErrorDescription": m15,
        "messageRepositoryAccessMode": m16,
        "messageRepositoryAlreadyExist": m17,
        "messageRepositoryIsNotOpen":
            MessageLookupByLibrary.simpleMessage("Le dépôt n\'est pas ouvert"),
        "messageRepositoryName":
            MessageLookupByLibrary.simpleMessage("Donnez un nom au dépôt"),
        "messageRepositoryNewName":
            MessageLookupByLibrary.simpleMessage("Nouveau nom du dépôt"),
        "messageRepositoryNewPassword":
            MessageLookupByLibrary.simpleMessage("Nouveau mot de passe"),
        "messageRepositoryPassword":
            MessageLookupByLibrary.simpleMessage("Mot de passe"),
        "messageRepositorySuggestedName": m18,
        "messageRepositoryToken":
            MessageLookupByLibrary.simpleMessage("Collez le lien ici"),
        "messageSaveLogFile": MessageLookupByLibrary.simpleMessage(
            "Enregistrer le fichier des journaux"),
        "messageSaveToLocation": MessageLookupByLibrary.simpleMessage(
            "Enregistrer le fichier dans ce dossier"),
        "messageSavingChanges": MessageLookupByLibrary.simpleMessage(
            "Voulez-vous enregistrer les modifications actuelles ?"),
        "messageScanQROrShare": MessageLookupByLibrary.simpleMessage(
            "Scannez ceci avec votre autre appareil ou partagez-le avec vos pairs"),
        "messageSecureUsingBiometrics":
            MessageLookupByLibrary.simpleMessage("Sécurisé par biométrie"),
        "messageSelectAccessMode": MessageLookupByLibrary.simpleMessage(
            "Sélectionnez une autorisation pour créer un lien de partage"),
        "messageSelectLocation":
            MessageLookupByLibrary.simpleMessage("Sélectionner l\'emplacement"),
        "messageSettingsRuntimeID":
            MessageLookupByLibrary.simpleMessage("Identifiant d\'exécution"),
        "messageShareActionDisabled": MessageLookupByLibrary.simpleMessage(
            "Vous devez d\'abord sélectionner une permission pour créer un dépôt"),
        "messageShareWithWR":
            MessageLookupByLibrary.simpleMessage("Partager avec un code QR"),
        "messageStorage": MessageLookupByLibrary.simpleMessage("Stockage"),
        "messageStoragePermission": MessageLookupByLibrary.simpleMessage(
            "Requis pour pouvoir accéder aux fichiers"),
        "messageSyncMobileData": MessageLookupByLibrary.simpleMessage(
            "Synchroniser avec les données mobiles"),
        "messageSyncingIsDisabledOnMobileInternet":
            MessageLookupByLibrary.simpleMessage(
                "La synchronisation est désactivée lors de l\'utilisation des données mobiles"),
        "messageTokenCopiedToClipboard": MessageLookupByLibrary.simpleMessage(
            "Le jeton du dépôt a été copié dans le presse-papiers."),
        "messageUnlockRepoFailed": MessageLookupByLibrary.simpleMessage(
            "Le mot de passe n\'a pas déverrouillé le dépôt"),
        "messageUnlockRepoOk": m19,
        "messageUnlockRepository": MessageLookupByLibrary.simpleMessage(
            "Entrez le mot de passe pour déverrouiller"),
        "messageUnlockUsingBiometrics": MessageLookupByLibrary.simpleMessage(
            "Déverrouiller en utilisant la biométrie"),
        "messageUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "Vous avez des modifications non enregistrées.\n\nVoulez-vous les annuler ?"),
        "messageVPN": MessageLookupByLibrary.simpleMessage("VPN"),
        "messageVerbosity":
            MessageLookupByLibrary.simpleMessage("Verbosité des journaux"),
        "messageView": MessageLookupByLibrary.simpleMessage("Voir"),
        "messageWiFi": MessageLookupByLibrary.simpleMessage("Wi-Fi"),
        "messageWriteReplicaExplanation": MessageLookupByLibrary.simpleMessage(
            "Accès complet. Votre pair peut lire et écrire"),
        "messageWritingFileCanceled": m20,
        "messageWritingFileError": m21,
        "messsageFailedAddRepository": m22,
        "messsageFailedCreateRepository": m23,
        "popupMenuItemChangePassword":
            MessageLookupByLibrary.simpleMessage("Modifier le mot de passe"),
        "popupMenuItemCopyPassword":
            MessageLookupByLibrary.simpleMessage("Copier le mot de passe"),
        "replacementAccess": m24,
        "replacementChanges": m25,
        "replacementEntry": m26,
        "replacementName": m27,
        "replacementNumber": m28,
        "replacementPath": m29,
        "replacementStatus": m30,
        "statusSync": MessageLookupByLibrary.simpleMessage("SYNCHRONISÉ"),
        "statusUnspecified":
            MessageLookupByLibrary.simpleMessage("Non spécifié"),
        "titleAbout": MessageLookupByLibrary.simpleMessage("À propos"),
        "titleAddFile": MessageLookupByLibrary.simpleMessage(
            "Ajouter un fichier à OuiSync"),
        "titleAddRepoToken": MessageLookupByLibrary.simpleMessage(
            "Importer un dépôt avec un jeton"),
        "titleAddRepository":
            MessageLookupByLibrary.simpleMessage("Importer un dépôt"),
        "titleAppTitle": MessageLookupByLibrary.simpleMessage("OuiSync"),
        "titleBackgroundAndroidPermissionsTitle":
            MessageLookupByLibrary.simpleMessage("Permissions requises"),
        "titleChangePassword":
            MessageLookupByLibrary.simpleMessage("Modifier le mot de passe"),
        "titleCreateFolder":
            MessageLookupByLibrary.simpleMessage("Créer un dossier"),
        "titleCreateRepository":
            MessageLookupByLibrary.simpleMessage("Créer un nouveau dépôt"),
        "titleDeleteFile":
            MessageLookupByLibrary.simpleMessage("Supprimer le fichier"),
        "titleDeleteFolder":
            MessageLookupByLibrary.simpleMessage("Supprimer le dossier"),
        "titleDeleteNotEmptyFolder": MessageLookupByLibrary.simpleMessage(
            "Supprimer le dossier non vide"),
        "titleDeleteRepository":
            MessageLookupByLibrary.simpleMessage("Supprimer le dépôt"),
        "titleDownloadLocation": MessageLookupByLibrary.simpleMessage(
            "Emplacement de téléchargement"),
        "titleDownloadToDevice":
            MessageLookupByLibrary.simpleMessage("Télécharger sur l\'appareil"),
        "titleEditRepository":
            MessageLookupByLibrary.simpleMessage("Modifier le dépôt"),
        "titleFileDetails":
            MessageLookupByLibrary.simpleMessage("Informations du fichier"),
        "titleFileExtensionChanged": MessageLookupByLibrary.simpleMessage(
            "Extension de fichier modifiée"),
        "titleFileExtensionMissing": MessageLookupByLibrary.simpleMessage(
            "Extension de fichier manquante"),
        "titleFolderActions": MessageLookupByLibrary.simpleMessage("Ajouter"),
        "titleFolderDetails":
            MessageLookupByLibrary.simpleMessage("Informations du dossier"),
        "titleLockAllRepos":
            MessageLookupByLibrary.simpleMessage("Verrouiller tous les dépôts"),
        "titleLogs": MessageLookupByLibrary.simpleMessage("Journaux"),
        "titleMovingEntry":
            MessageLookupByLibrary.simpleMessage("Déplacer l\'entrée"),
        "titleNetwork": MessageLookupByLibrary.simpleMessage("Réseau"),
        "titleRemoveBiometrics": MessageLookupByLibrary.simpleMessage(
            "Supprimer les informations biométriques"),
        "titleRepositoriesList":
            MessageLookupByLibrary.simpleMessage("Vos dépôts"),
        "titleRepository": MessageLookupByLibrary.simpleMessage("Dépôt"),
        "titleRepositoryName":
            MessageLookupByLibrary.simpleMessage("Nom du dépôt"),
        "titleRequiredPermission":
            MessageLookupByLibrary.simpleMessage("Permission requise"),
        "titleSaveChanges": MessageLookupByLibrary.simpleMessage(
            "Enregistrer les modifications"),
        "titleScanRepoQR":
            MessageLookupByLibrary.simpleMessage("Scanner le code QR du dépôt"),
        "titleSecurity": MessageLookupByLibrary.simpleMessage("Sécurité"),
        "titleSetPasswordFor": MessageLookupByLibrary.simpleMessage(
            "Définir un mot de passe pour"),
        "titleSettings": MessageLookupByLibrary.simpleMessage("Paramètres"),
        "titleShareRepository": m31,
        "titleStateMonitor":
            MessageLookupByLibrary.simpleMessage("Moniteur d\'état"),
        "titleUnlockRepository":
            MessageLookupByLibrary.simpleMessage("Déverrouiller le dépôt"),
        "titleUnsavedChanges": MessageLookupByLibrary.simpleMessage(
            "Modifications non enregistrées"),
        "typeFile": MessageLookupByLibrary.simpleMessage("Fichier"),
        "typeFolder": MessageLookupByLibrary.simpleMessage("Dossier")
      };
}
