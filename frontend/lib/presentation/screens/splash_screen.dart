import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPage();
}

class _SplashPage extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToWelcome();
  }

  void _navigateToWelcome() async {
    try {
      _logger.d('Splash screen: Starting navigation to welcome screen');
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        _logger.d('Splash screen: Navigating to welcome screen');
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    } catch (e, stackTrace) {
      _logger.e('Error in splash screen navigation', error: e, stackTrace: stackTrace);
      if (mounted) {
        // Fallback to a simple navigation if the named route fails
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: FutureBuilder<ByteData>(
        future: _loadSplashImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image.memory(
                snapshot.data!.buffer.asUint8List(),
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  _logger.e('Error loading splash image', error: error, stackTrace: stackTrace);
                  return _buildErrorPlaceholder();
                },
              ),
            );
          } else if (snapshot.hasError) {
            _logger.e('Error loading splash image', error: snapshot.error, stackTrace: snapshot.stackTrace);
            return _buildErrorPlaceholder();
          }
          
          // Show a loading indicator while the image is being loaded
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
  Future<ByteData> _loadSplashImage() async {
    try {
      _logger.d('Loading splash image');
      final image = await rootBundle.load('assets/images/splash.png');
      _logger.d('Splash image loaded successfully');
      return image;
    } catch (e, stackTrace) {
      _logger.e('Failed to load splash image', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'Welcome to BidaTask',
          style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}