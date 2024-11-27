import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logicalc Landing Page',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF64B5F6),
          primary: const Color(0xFF64B5F6),
          secondary: const Color(0xFF4FC3F7),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextPage() {
    if (_currentIndex < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Logicalc', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('About', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Contact', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildFeaturePage(
                  icon: Icons.check_circle,
                  title: 'Efficient Conversions',
                  description: 'Convert equations, diagrams, and generate truth tables.',
                ),
                _buildFeaturePage(
                  icon: Icons.calculate,
                  title: 'Analyze Your Data',
                  description: 'Utilize our tools to analyze your logical equations and data.',
                ),
                _buildFeaturePage(
                  icon: Icons.table_chart,
                  title: 'Generate Truth Tables',
                  description: 'Easily create truth tables from your logical expressions.',
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: _previousPage,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: _nextPage,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConversionPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: const Text('Get Started', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeaturePage({required IconData icon, required String title, required String description}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              description,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text('Logicalc', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About', style: TextStyle(color: Colors.black)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class ConversionPage extends StatelessWidget {
  const ConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose your conversion type!',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EquationInputPage()),
                );
              },
              child: const Text(
                'Convert Equation',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Convert Equation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Truth Table',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            // Redirect to Camera Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraPage()),
            );
          }
        },
      ),
    );
  }
}


class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Ensure that camera initialization happens asynchronously
    cameras = await availableCameras();
    
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0], // Select the first camera available
        ResolutionPreset.high,
      );

      await _cameraController.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      if (_cameraController.value.isInitialized) {
        // Capture the photo and save it to a file
        final image = await _cameraController.takePicture();

        // Optionally, display the image or handle the saved file
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
       body: Column(
      children: [
        if (_isCameraInitialized)
          Container(
            height: 400, // Adjust the height here
            child: AspectRatio(
              aspectRatio: _cameraController.value.aspectRatio,
              child: CameraPreview(_cameraController),
            ),
          )
          else
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _capturePhoto,
            child: const Text('Capture Photo'),
          ),
        ],
      ),
    );
  }
}

// Display the captured image on a new screen
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captured Image', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Image.file(File(imagePath)), // Display the captured image
      ),
    );
  }
}


class EquationInputPage extends StatefulWidget {
  const EquationInputPage({super.key});

  @override
  _EquationInputPageState createState() => _EquationInputPageState();
}

class _EquationInputPageState extends State<EquationInputPage> {
  final TextEditingController _controller = TextEditingController();

  void _handleKeyPress(String value) {
    setState(() {
      if (value == 'CLR') {
        _controller.clear();
      } else if (value == 'DEL') {
        final text = _controller.text;
        if (text.isNotEmpty) {
          _controller.text = text.substring(0, text.length - 1);
        }
      } else {
        _controller.text += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equation Input', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Input your equation:',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Equation',
              ),
            ),
            const SizedBox(height: 20),
            CustomKeyboard(onKeyPressed: _handleKeyPress),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(expression: _controller.text),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
              child: const Text('Convert', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// History Page
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: const Text(
          'History of conversions will be displayed here.',
          style: TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}

// Custom Keyboard Widget
class CustomKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const CustomKeyboard({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildKey('A'),         // Variable A
        _buildKey('B'),         // Variable B
        _buildKey('C'),         // Variable C
        _buildKey('DEL', icon: Icons.backspace_outlined),  // Backspace button
        _buildKey('∧'),         // Logical AND (symbol: ∧)
        _buildKey('∨'),         // Logical OR (symbol: ∨)
        _buildKey('¬'),         // Logical NOT (symbol: ¬)
        _buildKey('↑'),         // Logical NAND (symbol: ↑)
        _buildKey('↓'),         // Logical NOR (symbol: ↓)
        _buildKey('⊕'),         // Logical XOR (symbol: ⊕)
        _buildKey('⊙'),         // Logical XNOR (symbol: ⊙)
        _buildKey('('),         // Open parenthesis
        _buildKey(')'),         // Close parenthesis
        _buildKey('CLR'),       // Clear
      ],
    );
  }

  Widget _buildKey(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          onKeyPressed(label);
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        ),
        child: icon != null 
          ? Icon(icon, size: 24)
          : Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
      ),
    );
  }
}
