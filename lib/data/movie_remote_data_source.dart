import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:showtime/common/api_client.dart';
import 'package:showtime/common/api_constants.dart';
import 'package:showtime/data/movie_model.dart';
import 'package:showtime/data/moviesTrendingModel.dart';
import 'package:showtime/services/movieDetails.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>?> getTrending(String? languageString);
  Future<List<MovieModel>?> getMoviesByPath(String path);
  Future<List<MovieModel>?> getPopular(String? languageString);
  Future<List<MovieModel>?> getNowPlaying(String? languageString);
  Future<String?> getDirectorName(int movieId, bool isTV);
  Future<Movie> getMovieDetailsById(int id);
  Future<Movie> getTVDetailsById(int id);
  dynamic getSearchResult(String searchString);
  Future<List<Map<String, dynamic>>?> fetchMovieCrew(int movieId, bool isTV);
  Future<List<Map<String, dynamic>>?> fetchMovieCast(int movieId, bool isTV);
  Future<List<MovieModel>?> getMoviesByGenre(
      int genreId, String? languageString);
  Future<List<MovieModel>?> getMoviesByOTT(
      int ottId, int page_no, String? languageString);
  Future<List<MovieModel>?> getMoviesByNetwork(String path, int networkId);

  Future<Map<String, dynamic>> getPersonDetails(num personId);
}

class MovieRemoteDataSourceImpl extends MovieRemoteDataSource {
  final ApiClient client;

  MovieRemoteDataSourceImpl(this.client);

  @override
  Future<List<Map<String, dynamic>>?> fetchMovieCast(
      int movieId, bool isTV) async {
    String tvOrNot = isTV == true ? 'tv' : 'movie';
    final url =
        'https://api.themoviedb.org/3/$tvOrNot/$movieId/credits?api_key=${APIConstants.API_KEY}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cast = data['cast'];
        return List<Map<String, dynamic>>.from(cast);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }

  @override
  Future<List<Map<String, dynamic>>?> fetchMovieCrew(
      int movieId, bool isTV) async {
    String tvOrNot = isTV == true ? 'tv' : 'movie';
    final url =
        'https://api.themoviedb.org/3/$tvOrNot/$movieId/credits?api_key=${APIConstants.API_KEY}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final crew = data['crew'];
        return List<Map<String, dynamic>>.from(crew);
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }

  @override
  Future<List<MovieModel>?> getTrending(String? languageString) async {
    final response = await client
        .getSpecial('tv/popular?with_original_language=$languageString');

    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  Future<List<MovieModel>?> getPopular(String? languageString) async {
    final response = await client
        .getSpecial('movie/popular?with_original_language=$languageString');
    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  Future<List<MovieModel>?> getNowPlaying(String? languageString) async {
    final response = await client
        .getSpecial('movie/now_playing?with_original_language=$languageString');
    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  dynamic getSearchResult(String searchString) async {
    final arr = [];
    String searchWithSpaces = searchString.replaceAll(' ', '%20');
    final response = await http.get(
        Uri.parse(
            'https://api.themoviedb.org/3/search/multi?query=$searchWithSpaces&include_adult=false&language=en-US&page=1&api_key=7c5fb9c2eb6e1184d03ee3c68a959a1f'),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      //final movies = MoviesTrending.fromJson(res).results;
      print("RES(json): $res");
      final title = jsonDecode(response.body)['results'][0]['title'];
      final posterURL = jsonDecode(response.body)['results'][0]['poster_path'];
      arr.add(title);
      arr.add(posterURL);
      print(
          "FIRST MOVIE : ${jsonDecode(response.body)['results'][0]['original_title']}");
      print("results : ${jsonDecode(response.body)['results']}");

      return arr;
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  @override
  Future<List<MovieModel>?> getMoviesByGenre(
      int genreId, String? languageString) async {
    // TODO: implement getMoviesByGenre
    final response = await client.getSpecial(
        '/discover/movie?with_genres=$genreId&with_original_language=$languageString');
    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  Future<List<MovieModel>?> getMoviesByPath(String path) async {
    // TODO: implement getMoviesByPath
    final response = await client.getSpecial(path);
    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  Future<List<MovieModel>?> getMoviesByNetwork(
      String path, int networkId) async {
    // TODO: implement getMoviesByNetwork
    final response = await client.getSpecial('$path&with_networks=$networkId');
    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  Future<Movie> getMovieDetailsById(int id) async {
    final response = await client.get('movie/$id');
    final movie = Movie.fromJson(response);
    return movie;
  }

  @override
  Future<Movie> getTVDetailsById(int id) async {
    final response = await client.get('tv/$id');
    final movie = Movie.fromJson(response);
    return movie;
  }

  @override
  Future<List<MovieModel>?> getMoviesByOTT(
      int ottId, int page_no, String? languageString) async {
    // TODO: implement getMoviesByOTT
    final response = await client.getSpecial(
        '/discover/movie?include_adult=false&include_video=false&language=en-US&page=$page_no&watch_region=IN&with_original_language=$languageString&with_watch_providers=$ottId');
    final movies = MoviesTrending.fromJson(response).results;
    return movies;
  }

  @override
  Future<String?> getDirectorName(int movieId, bool isTV) async {
    String tvOrNot = isTV == true ? 'tv' : 'movie';
    final url = isTV == true
        ? 'https://api.themoviedb.org/3/$tvOrNot/$movieId?api_key=${APIConstants.API_KEY}'
        : 'https://api.themoviedb.org/3/$tvOrNot/$movieId/credits?api_key=${APIConstants.API_KEY}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (isTV) {
          final createdBy = data['created_by'] as List<dynamic>;
          if (createdBy.isNotEmpty) {
            final director = createdBy[0]['name'];
            return director;
          }
        } else {
          final crew = data['crew'];
          final director = crew.firstWhere(
              (person) => person['job'] == 'Director',
              orElse: () => null);
          if (director != null) {
            return director['name'];
          }
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }

    return null;
  }

  @override
  Future<Map<String, dynamic>> getPersonDetails(num personId) async {
    // TODO: implement getPersonDetails
    final url =
        'https://api.themoviedb.org/3/person/$personId?api_key=${APIConstants.API_KEY}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return data;
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }

    return {};
  }
}
