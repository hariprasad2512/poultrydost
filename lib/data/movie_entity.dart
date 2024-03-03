import 'package:http/http.dart';

class MovieEntity {
  late final String posterPath;
  late final int id;
  late final String title;
  late final num voteAverage;
  late final String releaseDate;
  late final String overview;

  MovieEntity(
      {required id,
      required title,
      required posterPath,
      required voteAverage,
      required releaseDate,
      required overview});

  List<Object> get props => [id, title, posterPath];

  bool get stringify => true;

  @override
  String toString() => props.toString();
}
