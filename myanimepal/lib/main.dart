import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';

_loadAnimeData() async {
  QuerySnapshot animesSnapshot =
      await Firestore.instance.collection("animes").getDocuments();
  return animesSnapshot.documents;
}

_loadMangaData() async {
  QuerySnapshot mangasSnapshot =
      await Firestore.instance.collection("mangas").getDocuments();
  return mangasSnapshot.documents;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var animeData = await _loadAnimeData();
  var mangaData = await _loadMangaData();
  runApp(MyAnimePal(animeData: animeData, mangaData: mangaData));
}

class MyAnimePal extends StatelessWidget {
  List<DocumentSnapshot> animeData, mangaData;
  MyAnimePal({@required this.animeData, @required this.mangaData}) {
    // TODO: check the performance of this :) What about 1000+ animes and mangas ???
    // Why not adding them to the database already ordered by genre?? XDD
    animeData.sort((s1, s2) =>
        s1.data["Genre"].toString().compareTo(s2.data["Genre"].toString()));
    mangaData.sort((s1, s2) =>
        s1.data["Genre"].toString().compareTo(s2.data["Genre"].toString()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My Anime Pal',
        home: SingIn(animeData: animeData, mangaData: mangaData));
  }
}
