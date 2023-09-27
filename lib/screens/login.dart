import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  static String routeName = "/login";
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController configsController = TextEditingController();
  late Timer timer;
  String urlDownload = '';
  String version = '1.0';
  String configs = 'iloadapi.harmonious.co.th';
  late List<FocusNode> focusNodes = List.generate(1, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    setState(() {
      version = '1.0';
      configs = 'hmcsmart.harmonious.co.th';
    });
    setSharedPrefs();
    //checkVersionAPK();
  }

  Future<void> setSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool checkConfigsPrefs = prefs.containsKey('configs');

    if (checkConfigsPrefs) {
      configs = prefs.getString('configs')!;
    } else {
      await prefs.setString('configs', 'iloadapi.harmonious.co.th');
      configs = prefs.getString('configs')!;
    }
  }

  /*Future<void> checkVersionAPK() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('configs') != null) {
        configs = prefs.getString('configs')!;
      }

      
      var url = Uri.parse(
          'https://' + configs + '/api/Documents/CheckVersion/' + version);

      http.Response response = await http.get(url);

      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 400) {
        late checkVersion result;
        setState(() {
          result = checkVersion.fromJson(data);
          urlDownload = result.url!;
        });

        String type = 'Warning';
        Icon icon = Icon(Icons.info_outline, color: Colors.lightBlue);
        switch (type) {
          case "Success":
            icon = Icon(Icons.check_circle_outline, color: Colors.lightGreen);
            break;
          case "Error":
            icon = Icon(Icons.error_outline, color: Colors.redAccent);
            break;
          case "Warning":
            icon =
                Icon(Icons.warning_amber_outlined, color: Colors.orangeAccent);
            break;
          case "Infomation":
            icon = Icon(Icons.info_outline, color: Colors.lightBlue);
            break;
        }

        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext builderContext) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  title: Row(children: [icon, Text(" " + type)]),
                  content: Text('Please Update Lastest Version'),
                  actions: <Widget>[
                    new TextButton(
                      child: new Text("OK"),
                      onPressed: () {
                        launchUrlDownload(urlDownload);
                      },
                    ),
                  ],
                ),
              );
            }).then((val) {});
      } else {
        showErrorDialog('Error checkVersion');
      }
    } catch (e) {
      showErrorDialog('Error occured while checkVersion');
    }
  }

  Future<void> launchUrlDownload(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }*/

  void alertDialog(String msg, String type) {
    Icon icon = Icon(Icons.info_outline, color: Colors.lightBlue);
    switch (type) {
      case "Success":
        icon = Icon(Icons.check_circle_outline, color: Colors.lightGreen);
        break;
      case "Error":
        icon = Icon(Icons.error_outline, color: Colors.redAccent);
        break;
      case "Warning":
        icon = Icon(Icons.warning_amber_outlined, color: Colors.orangeAccent);
        break;
      case "Infomation":
        icon = Icon(Icons.info_outline, color: Colors.lightBlue);
        break;
    }

    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          timer = Timer(Duration(seconds: 5), () {
            Navigator.of(context, rootNavigator: true).pop();
          });

          return AlertDialog(
            title: Row(children: [icon, Text(" " + type)]),
            content: Text(msg),
          );
        }).then((val) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }

  void showErrorDialog(String error) {
    alertDialog(error, 'Error');
  }

  void showSuccessDialog(String success) {
    alertDialog(success, 'Success');
  }

  Future<void> showProgressLoading(bool finish) async {
    ProgressDialog pr = ProgressDialog(context);
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: true);
    pr.style(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    if (finish == false) {
      await pr.show();
    } else {
      await pr.hide();
    }
  }

  Future<void> checkLogin() async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
  }

  Widget _titleWidget() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.215,
      width: MediaQuery.of(context).size.width * 0.55,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            'assets/hmc_logo.png',
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width * 1.2,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _bottomWidget() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height / 8,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: MediaQuery.of(context).size.width / 2.5,
            child: Image.asset("assets/shms1.png", width: size.width * 0.38),
          ),
          Positioned(
            right: MediaQuery.of(context).size.width / 80,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('1.2'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[400], //
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _contextWidget() {
    return Column(
      children: <Widget>[
        _entryFieldUsername("Usernamr", isPassword: false),
        SizedBox(height: 12),
        _entryFieldPassword("Password", isPassword: true),
      ],
    );
  }

  Widget _entryFieldUsername(String title, {bool isPassword = false}) {
    return Visibility(
        visible: true,
        child: SizedBox(
            child: TextFormField(
          controller: usernameController,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: Image.asset(
                  "assets/username.gif",
                  width: 1,
                  height: 1,
                )),
            hintText: 'Username',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10)),
            prefix: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12.0),
            ),
          ),
        )));
  }

  Widget _entryFieldPassword(String title, {bool isPassword = true}) {
    return Visibility(
        visible: true,
        child: TextFormField(
          obscureText: true,
          controller: passwordController,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12.0),
                child: Image.asset(
                  "assets/password.gif",
                  width: 1,
                  height: 1,
                )),
            hintText: 'Password',
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black12),
                borderRadius: BorderRadius.circular(10)),
            prefix: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
            ),
          ),
        ));
  }

  Widget _LoginButtonWidget() {
    return InkWell(
        child: Visibility(
      visible: true,
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(vertical: 1),
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: RoundedLoadingButton(
            color: Colors.blue.shade300,
            successColor: Color(0xfffbb448).withAlpha(100),
            controller: _btnController,
            onPressed: () async {
              await checkLogin();
            },
            valueColor: Colors.black,
            child: Text('Login', style: TextStyle(color: Colors.white))),
      ),
    ));
  }

  Widget _editWidget() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height / 11,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            right: MediaQuery.of(context).size.width / 4,
            child: ElevatedButton(
              onPressed: () {},
              child: const Icon(
                Icons.settings,
                size: 30,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return exit(0);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xfff7f6fb),
            body: Container(
                child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    children: [
                      //SizedBox(height: 4),
                      _titleWidget(),
                      SizedBox(height: 18),
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _contextWidget(),
                            SizedBox(height: 18),
                            _LoginButtonWidget(),
                            SizedBox(height: 8),
                            _editWidget(),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      _bottomWidget(),
                    ],
                  ),
                ),
              ),
            ))));
  }
}
