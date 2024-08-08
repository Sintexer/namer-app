import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          // useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void next() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (isFavorite()) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  bool isFavorite() {
    return favorites.contains(current);
  }

  void removeFavorite(int index) {
    if (index >= 0 && index < favorites.length) {
      favorites.removeAt(index);
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
      case 1:
        page = const LikedPage();
      default:
        throw UnimplementedError('no widget for selected index=$selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
                child: NavigationRail(
              extended: constraints.maxWidth >= 600,
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.home), label: Text('Home')),
                NavigationRailDestination(
                    icon: Icon(Icons.favorite), label: Text('Liked'))
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) => setState(() {
                selectedIndex = value;
              }),
            )),
            Expanded(
                child: SafeArea(
                  child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page),
                ))
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final pair = appState.current;
    final IconData favoriteIcon;
    if (appState.isFavorite()) {
      favoriteIcon = Icons.favorite;
    } else {
      favoriteIcon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => appState.toggleFavorite(),
                icon: Icon(favoriteIcon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () => appState.next(), child: Text("Next")),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class LikedPage extends StatelessWidget {
  const LikedPage();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall;

    if (appState.favorites.isEmpty) {
      return Center(child: Text('Nothing liked yet', style: style));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 20, bottom: 10),
                child: Text("Liked items", style: style),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appState.favorites.length,
              prototypeItem: LikedItem(
                  onClick: () => appState.removeFavorite(0),
                  pair: appState.favorites[0]),
              itemBuilder: (context, index) {
                return LikedItem(
                    onClick: () => appState.removeFavorite(index),
                    pair: appState.favorites[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LikedItem extends StatelessWidget {
  static const IconData dislikeIcon = Icons.heart_broken;

  final void Function() onClick;
  final WordPair pair;

  const LikedItem({required this.onClick, required this.pair});

  @override
  Widget build(BuildContext context) {

    return ListTile(
          leading: IconButton(onPressed: onClick, icon: Icon(dislikeIcon)),
          title: Text(pair.asLowerCase),
        );
  }
}
