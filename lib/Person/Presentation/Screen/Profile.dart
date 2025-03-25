// ignore_for_file: must_be_immutable

// ignore: unused_import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Components/AleartDiaglog.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Authentication/Domains/Entity/User.dart';

class Profile extends StatefulWidget {
  UserApp? userInformation;

  Profile({super.key, this.userInformation});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<String>? listImage;

  void viewAllPhoto() {
    showDialog(
        context: context, builder: (c) => const dialog(text: 'Not update yet'));
  }
  // void tapToChat(){
  //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>ChatScreen()));
  // }

  Future<List<String>?> getPhotoFromStorage(String currentUserID) async {
    final listImageOfAvatar = await Supabase.instance.client.storage
        .from('avatar')
        .list(path: '$currentUserID/');
    final listImageOfPost = await Supabase.instance.client.storage
        .from('post')
        .list(path: '$currentUserID/');
    final List<String> convertListOfAvavtar = listImageOfAvatar
        .map((e) => Supabase.instance.client.storage
            .from('avatar')
            .getPublicUrl('$currentUserID/${e.name}'))
        .toList();
    final List<String> convertListOfPost = listImageOfPost
        .map((e) => Supabase.instance.client.storage
            .from('post')
            .getPublicUrl('$currentUserID/${e.name}'))
        .toList();
    final List<String> list = convertListOfPost + convertListOfAvavtar;
    if (list.isEmpty) return null;
    return list;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            size: 30,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        title: Text('User Profile',
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.surface,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Avatar , name and other name
            Container(
              height: size.height * 0.2,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Avatar(
                    height_width: 0.25,
                    user: widget.userInformation!,
                  ),
                  Text(
                    widget.userInformation!.userName,
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    widget.userInformation!.otherName ?? '....',
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            //Action
            Center(
              child: SizedBox(
                width: size.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _itemAction(Icons.messenger_outline, null),
                    _itemAction(Icons.videocam_outlined, null),
                    _itemAction(Icons.call_outlined, null),
                    _itemAction(Icons.more_horiz, null),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              thickness: 1,
            ),
            // Information
            _itemInfor('Display Name', widget.userInformation!.userName),
            _itemInfor('Email address', widget.userInformation!.email),
            _itemInfor('Address', widget.userInformation!.address!),
            _itemInfor('Phone number', widget.userInformation!.phoneNumber!),
            const SizedBox(
              height: 20,
            ),
            // Photos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Photos',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface)),
                  GestureDetector(
                    onTap: viewAllPhoto,
                    child: Text('View All',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 10.0),
                child: FutureBuilder(
                    future: getPhotoFromStorage(widget.userInformation!.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Lỗi: ${snapshot.error}"));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text("Không có ảnh nào"));
                      }
                      final List<String> listImage = snapshot.data!;
                      return Row(
                        mainAxisAlignment: listImage.length <= 2
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.spaceEvenly,
                        children: [
                          if (listImage.length <= 3) ...[
                            for (int i = 0; i < listImage.length; i++)
                              _itemPhoto(listImage[i]),
                          ] else ...[
                            _itemPhoto(listImage[0]),
                            _itemPhoto(listImage[1]),
                            Stack(
                              children: [
                                _itemPhoto(listImage[2]),
                                GestureDetector(
                                  onTap: viewAllPhoto,
                                  child: Container(
                                    height: MediaQuery.of(context).size.width *
                                        0.26,
                                    width: MediaQuery.of(context).size.width *
                                        0.26,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: Text('+${listImage.length - 2}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ]
                        ],
                      );
                    }))
          ],
        ),
      ),
    );
  }

  Widget _itemAction(IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: MediaQuery.of(context).size.width * 0.10,
        width: MediaQuery.of(context).size.width * 0.10,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _itemInfor(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface)),
          Text(content,
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _itemPhoto(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.26,
        width: MediaQuery.of(context).size.width * 0.26,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: CacheImage(
            imageUrl: imageUrl, widthPlachoder: 0.26, heightPlachoder: 0.26),
      ),
    );
  }
}
