import 'dart:io';

class PeerAddr {
  final PeerProto proto;
  final InternetAddress addr;
  final int port;

  const PeerAddr(this.proto, this.addr, this.port);

  static PeerAddr? parse(String input) {
    final i = input.indexOf('/');
    if (i < 0) {
      return null;
    }

    final proto = switch (input.substring(0, i)) {
      'quic' => PeerProto.quic,
      'tcp' => PeerProto.tcp,
      _ => null,
    };

    if (proto == null) {
      return null;
    }

    input = input.substring(i + 1);

    final j = input.lastIndexOf(':');
    if (j < 0) {
      return null;
    }

    final rawPort = input.substring(j + 1);
    final port = int.tryParse(rawPort);
    if (port == null) {
      return null;
    }

    input = input.substring(0, j);
    input = input.replaceFirst('[', '');
    input = input.replaceFirst(']', '');

    final addr = InternetAddress.tryParse(input);
    if (addr == null) {
      return null;
    }

    return PeerAddr(proto, addr, port);
  }

  bool get isIPv4 => addr.type == InternetAddressType.IPv4;
  bool get isIPv6 => addr.type == InternetAddressType.IPv6;

  @override
  bool operator ==(Object other) =>
      other is PeerAddr &&
      other.proto == proto &&
      other.addr == addr &&
      other.port == port;

  @override
  int get hashCode => Object.hash(proto, addr, port);

  @override
  String toString() => addr.type == InternetAddressType.IPv6
      ? '${proto.name}/[${addr.address}]:$port'
      : '${proto.name}/${addr.address}:$port';
}

enum PeerProto {
  quic,
  tcp,
}
