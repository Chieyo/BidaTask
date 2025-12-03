import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../services/task_service.dart';
import '../../../domain/models/task_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final TaskService _taskService = TaskService();
List<Task> _allTasks = [];

  final MapController _mapController = MapController();
  bool _isMapReady = false;
  bool _isLoading = true;
  bool _hasCenteredOnUser = false;
  String? _errorMessage;
  latlng.LatLng? _currentPosition;
  static const latlng.LatLng _initialPosition = latlng.LatLng(13.6214, 123.1947); // Naga City
  final List<Marker> _markers = []; // Task markers only
  Marker? _currentLocationMarker; // Separate current location marker
  String _searchQuery = ''; // Search query
  List<Task> _filteredTasks = []; // Filtered tasks based on search
  
  // Store the last known position
  latlng.LatLng? _lastKnownPosition;
  final Set<String> _selectedCategories = {};
  String _selectedUrgency = 'medium';
  bool _receiveNotifications = true;
  final List<Map<String, dynamic>> _taskCategories = [
    {'name': 'Household Chores', 'selected': false},
    {'name': 'Delivery', 'selected': false},
    {'name': 'Online Assistance', 'selected': false}, // Check for hidden characters
    {'name': 'General Assistance', 'selected': false},
    {'name': 'Shopping', 'selected': false},
    {'name': 'Personal', 'selected': false},
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
      await _fetchAndDisplayTasks();
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

  Future<void> _fetchAndDisplayTasks() async {
    // Don't require current position to fetch tasks
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get selected categories
      final selectedCategoryNames = _taskCategories
          .where((cat) => cat['selected'] == true)
          .map((cat) => cat['name'] as String)
          .toList();
      
      // Debug print
      debugPrint('Selected categories: $selectedCategoryNames');
      
      // Fetch tasks
      List<Task> tasks;
      if (selectedCategoryNames.isEmpty) {
        // No categories selected, fetch all tasks
        debugPrint('Fetching all tasks');
        tasks = await _taskService.fetchNearbyTasks(category: null);
      } else if (selectedCategoryNames.length == 1) {
        // Single category selected, filter by that category
        debugPrint('Fetching tasks with category: ${selectedCategoryNames.first}');
        tasks = await _taskService.fetchNearbyTasks(category: selectedCategoryNames.first);
        debugPrint('API returned ${tasks.length} tasks for category "${selectedCategoryNames.first}"');
        debugPrint('Looking for exact match with: "${selectedCategoryNames.first}"');
        for (var task in tasks) {
          debugPrint('  - Task: "${task.title}", Category: "${task.category}" - Match: ${task.category == selectedCategoryNames.first}');
        }
        
        // If API returns tasks but none match exactly, try case-insensitive comparison
        if (tasks.isNotEmpty) {
          final matchingTasks = tasks.where((task) => 
            task.category.toLowerCase() == selectedCategoryNames.first.toLowerCase()
          ).toList();
          debugPrint('Case-insensitive matches: ${matchingTasks.length}');
          if (matchingTasks.length != tasks.length) {
            tasks = matchingTasks;
            debugPrint('Using case-insensitive filtered tasks: ${tasks.length}');
          }
        }
      } else {
        // Multiple categories selected, fetch all and filter client-side
        debugPrint('Fetching all tasks for multiple category filter');
        final allTasks = await _taskService.fetchNearbyTasks(category: null);
        tasks = allTasks.where((task) => selectedCategoryNames.contains(task.category)).toList();
      }
      
      // Apply urgency filter
      final selectedUrgencyNames = _urgencyLevels
          .where((level) => level['selected'] == true)
          .map((level) => level['name'] as String)
          .toList();
      
      debugPrint('Selected urgency names: $selectedUrgencyNames');
      
      if (selectedUrgencyNames.isNotEmpty) {
        debugPrint('Applying urgency filter: $selectedUrgencyNames');
        final originalTaskCount = tasks.length;
        tasks = tasks.where((task) {
          final priority = task.isUrgent ? 'urgent' : 'normal';
          debugPrint('Task: ${task.title}, Priority: $priority, isUrgent: ${task.isUrgent}');
          return selectedUrgencyNames.any((urgency) {
            switch (urgency.toLowerCase()) {
              case 'urgent':
                debugPrint('  Checking urgent: priority == urgent? ${priority == 'urgent'}');
                return priority == 'urgent';
              case 'within a week':
                debugPrint('  Checking within a week: priority normal/urgent? ${priority == 'normal' || priority == 'urgent'}');
                return priority == 'normal' || priority == 'urgent';
              case 'flexible':
                debugPrint('  Checking flexible: always true');
                return true; // Show all for flexible
              default:
                debugPrint('  Unknown urgency: $urgency');
                return false;
            }
          });
        }).toList();
        debugPrint('Urgency filter: $originalTaskCount -> ${tasks.length} tasks');
      } else {
        debugPrint('No urgency filter applied, keeping all ${tasks.length} tasks');
      }
      debugPrint('Fetched ${tasks.length} tasks');
      
      // Clear existing markers
      debugPrint('Clearing ${_markers.length} existing markers');
      _markers.clear();
      
      // Add task markers
      debugPrint('Processing ${tasks.length} tasks for markers...');
      for (var task in tasks) {
        debugPrint('Task: ${task.title}, Category: ${task.category}, Location: ${task.location}');
        latlng.LatLng location;
        
        // Parse location from PostGIS POINT format
        if (task.location != null && task.location.toString().startsWith('POINT(')) {
          try {
            // Extract coordinates from "POINT(longitude latitude)"
            final pointStr = task.location.toString().replaceAll('POINT(', '').replaceAll(')', '');
            final coords = pointStr.split(' ');
            if (coords.length == 2) {
              final longitude = double.parse(coords[0]);
              final latitude = double.parse(coords[1]);
              location = latlng.LatLng(latitude, longitude);
            } else {
              location = latlng.LatLng(13.6214, 123.1947); // Default to Naga City
            }
          } catch (e) {
            location = latlng.LatLng(13.6214, 123.1947); // Default to Naga City
          }
        } else {
          location = latlng.LatLng(13.6214, 123.1947); // Default to Naga City
        }
        
        debugPrint('Creating marker at: ${location.latitude}, ${location.longitude}');
        debugPrint('Current position: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
        
        // Add offset if marker is at current position to make it visible
        if (_currentPosition != null && 
            (location.latitude - _currentPosition!.latitude).abs() < 0.001 &&
            (location.longitude - _currentPosition!.longitude).abs() < 0.001) {
          debugPrint('Marker at current position, adding offset');
          // Add a small random offset to make markers at same location visible
          final randomOffset = (task.title.hashCode % 10) * 0.0001;
          location = latlng.LatLng(
            location.latitude + 0.0002 + randomOffset, // North offset
            location.longitude + 0.0002 + randomOffset, // East offset
          );
          debugPrint('Adjusted marker location to: ${location.latitude}, ${location.longitude}');
        }
        
        final marker = Marker(
          width: 50.0,
          height: 50.0,
          point: location,
          child: GestureDetector(
            onTap: () => _showTaskDetails(task),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _getUrgencyColor(task.isUrgent ? 'urgent' : 'normal'),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getCategoryIcon(task.category),
                color: _getUrgencyColor(task.isUrgent ? 'urgent' : 'normal'),
                size: 30.0,
              ),
            ),
          ),
        );
        _markers.add(marker);
        debugPrint('Marker added for task: ${task.title}. Total markers: ${_markers.length}');
      }

      debugPrint('Calling setState to update UI with ${_markers.length} markers');
      setState(() {
        _allTasks = tasks;
        _isLoading = false;
      });
      
      // Apply search and filters after fetching tasks
      _applySearchAndFilters();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tasks: $e';
        _isLoading = false;
      });
    }
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5, // Start at 50% of screen height
        maxChildSize: 0.8, // Max 80% of screen height
        minChildSize: 0.3, // Min 30% of screen height
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Task title (header)
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Category and urgency with pills
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.isUrgent 
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.isUrgent ? 'Urgent' : 'Normal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: task.isUrgent 
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Distance from user with icon
                  if (_currentPosition != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _calculateDistance(task),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Task details section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Task Details:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.description ?? 'No description provided',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Reward section with design
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF10B981), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Reward: ${task.formattedPrice}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Container(
                    height: 1,
                    color: const Color(0xFFE5E7EB),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Poster information with design
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          task.postedBy.isNotEmpty ? task.postedBy[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.postedBy.isNotEmpty ? task.postedBy : 'Anonymous User',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFF59E0B),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Trust Tier ${_getTrustTier(task.postedBy)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(), // Use remaining space
                ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _calculateDistance(Task task) {
    // Parse task location
    latlng.LatLng taskLocation;
    if (task.location != null && task.location.toString().startsWith('POINT(')) {
      try {
        final pointStr = task.location.toString().replaceAll('POINT(', '').replaceAll(')', '');
        final coords = pointStr.split(' ');
        if (coords.length == 2) {
          final longitude = double.parse(coords[0]);
          final latitude = double.parse(coords[1]);
          taskLocation = latlng.LatLng(latitude, longitude);
        } else {
          return 'Distance unavailable';
        }
      } catch (e) {
        return 'Distance unavailable';
      }
    } else {
      return 'Distance unavailable';
    }
    
    // Calculate distance using Haversine formula
    if (_currentPosition == null) return 'Distance unavailable';
    
    const double earthRadius = 6371000; // Earth's radius in meters
    
    final double lat1Rad = _currentPosition!.latitude * (3.14159265359 / 180);
    final double lat2Rad = taskLocation.latitude * (3.14159265359 / 180);
    final double deltaLatRad = (taskLocation.latitude - _currentPosition!.latitude) * (3.14159265359 / 180);
    final double deltaLonRad = (taskLocation.longitude - _currentPosition!.longitude) * (3.14159265359 / 180);
    
    final double a = math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(deltaLonRad / 2) * math.sin(deltaLonRad / 2);
    final double c = 2 * math.asin(math.sqrt(a));
    
    final double distance = earthRadius * c;
    
    if (distance < 1000) {
      return '${distance.round()} meters away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km away';
    }
  }
  
  int _getTrustTier(String postedBy) {
    // TODO: Implement actual trust tier logic based on user data
    // For now, return a random tier between 1-5 for demonstration
    return (postedBy.hashCode % 5) + 1;
  }

  void _updateFilters() {
    _applySearchAndFilters();
  }

  void _applySearchAndFilters() {
    debugPrint('_applySearchAndFilters called');
    debugPrint('Search query: "$_searchQuery"');
    debugPrint('Total _allTasks count: ${_allTasks.length}');
    
    // Start with all tasks
    List<Task> filteredTasks = List.from(_allTasks);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      debugPrint('Applying search filter for: "$_searchQuery"');
      filteredTasks = filteredTasks.where((task) {
        final titleMatch = task.title.toLowerCase().contains(_searchQuery);
        final categoryMatch = task.category.toLowerCase().contains(_searchQuery);
        final descriptionMatch = task.description?.toLowerCase().contains(_searchQuery) ?? false;
        debugPrint('Task: ${task.title} - Title: $titleMatch, Category: $categoryMatch, Description: $descriptionMatch');
        return titleMatch || categoryMatch || descriptionMatch;
      }).toList();
      debugPrint('Search filtered tasks count: ${filteredTasks.length}');
    }
    
    // Apply category filters
    final selectedCategoryNames = _taskCategories
        .where((cat) => cat['selected'] == true)
        .map((cat) => cat['name'] as String)
        .toList();
    
    if (selectedCategoryNames.isNotEmpty) {
      filteredTasks = filteredTasks.where((task) => 
        selectedCategoryNames.contains(task.category)
      ).toList();
    }
    
    // Apply urgency filters
    final selectedUrgencyNames = _urgencyLevels
        .where((level) => level['selected'] == true)
        .map((level) => level['name'] as String)
        .toList();
    
    if (selectedUrgencyNames.isNotEmpty) {
      debugPrint('Applying urgency filter: $selectedUrgencyNames');
      final beforeUrgencyFilter = filteredTasks.length;
      filteredTasks = filteredTasks.where((task) {
        final priority = task.isUrgent ? 'urgent' : 'normal';
        final matches = selectedUrgencyNames.any((urgency) {
          switch (urgency.toLowerCase()) {
            case 'urgent':
              debugPrint('  Task "${task.title}": priority=$priority, checking urgent -> ${priority == 'urgent'}');
              return priority == 'urgent';
            case 'within a week':
              debugPrint('  Task "${task.title}": priority=$priority, checking within a week -> ${priority == 'normal' || priority == 'urgent'}');
              return priority == 'normal' || priority == 'urgent'; // Show all tasks
            case 'flexible':
              debugPrint('  Task "${task.title}": priority=$priority, checking flexible -> ${priority == 'normal'}');
              return priority == 'normal'; // Show only non-urgent (flexible) tasks
            default:
              return false;
          }
        });
        return matches;
      }).toList();
      debugPrint('Urgency filter: $beforeUrgencyFilter -> ${filteredTasks.length} tasks');
    }
    
    // Update filtered tasks and rebuild markers
    _filteredTasks = filteredTasks;
    _buildMarkersFromTasks(_filteredTasks);
  }

  void _buildMarkersFromTasks(List<Task> tasks) {
    // Clear existing markers
    _markers.clear();
    
    // Add task markers
    for (var task in tasks) {
      latlng.LatLng location;
      
      // Parse location from PostGIS POINT format
      if (task.location != null && task.location.toString().startsWith('POINT(')) {
        try {
          // Extract coordinates from "POINT(longitude latitude)"
          final pointStr = task.location.toString().replaceAll('POINT(', '').replaceAll(')', '');
          final coords = pointStr.split(' ');
          if (coords.length == 2) {
            final longitude = double.parse(coords[0]);
            final latitude = double.parse(coords[1]);
            location = latlng.LatLng(latitude, longitude);
          } else {
            location = latlng.LatLng(13.6214, 123.1947); // Default to Naga City
          }
        } catch (e) {
          location = latlng.LatLng(13.6214, 123.1947); // Default to Naga City
        }
      } else {
        location = latlng.LatLng(13.6214, 123.1947); // Default to Naga City
      }
      
      // Add offset if marker is at current position to make it visible
      if (_currentPosition != null && 
          (location.latitude - _currentPosition!.latitude).abs() < 0.001 &&
          (location.longitude - _currentPosition!.longitude).abs() < 0.001) {
        // Add a small random offset to make markers at same location visible
        final randomOffset = (task.title.hashCode % 10) * 0.0001;
        location = latlng.LatLng(
          location.latitude + 0.0002 + randomOffset, // North offset
          location.longitude + 0.0002 + randomOffset, // East offset
        );
      }
      
      final marker = Marker(
        width: 50.0,
        height: 50.0,
        point: location,
        child: GestureDetector(
          onTap: () => _showTaskDetails(task),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _getUrgencyColor(task.isUrgent ? 'urgent' : 'normal'),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(task.category),
              color: _getUrgencyColor(task.isUrgent ? 'urgent' : 'normal'),
              size: 30.0,
            ),
          ),
        ),
      );
      _markers.add(marker);
    }
    
    setState(() {});
  }

  // Center map on all visible markers
  void _centerOnMarkers() {
    debugPrint('_centerOnMarkers called. Markers count: ${_markers.length}, Map ready: $_isMapReady');
    
    if (_markers.isEmpty || !_isMapReady) {
      debugPrint('Cannot center: No markers or map not ready');
      return;
    }
    
    // Calculate bounds of all markers
    double minLat = _markers.first.point.latitude;
    double maxLat = _markers.first.point.latitude;
    double minLng = _markers.first.point.longitude;
    double maxLng = _markers.first.point.longitude;
    
    for (var marker in _markers) {
      debugPrint('Marker at: ${marker.point.latitude}, ${marker.point.longitude}');
      if (marker.point.latitude < minLat) minLat = marker.point.latitude;
      if (marker.point.latitude > maxLat) maxLat = marker.point.latitude;
      if (marker.point.longitude < minLng) minLng = marker.point.longitude;
      if (marker.point.longitude > maxLng) maxLng = marker.point.longitude;
    }
    
    // Calculate center point
    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;
    
    debugPrint('Centering on: $centerLat, $centerLng');
    // Move map to center of markers
    _mapController.move(latlng.LatLng(centerLat, centerLng), 14.0);
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
        hintText: 'Search tasks or categories...',
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
        debugPrint('Search input changed to: "$value"');
        setState(() {
          _searchQuery = value.toLowerCase();
          _applySearchAndFilters();
        });
      },
    );
  }

  
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
    debugPrint('Building map with ${_markers.length} markers');
    
    // Add a test marker to verify markers are working
    if (_markers.isNotEmpty) {
      debugPrint('Markers available: ${_markers.map((m) => '(${m.point.latitude}, ${m.point.longitude})').join(', ')}');
    }
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
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
                markers: [
                  if (_currentLocationMarker != null) _currentLocationMarker!,
                  ..._markers,
                ],
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
    final sidebarWidth = screenSize.width / 2; // Half of screen width
    // Height from top of search bar to bottom of screen, minus 60 pixels to prevent overflow
    final sidebarHeight = screenSize.height - statusBarHeight - appBarHeight;
    
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
            color: Colors.white, // Clean white background
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20.0), // 20.dp topEnd
              bottomRight: Radius.circular(20.0), // 20.dp bottomEnd
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15), // Softer shadow
                spreadRadius: 0,
                blurRadius: 10, // Increased blur for softer shadow
                offset: const Offset(-2, 0), // Shadow on left side
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Text(
                    'Map',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Categories Section
                        _buildSectionHeader('Task Categories', null),
                        const SizedBox(height: 12),
                        ..._buildEnhancedCheckboxList(_taskCategories, isCategory: true),
                        const SizedBox(height: 20),
                        
                        // Urgency Section
                        _buildSectionHeader('Urgency Level', null),
                        const SizedBox(height: 12),
                        ..._buildEnhancedCheckboxList(_urgencyLevels, isCategory: false),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                
                // Action Buttons at bottom
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced checkbox list with better UX
  List<Widget> _buildEnhancedCheckboxList(List<Map<String, dynamic>> items, {required bool isCategory}) {
    return items.map((item) {
      return Material(
        color: Colors.transparent,
        elevation: 0,
        child: InkWell(
          onTap: () {
            debugPrint('Checkbox changed: ${item['name']} = ${!item['selected']}');
            setState(() {
              item['selected'] = !item['selected'];
              _updateFilters();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: item['selected'] 
                  ? (isCategory ? const Color(0xFFEBF5FF) : const Color(0xFFF0FDF4))
                  : Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Checkbox
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: item['selected'] 
                          ? (isCategory ? const Color(0xFF3B82F6) : const Color(0xFF10B981))
                          : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: item['selected'] 
                            ? (isCategory ? const Color(0xFF3B82F6) : const Color(0xFF10B981))
                            : const Color(0xFFD1D5DB),
                        width: 1.5,
                      ),
                    ),
                    child: item['selected']
                        ? Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // Label
                  Expanded(
                    child: Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black, // Black color for content
                        height: 1.3,
                      ),
                    ),
                  ),
                  // Badge showing count (optional - for future enhancement)
                  if (item['selected'])
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isCategory ? const Color(0xFF3B82F6) : const Color(0xFF10B981)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '✓',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isCategory ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // Section header
  Widget _buildSectionHeader(String title, IconData? icon) {
    if (icon != null) {
      return Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280), // Gray color for headers
            ),
          ),
        ],
      );
    } else {
      return Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280), // Gray color for headers
        ),
      );
    }
  }

  // Enhanced notification toggle
  Widget _buildNotificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 18,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 12),
              const Text(
                'Nearby task alerts',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          Switch.adaptive(
            value: _receiveNotifications,
            onChanged: (value) {
              setState(() {
                _receiveNotifications = value;
              });
            },
            activeColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFFEBF5FF),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  // Action buttons at the bottom
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Clear filters button
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                // Clear all filters and search
                _searchQuery = '';
                for (var category in _taskCategories) {
                  category['selected'] = false;
                }
                for (var urgency in _urgencyLevels) {
                  urgency['selected'] = false;
                }
                _applySearchAndFilters();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            icon: const Icon(Icons.clear_outlined, size: 16),
            label: const Text(
              'Clear All Filters',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Current location button
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
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.location_on, color: Colors.red, size: 16),
            label: const Text(
              'Center on Location',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  // Keep the original method for backward compatibility
  List<Widget> _buildCheckboxList(List<Map<String, dynamic>> items) {
    return _buildEnhancedCheckboxList(items, isCategory: true);
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
      
      // Update current location marker
      _currentLocationMarker = Marker(
        width: 40.0,
        height: 40.0,
        point: position,
        child: const Icon(
          Icons.location_pin,
          color: Colors.red,
          size: 40.0,
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

  Color _getUrgencyColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'urgent':
        return Colors.red;
      case 'medium':
      case 'normal':
        return Colors.orange;
      case 'low':
      case 'flexible':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'household chores':
        return Icons.cleaning_services;
      case 'delivery':
        return Icons.local_shipping;
      case 'online assistance':
        return Icons.computer;
      case 'general assistance':
        return Icons.help_outline;
      case 'shopping':
        return Icons.shopping_cart;
      case 'personal':
        return Icons.person;
      default:
        return Icons.task_alt;
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
