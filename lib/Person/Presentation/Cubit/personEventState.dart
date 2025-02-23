// ignore_for_file: camel_case_types

import '../../../Authentication/Domains/Entity/User.dart';

class personEventState{}

class initialPersonState extends personEventState{}

class updating extends personEventState{
 
}

class updateSuccess extends personEventState{
  UserApp? user;
  updateSuccess(this.user);
}

class updateFailed extends personEventState{}