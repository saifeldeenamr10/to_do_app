import 'package:flutter/material.dart';

class AddTaskImage extends StatelessWidget {
  const AddTaskImage({super.key, required this.image, this.onTap});
  final Image image;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 250,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(borderRadius: BorderRadius.circular(20), child: image),
      ),
    );
  }
}
