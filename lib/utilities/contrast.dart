import 'dart:math';

const redProp = 0.2126;
const blueProp = 0.0722;
const greenProp = 0.7152;
const gammaProp = 2.4;
const hexDivisor = 65535.0;

class FnColor {
  late double r;
  late double g;
  late double b;

  FnColor(this.r, this.g, this.b)
      : assert(r <= 1.0 &&
            r >= 0.0 &&
            g <= 1.0 &&
            g >= 0.0 &&
            b <= 1.0 &&
            b >= 0.0);

  FnColor.fromIntList(List<int> intColor) {
    assert(intColor.length == 3);
    assert(intColor[0] <= 0xffff &&
        intColor[0] >= 0 &&
        intColor[1] <= 0xffff &&
        intColor[1] >= 0 &&
        intColor[2] <= 0xffff &&
        intColor[2] >= 0);

    r = intColor[0] / hexDivisor;
    g = intColor[1] / hexDivisor;
    b = intColor[2] / hexDivisor;
  }

  List<int> toIntList() {
    return [
      (r * hexDivisor).round().toInt(),
      (g * hexDivisor).round().toInt(),
      (b * hexDivisor).round().toInt()
    ];
  }

  double get luminance {
    var a = [r, g, b].map((v) {
      return v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, gammaProp);
    }).toList();
    return a[0] * redProp + a[1] * greenProp + a[2] * blueProp;
  }

  double getContrastRatio(FnColor color) {
    var lum1 = luminance;
    var lum2 = color.luminance;
    var brightest = max(lum1, lum2);
    var darkest = min(lum1, lum2);
    return (brightest + 0.05) / (darkest + 0.05);
  }

  @override
  String toString() {
    return 'r: $r, g: $g, b: $b';
  }

  FnColor reverse() {
    List<int> intColor = [
      (r * hexDivisor).round(),
      (g * hexDivisor).round(),
      (b * hexDivisor).round()
    ].map((e) => 0xffff & ~(e.toInt())).toList();
    return FnColor.fromIntList(intColor);
  }

  FnColor shade(double factor) {
    assert(factor > 0.0 && factor <= 1.0);
    List<int> intColor = [
      (r * hexDivisor).round(),
      (g * hexDivisor).round(),
      (b * hexDivisor).round()
    ].map((e) => (e * factor).round().toInt()).toList();
    return FnColor.fromIntList(intColor);
  }

  FnColor tint(double factor) {
    assert(factor > 0.0 && factor <= 1.0);
    List<int> intColor = [
      (r * hexDivisor).round().toInt(),
      (g * hexDivisor).round().toInt(),
      (b * hexDivisor).round().toInt()
    ].map((e) => (e + (factor * (1.0 - e))).round().toInt()).toList();
    return FnColor.fromIntList(intColor);
  }
}
