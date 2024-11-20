import 'package:fnmap/constants.dart';
import 'package:fnmap/utilities/cidr_address.dart';
import 'package:validators/validators.dart' as valid;
import 'package:fnmap/utilities/logger.dart';

String _reIPRange = r'^((?:[0-9]{1,3}\.)|(?:[0-9]{1,3}\-[0-9]{1,3}\.)){3}(?:([0-9]{1,3})|([0-9]{1,3}\-[0-9]{1,3}))$';
String _reOctetRange = r'^(?:(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\-(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9]))$';

class NotAValidIPAddressException implements Exception {
  String cause;
  NotAValidIPAddressException (this.cause);
}

enum AddressType {
  ipAddress,
  ipRange,
  cidr,
  fqdn,
  invalidAddress,
}

bool isHostname(String value) {
  bool response = false;
  if (value.isNotEmpty && value.length < 255) {
    if (valid.isAlphanumeric(value)) {
      response = true;
    } else if (valid.isAlphanumeric(value.replaceAll('-', '')) && value[0] != '_') {
      response = true;
    }
  }
  return response;
}
//TODO: Make this check more rigorous
bool isValidIPRange(String range) {
  NLog log = NLog('isValidRange', flag: nLogTRACE, package: kPackageName);
  bool rc;
  rc = RegExp(_reIPRange).hasMatch(range);
  if (rc) {
    List<String> parts = range.split('.');
    for (var octet in parts) {
      // octet should be a number or a range
      int? value = int.tryParse(octet);
      if (value != null) {
        // its a number
        if (value < 255) {
          // This octet is good, keep going
          continue;
        } else {
          // Can't have an octet > 255
          log.debug('invalid octet $value in range $range');
          return false;
        }
      } else {
          rc = RegExp(_reOctetRange).hasMatch(octet);
          if (!rc) {
            // If the octet doesn't match the regex, then it is neither
            // a valid octet or range
            log.debug('invalid format $octet in range $range');
            return false;
          } else {
            // Check the range
            List<String> values = octet.split('-');
            if (values.length != 2) {
              //There should be two values, I don't think
              // this case is possible given the regular expression
              log.debug('invalid range values in $octet parsing $range');
              return false;
          } else {
              int? first = int.tryParse(values.first);
              if (first == null || first > 255) {
                log.debug('invalid first element ${values.first} in range $octet '
                    'parsing $range');
                return false;
              }
              int? second = int.tryParse(values.last);
              if (second == null || first >= second) {
                log.debug('invalid second element ${values.last} in range $octet '
                    'parsing $range');
                return false;
              }
            }
        }
      }
    }}
  return rc;
}

AddressType addressType(String address) {
  NLog log = NLog('isValidIPAddress:', flag: nLogTRACE, package: kPackageName);

  AddressType type = AddressType.invalidAddress;
  if (CidrCalculator.isValidCIDR(address)) {
    type = AddressType.cidr;
    log.debug('address [$address] is a valid CIDR');
  } else if (valid.isIP(address)) {
    type = AddressType.ipAddress;
    log.debug('address [$address] is a valid ip');
  } else if (isValidIPRange(address)) {
    type = AddressType.ipRange;
    log.debug('Sample address [$address] is a valid IP Range');
  } else if (valid.isFQDN(address)) {
    type = AddressType.fqdn;
    log.debug('Sample address [$address] is a valid FQDN');
  } else {
    log.debug('Sample address [$address] is not a valid CIDR, IP or FQDN');
  }
  return type;
}
bool isValidIPAddressList(String addressList) {
  final pattern = RegExp(r"\s+");
  List<String> list = addressList.split(pattern);

  for (String element in list) {
    if (!isValidIPAddress(element) && !isHostname(element)) {
      if (element.isEmpty) {
        continue;
      }
      return false;
    }
  }
  return true;
}

bool isValidIPAddress(String address) {
  // GLog log = GLog('isValidIPAddress:', properties: gLogPropALL);
  if (addressType(address) != AddressType.invalidAddress) {
    return true;
  } else {
    return false;
  }

}
