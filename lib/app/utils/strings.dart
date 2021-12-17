class Strings {
  Strings._();

  /// Configuration
  static const String directoryRepositoriesName = 'repositories';
  static const String databaseConfigurationName = 'config.db';

  /// Page titles
  static const String titleApp = 'OuiSync';
  static const String titleRootPage = 'Repositories';
  static const String titleAddShareFilePage = 'Add file to OuiSync';

  static const String rootPath = '/';

  // State messages

  // General
  static const String messageLoadingContents = 'Loading the directory contents...';
  static const String messageErrorLoadingContents = 'Oooops!\n(Something went wrong trying to do the thing,'
  ' sorry about that. Please try again)';

  static const String messageOhOh = '<color>Oh oh...</color> <size><bold>o.0</bold></size>';
  static const String messageErrorState = 'That did not work as we expected <size><bold>:\\</bold></size>\n'
  'Would you please try again... ? Thanks!\n\n<size><bold><icon></icon><bold></size>';

  // main_page.dart
  static const String messageNoRepo = 'Before adding a file, you need to create a repository';
  static const String messageCreateNewRepo = 'Create a new <bold>repository</bold>,'
  ' or link to one from a friend using a <bold>repository token</bold>';
  static const String messageNoRepos = 'No repositories found';
  static const String messageEmptyRepo = 'This repository is empty';
  static const String messageEmptyFolder = 'This folder is empty';
  static const String messageCreateAddNewItem = 'Create a new <bold>folder</bold>, or add a <bold>file</bold>,'
  ' using <icon></icon>';

  // add_shared_file_page.dart
  static const String messageEmptyFolderStructure = 'Move along, nothing to see here...';
  static const String messageCreateNewFolderRootToStart = 'Maybe start by creating a new <bold>folder</bold>\n'
  '... or just go ahead and use <size><bold>\/</bold></size>, we are not your mother';
  static const String messageCreateNewFolder = 'You can create a new <bold>folder</bold> (look down <icon></icon>)'
  '\n... or just drop it here, champ';

  // Dialogs

  static const String titleMovingEntry = 'Moving Entry';
  static const String messageMovingEntry = 'This function is not availabe when moving an entry';

  static const String titleCreateRepository = 'Create Repository';
  static const String titleAddRepository = 'Add Repository';
  static const String titleSettings = 'Settings';

  // Buttons text

  static const String actionCreateRepository = 'Create a Repository';
  static const String actionAddRepositoryWithToken = 'Add a Shared Repository';

  static const String actionReloadContents = 'Reload';


  static const String actionNewRepo = 'Create repository';
  static const String actionNewFolder = 'Create folder';
  static const String actionNewFile = 'Add file';

  static const String actionDeleteFolder = 'Delete folder';

  static const String actionPreviewFile = 'Preview file';
  static const String actionShareFile = 'Share file';
  static const String actionDeleteFile = 'Delete file';

  

}