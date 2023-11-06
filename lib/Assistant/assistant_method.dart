import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hopin/Assistant/request_assistan.dart';
import 'package:hopin/Model/directions.dart';
import 'package:hopin/Model/user_model.dart';
import 'package:hopin/global/global.dart';
import 'package:hopin/global/map_key.dart';
import 'package:hopin/infoHandler/app_info.dart';
import 'package:provider/provider.dart';
class AssistantMethods {
  static void readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child("users").child(currentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCoordinates(
      Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestRespsonse = await RequstAssistant.recieveRequest(apiUrl);

    if (requestRespsonse != "Error Occured,Failed,No Response") {
      humanReadableAddress =
          requestRespsonse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context,listen:false).updatePickUpLocationAddress(userPickUpAddress);

    }

    return humanReadableAddress;
  }
}
