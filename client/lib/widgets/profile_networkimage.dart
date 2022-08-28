import 'package:flutter/material.dart';

NetworkImage profileNetworkImage(String serviceUrl,String token,String email) {
  return NetworkImage('http://$serviceUrl/api/user_avatar/', headers : {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json; charset=UTF-8",
    "Accept": "application/json",
    "Authorization": "Bearer $token|:|:|$email"
  });
}