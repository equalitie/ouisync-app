import 'dart:convert';

class ConnectivityInfo {
  String protocol;
  String ipAddress;
  int portNumber;
  WiFiStatus wiFiStatus;
  ConnectivityInfo({
    required this.protocol,
    required this.ipAddress,
    required this.portNumber,
    required this.wiFiStatus,
  });

  ConnectivityInfo copyWith({
    String? protocol,
    String? ipAddress,
    int? portNumber,
    WiFiStatus? network,
  }) {
    return ConnectivityInfo(
      protocol: protocol ?? this.protocol,
      ipAddress: ipAddress ?? this.ipAddress,
      portNumber: portNumber ?? this.portNumber,
      wiFiStatus: network ?? this.wiFiStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'protocol': protocol,
      'ipAddress': ipAddress,
      'portNumber': portNumber,
      'network': wiFiStatus.index,
    };
  }

  factory ConnectivityInfo.fromMap(Map<String, dynamic> map) {
    return ConnectivityInfo(
      protocol: map['protocol'] ?? '',
      ipAddress: map['ipAddress'] ?? '',
      portNumber: map['portNumber']?.toInt() ?? 0,
      wiFiStatus: WiFiStatus.values[map['network']],
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectivityInfo.fromJson(String source) => ConnectivityInfo.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ConnectivityInfo(protocol: $protocol, ipAddress: $ipAddress, portNumber: $portNumber, network: $wiFiStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ConnectivityInfo &&
      other.protocol == protocol &&
      other.ipAddress == ipAddress &&
      other.portNumber == portNumber &&
      other.wiFiStatus == wiFiStatus;
  }

  @override
  int get hashCode {
    return protocol.hashCode ^
      ipAddress.hashCode ^
      portNumber.hashCode ^
      wiFiStatus.hashCode;
  }
}

enum WiFiStatus {
  Connected,
  Enabled,
  Disconnected
}
