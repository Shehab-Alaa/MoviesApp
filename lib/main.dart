import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' show Client;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies App',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Movies App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<_Result> movies;
  MovieApiClient apiClient;


  @override
  void initState() {
    super.initState();

    movies = List<_Result>();
    apiClient = MovieApiClient();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body:FutureBuilder<ItemModel>(
            future: apiClient.fetchMovieList(),
            builder: (context , snapshot){
              if (snapshot.hasData) {
                 movies = snapshot.data._results;

                 return Padding(
                   padding: const EdgeInsets.all(4.0),
                   child: GridView.builder(
              itemCount: movies.length ,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:2 ,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 1.2),) ,
              itemBuilder: (BuildContext context ,int index) {

                return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context ,
                          MaterialPageRoute(builder: (context) => MovieDetails(movies.elementAt(index)))
                      );
                    } ,
                    child: Card(
                     elevation: 5,
                    child: Image.network("http://image.tmdb.org/t/p/w185" + movies.elementAt(index)._posterPath,
                    fit: BoxFit.fill,)
              )
                );

              }
              ),
                 );

              }else if (snapshot.hasError){
                return Center(
                 child: Text("Please Check Your Connection !!")
                );
              }

              return Center(
                 child : CircularProgressIndicator()
              );
            },
          ),

    );
  }
}


class ItemModel{
  int _page;
  int _totalResults;
  int _totalPages;
  List<_Result> _results = [];

  ItemModel(this._page, this._totalResults, this._totalPages, this._results);

   factory ItemModel.fromJSON(Map<String, dynamic> json) {
    print(json['results'].length);
    int page = json['page'];
    int totalPages = json['total_pages'];
    int totalResults = json['total_results'];
    List<_Result> results = [];

    for(int i=0; i< json['results'].length; i++) {
      _Result result = _Result(json['results'][i]);
      results.add(result);
    }

     return ItemModel(page , totalResults , totalPages , results);
  }

  List<_Result> get results => _results;

  int get totalPages => _totalPages;

  int get totalResults => _totalResults;

  int get page => _page;

}


class _Result {
  int _voteCount;
  int _id;
  bool _video;
  var _voteAverage;
  String _title;
  double _popularity;
  String _posterPath;
  String _originalLanguage;
  String _originalTitle;
  List<int> _genreIds = [];
  String _backdropPath;
  bool _adult;
  String _overview;
  String _releaseDate;

  _Result(result) {
    _voteCount = result['vote_count'];
    _id = result['id'];
    _video = result['video'];
    _voteAverage = result['vote_average'];
    _title = result['title'];
    _popularity = result['popularity'];
    _posterPath = result['poster_path'];
    _originalLanguage = result['original_language'];
    _originalTitle = result['original_title'];

    for(int i=0; i< result['genre_ids'].length; i++){
      _genreIds.add(result['genre_ids'][i]);
    }

    _backdropPath = result['backdrop_path'];
    _adult = result['adult'];
    _overview = result['overview'];
    _releaseDate = result['release_date'];
  }

  String get releasDate =>_releaseDate;

  String get overview => _overview;

  bool get adult => _adult;

  String get backdropPath => _backdropPath;

  List<int> get genreIds => _genreIds;

  String get originalTitle => _originalTitle;

  String get originalLanguage => _originalLanguage;

  String get posterPath => _posterPath;

  double get popularity => _popularity;

  String get title => _title;

  double get voteAverage => _voteAverage.toDouble();

  bool get video => _video;

  int get id => _id;

  int get voteCount => _voteCount;
}

class MovieApiClient
{
  Client client = Client();
  final _apiKey = "107ed75bf9e25ec06bfe9fd33d042579";
  final _baseURL = "http://api.themoviedb.org/3/movie";

  Future<ItemModel> fetchMovieList() async{
    final response = await client
        .get("$_baseURL/top_rated?api_key=$_apiKey");

    if(response.statusCode == 200){
      return ItemModel.fromJSON(json.decode(response.body));
    }
    else{
      throw Exception('failed to laod data');
    }
  }
}


class MovieDetails extends StatelessWidget
{
  _Result movie;

  MovieDetails(_Result movie){
    this.movie = movie;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(movie.title),
    ),
    body: SingleChildScrollView(
          child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[

      Image.network("http://image.tmdb.org/t/p/w1280" + movie.backdropPath , fit: BoxFit.cover,) ,

      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            Image.network("http://image.tmdb.org/t/p/w185" + movie.posterPath) ,
            Column(
          children: <Widget>[
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Container(
                 child: FittedBox(
                   fit: BoxFit.fitWidth,
                   child: Text(movie.originalTitle , style: TextStyle(color: Colors.blueGrey , fontSize: 15),)
                 )
                 ),
               ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("Release Date: " + movie.releasDate),
            ) ,
            Row( children: <Widget>[
              Text(movie.voteAverage.toString()) ,
              Icon(Icons.star , color: Colors.yellow,)
            ],
            )

          ],
            )

          ],
        ),
      ) ,
      Text("Overview" , style: TextStyle(color: Colors.blue , fontSize: 20),) ,
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(movie.overview , style: TextStyle(fontSize: 15),),
      )
    ],
    ),
    )
    );
 }
}