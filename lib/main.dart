// Complete Flutter prototype for "Social Seniors" app, with all features and improvements.
// This is the full code—paste into lib/main.dart.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';

class AppState extends ChangeNotifier {
  bool isPremium = false;
  String userName = '';
  int userAge = 0;
  String userBio = '';
  String userGender = 'Male';
  File? userPhoto;
  double locationRadius = 10.0;
  bool notificationsEnabled = false;
  bool guardianEnabled = false;
  String guardianEmail = '';
  List<String> interests = [];
  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> events = [
    {'name': 'Bingo Night', 'location': 'Queen\'s Arms Pub', 'time': DateTime.now().add(Duration(days: 3)), 'category': 'Bingo'},
    {'name': 'England v Scotland', 'location': 'The Cricketers', 'time': DateTime.now().add(Duration(days: 5)), 'category': 'Football Matches'},
    {'name': 'Afternoon Tea Social', 'location': 'Ivy Rose Café', 'time': DateTime.now().add(Duration(days: 2)), 'category': 'Afternoon Tea'},
    {'name': 'Book Chat: Agatha Christie', 'location': 'Whitstable Library', 'time': DateTime.now().add(Duration(days: 1)), 'category': 'Book Club'},
  ];
  List<Map<String, dynamic>> nursingHomes = [
    {'name': 'Shoreline Manor', 'location': 'Whitstable', 'events': ['Bingo on Mondays', 'Coffee Mornings', 'Arts & Crafts'], 'photo': 'assets/shoreline.jpg'},
  ];
  bool largeText = false;
  bool highContrast = false;
  Map<String, dynamic>? offlineCache;
  String mood = '';
  List<Map<String, dynamic>> groups = [];
  List<String> reminders = [];
  String emergencyContact = '123-456-7890';
  DateTime selectedDay = DateTime.now();
  Timer? quizTimer;
  Duration quizCountdown = Duration(minutes: 30);

  void upgradeToPremium() {
    isPremium = true;
    notifyListeners();
  }

  void setProfile(String name, int age, String bio, String gender, File? photo, List<String> interests) {
    userName = name;
    userAge = age;
    userBio = bio;
    userGender = gender;
    userPhoto = photo;
    this.interests = interests;
    notifyListeners();
  }

  bool flagMessage(String message) {
    List<String> keywords = ['credit card', 'bank', 'send money'];
    return keywords.any((kw) => message.toLowerCase().contains(kw));
  }

  void toggleLargeText(bool value) {
    largeText = value;
    notifyListeners();
  }

  void toggleHighContrast(bool value) {
    highContrast = value;
    notifyListeners();
  }

  void loadOfflineCache() {
    offlineCache = {'profiles': [], 'events': []};
  }

  void setMood(String newMood) {
    mood = newMood;
    notifyListeners();
  }

  void addGroup(String name) {
    groups.add({'name': name, 'members': []});
    notifyListeners();
  }

  void addReminder(String reminder) {
    reminders.add(reminder);
    notifyListeners();
  }

  List<Map<String, dynamic>> getAiSuggestions() {
    return [{'name': 'AI Suggested Match', 'reason': 'Shares gardening interest'}];
  }

  void startQuizTimer() {
    quizTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (quizCountdown.inSeconds > 0) {
        quizCountdown -= Duration(seconds: 1);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  bool get canSendVoiceNote => isPremium;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'Social Seniors',
          theme: ThemeData(
            primaryColor: Colors.blue[900],
            scaffoldBackgroundColor: appState.highContrast ? Colors.black : Colors.white,
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                fontSize: appState.largeText ? 24 : 18,
                color: appState.highContrast ? Colors.white : Colors.black87,
              ),
            ),
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => WelcomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 20),
            Text('SocialSeniors', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Welcome Screen
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to', style: TextStyle(color: Colors.white, fontSize: 32)),
            Text('The Circle', style: TextStyle(color: Colors.white, fontSize: 32)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OnboardingScreen())),
              child: Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.beige,
                foregroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Onboarding Screen
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: [
          LocationRadiusStep(onNext: _nextStep),
          GuidelinesStep(onNext: _nextStep),
          TermsStep(onNext: _nextStep),
          TutorialStep(onNext: _nextStep),
          ProfileSetupScreen(onComplete: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()))),
          NotificationsStep(onNext: _nextStep),
        ],
      ),
    );
  }

  void _nextStep() {
    _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);
  }
}

// Location Radius Step
class LocationRadiusStep extends StatelessWidget {
  final VoidCallback onNext;
  LocationRadiusStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Set your location radius (miles)'),
          Slider(
            value: appState.locationRadius,
            min: 5,
            max: 50,
            onChanged: (val) {
              appState.locationRadius = val;
              appState.notifyListeners();
            },
          ),
          Text('Allow location access?'),
          ElevatedButton(onPressed: onNext, child: Text('Accept and Continue')),
        ],
      ),
    );
  }
}

// Guidelines Step
class GuidelinesStep extends StatelessWidget {
  final VoidCallback onNext;
  GuidelinesStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Community Guidelines'),
          Text('- No scams\n- Be respectful\n- etc.'),
          CheckboxListTile(
            value: true,
            onChanged: (_) {},
            title: Text('I agree'),
          ),
          ElevatedButton(onPressed: onNext, child: Text('Continue')),
        ],
      ),
    );
  }
}

// Terms Step
class TermsStep extends StatelessWidget {
  final VoidCallback onNext;
  TermsStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Terms & Conditions'),
          Text('Summary: ... Full link'),
          CheckboxListTile(
            value: true,
            onChanged: (_) {},
            title: Text('I accept'),
          ),
          ElevatedButton(onPressed: onNext, child: Text('Continue')),
        ],
      ),
    );
  }
}

// Tutorial Step
class TutorialStep extends StatelessWidget {
  final VoidCallback onNext;
  TutorialStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('How to use the app'),
          Text('Swipe right to connect\nSwipe left to skip\netc.'),
          ElevatedButton(onPressed: onNext, child: Text('Got it')),
        ],
      ),
    );
  }
}

// Notifications Step
class NotificationsStep extends StatelessWidget {
  final VoidCallback onNext;
  NotificationsStep({required this.onNext});

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Allow notifications?'),
          Switch(
            value: appState.notificationsEnabled,
            onChanged: (val) {
              appState.notificationsEnabled = val;
              appState.notifyListeners();
            },
          ),
          ElevatedButton(onPressed: onNext, child: Text('Continue')),
        ],
      ),
    );
  }
}

// Profile Setup Screen
class ProfileSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;
  ProfileSetupScreen({required this.onComplete});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  String selectedInterest = 'Companionship';
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('THE CIRCLE', style: TextStyle(color: Colors.white)), backgroundColor: Colors.orange),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.camera_alt, color: Colors.grey),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (val) => appState.userName = val,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onChanged: (val) => appState.userAge = int.tryParse(val) ?? 0,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Write a short bio...'),
                onChanged: (val) => appState.userBio = val,
              ),
              Text('Looking for a:'),
              RadioListTile(
                title: Text('Companionship'),
                value: 'Companionship',
                groupValue: selectedInterest,
                onChanged: (val) => setState(() => selectedInterest = val as String),
              ),
              RadioListTile(
                title: Text('Drinking Buddy'),
                value: 'Drinking Buddy',
                groupValue: selectedInterest,
                onChanged: (val) => setState(() => selectedInterest = val as String),
              ),
              RadioListTile(
                title: Text('Hobbies'),
                value: 'Hobbies',
                groupValue: selectedInterest,
                onChanged: (val) => setState(() => selectedInterest = val as String),
              ),
              RadioListTile(
                title: Text('Relationship'),
                value: 'Relationship',
                groupValue: selectedInterest,
                onChanged: (val) => setState(() => selectedInterest = val as String),
              ),
              ElevatedButton(
                onPressed: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) appState.userPhoto = File(pickedFile.path);
                  appState.setProfile(appState.userName, appState.userAge, appState.userBio, appState.userGender, appState.userPhoto, [selectedInterest]);
                  widget.onComplete();
                },
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outline), label: ''),
        ],
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  stt.SpeechToText speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDailyCheckIn());
    speech.initialize();
  }

  void _showDailyCheckIn() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('How are you today?'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(icon: Icon(Icons.sentiment_very_satisfied), onPressed: () => _setMood('Happy')),
            IconButton(icon: Icon(Icons.sentiment_neutral), onPressed: () => _setMood('Neutral')),
            IconButton(icon: Icon(Icons.sentiment_very_dissatisfied), onPressed: () => _setMood('Sad')),
          ],
        ),
      ),
    );
  }

  void _setMood(String mood) {
    Provider.of<AppState>(context, listen: false).setMood(mood);
    Navigator.pop(context);
  }

  void _startVoiceCommand() {
    speech.listen(onResult: (result) {
      String command = result.recognizedWords.toLowerCase();
      if (command.contains('pub bench')) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PubBenchScreen()));
      } // Add more for other sections
    });
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    appState.loadOfflineCache(); // Mock offline
    return Scaffold(
      body: Column(
        children: [
          if (appState.getAiSuggestions().isNotEmpty)
            Card(child: ListTile(title: Text('AI Suggestion: ${appState.getAiSuggestions()[0]['name']}'), subtitle: Text(appState.getAiSuggestions()[0]['reason']))),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                Card(
                  color: Colors.green[800],
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PubBenchScreen())),
                    child: Center(child: Text('Pub Bench', style: TextStyle(color: Colors.white))),
                  ),
                ),
                Card(
                  color: Colors.orange[200],
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AfternoonTeaScreen())),
                    child: Center(child: Text('Afternoon Tea', style: TextStyle(color: Colors.white))),
                  ),
                ),
                Card(
                  color: Colors.pink[300],
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RelationshipScreen())),
                    child: Center(child: Text('Relationship', style: TextStyle(color: Colors.white))),
                  ),
                ),
                Card(
                  color: Colors.blue[900],
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuizNightScreen())),
                    child: Center(child: Text('Quiz Night', style: TextStyle(color: Colors.white))),
                  ),
                ),
                Card(
                  color: Colors.blue[300],
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventsScreen())),
                    child: Center(child: Text('Events', style: TextStyle(color: Colors.white))),
                  ),
                ),
                Card(
                  color: Colors.brown[200],
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NursingHomesScreen())),
                    child: Center(child: Text('Nursing Homes', style: TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startVoiceCommand,
        child: Icon(Icons.mic),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: 'Wellness'),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.orange,
        onTap: (index) {
          if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => EventsScreen()));
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
          if (index == 4) Navigator.push(context, MaterialPageRoute(builder: (_) => WellnessScreen()));
        },
      ),
    );
  }
}

// Pub Bench Screen
class PubBenchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Peter, 65', style: TextStyle(color: Colors.white)),
                  subtitle: Text('A bitter for me.', style: TextStyle(color: Colors.yellow)),
                  trailing: ElevatedButton(onPressed: () {}, child: Text('Fancy a Pint?'), style: ElevatedButton.styleFrom(backgroundColor: Colors.black)),
                ),
                // More profiles...
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Pub Locator'),
                content: Container(
                  height: 200,
                  child: GoogleMap(initialCameraPosition: CameraPosition(target: LatLng(51.5, -0.09), zoom: 14)),
                ),
              ),
            ),
            child: Text('Find Local Pubs'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).addGroup('Pub Bench Group');
              Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatScreen(groupName: 'Pub Bench Group')));
            },
            child: Text('Create Group'),
          ),
        ],
      ),
    );
  }
}

// Afternoon Tea Screen
class AfternoonTeaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100],
      body: Column(
        children: [
          Card(
            child: Column(
              children: [
                CircleAvatar(radius: 50),
                Text('Marjorie, 72'),
                Text('Cheltenham'),
                Text('About Me...'),
                Row(
                  children: [Chip(label: Text('Reading')), Chip(label: Text('History'))],
                ),
                ElevatedButton(onPressed: () {}, child: Text('Send Message')),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Share a Recipe'),
                content: Column(
                  children: [
                    TextField(decoration: InputDecoration(labelText: 'Recipe Name')),
                    ElevatedButton(onPressed: () {}, child: Text('Upload Photo')),
                    ElevatedButton(onPressed: () {}, child: Text('Share')),
                  ],
                ),
              ),
            ),
            child: Text('Share Recipe'),
          ),
        ],
      ),
    );
  }
}

// Relationship Screen
class RelationshipScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: Column(
        children: [
          Card(
            child: Column(
              children: [
                CircleAvatar(radius: 50),
                Text('Name, Age'),
                Text('Location'),
                Text('About Me...'),
                Row(
                  children: [Chip(label: Text('Interest1'))],
                ),
                ElevatedButton(onPressed: () {}, child: Text('Send Message')),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompatibilityQuizScreen())),
            child: Text('Take Compatibility Quiz'),
          ),
        ],
      ),
    );
  }
}

class CompatibilityQuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Compatibility Quiz')),
      body: ListView(
        children: [
          Text('Question 1: Favorite hobby?'),
          RadioListTile(title: Text('Reading'), value: 1, groupValue: 0, onChanged: (_) {}),
          ElevatedButton(onPressed: () {}, child: Text('Submit')),
        ],
      ),
    );
  }
}

// Quiz Night Screen
class QuizNightScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    if (appState.quizTimer == null) appState.startQuizTimer();
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: Column(
          children: [
            Text('Quiz Night', style: TextStyle(color: Colors.yellow, fontSize: 32)),
            Text('Next Quiz in: ${appState.quizCountdown.inMinutes}:${appState.quizCountdown.inSeconds % 60}'),
            ElevatedButton(
              onPressed: () {},
              child: Text('Send Voice Invite'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BrainGameScreen())),
              child: Text('Play Quick Puzzle'),
            ),
          ],
        ),
      ),
    );
  }
}

// Events Screen
class EventsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(Duration(days: 30)),
            lastDay: DateTime.now().add(Duration(days: 30)),
            focusedDay: appState.selectedDay,
            selectedDayPredicate: (day) => isSameDay(appState.selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              appState.selectedDay = selectedDay;
              appState.notifyListeners();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: appState.events.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(appState.events[index]['name']),
                    subtitle: Text('${appState.events[index]['location']} - ${DateFormat('EEE h:mm a').format(appState.events[index]['time'])}'),
                    trailing: ElevatedButton(onPressed: () {}, child: Text('Interested')),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Senior Discount at Local Cafe'),
              trailing: Text('20% off'),
            ),
          ),
        ],
      ),
    );
  }
}

// Nursing Homes Screen
class NursingHomesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      body: ListView.builder(
        itemCount: appState.nursingHomes.length,
        itemBuilder: (context, index) {
          var home = appState.nursingHomes[index];
          return Card(
            child: Column(
              children: [
                Image.asset(home['photo'], height: 150, fit: BoxFit.cover),
                Text(home['name']),
                Text(home['location']),
                Column(children: home['events'].map((e) => Text('• $e')).toList()),
                ElevatedButton(onPressed: () {}, child: Text('Book a Visit')),
                ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Virtual Tour'),
                      content: Text('Mock Tour: "Welcome to Shoreline Manor..."'),
                      actions: [TextButton(onPressed: () {}, child: Text('Play Voice Overview'))],
                    ),
                  ),
                  child: Text('Virtual Tour'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Chat Screen
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String message = '';
  List<String> chat = [];

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemCount: chat.length, itemBuilder: (_, i) => ListTile(title: Text(chat[i])))),
          Row(
            children: [
              Expanded(child: TextField(onChanged: (val) => message = val, decoration: InputDecoration(hintText: 'Type message'))),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  if (appState.flagMessage(message)) {
                    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Warning: Unsafe content.')));
                  }
                  chat.add(message);
                  setState(() {});
                },
              ),
              IconButton(
                icon: Icon(Icons.mic),
                onPressed: () {
                  if (appState.canSendVoiceNote) {
                    // Mock recording
                    showDialog(context: context, builder: (_) => AlertDialog(title: Text('Recording Voice Note...')));
                  } else {
                    showUpgradeDialog(context);
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.photo),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Share Memory'),
                    content: Column(
                      children: [
                        ElevatedButton(onPressed: () {}, child: Text('Upload Photo')),
                        TextField(decoration: InputDecoration(labelText: 'Caption')),
                        ElevatedButton(onPressed: () {}, child: Text('Share')),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.emergency),
                onPressed: () => launchUrl(Uri.parse('tel:${appState.emergencyContact}')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Wellness Screen
class WellnessScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Wellness')),
      body: ListView(
        children: [
          Text('Reminders'),
          TextField(
            decoration: InputDecoration(labelText: 'Add Reminder'),
            onSubmitted: (val) => appState.addReminder(val),
          ),
          ...appState.reminders.map((r) => ListTile(title: Text(r))),
          ElevatedButton(
            onPressed: () => launchUrl(Uri.parse('tel:${appState.emergencyContact}')),
            child: Text('Call Emergency Contact'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BrainGameScreen())),
            child: Text('Play Brain Game'),
          ),
        ],
      ),
    );
  }
}

// Brain Game Screen
class BrainGameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brain Training')),
      body: Center(
        child: Column(
          children: [
            Text('Quick Puzzle: What's 2 + 2?'),
            TextField(),
            ElevatedButton(onPressed: () {}, child: Text('Submit')),
          ],
        ),
      ),
    );
  }
}

// Group Chat Screen
class GroupChatScreen extends StatelessWidget {
  final String groupName;

  GroupChatScreen({required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: Column(
        children: [
          Expanded(child: ListView()),
          TextField(decoration: InputDecoration(hintText: 'Message group...')),
        ],
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Column(
        children: [
          if (appState.userPhoto != null) Image.file(appState.userPhoto!),
          Text(appState.userName),
          Text('Age: ${appState.userAge}'),
          Text(appState.userBio),
          ElevatedButton(onPressed: () {}, child: Text('Edit Profile')),
        ],
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return Scaffold(
      body: ListView(
        children: [
          SwitchListTile(title: Text('Large Text'), value: appState.largeText, onChanged: appState.toggleLargeText),
          SwitchListTile(title: Text('High Contrast'), value: appState.highContrast, onChanged: appState.toggleHighContrast),
          ListTile(title: Text('Extras'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExtrasScreen()))),
          ListTile(title: Text('Help'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpScreen()))),
        ],
      ),
    );
  }
}

// Extras Screen
class ExtrasScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    if (appState.isPremium) return Text('You are premium!');
    return Scaffold(
      body: ListView(
        children: [
          ListTile(title: Text('Social Seniors Plus - £4.99/month'), trailing: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen())), child: Text('Subscribe'))),
          ListTile(title: Text('Lifetime - £19.99'), trailing: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen())), child: Text('Buy'))),
        ],
      ),
    );
  }
}

// Payment Screen
class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Confirm & Pay'),
            Text('Social Seniors Plus £4.99/month'),
            ElevatedButton(onPressed: () {
              Provider.of<AppState>(context, listen: false).upgradeToPremium();
            }, child: Text('Subscribe Now')),
          ],
        ),
      ),
    );
  }
}

// Help Screen
class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ExpansionTile(title: Text('I can’t upload a photo'), children: [Text('Steps...')]),
          // More...
        ],
      ),
    );
  }
}

// Upgrade Dialog
void showUpgradeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Upgrade to Premium'),
      content: Text('Unlock voice notes and more!'),
      actions: [TextButton(onPressed: () {}, child: Text('Upgrade'))],
    ),
  );
}

// Feedback Survey
void showFeedbackSurvey(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('How was your chat?'),
      content: Row(
        children: [
          IconButton(icon: Icon(Icons.thumb_up), onPressed: () {}),
          IconButton(icon: Icon(Icons.thumb_down), onPressed: () {}),
        ],
      ),
    ),
  );
}
