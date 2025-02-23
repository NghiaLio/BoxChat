// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double height_width;
  BoxBorder? border;
  UserApp? user;
  Avatar({super.key, required this.height_width, this.user, this.border});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.width * height_width,
      width: size.width * height_width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, border: border),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: user!.avatarUrl!.isEmpty
            ? const Image(
                image: AssetImage('assets/images/person.jpg'),
                fit: BoxFit.fill,
              )
            : CacheImage(
                imageUrl: user!.avatarUrl!,
                widthPlachoder: height_width,
                heightPlachoder: height_width),
      ),
    );
  }
}

class CacheImage extends StatelessWidget {
  String imageUrl;
  double widthPlachoder;
  double heightPlachoder;
  CacheImage(
      {super.key,
      required this.imageUrl,
      required this.widthPlachoder,
      required this.heightPlachoder});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
              height: MediaQuery.of(context).size.width * heightPlachoder,
              width: MediaQuery.of(context).size.width * widthPlachoder,
              color: Colors.grey,
              child: const Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
        imageUrl: imageUrl);
  }
}
