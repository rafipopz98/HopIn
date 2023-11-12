import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopin/Model/direction_detail_info.dart';
import 'package:hopin/Model/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel?userModelCurrentInfo;

DirectionsDeatilsInfo? tripDirectionDetailsInfo;

String userDropOffAddress="";