import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myanimepal/statuses.dart';
import 'package:search_widget/search_widget.dart';
import 'DescriptionPage.dart';
import 'statuses.dart';

class PersonalPage extends StatefulWidget {
  FirebaseUser user;
  List<DocumentSnapshot> animeData, mangaData, aniMangaData;
  PersonalPage({@required this.user});

  @override
  PersonalPageState createState() => PersonalPageState();
}

class PersonalPageState extends State<PersonalPage> {
  DocumentSnapshot selectedItem;
  bool animes = true;

  void refresh() {
    setState(() {});
  }

  void setupStatus(Function refresh) async {
    widget.animeData = await getAnimeListUser(widget.user.displayName);
    widget.mangaData = await getMangaListUser(widget.user.displayName);
    if (widget.animeData != null || widget.mangaData != null) {
      widget.aniMangaData = widget.animeData + widget.mangaData;
    }
    refresh();
  }

  @override
  void initState() {
    setupStatus(refresh);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Viewing " +
              widget.user.displayName +
              "'s MyAnimePal", // TODO: Show this in the user list, not here
          style: TextStyle(color: Colors.black, fontSize: 15),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Image.network(
              "https://firebasestorage.googleapis.com/v0/b/myanimepal.appspot.com/o/MyAnimePalLogo.png?alt=media&token=57926b6e-1808-43c8-9d99-e4b5572ef93e")
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              child: Text(
                "Profile Page",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
          ),
          searchBar(),
          SizedBox(height: 10),
          toggleAniMangaViewButton(),
          SizedBox(height: 10),
          (animes) ? animangaList("animes") : animangaList("mangas"),
        ],
      ),
    );
  }

  searchBar() {
    if (widget.animeData != null &&
        widget.mangaData != null &&
        widget.aniMangaData != null) {
      return SearchWidget<DocumentSnapshot>(
          dataList: widget.aniMangaData,
          listContainerHeight: MediaQuery.of(context).size.height / 4,
          queryBuilder: (query, list) {
            return list
                .where((item) =>
                    item.documentID.toLowerCase().contains(query.toLowerCase()))
                .toList();
          },
          popupListItemBuilder: (item) {
            return Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  item.documentID,
                  style: const TextStyle(fontSize: 16),
                ));
          },
          selectedItemBuilder: (item, deleteSelectedItem) {
            return Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  item.documentID,
                  style: const TextStyle(fontSize: 16),
                ));
          },

          // TODO: go to the anime specific page when clicked
          onItemSelected: (item) {
            setState(() {
              selectedItem = item;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DescriptionPage(user: widget.user, aniManga: item)));
            });
          });
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }

  toggleAniMangaViewButton() {
    return Container(
      height: 70.0,
      width: 70.0,
      child: FittedBox(
        child: FloatingActionButton(
          splashColor: Colors.cyan,
          child: Text(
            "Anime/Manga",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              animes = !animes;
            });
          },
        ),
      ),
    );
  }

  animangaList(String list) {
    if ((animes && widget.animeData != null) ||
        (!animes && widget.mangaData != null)) {
      return StreamBuilder(
        stream: Firestore.instance.collection(list).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Flexible(
            // TODO: this is just a test. display only X ammunt of animes and mangas,
            // separe them, add a button to see the  anime/ manga page
            child: GridView.builder(
              itemCount: (list == "animes")
                  ? widget.animeData.length
                  : widget.mangaData.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                DocumentSnapshot doc = (list == "animes")
                    ? widget.animeData[index]
                    : widget.mangaData[index];
                Map<String, dynamic> data = doc.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                   // SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 8),
                      child: InkWell(
                        child: Container(
                          width: 100,
                          height: 166,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(data["ImagePath"]),
                            ),
                          ),
                        ),
                        onDoubleTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => DescriptionPage(
                                  user: widget.user, aniManga: doc)));
                          //Open the second page with this meal
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        doc.documentID,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                  ],
                );
              },
            ),
          );
        },
      );
    } else {
      return Container(
        width: 0,
        height: 0,
      );
    }
  }
}
