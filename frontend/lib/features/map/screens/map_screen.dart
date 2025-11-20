import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  bool _isLoading = true;
  bool _hasCenteredOnUser = false;
  String? _errorMessage;
  latlng.LatLng? _currentPosition;
  static const latlng.LatLng _initialPosition = latlng.LatLng(13.6214, 123.1947); // Naga City
  final List<Marker> _markers = [];
  
  // Store the last known position
  latlng.LatLng? _lastKnownPosition;
  final Set<String> _selectedCategories = {};
  String _selectedUrgency = 'medium';
  bool _receiveNotifications = true;
  final List<Map<String, dynamic>> _taskCategories = [
    {'name': 'Household / Chores', 'selected': false},
    {'name': 'Errands / Delivery', 'selected': false},
    {'name': 'Digital / Online Tasks', 'selected': false},
    {'name': 'General Assistance', 'selected': false},
    {'name': 'Miscellaneous', 'selected': false},
  ];

  final List<Map<String, dynamic>> _urgencyLevels = [
    {'name': 'Urgent', 'selected': false},
    {'name': 'Within a week', 'selected': false},
    {'name': 'Flexible', 'selected': false},
  ];
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hasCenteredOnUser = false;
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      setState(() => _isLoading = true);
      await _getCurrentLocation();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to get location: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        // Handle search
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          // Handle apply
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Apply',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Removed duplicate _buildSectionTitle method

  Widget _buildCategoryChips() {
    final categories = [
      'House Cleaning',
      'Laundry',
      'Car Wash',
      'Carpet Cleaning',
      'Gardening',
      'Other'
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: categories.map((category) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isSelected = _selectedCategories.contains(category);
            return CheckboxListTile(
              title: Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              value: isSelected,
              activeColor: const Color(0xFF2E7D32),
              checkColor: Colors.white,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              dense: true,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      children: [
        _buildUrgencyOption('Urgent', 'urgent'),
        const SizedBox(height: 8),
        _buildUrgencyOption('Within a week', 'within_a_week'),
        const SizedBox(height: 8),
        _buildUrgencyOption('Flexible', 'flexible'),
      ],
    );
  }
  
  Widget _buildUrgencyOption(String title, String value) {
    final isSelected = _selectedUrgency == value;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: RadioListTile<String>(
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          value: value,
          groupValue: _selectedUrgency,
          activeColor: const Color(0xFF2E7D32),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          onChanged: (value) {
            setState(() {
              _selectedUrgency = value!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Notify me when there is a task nearby',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Switch.adaptive(
          value: _receiveNotifications,
          activeColor: const Color(0xFF2E7D32),
          onChanged: (value) {
            setState(() {
              _receiveNotifications = value!;
            });
          },
        ),
      ],
    );
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them to use this feature.';
          _isLoading = false;
        });
        return;
      }

      // Check location permission
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
        if (!permission.isGranted) {
          setState(() {
            _errorMessage = 'Location permission is required to show your current location.';
            _isLoading = false;
          });
          return;
        }
      }

      // If permission is granted, get current location
      await _centerViewOnUserLocation();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 14.0,
              onMapReady: _onMapCreated,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bidatask.app',
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // Sidebar overlay
          if (_isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(
                color: Colors.black54,
              ),
            ),
            
          // Sidebar
          _buildSidebar(),
          
          // Loading and Error Indicators
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          
          // Top Bar with Search and Menu
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Menu Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black87, size: 24),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _isSidebarOpen = !_isSidebarOpen;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Search Bar
                  Expanded(
                    child: _buildSearchBar(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 60.0; // Height of the app bar with search
    
    final screenSize = MediaQuery.of(context).size;
    // Using exact width from Figma and dynamic height
    const sidebarWidth = 286.0; // 286.dp
    // Calculate height to be screen height minus top padding (status bar + app bar + some spacing)
    final sidebarHeight = MediaQuery.of(context).size.height - statusBarHeight - appBarHeight - 8.0; // 8.0 is extra spacing
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: _isSidebarOpen ? 8.0 : -sidebarWidth, // 8.0 is spacing from left edge
      top: statusBarHeight + appBarHeight + 8.0, // 8.0 is spacing below search bar
      width: sidebarWidth,
      height: sidebarHeight,
      child: Material(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          width: sidebarWidth,
          height: sidebarHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB), // Light gray background
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20.0), // 20.dp topEnd
              bottomRight: Radius.circular(20.0), // 20.dp bottomEnd
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x40000000), // Shadow color with 25% opacity
                spreadRadius: 0,
                blurRadius: 3, // 3.dp elevation
                offset: const Offset(0, 3), // 3.dp elevation
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Map',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 24 / 20, // line height / font size
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _isSidebarOpen = false;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Task Categories Section
                const Text(
                  'Task Categories',
                  style: TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 24 / 13, // line height / font size
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildCheckboxList(_taskCategories),
                const SizedBox(height: 16),
                
                // Urgency Section
                const Text(
                  'Urgency',
                  style: TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 24 / 13, // line height / font size
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildCheckboxList(_urgencyLevels),
                const SizedBox(height: 16),
                
                // Notification Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nearby task alert',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch.adaptive(
                        value: _receiveNotifications,
                        onChanged: (value) {
                          setState(() {
                            _receiveNotifications = value;
                          });
                        },
                        activeColor: Colors.blue,
                        activeTrackColor: Colors.blue.withOpacity(0.3),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Current Location Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isSidebarOpen = false;
                      });
                      _centerViewOnUserLocation();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.my_location, size: 16),
                    label: const Text(
                      'Current Location',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCheckboxList(List<Map<String, dynamic>> items) {
    return items.map((item) {
      return CheckboxListTile(
        title: Text(
          item['name'],
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
            height: 24 / 15, // line height / font size
            letterSpacing: 0.5,
          ),
        ),
        value: item['selected'],
        onChanged: (value) {
          setState(() {
            item['selected'] = value;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        dense: true,
      );
    }).toList();
  }

  void _onMapCreated() {
    _isMapReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasCenteredOnUser) {
        _initializeLocation();
      }
    });
  }

  bool _isFirstLoad = true;
  bool _hasSetInitialLocation = false;
  
  // Center on a specific position
  Future<void> _centerOnPosition(latlng.LatLng position) async {
    if (!_isMapReady) return;
    
    // Add a small delay to ensure the map is ready
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      debugPrint('Centering on position: ${position.latitude}, ${position.longitude}');
      await _mapController.move(position, 15.0);
      
      _markers.clear();
      _markers.add(
        Marker(
          width: 40.0,
          height: 40.0,
          point: position,
          child: const Icon(
            Icons.location_pin,
            color: Colors.red,
            size: 40.0,
          ),
        ),
      );
      
      // Update last known position
      _lastKnownPosition = position;
      
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error centering on position: $e');
    }
  }

  Future<void> _centerViewOnUserLocation() async {
    if (!_isMapReady) return;
    
    try {
      setState(() => _isLoading = true);
      
      // Use the existing _getCurrentLocation method which has all the logic
      final position = await _getCurrentLocation();
      
      // Only update if we got a valid position
      if (position.latitude != 0.0 && position.longitude != 0.0) {
        await _centerOnPosition(position);
        setState(() {
          _currentPosition = position;
          _hasCenteredOnUser = true;
        });
      } else {
        throw 'Invalid position received';
      }
      
    } catch (e) {
      debugPrint('Error in _centerViewOnUserLocation: $e');
      
      // Show error message
      if (mounted) {
        setState(() {
          _errorMessage = 'Error getting location: ${e.toString()}';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not get current location'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _centerViewOnUserLocation,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<latlng.LatLng> _getCurrentLocation() async {
    try {
      debugPrint('1. Starting location fetch...');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('2. Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        debugPrint('3. Requesting to enable location services...');
        bool opened = await Geolocator.openLocationSettings();
        debugPrint('4. User opened location settings: $opened');
        
        // Wait a moment for the user to enable location services
        await Future.delayed(const Duration(seconds: 2));
        
        // Check again if location services are enabled
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        debugPrint('5. Location service status after request: $serviceEnabled');
        
        if (!serviceEnabled) {
          throw 'Location services are disabled. Please enable them to continue.';
        }
      }
      
      // Check location permissions
      debugPrint('6. Checking location permissions...');
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('7. Current permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        debugPrint('8. Requesting location permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('9. New permission status: $permission');
        
        if (permission == LocationPermission.denied) {
          throw 'Location permission is required to show your current location';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        debugPrint('10. Permission permanently denied, opening app settings...');
        bool opened = await openAppSettings();
        debugPrint('11. Opened app settings: $opened');
        
        // Wait a moment for the user to change settings
        await Future.delayed(const Duration(seconds: 2));
        
        // Check permission again
        permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          throw 'Location permission is permanently denied. Please enable it in app settings.';
        }
      }

      debugPrint('12. Getting current position...');
      Position position;
      
      try {
        // First try to get last known position (faster)
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null && !_hasCenteredOnUser) {
          debugPrint('13. Using last known position: ${lastPosition.latitude}, ${lastPosition.longitude}');
          return latlng.LatLng(lastPosition.latitude, lastPosition.longitude);
        }
        
        // If no last known position or we need fresh data, get current position
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        debugPrint('14. Got fresh position: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        debugPrint('Error getting position: $e');
        
        // If current position fails, try last known position
        try {
          debugPrint('15. Trying to get last known position...');
          Position? lastPosition = await Geolocator.getLastKnownPosition();
          if (lastPosition != null) {
            debugPrint('16. Using last known position: ${lastPosition.latitude}, ${lastPosition.longitude}');
            return latlng.LatLng(lastPosition.latitude, lastPosition.longitude);
          }
          throw 'Could not get current or last known location';
        } catch (e) {
          debugPrint('Error getting last known position: $e');
          rethrow;
        }
      }
      
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
      return latlng.LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('ERROR in _getCurrentLocation: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location Error: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _initializeLocation();
              },
            ),
          ),
        );
      }
      rethrow;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Categories'),
            // TODO: Add category checkboxes
            const SizedBox(height: 16),
            const Text('Urgency'),
            // TODO: Add urgency filter
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Apply filters
              Navigator.pop(context);
            },
            child: const Text('APPLY'),
          ),
        ],
      ),
    );
  }
}
