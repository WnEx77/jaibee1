import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jaibee/core/theme/mint_jade_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final mintJade = Theme.of(context).extension<MintJadeColors>()!;

    return SafeArea(
      child: Container(
        height: preferredSize.height,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: mintJade.appBarColor.withOpacity(0.6), // semi-transparent
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: CupertinoNavigationBar(
          backgroundColor: Colors.transparent,
          border: null, // removes bottom border line
          middle: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          leading: showBackButton
              ? GestureDetector(
                  onTap: onBackPressed ?? () => Navigator.pop(context),
                  child: const Icon(CupertinoIcons.back, color: Colors.white),
                )
              : null,
          trailing: actions != null && actions!.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              : null,
        ),
      ),
    );
  }
}
