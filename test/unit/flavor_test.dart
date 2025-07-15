import 'package:flutter_test/flutter_test.dart';
import 'package:ouisync_app/app/utils/flavor.dart';

void main() {
  test('toString', () {
    expect(Flavor.production.toString(), equals('production'));
    expect(Flavor.nightly.toString(), equals('nightly'));
    expect(Flavor.unofficial.toString(), equals('unofficial'));
  });
}
