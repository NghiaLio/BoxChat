import 'package:chat_app/Config/Avatar.dart';
import 'package:flutter/material.dart';

import '../../../../Authentication/Domains/Entity/User.dart';

// ignore: must_be_immutable
class DisplayImage extends StatelessWidget {
  UserApp? userOfImage;
  String? urlImage;
  DisplayImage({super.key, this.urlImage, this.userOfImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              size: 28,
              color: Colors.white,
            )),
        title: Text(
          userOfImage!.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined,
                size: 30, color: Colors.white),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CacheImage(
                imageUrl: urlImage!,
                widthPlachoder: double.infinity,
                heightPlachoder: double.infinity),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 30,
                width: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'HD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_outlined,
                    size: 28, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
