import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chat_app/Person/Presentation/Cubit/ThemeCubit.dart';
import 'package:chat_app/Theme/Theme.dart';
import 'package:chat_app/config/ColorTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingTheme extends StatefulWidget {
  const SettingTheme({super.key});

  @override
  State<SettingTheme> createState() => _SettingThemeState();
}

class _SettingThemeState extends State<SettingTheme> {
  late bool _isSwitchOn;
  late String primaryColorString;
  late ThemeData? themeCurrent;
  late Color primaryColor;
  void changeTheme(value) async {
    setState(() {
      _isSwitchOn = value;
    });
    await context
        .read<Themecubit>()
        .changeTheme(value)
        .catchError((onError) {
      setState(() {
        _isSwitchOn = value;
      });
      showSnackBar.show_error('have error', context);
    });
  }

  bool checkMainColor(Color color) {
    final String colorString = Colortheme.colorToRGBA(color);
    return colorString == primaryColorString;
  }

  void changeMainColor(Color color) async {
    setState(() {
      primaryColorString = Colortheme.colorToRGBA(color);
    });
    if(themeCurrent == getTheme(primaryColor, Brightness.light)){
      await context.read<Themecubit>().changePrimaryColor(color);
    }else{
      await context.read<Themecubit>().changePrimaryColor(color);
    }
  }

  @override
  void initState() {
    themeCurrent = context.read<Themecubit>().theme;
    primaryColor = context.read<Themecubit>().primaryColor;
    if (themeCurrent == getTheme(primaryColor, Brightness.light)) {
      _isSwitchOn = false;
    } else {
      _isSwitchOn = true;
    }
    print(_isSwitchOn);
    primaryColorString = Colortheme.colorToRGBA(primaryColor);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: Theme.of(context).colorScheme.primaryContainer,
            )),
        title: Text(
          'Setting Theme',
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primaryContainer,
              fontWeight: FontWeight.w500),
        ),
      ),
      body: Column(
        children: [
          //Setting theme dark light
          _settingTheme(),
          //Setting main color
          _settingMainColor('Green')
        ],
      ),
    );
  }

  Widget _settingTheme() {
    return SwitchListTile(
      value: _isSwitchOn,
      title: Text(
        'Theme Mode',
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      onChanged: (value) => changeTheme(value),
      subtitle: Text(
        _isSwitchOn ? 'Dark' : 'Light',
        style: TextStyle(
            fontSize: 14, color: Theme.of(context).colorScheme.surface),
      ),
      secondary: Icon(
        Icons.colorize_sharp,
        size: 30,
        color: Theme.of(context).colorScheme.surface,
      ),
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveThumbColor: Theme.of(context).colorScheme.primary,
      inactiveTrackColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  Widget _settingMainColor(String colorName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Icon(
            Icons.color_lens_sharp,
            size: 24,
            color: Theme.of(context).colorScheme.surface,
          ),
          const SizedBox(
            width: 20.0,
          ),
          Text(
            'Main color',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              for (int i = 0; i < Colortheme.colorList.length; i++)
                _itemColor(Colortheme.colorList[i])
            ],
          )
        ],
      ),
    );
  }

  Widget _itemColor(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: GestureDetector(
        onTap: () => !checkMainColor(color) ? changeMainColor(color) : null,
        child: Container(
          height: MediaQuery.of(context).size.width * 0.08,
          width: MediaQuery.of(context).size.width * 0.08,
          alignment: Alignment.topRight,
          decoration: BoxDecoration(
              color: color,
              border: checkMainColor(color)
                  ? Border.all(
                      color: Theme.of(context).colorScheme.surface, width: 1)
                  : null),
          child: checkMainColor(color)
              ? Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.check,
                    size: 10,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
          // child: ,
        ),
      ),
    );
  }
}
