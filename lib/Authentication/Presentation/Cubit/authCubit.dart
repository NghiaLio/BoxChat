import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Domains/Repo/UserRepo.dart';
import 'authState.dart';

class AuthCubit extends Cubit<authState>{
  final UserRepo userRepo;
  AuthCubit({required this.userRepo}) : super(initialAuth());

  UserApp? _user;

  UserApp? get userData => _user;
  //check login
  Future<UserApp?> checkAuth()async{
    final UserApp? user = await userRepo.getCurrentUser();

    if(user != null){
      _user = user;
      emit(Authenticated(user));
    }else{
      emit(UnAuthenticated());
    }
    return null;
  }
  //getUser 
  Future<UserApp?> getUser()async{
    final UserApp? user = await userRepo.getCurrentUser();
    _user = user;
    return user;
  }
  //login
  Future<void> login(String email, String password)async{
    try{
      UserApp? user = await userRepo.login(email, password);
      if(user != null){
        _user = user;
        emit(Authenticated(user));
      }else{
        emit(FailAuth('Tài khoản hoặc mật khẩu không đúng'));
        emit(UnAuthenticated());
      }
    }catch(e){
      emit(FailAuth('Có lỗi'));
    }
  }
  //register
  Future<void> register(String name, String email, String password) async{
    try{
      UserApp? user = await userRepo.register(name, email, password);
      if(user != null){
        _user = user;
        emit(UnAuthenticated());
      }else{
        emit(FailAuth('Tạo tài khoản thất bại, thử lại sau'));
        emit(UnAuthenticated());
      }
    }catch(e){
      emit(FailAuth('Tạo tài khoản thất bại, thử lại sau'));
    }
  }
  //update online
  Future<void> updateIsOnline(bool isOnline)async {
    await userRepo.updateOnline(isOnline);
  }

  //logout
  Future<void> logOut()async{
    await updateIsOnline(false);
    await userRepo.logOut();
    emit(UnAuthenticated());
  }

  //Reset password
  Future<String?> resetPass(String email) async{
   final String? result = await userRepo.resetPassword(email);
   if(result == null){
     return null;
   }else{
     return result;
   }
  }
}