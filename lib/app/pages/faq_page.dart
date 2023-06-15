import 'package:flutter/material.dart';
import 'package:flutter_faq/flutter_faq.dart';

import '../utils/dimensions.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('FAQ')),
        body: Column(children: [
          Expanded(child: _allFAQList(context))
          // Expanded(child: _faqList(faqs)),
          // Expanded(child: _faqList(otherFAQs))
        ]));
  }

  Widget _allFAQList(BuildContext context) => CustomScrollView(
        slivers: [
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => FAQ(
                      showDivider: false,
                      queStyle: TextStyle(
                          color: Colors.black,
                          fontSize: Dimensions.fontAverage),
                      queDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      ansStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: Dimensions.fontSmall),
                      ansDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.zero)),
                      question: faqs.keys.elementAt(index),
                      answer: faqs.values.elementAt(index)),
                  childCount: faqs.length)),
          SliverToBoxAdapter(
              child: Padding(
                  padding: Dimensions.paddingAll20,
                  child: Text('Other FAQs',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.fontAverage)))),
          SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => FAQ(
                      showDivider: false,
                      queStyle: TextStyle(
                          color: Colors.black,
                          fontSize: Dimensions.fontAverage),
                      queDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                      ansStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: Dimensions.fontSmall),
                      ansDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(Radius.zero)),
                      question: otherFAQs.keys.elementAt(index),
                      answer: otherFAQs.values.elementAt(index)),
                  childCount: otherFAQs.length))
        ],
      );

  Widget _faqList(Map<String, String> faqList) => ListView.builder(
      itemCount: faqList.length,
      itemBuilder: (context, index) => FAQ(
          showDivider: false,
          queStyle:
              TextStyle(color: Colors.black, fontSize: Dimensions.fontAverage),
          queDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          ansStyle:
              TextStyle(color: Colors.black87, fontSize: Dimensions.fontSmall),
          ansDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.zero)),
          question: faqList.keys.elementAt(index),
          answer: faqList.values.elementAt(index)));

  Widget _otherFAQs() => ListView.separated(
      itemBuilder: (context, index) => FAQ(
          question: otherFAQs.keys.elementAt(index),
          answer: otherFAQs.values.elementAt(index)),
      separatorBuilder: (context, index) => Divider(),
      itemCount: otherFAQs.length);
}

final faqs = {
  'What is a repository?': 'Repository is simply a place where you can store '
      'and share your files and folders securely, using Ouisync. You can think'
      ' of it as a root folder, or even a safe, that will contain other '
      'folders and files that you want to share with your peers.',
  'Where can I see my repositories?': 'When you open Ouisync app, after the '
      'onboarding screens, you will see the main screen listing all the '
      'repositories you have created. Initially this screen will be empty, '
      'but as you go creating repositories, they will be listed here.',
  'How can I create new repositories?': 'We hid this well? didn\'t we? Joking...'
      ' Of course, to create a new repository, you need to tap on the button '
      '\'Plus\'.\n\nThen you select Create Reporitory. The app will propose you'
      ' to add a local password. It is not mandatory and you can also add it '
      'later.\n\nSee <<What is a \'local password\'?>> for more information',
  'How can I add files and folders to my repository? ': 'That\'s easy.  You go '
      'to the repository contents screen and you tap on the \'Plus\' button. '
      'This will open a small window where you can select if you want to create'
      ' a folder for your files within that repository or you want to add files'
      ' to it from your device or external storage (such as USB stick or SD '
      'card).',
  'What does it mean to \'import\' a repository?': 'To import repository means '
      'that you want to recreate on your device a repository that a peer has '
      'shared with you. You start with the same \'Plus\' button and then you '
      'select \'Import\'. This action will import into your device all the files'
      ' contained in the repository that your peer shared with you.',
  'How can I share my repository with my peers (or my other devices)?': 'You '
      'can do this by tapping the repository settings icon (gear) and then tap'
      ' on Share (share icon). If the peer (or device) with whom you want to '
      'share a repository is nearby, they can tap on Import repository on their'
      ' device and then scan the QR code displayed on your screen.\n\nThis '
      'action will import a copy of your repository onto your peer\'s device,'
      ' including all the files and folders within it.\n\nIf your peer is not '
      'nearby, you can select to generate a token link which you can send to '
      'them via email, any messaging application etc. They will need to copy and'
      ' paste that link into the field provided when they tap <<Import '
      'Repository>> on their device.\n\nPS: to paste a link to the input field,'
      ' you tap and hold your finger on it, until a small \'Paste\' button '
      'appears. Then you tap that... (you probably already knew that... but this'
      ' is in case you didn\'t...)',
  'How do I decide which permissions to select when sharing a repository?':
      '\'Read / Write\'\n\nIt depends what you want the peers with whom your '
          'shared your repository to be able to do. If you want them to be able'
          ' to add files, delete them, rename or move them, then you share your'
          ' repository with \'Read / Write\' permission.\n\nAn example of a use'
          ' case for this level of permissions: sharing photos with friends and'
          ' family, or working collaboratively on a project.\n\n'
          '\'Read\'\n\nIf you want your peers to only be able to read the '
          'repository contents, then you select... (you guessed it... ) Read '
          'permissions.  This means they will be able to open te files and read'
          ' them, but they won\'t be able to add new files to your shared '
          'repository, or delete any files from it, or move them etc.\n\n'
          'An example use case would be when you want to share the information '
          'regarding an event, or news items, or maybe regarding certain '
          'products, or may be you are a teacher sharing some content with your'
          ' students etc. Then you want the recipients to be able to read the '
          'contents but not change them.\n\n'
          '\'Blind\'\n\nThis level of permissions can be useful when you want '
          'to securely store your repository as a backup. This means that the '
          'person or device with whom you shared your repository as \'blind\' '
          'won\'t be able to either open the files to read them, or make any '
          'changes to them.  This way you can store your data securely on a '
          'friend\'s computer, for example.',
  'How can I use my repository as secure backup?':
      '\'Create Secure Backup\'\n\nYou can create a secure backup repository '
          'on your own or even on a friend\'s device. To do that you first '
          'need to generate the \'read and write\' token link for the repository'
          ' that you want to store  blind.  You keep the read and write token '
          'link somewhere safe, as you will need it for retrieving the '
          'information from your blind copy later on.\n\nThen you create a blind'
          ' token link and import a blind repository into the backup device.\n\n'
          '\'Retrieving Information from the Blind repository\'\n\nIf you '
          'accidentally delete a repository from your primary device, what you '
          'can do is go to Import Repository, copy and paste the \'READ-WRITE\''
          ' token that you kept somewhere safe into the provided field, and '
          'that\'s it. Once your primary device connects with your backup device'
          ', they will sync - ie the primary repository will automatically sync'
          ' with your backup repository and receive all the files that '
          'repository contains.\n\nNotice: if you lose your read-write token '
          'link for the backup repository, you won\'t be able to retrieve data '
          'from that blind copy.\n\nNote: if you add files to your primary '
          'repository, that addition will be propagated to your backup '
          'repository too (if your backup device is connected/online). That means'
          ' that your backup repository will automatically receive all updates '
          'from your primary repository.\n\nBut if you delete any files in your'
          ' primary repository, then that deletion will be propagated too, and '
          'you won\'t be able to retrieve those files.  So Ouisync is currently'
          ' primarily a synchronisation tool and not a secure backup tool.\n\n'
          'The selective syncing, and creating snapshots in time that will alow'
          ' you to go back to the previous version of your repository is '
          'foreseen for development in future Ouisync releases.',
  'Can my peers re-share my token links?': 'Yes. They can generate the token '
      'links with the same permissions they had in the original token link that'
      ' they received from you, or lower. This means that if a person has '
      'received a token link to import a directory with read-write permissions '
      'they are able to generate the same kind of token to share the same '
      'repository with other people, or they can also generate the token links '
      'for the same repository but with lower permissions - read only or blind.'
      ' If they imported a repository with read permissions only, then they can'
      ' share it with others as read or blind. And if they imported your '
      'repository as blind, they can only share it on as blind.',
  'What happens if I delete files in my repository?': 'File deletion is '
      'propagated to all replicas in existence - which means, the same file that'
      ' you deleted will be automatically deleted in the repositories of all the'
      ' peers with whom you have shared it.\n\nEqually, if your peers delete any'
      ' files in any of the repositories that they have imported from you, their'
      ' file deletions will be propagated to your device too.  It works both '
      'ways - ie repositories shared  with read-write permissions will sync with'
      ' each other, including the file edit, addition or deletion.',
  'What happens if I rename files in my repository?': 'If you rename files in '
      'your repository, the new file name will be propagated to the repositories'
      ' of all the peers that you shared your repository with.',
  'Can I move my files from one repository to another?': 'No. At the moment you'
      ' can only move files from one folder to another within the same '
      'repository. Moving files from one repository to another is planned for '
      'future releases of Ouisync.',
  'Are my files stored on a server? Why?': 'Yes. They are stored encrypted and '
      'are not readable by the server.  The purpose of the server storage is to'
      ' facilitate file syncing when peers are not online at the same time. If '
      'you want to share a repository with a peer who is not online at the '
      'moment, your repository data will be stored encrypted on the server and '
      'when your peer comes online and connects either to the server (or to your'
      ' device) the files from the stored repository will sync with the files in'
      ' your peer\'s repository.',
  'How can I connect to the server?': 'This happens automatically when you share'
      ' a repository with a peer - you don\'t need to perform any additional '
      'actions.',
  'Where is this server and who runs it?': '[Add info about the country where '
      'the servers are and so on]',
  'What private data does Ouisync use/store?': 'Ouisync uses IP addresses of '
      'your devices to be able to connect you with your peers in the '
      'peer-to-peer network. We don\'t store those IP addresses anywhere on our'
      ' systems. We don\'t keep any other user data.',
  'What happens if me and my peers make changes to a repository at the same '
      'time?': '[Add answer]',
  'Do I need to set up a password (or biometric protection) to protect my '
      'repositories?': 'That is largely up to you. Whether you protect your '
      'repositories with passwords or biometrics depends on the sensitivy of '
      'data that you store in Ouisync repositories and habitual usage of your '
      'devices.  For storing and sharing the photos of your cat, maybe a '
      'password is not necessary. But for storing more sensitive personal data,'
      ' we recommend passwords (or biometrics) to be set up.\n\nYou can have a '
      'different password for each repository. It is also possible to have a '
      'mixture of password (or biometrics) protected Ouisync repositories and '
      'the ones without protection.',
  'What is a \'local password\'?': 'Local password means it is a password set up'
      ' only for your own device.  You don\'t need to share it with your peers.'
      ' They can set up their own passwords to protect the shared Ouisync '
      'repositories on their own devices.',
  'How can I lock my repositories when I\'m not actively using them?': 'To lock'
      ' your repositories when not actively working on them, you need to tap on'
      ' this button (icon left to the repository name). To unlock them, you tap'
      ' on repository name or on this icon (unlock icon). If your '
      'repository is protected by password, you need to enter the password when'
      ' prompted. Otherwise, just tap on Unlock button and you can continue to'
      ' work on your repository.'
};

final otherFAQs = {
  'Advantages of using Ouisync over Dropbox (or other similar solutions)?':
      '\n\n\'Free to use\'\n\nTo be able to share files using Dropbox, you need'
          ' to create a Dropbox account. This requires your name, email, credit '
          'card. It requires payment.\n\nOuisync is free and open source software. '
          'To share files using Ouisync, you only need to install the app. That\'s '
          'it. No payment is required.\n\n'
          '\'Anonymity\'\n\nOuisync does not require creation of user account. '
          'With Ouisync, it is simply a case of installing the app and using it.'
          ' All users are completey annonymous.\n\n'
          '\'Ouisync is a P2P solution\'\n\nThis means that using Ouisync '
          'successfully does not depend on any central server anywhere. Ouisync'
          ' makes use of decentralised peer-to-peer network, which makes it '
          'effective file sharing app even in situations where well known file '
          'sharing servers, such as Dropbox or Google Drive are unavailable.',
  'How can I sync the files with my peers or with my other devices without '
      'internet?': 'In situations with limited internet availability, you will '
      'need to make sure some means of connecting to other devices still exist.'
      ' This could be a WiFi signal available to all devices that want to share'
      ' Ouisync repositories, or it could be intranet, local network or similar'
      ' technologies.\n\nCurrently repositories cannot be shared via BlueTooth,'
      ' but that feature is planned for future releases.'
};
