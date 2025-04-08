// TODO: replace this with `Result` from `result_type` once we bump it to v1.0.
import 'package:ouisync/ouisync.dart';

import '../../generated/l10n.dart';
import '../cubits/repos.dart';

sealed class ShareTokenResult {
  const ShareTokenResult();

  ShareTokenError? get error;
}

class ShareTokenValid extends ShareTokenResult {
  const ShareTokenValid(this.value);

  final ShareToken value;

  @override
  ShareTokenError? get error => null;
}

class ShareTokenInvalid extends ShareTokenResult {
  const ShareTokenInvalid(this.error);

  @override
  final ShareTokenError error;
}

sealed class ShareTokenError {
  const ShareTokenError();
}

class ShareTokenEmpty extends ShareTokenError {
  const ShareTokenEmpty();

  @override
  String toString() => S.current.messageErrorTokenEmpty;
}

class ShareTokenMalformed extends ShareTokenError {
  const ShareTokenMalformed();

  @override
  String toString() => S.current.messageErrorTokenInvalid;
}

class ShareTokenRepoExists extends ShareTokenError {
  const ShareTokenRepoExists(this.repoName);

  final String repoName;

  @override
  String toString() => S.current.messageRepositoryAlreadyExist(repoName);
}

Future<ShareTokenResult> parseShareToken(
  ReposCubit reposCubit,
  String input,
) async {
  if (input.isEmpty) {
    return const ShareTokenInvalid(ShareTokenEmpty());
  }

  try {
    final token = await reposCubit.session.validateShareToken(input);
    final infoHash = await reposCubit.session.getShareTokenInfoHash(token);
    final repo = reposCubit.state.findByInfoHash(infoHash);

    if (repo != null) {
      return ShareTokenInvalid(ShareTokenRepoExists(repo.name));
    }

    return ShareTokenValid(token);
  } catch (e) {
    return const ShareTokenInvalid(ShareTokenMalformed());
  }
}
