import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather News',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  final LocalStorageService _localStorageService = LocalStorageService();
  final NewsService _newsService = NewsService();
  List<Article> _favoriteArticles = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  _loadFavorites() async {
    _favoriteArticles = await _localStorageService.getFavoriteArticles();
    setState(() {});
  }

  // Function to fetch news based on a specific topic (carbon dioxide, global warming, or user input topic)
  Future<void> searchNews(String topic, String apiKey) async {
    final url =
        'https://newsapi.org/v2/everything?q=${Uri.encodeComponent(topic)}&language=en&sortBy=publishedAt&apiKey=$apiKey';


    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Navigate to the ResultsScreen and pass the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            response: response.body,
            localStorageService: _localStorageService,
            favoriteArticles: _favoriteArticles,
          ),
        ),
      );
    }

  }
// Function to fetch carbon dioxide and global warming related news
  Future<void> fetchCarbonDioxideNews() async {
    final apiKey = 'a5389dbeb02f4290b04432bdf372d38a'; // Replace with your API key
    final url =
        'https://newsapi.org/v2/everything?q=carbon%20dioxide%20global%20warming&language=en&sortBy=publishedAt&apiKey=$apiKey';


    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Navigate to the ResultsScreen and pass the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(response: response.body,
            localStorageService: _localStorageService,
            favoriteArticles: _favoriteArticles,),
        ),
      );

    }
  }

  // Disaster-related actions
  Future<void> fetchDisasterNews(String query) async {
    final apiKey = 'a5389dbeb02f4290b04432bdf372d38a'; // Replace with your API key
    final url =
        'https://newsapi.org/v2/everything?q=$query&language=en&sortBy=publishedAt&apiKey=$apiKey';


    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Navigate to the ResultsScreen and pass the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(response: response.body,
            localStorageService: _localStorageService,
            favoriteArticles: _favoriteArticles,),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Input and button for searching carbon dioxide & global warming related news
            TextField(
              controller: _controller1,
              decoration: InputDecoration(
                labelText: 'Enter a topic',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String topic = _controller1.text.isEmpty
                    ? 'carbon dioxide global warming'
                    : _controller1.text;
                searchNews(topic, 'a5389dbeb02f4290b04432bdf372d38a');  // API key for this search
              },
              child: Text('Search'),
            ),
            SizedBox(height: 32),

            // Input and button for searching user input related news
            TextField(
              controller: _controller2,
              decoration: InputDecoration(
                labelText: 'Enter topics',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                String topic = _controller2.text.isEmpty ? 'climate change' : _controller2.text;
                searchNews(topic, 'a5389dbeb02f4290b04432bdf372d38a');  // API key for this search
              },
              child: Text('Search'),
            ),
            SizedBox(height: 32),

            // Button for fetching carbon dioxide and global warming related news
            ElevatedButton(
              onPressed: fetchCarbonDioxideNews,  // Fetch carbon dioxide related news
              child: Text("Carbon Dioxide & Global Warming"),
            ),

            SizedBox(height: 32),

            // Section with disaster-related clickable texts
            Text('Disaster News:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                GestureDetector(
                  onTap: () => fetchDisasterNews('floods'),
                  child: Text(
                    'Floods',
                    style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
                GestureDetector(
                  onTap: () => fetchDisasterNews('storms'),
                  child: Text(
                    'Storms',
                    style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
                GestureDetector(
                  onTap: () => fetchDisasterNews('hurricanes'),
                  child: Text(
                    'Hurricanes',
                    style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// The ResultsScreen widget displays the search results
class ResultsScreen extends StatelessWidget {
  final String response;
  final LocalStorageService localStorageService;
  final List<Article> favoriteArticles;

  ResultsScreen({
    required this.response,
    required this.localStorageService,
    required this.favoriteArticles,
  });

  @override
  Widget build(BuildContext context) {
    var decodedResponse = json.decode(response);

    return Scaffold(
      appBar: AppBar(
        title: Text('Searched Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('articles')
            ? ListView.builder(
          itemCount: decodedResponse['articles'].length,
          itemBuilder: (context, index) {
            var articleJson = decodedResponse['articles'][index];
            Article article = Article.fromJson(articleJson);
            bool isFavorite = favoriteArticles.any((favorite) => favorite.title == article.title);

            return Dismissible(
              key: Key(article.title),
              onDismissed: (direction) {
                localStorageService.removeFavoriteArticle(article);
              },
              background: Container(color: Colors.red),
              child: ListTile(
                title: Text(article.title),
                subtitle: Text(article.description),
                trailing: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    // Update favorite status
                    if (isFavorite) {
                      favoriteArticles.remove(article);
                    } else {
                      favoriteArticles.add(article);
                    }
                    localStorageService.saveFavoriteArticles(favoriteArticles);
                  },
                ),
              ),
            );
          },
        )
            : SingleChildScrollView(
          child: Text(response),
        ),
      ),
    );
  }
}

// 1. NewsService class to fetch articles from NewsAPI
class NewsService {
  final String apiKey = 'a5389dbeb02f4290b04432bdf372d38a';  // Replace with your NewsAPI key

  // Fetch articles related to global warming
  Future<List<Article>> fetchArticles() async {
    final url = Uri.parse(
        'https://newsapi.org/v2/everything?q=global%20warming&apiKey=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Article> articles = (data['articles'] as List).map((articleJson) {
        return Article.fromJson(articleJson);
      }).toList();
      return articles;
    } else {
      throw Exception('Failed to load articles');
    }
  }
}

// 2. Article model
class Article {
  final String title;
  final String url;
  final String description;

  Article({required this.title, required this.url, required this.description});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'],
      url: json['url'],
      description: json['description'] ?? 'No description available',
    );
  }
}

// 3. LocalStorageService class to save, retrieve, and remove favorite articles
class LocalStorageService {
  Future<void> saveFavoriteArticles(List<Article> articles) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> articlesJson = articles.map((article) {
      return json.encode({
        'title': article.title,
        'url': article.url,
        'description': article.description,
      });
    }).toList();
    await prefs.setStringList('favorite_articles', articlesJson);
  }

  Future<List<Article>> getFavoriteArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? articlesJson = prefs.getStringList('favorite_articles');
    if (articlesJson == null) {
      return [];
    } else {
      return articlesJson.map((articleJson) {
        Map<String, dynamic> articleMap = json.decode(articleJson);
        return Article.fromJson(articleMap);
      }).toList();
    }
  }

  Future<void> removeFavoriteArticle(Article article) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? articlesJson = prefs.getStringList('favorite_articles');
    if (articlesJson != null) {
      articlesJson.removeWhere((jsonStr) {
        Map<String, dynamic> articleMap = json.decode(jsonStr);
        return articleMap['title'] == article.title;
      });
      await prefs.setStringList('favorite_articles', articlesJson);
    }
  }
}

