import 'package:chat_app/Components/Navigation/NavigationState.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<NavigationState>{
  NavigationCubit() : super(NavigationState(0));
  void changeIndex(int index){
    emit(NavigationState(index));
  }
}