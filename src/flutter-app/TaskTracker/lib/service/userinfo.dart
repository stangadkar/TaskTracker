/*
 * Copyright (c) 2020 by Botorabi. All rights reserved.
 * https://github.com/botorabi/TaskTracker
 *
 * License: MIT License (MIT), read the LICENSE text in
 *          main directory for more details.
 */

import 'dart:convert';

import 'package:TaskTracker/common/utf8.utils.dart';

class UserInfo {

  static const String ROLE_PREFIX = 'ROLE_';

  int id;
  String realName = '';
  String login = '';
  String email = '';
  String password = '';
  DateTime dateCreation;
  DateTime lastLogin;
  List<String> roles = [];

  UserInfo();

  bool isAdmin() {
    return ((roles != null) && roles.contains("ROLE_ADMIN"));
  }

  factory UserInfo.fromMap(final Map<String, dynamic> fields) {
    UserInfo userInfo = UserInfo();
    userInfo.id = fields['id'];
    userInfo.realName = Utf8Utils.fromUtf8(fields['realName']);
    userInfo.login = Utf8Utils.fromUtf8(fields['login']);
    if (fields['email'] != null) {
      userInfo.email = Utf8Utils.fromUtf8(fields['email']);
    }
    if (fields['dateCreation'] != null) {
      userInfo.dateCreation = DateTime.parse(fields['dateCreation'].toString());
    }
    if (fields['lastLogin'] != null) {
      userInfo.lastLogin = DateTime.parse(fields['lastLogin'].toString());
    }
    if (fields['roles'] != null) {
      userInfo.roles = List.from(fields['roles']);
    }
    userInfo.password = '';
    return userInfo;
  }

  factory UserInfo.fromJsonString(final String jsonString) {
    Map<String, dynamic> fields = jsonDecode(jsonString);
    return UserInfo.fromMap(fields);
  }

  static List<UserInfo> listFromJsonString(final String jsonString) {
    List<UserInfo> userInfoList = List<UserInfo>();
    dynamic users = jsonDecode(jsonString);
    users.forEach((element) {
      userInfoList.add(UserInfo.fromMap(element));
    });
    return userInfoList;
  }

  Map toJson() {
    return {
      'id' : id,
      'realName' : realName,
      'login' : login,
      'email' : email,
      'password': password,
      'roles' : roles?.toList()
    };
  }
}
