// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ChangeNotifierProvider(
    create: (context) => ThemeProvider(),
    builder: (context, _) {
      final themeProvider = Provider.of<ThemeProvider>(context);
      return MaterialApp(
        themeMode: themeProvider.themeMode,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      );
    },
  ));
}

class MyThemes {
  static final darkTheme = ThemeData(
    textTheme: GoogleFonts.ubuntuTextTheme().apply(bodyColor: Colors.white),
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(
      primary: Color.fromARGB(255, 37, 150, 190),
      secondary: Color(0xffa19065),
    ),
  );
  static final lightTheme = ThemeData(
    textTheme: GoogleFonts.ubuntuTextTheme(),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 37, 150, 190),
      secondary: Color(0xffa19065),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.dark;
  bool get isDarkMode => themeMode == ThemeMode.dark;

  ThemeProvider() {
    _getThemePreference();
  }

  Future<void> _getThemePreference() async {
    final themePreference = await UserSecureStorage.getTheme() ?? "true";
    themeMode = themePreference == "true" ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference(isOn);
    notifyListeners();
  }

  Future<void> _saveThemePreference(bool isOn) async {
    await UserSecureStorage.setTheme(isOn.toString());
  }
}

class ChangeThemeButtonWidget extends StatelessWidget {
  const ChangeThemeButtonWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Switch.adaptive(
        activeThumbImage: const AssetImage("assets/images/moonicon.png"),
        inactiveThumbImage: const AssetImage("assets/images/sunicon.png"),
        activeColor: Colors.grey.shade700,
        value: themeProvider.isDarkMode,
        onChanged: (value) async {
          final provider = Provider.of<ThemeProvider>(context, listen: false);
          provider.toggleTheme(value);
        });
  }
}

var link = "https://obs.yildiz.edu.tr/oibs/ogrenci/login.aspx";

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late InAppWebViewController edevletcontroller;
  String edevletlink =
      "giris.turkiye.gov.tr/Giris/gir?oauthClientId=640cbd04-b79a-4457-8acf-323ac1d4075b&continue=https%3A%2F%2Fgiris.turkiye.gov.tr%2FOAuth2AuthorizationServer%2FAuthorizationController%3Fresponse_type%3Dcode%26client_id%3D640cbd04-b79a-4457-8acf-323ac1d4075b%26state%3DOgrenci%26scope%3DKimlik-Dogrula%253BAd-Soyad%26redirect_uri%3Dhttps%253A%252F%252Fobs.yildiz.edu.tr%252Frouter.aspx";
  String obsLink = "https://obs.yildiz.edu.tr/oibs/ogrenci/login.aspx";
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();
  final TextEditingController secCodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController TCKNController = TextEditingController();
  final TextEditingController eDevletPasswordController =TextEditingController();
  late FocusNode secFocusNode;
  late FocusNode usernameFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode eDevletPasswordFocusNode;
  late String secCode;
  late int webviewwidth;
  bool _obscureText = true;
  bool _obscureTCKN = true;
  bool _infoOffstage = true;
  bool _offstage = true;

  void logOut() async {
    await webViewController.evaluateJavascript(
        source: "__doPostBack('btnRefresh',''); __doPostBack('btnLogout','');");
  }

  void edevletgiris() {}

  void login() async {
    await UserSecureStorage.setUsername(usernameController.text);
    await UserSecureStorage.setPassword(passwordController.text);
    await webViewController.evaluateJavascript(
        source:
            "document.getElementById('txtParamT01').value = '${usernameController.text}';");
    await webViewController.evaluateJavascript(
        source:
            "document.getElementById('txtParamT02').value = '${passwordController.text}';");
    await webViewController.evaluateJavascript(
        source:
            "document.getElementById('txtSecCode').value = '${secCodeController.text}';");
    await webViewController.evaluateJavascript(
        source: "document.getElementById('btnLogin').click();");
  }

  @override
  void initState() {
    super.initState();
    secFocusNode = FocusNode();
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    eDevletPasswordFocusNode = FocusNode();
    init();
    secCodeController.text = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      adjustForm();
    });
  }

  Future init() async {
    final name = await UserSecureStorage.getUsername() ?? '';
    final password = await UserSecureStorage.getPassword() ?? '';
    final TCKN = await UserSecureStorage.getTCKN() ?? '';
    final eDevletPassword = await UserSecureStorage.getEdevletPassword() ?? '';

    setState(() {
      usernameController.text = name;
      passwordController.text = password;
      TCKNController.text = TCKN;
      eDevletPasswordController.text = eDevletPassword;
    });
    setFocus();
    login();
  }

  void setFocus() {
    if (usernameController.text == '') {
      FocusScope.of(context).requestFocus(usernameFocusNode);
    } else if (passwordController.text == '') {
      FocusScope.of(context).requestFocus(passwordFocusNode);
    } else {
      FocusScope.of(context).requestFocus(secFocusNode);
    }
  }

  void adjustForm() async {
    await webViewController.evaluateJavascript(
        source:
            "setInterval(function() {window.location.reload();}, 300000); var imgCaptchaImg = document.getElementById('imgCaptchaImg'); document.body.appendChild(imgCaptchaImg); imgCaptchaImg.style.width = 'auto';imgCaptchaImg.style.height = 'auto';document.getElementById('form1').style.display = 'none';document.getElementById('imgCaptchaImg').onclick = '';");
  }

  void goToHomePage(String compurl) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePage(redirecturl: compurl)));
  }

  void handleError(String error, FocusNode node) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    FocusScope.of(context).requestFocus(node);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 5,
                      child: Image.asset("assets/images/ytu_logo.png"),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Text(
                        "YTÜ Öğrenci Bilgi Sistemi",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: TextField(
                        focusNode: usernameFocusNode,
                        onSubmitted: (username) {
                          setState(() {
                            UserSecureStorage.setUsername(username);
                          });
                          FocusScope.of(context)
                              .requestFocus(passwordFocusNode);
                        },
                        controller: usernameController,
                        decoration: InputDecoration(
                          focusColor: const Color.fromARGB(255, 28, 39, 86),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          labelText: "Kullanıcı Adı",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: TextField(
                        controller: passwordController,
                        focusNode: passwordFocusNode,
                        onSubmitted: (password) {
                          setState(() {
                            UserSecureStorage.setPassword(password);
                          });
                          FocusScope.of(context).requestFocus(secFocusNode);
                        },
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          focusColor: const Color.fromARGB(255, 28, 39, 86),
                          suffixIcon: IconButton(
                            icon: AnimatedCrossFade(
                              firstChild: const Icon(Icons.visibility_off),
                              secondChild: const Icon(Icons.visibility),
                              crossFadeState: _obscureText
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                              duration: const Duration(milliseconds: 250),
                            ),
                            color: Colors.grey,
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          labelText: "Şifre",
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                      child: TextFormField(
                        focusNode: secFocusNode,
                        controller: secCodeController,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          focusColor: const Color.fromARGB(255, 28, 39, 86),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                logOut();
                              });
                            },
                            icon: const Icon(Icons.loop),
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          labelText: "Güvenlik Kodu",
                          icon: SizedBox(
                            width: 177,
                            height: 40,
                            child: InAppWebView(
                              key: webViewKey,
                              initialUrlRequest:
                                  URLRequest(url: Uri.parse(link)),
                              onWebViewCreated:
                                  (InAppWebViewController controller) {
                                webViewController = controller;
                              },
                              onLoadStart: (InAppWebViewController controller,
                                  Uri? url) {},
                              onLoadStop: (InAppWebViewController controller,
                                  Uri? url) async {
                                if (url.toString() != link) {
                                  goToHomePage(url.toString());
                                } else {
                                  String sonuc =
                                      await controller.evaluateJavascript(
                                              source:
                                                  "document.getElementById('lblSonuclar').innerHTML;")
                                          as String;
                                  if (sonuc ==
                                      'UYARI!! Aynı tarayıcıdan birden fazla giriş yapılamaz. Lütfen tüm açık tarayıcıları kapatın ve tarayıcınızı yeniden başlatın.') {
                                    controller.evaluateJavascript(
                                        source:
                                            "__doPostBack('btnRefresh','');");
                                  } else if (sonuc ==
                                      'Güvenlik kodu hatalı girildi !') {
                                    handleError("Güvenlik kodu hatalı girildi",
                                        secFocusNode);
                                  } else if (sonuc ==
                                      "HATA:D21032301:Kullanıcı adı veya şifresi geçersiz.") {
                                    handleError(
                                        "Kullanıcı Adı veya Şifre hatalı",
                                        passwordFocusNode);
                                  }
                                  adjustForm();
                                  secCodeController.clear();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Stack(children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 208, 1, 27),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: () {
                              setState(() {
                                _offstage = !_offstage;
                              });
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Image.asset(
                                      "assets/images/edevletgiris.png",
                                      height: 36,
                                      width: 36,
                                    ),
                                    const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("e-Devlet ile Giriş Yap")),
                                    Container(
                                        width: 0.5,
                                        height: 30,
                                        color: Colors.white.withOpacity(1)),
                                    const SizedBox(width: 10)
                                  ]),
                            ),
                          ),
                          Positioned(
                              right: -10,
                              child: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StatefulBuilder(
                                      builder: (context, setStatee) =>
                                          AlertDialog(
                                        title: const Text(
                                          "e-Devlet Giriş Bilgilerini Düzenle",
                                          textAlign: TextAlign.center,
                                        ),
                                        content: SizedBox(
                                          height: 195,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 10),
                                                child: TextField(
                                                  autofocus: true,
                                                  obscureText: _obscureTCKN,
                                                  controller: TCKNController,
                                                  onSubmitted: (TCKN) {
                                                    setState(() {
                                                      UserSecureStorage.setTCKN(
                                                          TCKN);
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                              eDevletPasswordFocusNode);
                                                    });
                                                  },
                                                  textInputAction:
                                                      TextInputAction.next,
                                                  decoration: InputDecoration(
                                                    focusColor:
                                                        const Color.fromARGB(
                                                            255, 28, 39, 86),
                                                    suffixIcon: IconButton(
                                                      icon: AnimatedCrossFade(
                                                        firstChild: const Icon(
                                                            Icons
                                                                .visibility_off),
                                                        secondChild: const Icon(
                                                            Icons.visibility),
                                                        crossFadeState:
                                                            _obscureTCKN
                                                                ? CrossFadeState
                                                                    .showFirst
                                                                : CrossFadeState
                                                                    .showSecond,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    250),
                                                      ),
                                                      color: Colors.grey,
                                                      onPressed: () {
                                                        setStatee(() {
                                                          _obscureTCKN =
                                                              !_obscureTCKN;
                                                        });
                                                      },
                                                    ),
                                                    border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    labelText:
                                                        "TC Kimlik Numarası",
                                                  ),
                                                ),
                                              ),
                                              TextField(
                                                controller:
                                                    eDevletPasswordController,
                                                onSubmitted: (password) {
                                                  UserSecureStorage
                                                      .setEdevletPassword(
                                                          password);
                                                },
                                                focusNode:
                                                    eDevletPasswordFocusNode,
                                                obscureText: true,
                                                decoration: InputDecoration(
                                                  focusColor:
                                                      const Color.fromARGB(
                                                          255, 28, 39, 86),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  labelText: "e-Devlet Şifresi",
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20),
                                                child: Text(
                                                  "e-Devlet ile girişlerinizde TCKN ve e-Devlet şifrenizin otomatik doldurulması için bu bölümü doldurabilirsiniz.",
                                                  style:
                                                      TextStyle(fontSize: 14),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  UserSecureStorage.setTCKN('');
                                                  UserSecureStorage
                                                      .setEdevletPassword('');
                                                  setState(() {
                                                    TCKNController.text = '';
                                                    eDevletPasswordController
                                                        .text = '';
                                                  });
                                                  Navigator.of(context).pop();
                                                  await edevletcontroller
                                                      .evaluateJavascript(
                                                          source:
                                                              "document.getElementById('tridField').value = ''; document.getElementById('egpField').value = '';");
                                                },
                                                child: const Text(
                                                  "Bilgileri Sil",
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      decoration: TextDecoration
                                                          .underline),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text(
                                                      "İptal",
                                                      style: TextStyle(
                                                          color: Colors.red),
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      UserSecureStorage.setTCKN(
                                                          TCKNController.text);
                                                      UserSecureStorage
                                                          .setEdevletPassword(
                                                              eDevletPasswordController
                                                                  .text);
                                                      Navigator.of(context)
                                                          .pop();
                                                      await edevletcontroller
                                                          .evaluateJavascript(
                                                              source:
                                                                  "document.getElementById('tridField').value = '${TCKNController.text}'; document.getElementById('egpField').value = '${eDevletPasswordController.text}';");
                                                    },
                                                    child: const Text("Kaydet"),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.settings,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ))
                        ]),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffa19065),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            login();
                          },
                          child: const Text("Giriş Yap"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: ChangeThemeButtonWidget(),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _infoOffstage = !_infoOffstage;
                        });
                        Future.delayed(const Duration(seconds: 5), () {
                          setState(() {
                            _infoOffstage = true;
                          });
                        });
                      },
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                    AnimatedOpacity(
                        opacity: _infoOffstage ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                            width: MediaQuery.of(context).size.width * 3/4,
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              "Bu uygulamada kullanılan ve kaydedilen hiçbir veri üçüncü bir taraf ile paylaşılmamakta olup hepsi cihazınızda şifrelenmiş bir şekilde saklanmaktadır.",
                              softWrap: true,
                              style: TextStyle(fontSize: 10),
                            ))),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: _offstage ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: Offstage(
                  offstage: _offstage,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _offstage = !_offstage;
                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width,
                          child: InAppWebView(
                            initialUrlRequest: URLRequest(url: Uri.parse(link)),
                            onWebViewCreated:(InAppWebViewController controller) {edevletcontroller = controller;},
                            onLoadStart: (InAppWebViewController controller,Uri? url) {
                            },
                            onLoadStop: (InAppWebViewController controller,Uri? url) async {
                              controller.evaluateJavascript(source:"__doPostBack('btnEdevletLogin','');");
                              Future.delayed(const Duration(seconds: 1),() async {
                                await controller.evaluateJavascript(source:"document.getElementById('smartbanner').style.display = 'none'; document.querySelector('#loginForm > div.formSubmitRow > input.backButton').style.display = 'none';");
                                await controller.scrollTo(x: 0, y: 840);
                                String tckn =await UserSecureStorage.getTCKN() ?? '';
                                String eDevletPassword = await UserSecureStorage.getEdevletPassword() ??'';
                                if (tckn.isNotEmpty && eDevletPassword.isNotEmpty) {
                                  await controller.evaluateJavascript(source:"document.getElementById('tridField').value = '$tckn'; document.getElementById('egpField').value = '$eDevletPassword';");}
                              });
                              Uri? location = await controller.getUrl();
                              if (await controller.canGoBack() && location.toString() != edevletlink) {
                                goToHomePage(location.toString());
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future openEdevletDialog() async {
    setState(() {
      _offstage = !_offstage;
    });
  }
}

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyTheme = 'dark';
  static const _keyEdevletTCKN = 'TCKN';
  static const _keyEdevletPassword = 'edevletPassword';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyStudentName = 'studentName';
  static Future setTheme(String isDark) async =>
      await _storage.write(key: _keyTheme, value: isDark);
  static Future setTCKN(String TCKN) async =>
      await _storage.write(key: _keyEdevletTCKN, value: TCKN);
  static Future setEdevletPassword(String password) async =>
      await _storage.write(key: _keyEdevletPassword, value: password);
  static Future setPassword(String password) async =>
      await _storage.write(key: _keyPassword, value: password);
  static Future setStudentName(String studentName) async =>
      await _storage.write(key: _keyStudentName, value: studentName);
  static Future setUsername(String username) async =>
      await _storage.write(key: _keyUsername, value: username);
  static Future<String?> getTCKN() async =>
      await _storage.read(key: _keyEdevletTCKN);
  static Future<String?> getEdevletPassword() async =>
      await _storage.read(key: _keyEdevletPassword);
  static Future<String?> getTheme() async =>
      await _storage.read(key: _keyTheme);
  static Future<String?> getPassword() async =>
      await _storage.read(key: _keyPassword);
  static Future<String?> getUsername() async =>
      await _storage.read(key: _keyUsername);
  static Future<String?> getStudentName() async =>
      await _storage.read(key: _keyStudentName);
}
