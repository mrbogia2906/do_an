import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    this.width = 50,
    this.height = 50,
    this.radius = 45,
    required this.imageUrl,
    super.key,
  });

  final double width;

  final double height;

  final String imageUrl;

  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            Container(),
        errorWidget: (context, url, error) => Container(),
      ),
    );
  }
}
