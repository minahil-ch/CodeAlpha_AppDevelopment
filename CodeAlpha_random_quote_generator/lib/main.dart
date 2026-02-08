import 'package:flutter/material.dart';

void main() {
  runApp(const QuoteGeneratorApp());
}

class QuoteGeneratorApp extends StatelessWidget {
  const QuoteGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Quotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const QuoteGeneratorScreen(),
    );
  }
}

class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

class QuoteGeneratorScreen extends StatefulWidget {
  const QuoteGeneratorScreen({super.key});

  @override
  State<QuoteGeneratorScreen> createState() => _QuoteGeneratorScreenState();
}

class _QuoteGeneratorScreenState extends State<QuoteGeneratorScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Sample collection of 50+ diverse quotes
  final List<Quote> _quotes = [
    Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
    Quote(text: "Innovation distinguishes between a leader and a follower.", author: "Steve Jobs"),
    Quote(text: "Life is what happens to you while you're busy making other plans.", author: "John Lennon"),
    Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
    Quote(text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle"),
    Quote(text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson"),
    Quote(text: "Be yourself; everyone else is already taken.", author: "Oscar Wilde"),
    Quote(text: "So many books, so little time.", author: "Frank Zappa"),
    Quote(text: "Two things are infinite: the universe and human stupidity; and I'm not sure about the universe.", author: "Albert Einstein"),
    Quote(text: "A room without books is like a body without a soul.", author: "Marcus Tullius Cicero"),
    Quote(text: "Be who you are and say what you feel, because those who mind don't matter, and those who matter don't mind.", author: "Bernard M. Baruch"),
    Quote(text: "You know you're in love when you can't fall asleep because reality is finally better than your dreams.", author: "Dr. Seuss"),
    Quote(text: "You only live once, but if you do it right, once is enough.", author: "Mae West"),
    Quote(text: "Be the change that you wish to see in the world.", author: "Mahatma Gandhi"),
    Quote(text: "In the end, it's not the years in your life that count. It's the life in your years.", author: "Abraham Lincoln"),
    Quote(text: "Life is either a daring adventure or nothing at all.", author: "Helen Keller"),
    Quote(text: "To live is the rarest thing in the world. Most people exist, that is all.", author: "Oscar Wilde"),
    Quote(text: "Without music, life would be a mistake.", author: "Friedrich Nietzsche"),
    Quote(text: "We are all in the gutter, but some of us are looking at the stars.", author: "Oscar Wilde"),
    Quote(text: "Not all those who wander are lost.", author: "J.R.R. Tolkien"),
    Quote(text: "The man who does not read books has no advantage over the one who cannot read them.", author: "Mark Twain"),
    Quote(text: "The journey of a thousand miles begins with one step.", author: "Lao Tzu"),
    Quote(text: "That which does not kill us makes us stronger.", author: "Friedrich Nietzsche"),
    Quote(text: "The greatest glory in living lies not in never falling, but in rising every time we fall.", author: "Nelson Mandela"),
    Quote(text: "The way to get started is to quit talking and begin doing.", author: "Walt Disney"),
    Quote(text: "Your time is limited, so don't waste it living someone else's life.", author: "Steve Jobs"),
    Quote(text: "If life were predictable it would cease to be life, and be without flavor.", author: "Eleanor Roosevelt"),
    Quote(text: "If you look at what you have in life, you'll always have more. If you look at what you don't have in life, you'll never have enough.", author: "Oprah Winfrey"),
    Quote(text: "Life is what happens when you're busy making other plans.", author: "John Lennon"),
    Quote(text: "Spread love everywhere you go. Let no one ever come to you without leaving happier.", author: "Mother Teresa"),
    Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt"),
    Quote(text: "Tell me and I forget. Teach me and I remember. Involve me and I learn.", author: "Benjamin Franklin"),
    Quote(text: "Whoever is happy will make others happy too.", author: "Anne Frank"),
    Quote(text: "Don't judge each day by the harvest you reap but by the seeds that you plant.", author: "Robert Louis Stevenson"),
    Quote(text: "The best and most beautiful things in the world cannot be seen or even touched - they must be felt with the heart.", author: "Helen Keller"),
    Quote(text: "It is during our darkest moments that we must focus to see the light.", author: "Aristotle"),
    Quote(text: "Do not go where the path may lead, go instead where there is no path and leave a trail.", author: "Ralph Waldo Emerson"),
    Quote(text: "The greatest weapon against stress is our ability to choose one thought over another.", author: "William James"),
    Quote(text: "The purpose of our lives is to be happy.", author: "Dalai Lama"),
    Quote(text: "The only true wisdom is in knowing you know nothing.", author: "Socrates"),
    Quote(text: "Life is really simple, but we insist on making it complicated.", author: "Confucius"),
    Quote(text: "An unexamined life is not worth living.", author: "Socrates"),
    Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs"),
    Quote(text: "The whole secret of a successful life is to find out what is one's destiny to do, and then do it.", author: "Henry Ford"),
    Quote(text: "In order to write about life first you must live it.", author: "Ernest Hemingway"),
    Quote(text: "The big lesson in life, baby, is never be scared of anyone or anything.", author: "Frank Sinatra"),
    Quote(text: "The most difficult thing is the decision to act, the rest is merely tenacity.", author: "Amelia Earhart"),
    Quote(text: "The good life is a process, not a state of being.", author: "Carl Jung"),
    Quote(text: "The secret of getting ahead is getting started.", author: "Mark Twain"),
    Quote(text: "The best revenge is massive success.", author: "Frank Sinatra"),
  ];

  Quote? _currentQuote;
  int? _lastQuoteIndex;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Get initial quote on startup
    _getRandomQuote();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _getRandomQuote() {
    int randomIndex;
    do {
      randomIndex = _generateRandomIndex();
    } while (_quotes.length > 1 && randomIndex == _lastQuoteIndex);

    setState(() {
      _lastQuoteIndex = randomIndex;
      _currentQuote = _quotes[randomIndex];
    });

    // Trigger animation
    _animationController.reset();
    _animationController.forward();
  }

  int _generateRandomIndex() {
    return (DateTime.now().millisecond * 13) % _quotes.length;
  }

  void _shareQuote() {
    if (_currentQuote != null) {
      String shareText = '"${_currentQuote!.text}"\n\n- ${_currentQuote!.author}';
      // For now, showing a snackbar with the quote text
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quote copied: $shareText'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quotes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnimation.value,
                        child: Transform.scale(
                          scale: _fadeAnimation.value,
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 0.5,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: _currentQuote != null
                                        ? Text(
                                            '"${_currentQuote!.text}"',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              height: 1.5,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                          )
                                        : const CircularProgressIndicator(),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '- ${_currentQuote?.author ?? ""}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _getRandomQuote,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Quote'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  IconButton(
                    onPressed: _shareQuote,
                    icon: const Icon(Icons.share),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getRandomQuote,
        tooltip: 'Refresh Quote',
        child: const Icon(Icons.autorenew),
      ),
    );
  }
}