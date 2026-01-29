import 'package:flutter/material.dart';

class MainImage extends StatelessWidget {
  const MainImage({super.key, required this.image, this.onTap});
  final Image image;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 300,
        width: double.infinity,

        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: image,
      ),
    );
  }
}
