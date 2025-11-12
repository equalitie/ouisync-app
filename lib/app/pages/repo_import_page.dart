import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../generated/l10n.dart';
import '../cubits/cubits.dart' show RepoImportCubit, ReposCubit;
import '../models/models.dart';
import '../utils/platform/platform.dart' show PlatformValues;
import '../utils/share_token.dart';
import '../utils/utils.dart'
    show
        AppThemeExtension,
        Constants,
        Dimensions,
        Fields,
        Permissions,
        showSnackBar,
        ThemeGetter;
import '../widgets/widgets.dart' show BlocHolder, DirectionalAppBar;
import 'pages.dart';

class RepoImportPage extends StatelessWidget {
  const RepoImportPage({super.key, required this.reposCubit});

  final ReposCubit reposCubit;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DirectionalAppBar(
      title: Text(S.current.titleAddRepoToken),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black87,
      titleTextStyle: context.theme.appTextStyle.titleMedium,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: Dimensions.paddingAll20,
        child: BlocHolder<RepoImportCubit>(
          create: () => RepoImportCubit(reposCubit: reposCubit),
          builder: (context, cubit) =>
              BlocBuilder<RepoImportCubit, ShareTokenResult?>(
                bloc: cubit,
                builder: (context, state) =>
                    _buildContent(context, cubit, state),
              ),
        ),
      ),
    ),
  );

  Widget _buildContent(
    BuildContext context,
    RepoImportCubit cubit,
    ShareTokenResult? state,
  ) {
    final noReposImageHeight = MediaQuery.of(context).size.height * 0.2;

    final children = [
      Fields.placeholderWidget(
        assetName: Constants.assetPathAddWithQR,
        assetHeight: noReposImageHeight,
      ),
      _buildScanQrCode(context),
      _buildOrSeparator(context),
      _buildUseToken(context, cubit, state),
    ];

    if (PlatformValues.isDesktopDevice) {
      children
        ..add(_buildOrSeparator(context))
        ..add(_buildImportOuisyncDb(context));
    }

    return Column(children: children);
  }

  Widget _buildScanQrCode(BuildContext context) => Column(
    children: [
      Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            children: [
              Fields.constrainedText(S.current.messageAddRepoQR, flex: 0),
            ],
          ),
          if (PlatformValues.isDesktopDevice)
            Row(
              children: [
                Fields.constrainedText(
                  '(${S.current.messageAvailableOnMobile})',
                  flex: 0,
                  style: context.theme.appTextStyle.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
      Dimensions.spacingVerticalDouble,
      _builScanQRButton(context),
    ],
  );

  /// We don't support QR reading for desktop at the moment, just mobile.
  /// TODO: Find a plugin for reading QR with support for Windows, Linux
  Widget _builScanQRButton(BuildContext context) => Fields.inPageButton(
    onPressed: PlatformValues.isDesktopDevice
        ? null
        : () async {
            final permissionGranted = await _checkPermission(
              context,
              Permission.camera,
            );
            if (!permissionGranted) return;

            final data = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRScanner(reposCubit.session),
              ),
            );

            if (data == null) return;

            final result = await parseShareToken(reposCubit, data);
            switch (result) {
              case ShareTokenValid(value: final token):
                await Navigator.of(
                  context,
                ).maybePop(RepoImportFromToken(token));
              case ShareTokenInvalid(error: final error):
                showSnackBar(context, error.toString());
            }
          },
    leadingIcon: const Icon(Icons.qr_code_2_outlined),
    text: S.current.actionScanQR.toUpperCase(),
  );

  Future<bool> _checkPermission(
    BuildContext context,
    Permission permission,
  ) async {
    final status = await Permissions.requestPermission(context, permission);
    return status == PermissionStatus.granted;
  }

  Widget _buildOrSeparator(BuildContext context) {
    return Padding(
      padding: Dimensions.paddingVertical20,
      child: Row(
        children: [
          const Expanded(
            child: Divider(
              thickness: 1.0,
              endIndent: 20.0,
              color: Colors.black26,
            ),
          ),
          Text(
            S.current.messageOr.toUpperCase(),
            style: context.theme.appTextStyle.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Expanded(
            child: Divider(thickness: 1.0, indent: 20.0, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _buildUseToken(
    BuildContext context,
    RepoImportCubit cubit,
    ShareTokenResult? state,
  ) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Fields.constrainedText(
            S.current.messageAddRepoLink,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      Dimensions.spacingVerticalDouble,
      Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(Dimensions.radiusSmall),
          ),
          color: Constants.inputBackgroundColor,
        ),
        child: Fields.formTextField(
          context: context,
          key: ValueKey('token'),
          controller: cubit.tokenController,
          labelText: S.current.labelRepositoryLink,
          hintText: S.current.messageRepositoryToken,
          errorText: state?.error?.toString(),
          suffixIcon: const Icon(Icons.key_rounded),
        ),
      ),
      _builAddRepositoryButton(context, state),
    ],
  );

  Widget _builAddRepositoryButton(
    BuildContext context,
    ShareTokenResult? state,
  ) =>
      _buildButton(S.current.actionAddRepository.toUpperCase(), switch (state) {
        ShareTokenValid(value: final token) => () async => await Navigator.of(
          context,
        ).maybePop(RepoImportFromToken(token)),
        ShareTokenInvalid() || null => null,
      });

  Widget _buildImportOuisyncDb(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Fields.constrainedText(
              S.current.messageAddRepoDb,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        Dimensions.spacingVerticalDouble,
        _buildButton(S.current.buttonLocateRepository, () async {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              RepoLocation.defaultExtension,
              RepoLocation.legacyExtension,
            ],
          );
          if (result == null) return;

          final locations = result.paths
              .whereType<String>()
              .map((path) => RepoLocation.fromDbPath(path))
              .toList();

          await Future.wait(locations.map(reposCubit.importRepoFromLocation));

          await Navigator.of(context).maybePop(RepoImportFromFiles(locations));
        }),
      ],
    );
  }

  Widget _buildButton(String text, Future<void> Function()? onPressed) =>
      Padding(
        padding: Dimensions.paddingVertical20,
        child: Fields.inPageAsyncButton(onPressed: onPressed, text: text),
      );
}

sealed class RepoImportResult {
  const RepoImportResult();
}

class RepoImportFromToken extends RepoImportResult {
  const RepoImportFromToken(this.token);

  final ShareToken token;

  @override
  String toString() => '$runtimeType($token)';
}

class RepoImportFromFiles extends RepoImportResult {
  const RepoImportFromFiles(this.locations);

  final List<RepoLocation> locations;

  @override
  String toString() => '$runtimeType($locations)';
}
