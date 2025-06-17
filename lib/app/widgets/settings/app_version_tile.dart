import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync/ouisync.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'settings_tile.dart';
import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/click_counter.dart';

class AppVersionTile extends StatefulWidget {
  final Session session;
  final UpgradeExistsCubit upgradeExists;
  final Widget title;
  final Widget leading;

  AppVersionTile({
    required this.session,
    required this.upgradeExists,
    required this.title,
    required this.leading,
  });

  @override
  State<AppVersionTile> createState() => _AppVersionTileState();
}

class _AppVersionTileState extends State<AppVersionTile> {
  late Future<String> _version;
  final _clickCounter = ClickCounter(timeoutMs: 3000);

  @override
  void initState() {
    super.initState();
    _version = PackageInfo.fromPlatform().then((info) => info.version);
  }

  @override
  Widget build(BuildContext context) => SettingsTile(
    leading: widget.leading,
    title: widget.title,
    value: _getAppVersion(),
    onTap: () => _onTap(context),
  );

  FutureBuilder<String> _getAppVersion() => FutureBuilder<String>(
    future: _version,
    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
      late Widget version;

      if (snapshot.hasData) {
        final suffix = appFlavor != null ? ' ($appFlavor)' : '';

        version = Text('${snapshot.data!}$suffix');
      } else if (snapshot.hasError) {
        version = Text('???');
      } else {
        version = Text('...');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          version,
          BlocBuilder<UpgradeExistsCubit, bool>(
            bloc: widget.upgradeExists,
            builder: (context, state) {
              if (state) {
                return Text(
                  S.current.messageNewVersionIsAvailable,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                );
              } else {
                return SizedBox.shrink();
              }
            },
          ),
        ],
      );
    },
  );

  void _onTap(BuildContext context) {
    if (_clickCounter.registerClick() >= 3) {
      _clickCounter.reset();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StateMonitorPage(widget.session),
        ),
      );
    }
  }
}
