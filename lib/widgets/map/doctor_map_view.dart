import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';

class DoctorMapView extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorMapView({Key? key, required this.doctor}) : super(key: key);

  @override
  State<DoctorMapView> createState() => _DoctorMapViewState();
}

class _DoctorMapViewState extends State<DoctorMapView> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _setupMarker();
  }

  void _setupMarker() {
    if (widget.doctor.location != null) {
      final marker = Marker(
        markerId: MarkerId(widget.doctor.id),
        position: LatLng(
          widget.doctor.location!.latitude,
          widget.doctor.location!.longitude,
        ),
        infoWindow: InfoWindow(
          title: widget.doctor.name,
          snippet: widget.doctor.address,
        ),
      );
      setState(() {
        _markers = {marker};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doctor.location == null) {
      return const Center(child: Text('Location not available'));
    }

    return GoogleMap(
      onMapCreated: (controller) => _controller = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          widget.doctor.location!.latitude,
          widget.doctor.location!.longitude,
        ),
        zoom: 15.0,
      ),
      markers: _markers,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      zoomControlsEnabled: true,
      myLocationEnabled: true,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}