import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class LocationService{

  //Obtener el permiso apra la ubicacion
  Future<bool> handlePermission() async {

    bool permissionEnabled;
    LocationPermission permission;

    permissionEnabled = await Geolocator.isLocationServiceEnabled();

    if(!permissionEnabled){
      return false;
    }

    permission = await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission==LocationPermission.denied){
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever){
      return false;
    }

    return true;
  }

  //Obtener la ubicacion actual
  Future<Position?> getLocation() async {
    if(await handlePermission()){
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
    }
    return null;
  }



}