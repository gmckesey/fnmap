import 'dart:math';

class NotAValidCIDRException implements Exception {
  String cause;
  NotAValidCIDRException(this.cause);
}
///
/// [CidrCalculator] can be used to fetch summary information for CIDR address like "192.168.0.2/22".
///
class CidrCalculator {
  static const String _reCIDRPattern = r'^(?:'
      r'(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}(?:[0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\/([1-9]|[1-2]\d|3[0-2])$';

  static const String _reIPPattern = r"@([a-z][a-z0-9_]{4,31})";

  static bool isValidCIDR(String cidr) {
    return RegExp(_reCIDRPattern).hasMatch(cidr);
  }

/*
  static bool isValidIP(String ip) {
    return RegExp(_reIPPattern).hasMatch(ip);
  }
*/

  /// parse cidr address info
  static CIDRInfo parse(String cidr) {
    int maskLength;
    String mask;
    String ip;
    String network;
    String broadcast;
    String first;
    String last;
    int available;

    /// split address by dot
    List<String> splitAddress(String ipAddress) {
      return ipAddress.split(r'.');
    }

    /// convert to bin list
    List<String> convertToBinaryArray(List<String> array) {
      for (int i = 0; i < array.length; i++) {
        array[i] = (int.parse(array[i]) + 256).toRadixString(2).substring(1);
      }
      return array;
    }

    if (!isValidCIDR(cidr)) {
      throw NotAValidCIDRException("CIDR $cidr is invalid.");
    }

    maskLength = int.parse(cidr.substring(cidr.indexOf(r'/') + 1));
    ip = cidr.substring(0, cidr.indexOf(r'/'));

    /// get mask from mask length
    String getMaskCodeFromMaskLength(int length) {
      String maskBinary = '1' * length + '0' * (32 - length);
      return '${int.parse(maskBinary.substring(0, 8), radix: 2)}'
          '.${int.parse(maskBinary.substring(8, 16), radix: 2)}'
          '.${int.parse(maskBinary.substring(16, 24), radix: 2)}'
          '.${int.parse(maskBinary.substring(24, 32), radix: 2)}';
    }

    mask = getMaskCodeFromMaskLength(maskLength);

    /// get network ID
    String getNetworkId() {
      List<String> ipArr = splitAddress(ip);
      List<String> maskArr = splitAddress(mask);
      List<String> networkArr = [];
      for (int i = 0; i < 4; i++) {
        networkArr
            .add((int.parse(ipArr[i]) & int.parse(maskArr[i])).toString());
      }
      String networkId = networkArr.join('.');

      return networkId;
    }

    network = getNetworkId();

    /// get network broadcast address
    String getNetworkBroadcast() {
      List<String> maskArr = splitAddress(mask);
      List<String> networkIdArr = splitAddress(network);
      String maskBinaryString = convertToBinaryArray(maskArr).join(r'.');
      int hostIndexOfMask = maskBinaryString.indexOf(r'0');
      String networkIdBinaryString =
          convertToBinaryArray(networkIdArr).join(r'.');
      String netAddressOfNetwork =
          networkIdBinaryString.substring(0, hostIndexOfMask);
      String hostOfNetwork = networkIdBinaryString
          .substring(hostIndexOfMask, networkIdBinaryString.length)
          .replaceAll(RegExp(r'\d'), '1');
      List<String> broadcastStringArr =
          (netAddressOfNetwork + hostOfNetwork).split(r'.');
      for (int i = 0; i < 4; i++) {
        broadcastStringArr[i] =
            int.parse(broadcastStringArr[i], radix: 2).toString();
      }
      return broadcastStringArr.join(r'.');
    }

    broadcast = getNetworkBroadcast();

    /// get first host in cidr
    String getNetworkStart() {
      List<String> networkIdArr = splitAddress(network);
      networkIdArr[3] = (int.parse(networkIdArr[3]) + 1).toString();
      return networkIdArr.join('.');
    }

    /// get last host in cidr
    String getNetworkEnd() {
      List<String> broadcastArr = splitAddress(broadcast);
      broadcastArr[3] = (int.parse(broadcastArr[3]) - 1).toString();
      return broadcastArr.join('.');
    }

    first = getNetworkStart();
    last = getNetworkEnd();
    available = (pow(2, 32 - maskLength) - 2) as int;

    return CIDRInfo(
      mask: mask,
      network: network,
      broadcast: broadcast,
      first: first,
      last: last,
      available: available,
    );
  }
}

class CIDRInfo {
  /// netmask
  late String mask;

  /// Subnet ID
  late String network;

  /// broadcast address
  late String broadcast;

  /// first host address
  late String first;

  /// last host address
  late String last;

  /// available host addresses
  late int available;

  CIDRInfo({
    required this.mask,
    required this.network,
    required this.broadcast,
    required this.first,
    required this.last,
    required this.available,
  });

  CIDRInfo.fromString(String strCIDR) {
    CIDRInfo cidr =  CidrCalculator.parse(strCIDR);
    mask = cidr.mask;
    network = cidr.network;
    broadcast = cidr.broadcast;
    first = cidr.first;
    last = cidr.last;
    available = cidr.available;
  }

  CIDRInfo.from(CIDRInfo original) {
    mask = original.mask;
    network = original.network;
    broadcast = original.broadcast;
    first = original.first;
    last = original.last;
    available = original.available;
  }

  @override
  String toString() {
    return "mask: $mask\nnetwork: $network\nbroadcast: $broadcast\nfirst: "
        "$first\nlast: $last\navailable: $available";
  }

  String strCIDRExpanded() {
    return "$network/$mask";
  }

  String strCIDR() {
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return (other is CIDRInfo) &&
        (other.mask == mask) &&
        (other.network == network) &&
        (other.broadcast == broadcast) &&
        (other.first == first) &&
        (other.last == last) &&
        (other.available == available);
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      mask.hashCode ^
      network.hashCode ^
      broadcast.hashCode ^
      first.hashCode ^
      last.hashCode ^
      available.hashCode;
}
