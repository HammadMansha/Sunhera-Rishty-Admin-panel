import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/BlockedUsersProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/ConnectionProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/contactsProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/favouriteUserProvider.dart';
import 'package:sunhare_rishtey_new_admin/Impersonate/provider/userRequestProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/PartnerPrefsProvider.dart';
import 'package:sunhare_rishtey_new_admin/provider/groupProvider.dart';
import 'Impersonate/provider/imagesProvider.dart';
import 'provider/getAllUserProvider.dart';
import 'provider/getTrashUsers.dart';
import 'provider/userActionsProvider.dart';
import 'package:provider/provider.dart';
import 'auth/authService.dart';
import 'config/theme.dart';

AppThemeData theme = AppThemeData();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: HexColor('70c4bc'), // status bar color
    ),
  );

  await Firebase.initializeApp();
  theme.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AllUser(),
        ),
        ChangeNotifierProvider(
          create: (_) => TrashUsers(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserActions(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GroupdedProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PartnerPrefsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ImageListProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => BlockedUsersProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserRequests(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavUsers(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin',
      home: AuthService().checkAuth(),
    );
  }
}
