import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Components/CircleProgressIndicator.dart';
import 'package:chat_app/Components/DisplayImage.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chat_app/Components/timePost.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/likes.dart';
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialCubits.dart';
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialState.dart';
import 'package:chat_app/SocialMedia/Presentation/Screen/CreatePostScreen.dart';
import 'package:chat_app/SocialMedia/Presentation/Screen/SearchSocial.dart';
import 'package:chat_app/SocialMedia/Presentation/Screen/commentScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readmore/readmore.dart';

import '../../../Components/Avatar.dart';
import '../../Domain/Entities/post.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  UserApp? currentUser;

  void openSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => Searchsocial()));
  }

  void selectImage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Createpostscreen(
                  currentUser: currentUser,
                  isShowPickedImage: true,
                )));
  }

  void openCreatePostScreen() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Createpostscreen(
                  currentUser: currentUser,
                  isShowPickedImage: false,
                )));
  }

  bool checkLike(List<Likes> listLike) {
    return listLike.any((like) => like.user_id == currentUser!.id);
  }

  void toggleLike(Posts post) async {
    // to smoth ui
    final bool isLiked = checkLike(post.listLikes!);
    //set like
    setState(() {
      if (isLiked) {
        post.listLikes!.removeWhere((likes) => likes.post_id == post.id!);
      } else {
        post.listLikes!.add(Likes(post_id: post.id!, user_id: currentUser!.id));
      }
    });

    await context
        .read<Socialcubits>()
        .toggleLikePost(post.id!, currentUser!.id)
        .catchError((onError) {
      //restore like
      setState(() {
        if (isLiked) {
          post.listLikes!
              .add(Likes(post_id: post.id!, user_id: currentUser!.id));
        } else {
          post.listLikes!.removeWhere((likes) => likes.post_id == post.id!);
        }
      });
    });
  }

  void showComment(Posts post) {
    showModalBottomSheet(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Commentscreen(
              listComments: post.listComments!,
              postID: post.id!,
              currentUser: currentUser,
              numFavor: post.listLikes!.length,
            ));
  }

  void openImage(String imageUrl, String user_id, String user_name) {
    final UserApp user = UserApp(id: user_id, userName: user_name, email: '');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => DisplayImage(
                  urlImage: imageUrl,
                  userOfImage: user,
                )));
  }

  @override
  void initState() {
    currentUser = context.read<AuthCubit>().userData;
    context.read<Socialcubits>().getAllPost(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          //Appbar
          _appBar(),
          //body
          Expanded(
              child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _postBar(),
              ),
              _displayPost()
            ],
          )),
          // Expanded(child: )
        ],
      ),
    );
  }

  Widget _appBar() {
    return GestureDetector(
      onTap: openSearch,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        color: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.only(top: 40, left: 20),
        child: Row(
          children: [
            //Search Icon
            Icon(
              Icons.search,
              size: 30,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(
              width: 20,
            ),
            //Text Search
            Text(
              'Search',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primaryContainer),
            )
          ],
        ),
      ),
    );
  }

  Widget _postBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1 - 10,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      child: Column(
        children: [
          Row(
            children: [
              Avatar(
                height_width: 0.13,
                user: currentUser,
              ),
              const SizedBox(
                width: 15,
              ),
              GestureDetector(
                onTap: openCreatePostScreen,
                child: Text(
                  'How are you today?',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              const Spacer(),
              IconButton(
                  onPressed: selectImage,
                  icon: Icon(
                    Icons.image_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ))
            ],
          )
        ],
      ),
    );
  }

  Widget _displayPost() {
    return BlocConsumer<Socialcubits, Socialstate>(
        builder: (context, state) {
          print(state);
          if (state is loadedPost) {
            List<Posts> listPost = state.listPost ?? [];
            return SliverList(
                delegate: SliverChildBuilderDelegate(
                    childCount: listPost.length,
                    (context, index) => _itemPost(listPost[index])));
          } else {
            return SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                child:  Loading(height_width: MediaQuery.of(context).size.width*0.1, color:Theme.of(context).colorScheme.primary ),
              ),
            );
          }
        },
        listener: (context, state) {});
  }

  Widget _itemPost(Posts post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 5,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Avatar
              Row(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.15,
                    width: MediaQuery.of(context).size.width * 0.15,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: post.image_user_url.isEmpty
                        ? const Image(
                            image: AssetImage('assets/images/person.jpg'),
                            fit: BoxFit.cover,
                          )
                        : CacheImage(
                            imageUrl: post.image_user_url,
                            widthPlachoder: 0.15,
                            heightPlachoder: 0.15),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //name
                      Text(
                        post.user_name,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.surface),
                      ),
                      //time
                      Text(
                        Timepost.timeBefore(post.created_at!),
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // PopupMenuButton(
                  //     color: Theme.of(context).scaffoldBackgroundColor,
                  //     padding: EdgeInsets.zero,
                  //     shape: const RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  //     icon: Icon(
                  //       Icons.more_horiz,
                  //       size: 30,
                  //       color: Theme.of(context).colorScheme.onSurface,
                  //     ),
                  //     itemBuilder: (context) => [
                  //           PopupMenuItem(
                  //               value: 'del',
                  //               child: Text(
                  //                 'Delete',
                  //                 style: TextStyle(
                  //                     color:
                  //                         Theme.of(context).colorScheme.surface),
                  //               )),
                  //           PopupMenuItem(
                  //               value: 'edit',
                  //               child: Text('Edit',
                  //                   style: TextStyle(
                  //                       color: Theme.of(context)
                  //                           .colorScheme
                  //                           .surface))),
                  //         ]
                  //     )
                  IconButton(
                      onPressed: () => showSnackBar.show_error(
                          'Funtion not upgrade yet', context),
                      icon: Icon(
                        Icons.more_horiz,
                        size: 30,
                        color: Theme.of(context).colorScheme.onSurface,
                      ))
                ],
              ),
              //content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ReadMoreText(
                  post.content,
                  trimMode: TrimMode.Line,
                  trimLines: 5,
                  trimCollapsedText: 'show more',
                  trimExpandedText: '__show less',
                  moreStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface),
                  lessStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface),
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.surface),
                ),
              ),
              //Image
              post.post_image_url.isNotEmpty
                  ? GestureDetector(
                      onTap: () => openImage(
                          post.post_image_url, post.user_id, post.user_name),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: post.post_image_url,
                          maxHeightDiskCache: 300,
                        ),
                      ),
                    )
                  : Container(),
              //Like, comment
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.08,
                  child: Row(
                    children: [
                      //like
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.15),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 10.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => toggleLike(post),
                              child: Row(
                                children: [
                                  Icon(
                                    checkLike(post.listLikes!)
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 21,
                                    color: checkLike(post.listLikes!)
                                        ? Colors.redAccent
                                        : Theme.of(context).colorScheme.surface,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Like',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: checkLike(post.listLikes!)
                                            ? Colors.redAccent
                                            : Theme.of(context)
                                                .colorScheme
                                                .surface),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                width: 0.5,
                                height: 20,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 21,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  post.listLikes!.length.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      //comment
                      GestureDetector(
                        onTap: () => showComment(post),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.15),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Icon(
                            Icons.message_outlined,
                            size: 24,
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.8),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
