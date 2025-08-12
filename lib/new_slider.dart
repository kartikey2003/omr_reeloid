import 'package:flutter/material.dart';

class MovieSlider extends StatelessWidget {
  final String title;
  final List<MovieItem> movies;

  const MovieSlider({
    super.key,
    required this.title,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Movie List
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: movies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final MovieItem movie;

  const MovieCard({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Movie Poster Image
                    movie.imageUrl.isNotEmpty
                        ? Image.network(
                      movie.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderPoster();
                      },
                    )
                        : _buildPlaceholderPoster(),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Movie Info Overlay
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                movie.year.toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: movie.rating >= 8.0
                                      ? Colors.green
                                      : movie.rating >= 7.0
                                      ? Colors.orange
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  movie.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie,
            color: Colors.grey[600],
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class MovieItem {
  final String title;
  final String imageUrl;
  final int year;
  final double rating;
  final List<String> genres;

  MovieItem({
    required this.title,
    required this.imageUrl,
    required this.year,
    required this.rating,
    this.genres = const [],
  });
}

// Example usage widget
class NetflixStyleHomePage extends StatelessWidget {
  const NetflixStyleHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'MovieFlix',
          style: TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MovieSlider(
              title: 'Trending Now',
              movies: _getTrendingMovies(),
            ),
            MovieSlider(
              title: 'Action & Adventure',
              movies: _getActionMovies(),
            ),
            MovieSlider(
              title: 'Comedies',
              movies: _getComedyMovies(),
            ),
            MovieSlider(
              title: 'Recently Added',
              movies: _getRecentMovies(),
            ),
          ],
        ),
      ),
    );
  }

  List<MovieItem> _getTrendingMovies() {
    return [
      MovieItem(
        title: 'Berlin 2024',
        imageUrl: 'https://via.placeholder.com/300x400/ff6b6b/ffffff?text=Berlin+2024',
        year: 2024,
        rating: 8.2,
        genres: ['Action', 'Crime', 'Drama'],
      ),
      MovieItem(
        title: 'Money Heist',
        imageUrl: 'https://via.placeholder.com/300x400/4ecdc4/ffffff?text=Money+Heist',
        year: 2023,
        rating: 9.1,
        genres: ['Crime', 'Drama'],
      ),
      MovieItem(
        title: 'Stranger Things',
        imageUrl: 'https://via.placeholder.com/300x400/45b7d1/ffffff?text=Stranger+Things',
        year: 2024,
        rating: 8.7,
        genres: ['Sci-Fi', 'Horror'],
      ),
      MovieItem(
        title: 'The Crown',
        imageUrl: 'https://via.placeholder.com/300x400/f9ca24/ffffff?text=The+Crown',
        year: 2023,
        rating: 8.9,
        genres: ['Drama', 'History'],
      ),
      MovieItem(
        title: 'Ozark',
        imageUrl: 'https://via.placeholder.com/300x400/6c5ce7/ffffff?text=Ozark',
        year: 2024,
        rating: 8.4,
        genres: ['Crime', 'Drama'],
      ),
    ];
  }

  List<MovieItem> _getActionMovies() {
    return [
      MovieItem(
        title: 'John Wick 4',
        imageUrl: 'https://via.placeholder.com/300x400/2d3436/ffffff?text=John+Wick+4',
        year: 2023,
        rating: 8.8,
        genres: ['Action'],
      ),
      MovieItem(
        title: 'Fast X',
        imageUrl: 'https://via.placeholder.com/300x400/00b894/ffffff?text=Fast+X',
        year: 2023,
        rating: 7.2,
        genres: ['Action'],
      ),
      MovieItem(
        title: 'Extraction 2',
        imageUrl: 'https://via.placeholder.com/300x400/e17055/ffffff?text=Extraction+2',
        year: 2023,
        rating: 7.9,
        genres: ['Action'],
      ),
      MovieItem(
        title: 'The Gray Man',
        imageUrl: 'https://via.placeholder.com/300x400/636e72/ffffff?text=The+Gray+Man',
        year: 2022,
        rating: 6.8,
        genres: ['Action', 'Thriller'],
      ),
    ];
  }

  List<MovieItem> _getComedyMovies() {
    return [
      MovieItem(
        title: 'Red Notice',
        imageUrl: 'https://via.placeholder.com/300x400/fd79a8/ffffff?text=Red+Notice',
        year: 2021,
        rating: 6.4,
        genres: ['Comedy', 'Action'],
      ),
      MovieItem(
        title: 'Murder Mystery',
        imageUrl: 'https://via.placeholder.com/300x400/fdcb6e/ffffff?text=Murder+Mystery',
        year: 2023,
        rating: 6.7,
        genres: ['Comedy', 'Mystery'],
      ),
      MovieItem(
        title: 'Glass Onion',
        imageUrl: 'https://via.placeholder.com/300x400/74b9ff/ffffff?text=Glass+Onion',
        year: 2022,
        rating: 7.5,
        genres: ['Comedy', 'Mystery'],
      ),
    ];
  }

  List<MovieItem> _getRecentMovies() {
    return [
      MovieItem(
        title: 'Wednesday',
        imageUrl: 'https://via.placeholder.com/300x400/2d3436/ffffff?text=Wednesday',
        year: 2024,
        rating: 8.3,
        genres: ['Comedy', 'Horror'],
      ),
      MovieItem(
        title: 'The Witcher',
        imageUrl: 'https://via.placeholder.com/300x400/a29bfe/ffffff?text=The+Witcher',
        year: 2024,
        rating: 8.1,
        genres: ['Fantasy', 'Action'],
      ),
      MovieItem(
        title: 'Squid Game',
        imageUrl: 'https://via.placeholder.com/300x400/fd79a8/ffffff?text=Squid+Game',
        year: 2023,
        rating: 9.2,
        genres: ['Thriller', 'Drama'],
      ),
    ];
  }
}

// Main app
class MovieApp extends StatelessWidget {
  const MovieApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Netflix Style Movie Slider',
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const NetflixStyleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(const MovieApp());
}