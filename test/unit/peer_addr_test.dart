import 'dart:io';

import 'package:ouisync_app/app/utils/peer_addr.dart';
import 'package:test/test.dart';

void main() {
  test('parse', () {
    expect(
      PeerAddr.parse('quic/127.0.0.1:12345'),
      equals(PeerAddr(
        PeerProto.quic,
        InternetAddress('127.0.0.1', type: InternetAddressType.IPv4),
        12345,
      )),
    );

    expect(
      PeerAddr.parse('tcp/127.0.0.1:12346'),
      equals(PeerAddr(
        PeerProto.tcp,
        InternetAddress('127.0.0.1', type: InternetAddressType.IPv4),
        12346,
      )),
    );

    expect(
      PeerAddr.parse('quic/[::]:12347'),
      equals(PeerAddr(
        PeerProto.quic,
        InternetAddress('::', type: InternetAddressType.IPv6),
        12347,
      )),
    );

    expect(
      PeerAddr.parse('quic/[2345:0425:2CA1:0000:0000:0567:5673:23b5]:12348'),
      equals(PeerAddr(
        PeerProto.quic,
        InternetAddress(
          '2345:0425:2CA1:0000:0000:0567:5673:23b5',
          type: InternetAddressType.IPv6,
        ),
        12348,
      )),
    );
  });

  test('parse invalid', () {
    expect(PeerAddr.parse(''), isNull);
    expect(PeerAddr.parse('blah'), isNull);
    expect(PeerAddr.parse('127.0.0.1'), isNull);
    expect(PeerAddr.parse('127.0.0.1:12345'), isNull);
    expect(PeerAddr.parse('quic/127.0.0.1'), isNull);
    expect(PeerAddr.parse('blah/127.0.0.1:12345'), isNull);
    expect(PeerAddr.parse('quic/300.0.0.1:12345'), isNull);
  });
}
