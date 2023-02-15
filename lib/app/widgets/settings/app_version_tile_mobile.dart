import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ouisync_plugin/ouisync_plugin.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../../generated/l10n.dart';
import '../../cubits/cubits.dart';
import '../../pages/pages.dart';
import '../../utils/click_counter.dart';

class AppVersionTileMobile extends StatefulWidget {
  final Session session;
  final Widget title;
  final Widget? leading;

  AppVersionTileMobile(
      {required this.session, required this.title, this.leading});

  @override
  State<AppVersionTileMobile> createState() => _AppVersionTileMobileState();
}

class _AppVersionTileMobileState extends State<AppVersionTileMobile> {
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
        value: FutureBuilder<String>(
          future: _version,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            late Widget version;

            if (snapshot.hasData) {
              version = Text(snapshot.data!);
            } else if (snapshot.hasError) {
              version = Text("???");
            } else {
              version = Text("...");
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                version,
                BlocBuilder<UpgradeExistsCubit, bool>(
                  builder: (context, state) {
                    if (state) {
                      return Text(
                        S.current.messageNewVersionIsAvailable,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ],
            );
          },
        ),
        onPressed: _onPressed,
      );

  void _onPressed(BuildContext context) {
    if (_clickCounter.registerClick() >= 3) {
      _clickCounter.reset();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StateMonitorPage(widget.session)));
    }
  }
}
