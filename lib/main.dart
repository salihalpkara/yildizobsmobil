import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}
var link = "https://obs.yildiz.edu.tr/oibs/ogrenci/login.aspx";



class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();

  final TextEditingController secCodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late FocusNode secFocusNode;
  late FocusNode usernameFocusNode;
  late FocusNode passwordFocusNode;
  late String secCode;
  late int webviewwidth;

  void logOut() async {
    await webViewController.evaluateJavascript(source:
    "__doPostBack('btnRefresh',''); __doPostBack('btnLogout','');");
  }

  void login() async {
    await UserSecureStorage.setUsername(usernameController.text);
    await UserSecureStorage.setPassword(passwordController.text);
    await webViewController.evaluateJavascript(source:
    "document.getElementById('txtParamT01').value = '${usernameController.text}';");
    await webViewController.evaluateJavascript(source:
    "document.getElementById('txtParamT02').value = '${passwordController.text}';");
    await webViewController.evaluateJavascript(source:
    "document.getElementById('txtSecCode').value = '${secCodeController.text}';");
    await webViewController.evaluateJavascript(source: "document.getElementById('btnLogin').click();");
  }

  @override
  void initState() {
    super.initState();
    secFocusNode = FocusNode();
    usernameFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    init();
    secCodeController.text = '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      adjustForm();
    });
  }

  Future init() async {
    final name = await UserSecureStorage.getUsername() ?? '';
    final password = await UserSecureStorage.getPassword() ?? '';

    setState(() {
      usernameController.text = name;
      passwordController.text = password;
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
    await webViewController.evaluateJavascript(source:
    "setInterval(function() {window.location.reload();}, 300000); var imgCaptchaImg = document.getElementById('imgCaptchaImg'); document.body.appendChild(imgCaptchaImg); imgCaptchaImg.style.width = 'auto';imgCaptchaImg.style.height = 'auto';document.getElementById('form1').style.display = 'none';document.getElementById('imgCaptchaImg').onclick = '';");
  }

  void goToHomePage(String compurl) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomePage(redirecturl: compurl)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: Image.asset("assets/images/ytu_logo.png"),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                focusNode: usernameFocusNode,
                onSubmitted: (username) {
                  setState(() {
                    UserSecureStorage.setUsername(username);
                  });
                  FocusScope.of(context).requestFocus(passwordFocusNode);
                },
                controller: usernameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: "Kullanıcı Adı",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                onSubmitted: (password) {
                  setState(() {
                    UserSecureStorage.setPassword(password);
                  });
                  FocusScope.of(context).requestFocus(secFocusNode);
                },
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: "Şifre",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: TextField(
                focusNode: secFocusNode,
                controller: secCodeController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                  labelText: "Güvenlik Kodu",
                  icon: SizedBox(
                    width: 177,
                    height: 40,
                    child: InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: Uri.parse(link)),
                      onWebViewCreated: (InAppWebViewController controller) {
                        webViewController = controller;
                        logOut();
                      },
                      onLoadStart: (InAppWebViewController controller, Uri? url) {
                      },
                      onLoadStop: (InAppWebViewController controller, Uri? url) {
                        if (url.toString() != link) {
                          goToHomePage(url.toString());
                        } else {
                          adjustForm();
                          secCodeController.clear();}
                      },
                    ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffa19065)),
              onPressed: () {

                login();
              },
              child: const Text("Giriş Yap"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
            logOut();
          });
        },
        child: const Icon(Icons.loop_outlined),
      ),
    );
  }
}

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyStudentName = 'studentName';
  static Future setPassword(String password) async =>
      await _storage.write(key: _keyPassword, value: password);
  static Future setStudentName(String studentName) async =>
      await _storage.write(key: _keyStudentName, value: studentName);
  static Future setUsername(String username) async =>
      await _storage.write(key: _keyUsername, value: username);
  static Future<String?> getPassword() async =>
      await _storage.read(key: _keyPassword);
  static Future<String?> getUsername() async =>
      await _storage.read(key: _keyUsername);
  static Future<String?> getStudentName() async =>
      await _storage.read(key: _keyStudentName);
}

class HomePage extends StatefulWidget {
  final String? redirecturl;
  const HomePage({Key? key, required this.redirecturl}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();

  void logOut() async {
    await webViewController.evaluateJavascript(source:
    "__doPostBack('btnRefresh',''); __doPostBack('btnLogout','');");
  }

  void goToLoginPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return false;
        } else {
          logOut();
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(
                url: Uri.parse(widget.redirecturl.toString())),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (InAppWebViewController controller, Uri? url) {
            },
            onLoadStop: (InAppWebViewController controller, Uri? url) {
              if (url.toString() == link) {
                goToLoginPage();
                // Navigator.push(context,
                //     MaterialPageRoute(
                //         builder: (context) => const LoginPage()));
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              logOut();
            },
            child: const Icon(Icons.logout_sharp),
          ),
        ),
      ),
    );
  }
}
