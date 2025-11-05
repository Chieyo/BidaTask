import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskTitleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController();
  final _dateController = TextEditingController();
  
  String? _selectedCategory;
  String? _selectedPriority;
  bool _expireAfter24Hours = false;
  bool _useCurrentLocation = true;
  latlng.LatLng? _selectedLocation;
  String _locationName = 'No location selected';
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _categories = [
    {'value': 'delivery', 'label': 'Delivery', 'icon': Icons.local_shipping},
    {'value': 'shopping', 'label': 'Shopping', 'icon': Icons.shopping_cart},
    {'value': 'chores', 'label': 'Chores', 'icon': Icons.cleaning_services},
    {'value': 'online_task', 'label': 'Online Tasks', 'icon': Icons.cleaning_services},
    {'value': 'general_assitance', 'label': 'General Assitance', 'icon': Icons.cleaning_services},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'Low', 'color': Colors.green},
    {'value': 'medium', 'label': 'Medium', 'color': Colors.orange},
    {'value': 'high', 'label': 'High', 'color': Colors.red},
  ];

  @override
  void dispose() {
    _taskTitleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _dateController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Update the location
      final currentLatLng = latlng.LatLng(
        position.latitude,
        position.longitude,
      );
      
      // Update the address
      await _getAddressFromLatLng(currentLatLng);
      
      // Update the state
      if (mounted) {
        setState(() {
          _selectedLocation = currentLatLng;
          _useCurrentLocation = true;
        });
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    if (_expireAfter24Hours) {
      return;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  Future<latlng.LatLng?> _showMapDialog(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && 
          permission != LocationPermission.always) {
        if (!mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are required')),
        );
        return null;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    final latLng = latlng.LatLng(position.latitude, position.longitude);
    
    if (!mounted) return null;

    // Return the result of showDialog directly
    return await showDialog<latlng.LatLng>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Location'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation ?? latLng,
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _selectedLocation = point;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bidatask.app',
                  ),
                  MarkerLayer(
                    markers: _selectedLocation != null
                        ? [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ]
                        : [],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _mapController.move(latLng, 15);
                  setState(() {
                    _selectedLocation = latLng;
                  });
                },
                child: const Text('My Location'),
              ),
              TextButton(
                onPressed: () {
                  if (_selectedLocation != null) {
                    Navigator.of(context).pop(_selectedLocation);
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _getAddressFromLatLng(latlng.LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
        ].where((part) => part != null && part.isNotEmpty).toList();
        
        if (mounted) {
          setState(() {
            _locationName = addressParts.join(', ');
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      if (mounted) {
        setState(() {
          _locationName = 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
      }
    }
  }
  

  void _handlePostTask() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        latlng.LatLng finalLocation;
        
        if (_useCurrentLocation) {
          // Get current position if "Use Current Location" is selected
          final position = await Geolocator.getCurrentPosition();
          finalLocation = latlng.LatLng(position.latitude, position.longitude);
        } else if (_selectedLocation != null) {
          // Use the manually selected location
          finalLocation = _selectedLocation!;
        } else {
          // No location selected
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a location')),
          );
          return;
        }

        // Proceed with task creation using finalLocation
        debugPrint('Task Location: ${finalLocation.latitude}, ${finalLocation.longitude}');
        
        // Show success dialog
        _showConfirmationDialog(context);
        
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Task Posted Successfully!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Message
                Text(
                  'Your task has been successfully posted and is now visible to potential taskers.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View My Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Task',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Task Title
                Text(
                  'Task Title',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _taskTitleController,
                  maxLength: 50,
                  decoration: InputDecoration(
                    hintText: 'Task Title',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a task title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Category
                Text(
                  'Category',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Choose a category',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['value'],
                      child: Row(
                        children: [
                          Icon(category['icon'], size: 20, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            category['label'],
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Description',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Add a description...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Task Priority
                Text(
                  'Task Priority',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    hintText: 'Choose a priority',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _priorities.map((priority) {
                    return DropdownMenuItem<String>(
                      value: priority['value'],
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: priority['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            priority['label'],
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a priority';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Reward
                Text(
                  'Reward',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rewardController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp('[^0-9.]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // Allow empty input
                      if (newValue.text.isEmpty) return newValue;
                      
                      // Check for multiple decimal points
                      if (newValue.text.split('.').length > 2) {
                        return oldValue;
                      }

                      // Check if there are more than 2 decimal places
                      if (newValue.text.contains('.')) {
                        final parts = newValue.text.split('.');
                        if (parts[1].length > 2) {
                          return oldValue;
                        }
                      }

                      // Limit total digits before decimal
                      if (newValue.text.contains('.')) {
                        final beforeDecimal = newValue.text.split('.')[0];
                        if (beforeDecimal.length > 7) {
                          return oldValue;
                        }
                      } else if (newValue.text.length > 7) {
                        return oldValue;
                      }

                      return newValue;
                    }),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Text(
                        '₱',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    counterText: '',
                    hintText: '0.00',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    isDense: true,
                  ),
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reward amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Location
                Text(
                  'Location',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Use Current Location Button
                    InkWell(
                      onTap: () {
                        // Only fetch location if not already selected
                        if (!_useCurrentLocation) {
                          _getCurrentLocation();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _useCurrentLocation ? Colors.blue.shade50 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _useCurrentLocation 
                                ? Colors.blue.shade300 
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _useCurrentLocation,
                              onChanged: (value) {
                                if (value == true) {
                                  _getCurrentLocation();
                                } else {
                                  setState(() {
                                    _useCurrentLocation = false;
                                  });
                                }
                              },
                              activeColor: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.my_location, color: Colors.blue),
                            const SizedBox(width: 12),
                            Text(
                              'Use Current Location',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Set Location Button
                    InkWell(
                      onTap: () async {
                        final location = await _showMapDialog(context);
                        if (location != null) {
                          setState(() {
                            _useCurrentLocation = false;
                            _selectedLocation = location;
                            _getAddressFromLatLng(location);
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: !_useCurrentLocation && _selectedLocation != null 
                              ? Colors.blue.shade50 
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !_useCurrentLocation && _selectedLocation != null
                                ? Colors.blue.shade300 
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Radio<bool>(
                              value: false,
                              groupValue: _useCurrentLocation,
                              onChanged: (value) {
                                setState(() {
                                  _useCurrentLocation = false;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedLocation != null && !_useCurrentLocation
                                    ? _locationName
                                    : 'Set Location on Map',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: _selectedLocation != null && !_useCurrentLocation
                                      ? Colors.black87
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            if (_selectedLocation != null && !_useCurrentLocation)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 20, color: Colors.blue),
                                onPressed: () async {
                                  final lat = _selectedLocation!.latitude;
                                  final lng = _selectedLocation!.longitude;
                                  final url = Uri.parse('https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=16/$lat/$lng');
                                  
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  } else {
                                    debugPrint('Could not launch $url');
                                  }
                                },
                                tooltip: 'Open in Maps',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Post Expiration
                Text(
                  'Post Expiration',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  enabled: !_expireAfter24Hours,
                  onTap: _expireAfter24Hours ? null : _selectDate,
                  decoration: InputDecoration(
                    hintText: 'MM/DD/YYYY',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: _expireAfter24Hours ? Colors.grey[400] : Colors.black87,
                      ),
                      onPressed: _expireAfter24Hours ? null : _selectDate,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    filled: true,
                    fillColor: _expireAfter24Hours ? Colors.grey[100] : Colors.white,
                  ),
                  validator: (value) {
                    if (!_expireAfter24Hours && (value == null || value.isEmpty)) {
                      return 'Please select an expiration date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Expire after 24 hours checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _expireAfter24Hours,
                        onChanged: (value) {
                          setState(() {
                            _expireAfter24Hours = value ?? false;
                            if (_expireAfter24Hours) {
                              // Auto-set date to 24 hours from now
                              _dateController.text = DateFormat('MM/dd/yyyy')
                                  .format(DateTime.now().add(const Duration(hours: 24)));
                            } else {
                              // Clear the date when unchecked
                              _dateController.clear();
                            }
                          });
                        },
                        activeColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expire after 24 hours',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Post Task Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _showConfirmationDialog(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    elevation: 0,
                  ),
                  child: Text(
                    'Post Task',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}