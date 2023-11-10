import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_restful2/model/user_model.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScrollController scrollController = ScrollController();
  bool isLoadingMore = false;
  List<UsersModelData?> users = [];
  int? page = 1;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
    fetchUsers().then(
      (value) {
        if (value != null && value.data != null) {
          setState(() {
            users = users + value.data!;
            //veriKaydi();
            //debugPrint(users.toString());
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Material App",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Material App Bar"),
          //actions: [IconButton(onPressed: , icon: const Icon(Icons.leave_bags_at_home))],
        ),
        body: ListView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.all(12.0),
          controller: scrollController,
          itemCount: isLoadingMore ? users.length + 1 : users.length,
          itemBuilder: (context, index) {
            if (index < users.length) {
              return Card(
                margin: EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(
                      "${users[index]!.firstName! + users[index]!.lastName!}"),
                  subtitle: Text(users[index]!.email ?? ""),
                  leading: CachedNetworkImage(
                    imageUrl: users[index]!.avatar ?? "",
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                  //     CircleAvatar(
                  //   backgroundImage: NetworkImage(users[index]!.avatar ?? ""),
                  // ),

                  trailing: IconButton(
                      onPressed: () => DefaultCacheManager()
                          .removeFile(users[index]!.avatar ?? ""),
                      icon: const Icon(Icons.leave_bags_at_home)),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  Future<UsersModel?> fetchUsers() async {
    String? url = "https://reqres.in/api/users?page=$page";
    print("$url");
    var res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      var jsonBody = UsersModel.fromJson(jsonDecode(res.body));
      return jsonBody;
    } else {
      print("İstek başarısız oldu => ${res.statusCode}");
    }
    //editor ekletti alttakini
    return null;
  }

  Future<void> _scrollListener() async {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      setState(() {
        isLoadingMore = true;
      });
      page = (page! + 1);
      await fetchUsers().then(
        (value) {
          if (value != null && value.data != null) {
            setState(() {
              users = users + value.data!;
              //veriKaydi();
              //debugPrint(users.toString());
              isLoadingMore = false;
            });
          }
        },
      );
    }
  }

  /*
  Future<void> veriKaydi() async {
    var sp = await SharedPreferences.getInstance();

    for (var a in users) {
      sp.setInt("id", a!.id ?? 1);
      sp.setString("email", a.email ?? "");
      sp.setString("firstname", a.firstName ?? "");
      sp.setString("lastname", a.lastName ?? "");
    }
  }

  Future<void> veriOku() async {
    //veri okuma kısmı, sil ve guncelle kısmı eğer baska bir yere veri cekeceksek işimize yarar yoksa bu sayfada kullanılmıyacak
    var sp = await SharedPreferences.getInstance();

    int? id = sp.getInt("id") ?? 99;
    String? email = sp.getString("email") ?? "email yok";
    String? firstname = sp.getString("firstname") ?? "firstname yok";
    String? lastname = sp.getString("lastname") ?? "lastname yok";
  }

  Future<void> veriSil() async {
    var sp = await SharedPreferences.getInstance();

    sp.remove("id");
  }

  Future<void> veriGuncelle() async {
    var sp = await SharedPreferences.getInstance();

    sp.setInt("id",45566);
  }
  */
}
