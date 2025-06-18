import 'package:flutter/material.dart';

@immutable
class MintJadeColors extends ThemeExtension<MintJadeColors> {
  final Color appBarColor;
  final Color navBarColor;
  final Color selectedIconColor;
  final Color unselectedIconColor;
  final Color buttonColor;  // New property added

  const MintJadeColors({
    required this.appBarColor,
    required this.navBarColor,
    required this.selectedIconColor,
    required this.unselectedIconColor,
    required this.buttonColor,  // include in constructor
  });

  @override
  MintJadeColors copyWith({
    Color? appBarColor,
    Color? navBarColor,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? buttonColor,  // add here
  }) {
    return MintJadeColors(
      appBarColor: appBarColor ?? this.appBarColor,
      navBarColor: navBarColor ?? this.navBarColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      buttonColor: buttonColor ?? this.buttonColor,  // copyWith
    );
  }

  @override
  MintJadeColors lerp(ThemeExtension<MintJadeColors>? other, double t) {
    if (other is! MintJadeColors) return this;
    return MintJadeColors(
      appBarColor: Color.lerp(appBarColor, other.appBarColor, t)!,
      navBarColor: Color.lerp(navBarColor, other.navBarColor, t)!,
      selectedIconColor: Color.lerp(selectedIconColor, other.selectedIconColor, t)!,
      unselectedIconColor: Color.lerp(unselectedIconColor, other.unselectedIconColor, t)!,
      buttonColor: Color.lerp(buttonColor, other.buttonColor, t)!,  // lerp for buttonColor
    );
  }
}
