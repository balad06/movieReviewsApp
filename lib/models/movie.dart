import 'package:hive/hive.dart';
part 'movie.g.dart';
@HiveType(typeId: 1)
class Movie {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String movieName;
  @HiveField(2)
  final String movieDirect;
  @HiveField(3)
  final String posterUrl;
  @HiveField(4)
  final String uID;
  Movie(
      {required this.id,
      required this.movieName,
      required this.movieDirect,
      this.posterUrl = '',
      required this.uID,
      });
}
