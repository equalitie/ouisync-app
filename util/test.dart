import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'release.dart';

void main() {
  test('asset_description', () {
    final samples = [
      (
        "ouisync_0.9.0-production+70.2718e34.msix.sha256",
        "ouisync_0.9.0.msix.sha256",
      ),
      (
        "ouisync_0.9.0-nightly+70.2718e34.msix.sha256",
        "ouisync_2718e34.msix.sha256",
      ),
      ("ouisync_0.9.0-production+70.2718e34.msix", "ouisync_0.9.0.msix"),
      (
        "ouisync-cli_0.9.0-production+70.2718e34_arm64.deb",
        "ouisync-cli_0.9.0_arm64.deb",
      ),
      (
        "ouisync-cli_0.9.0-unofficial+70.2718e34_arm64.deb",
        "ouisync-cli_2718e34_arm64.deb",
      ),
    ];

    for (final (filename, releasedName) in samples) {
      final desc = AssetDesc.parse(filename);
      expect(desc.toString(), equals(filename));
      expect(desc.gitHubName(), equals(releasedName));
    }
  });
}
