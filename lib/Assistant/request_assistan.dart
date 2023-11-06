import 'dart:convert';

import 'package:http/http.dart' as http;

class RequstAssistant{
  static Future<dynamic> recieveRequest(String url)async{
    http.Response httpResponse=await http.get(Uri.parse(url));

    try{

      if(httpResponse.statusCode==200){
        String responseData=httpResponse.body;
        var decodeResponseData=jsonDecode(responseData);

        return decodeResponseData;
      }
      else{
        return "Error Occured,Failed,No Response";
      }

    }catch(e){
      return "Error Occured,Failed,No Response";
    }
  }
}