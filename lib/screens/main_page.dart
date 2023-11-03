import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:geo'
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {


  LatLng? pickLocation;
  loc.Location location=loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState=GlobalKey<ScaffoldState>()

  double serachLocationContainerHeight=220;
  double waitingResponseFromDriverContainerHeight=0;
  double assignedDriverInfoDriverContainerHeight=0;

  Position? userCurrentPosition;
  var geoLocation=GeoLocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap=0;

  List<LatLng> pLineCordinateList=[];
  Set<PolyLine> polyLineSet={};

  Set<Marker> markSet={};
  Set<Circle> circleSet={};

  String userName="";
  String userEmail="";

  bool navigationDrawer=true;

  bool activeNearbyDriversLoaded=flase;


  



  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
