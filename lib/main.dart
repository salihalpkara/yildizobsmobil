import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() => runApp(const MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    ));

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final WebViewController controller;
  final TextEditingController secCodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final secFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  var secCode;
  var webviewwidth;

  void logOut() async {
    await controller.runJavaScript("__doPostBack('btnLogout','');");
  }

  bool isLoggedIn = false;
  void login() async {
    await UserSecureStorage.setUsername(usernameController.text);
    await UserSecureStorage.setPassword(passwordController.text);
    await controller.runJavaScript(
        "document.getElementById('txtParamT01').value = '${usernameController.text}';");
    await controller.runJavaScript(
        "document.getElementById('txtParamT02').value = '${passwordController.text}';");
    await controller.runJavaScript(
        "document.getElementById('txtSecCode').value = '${secCodeController.text}';");
    await controller
        .runJavaScript("document.getElementById('btnLogin').click();");
    Future.delayed(const Duration(seconds: 2), () async {
      final String? finalurl = await controller.currentUrl();
      String compurl = finalurl.toString();
      if (compurl != "https://obs.yildiz.edu.tr/oibs/ogrenci/login.aspx") {
        goToHomePage(compurl);
      }
    });

    // while (controller.currentUrl ==
    //     "https://obs.yildiz.edu.tr/oibs/ogrenci/login.aspx") {
    //   await Future.delayed(Duration(milliseconds: 20000));
    // }
    // final String? finalurl = await controller.currentUrl();
    // String compurl = finalurl.toString();
    // goToHomePage(compurl);
  }

  @override
  void initState() {
    super.initState();

    init();
    secCodeController.text = '';
    var link = "https://obs.yildiz.edu.tr/oibs/ogrenci/login.aspx";

    // #docregion webview_controller
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            adjustForm();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(link));
    controller.reload();

    // #enddocregion webview_controller

    WidgetsBinding.instance.addPostFrameCallback((_) => adjustForm());
  }

  Future init() async {
    final name = await UserSecureStorage.getUsername() ?? '';
    final password = await UserSecureStorage.getPassword() ?? '';

    setState(() {
      usernameController.text = name;
      passwordController.text = password;
    });
  }

  void adjustForm() async {
    await controller.runJavaScript(
        "var imgCaptchaImg = document.getElementById('imgCaptchaImg'); document.body.appendChild(imgCaptchaImg); imgCaptchaImg.style.width = 'auto';imgCaptchaImg.style.height = 'auto';document.getElementById('form1').style.display = 'none';document.getElementById('imgCaptchaImg').onclick = '';");
  }

  void goToHomePage(String compurl) {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomePage(url: compurl)));
  }

  @override
  Widget build(BuildContext context) {
    login();
    if (usernameController.text == '') {
      FocusScope.of(context).requestFocus(usernameFocusNode);
    } else if (passwordController.text == '') {
      FocusScope.of(context).requestFocus(passwordFocusNode);
    } else {
      FocusScope.of(context).requestFocus(secFocusNode);
    }
    return Scaffold(
      body: Form(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
              child: Image.asset("assets/images/ytu_logo.png"),
            ),
            Text("Hoşgeldin ${usernameController.text}"),
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
                    child: WebViewWidget(controller: controller),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xffa19065)),
              onPressed: () {
                login();
              },
              child: Text("Giriş Yap"),
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
        child: Icon(Icons.loop_outlined),
      ),
    );
  }
}

class UserSecureStorage {
  static final _storage = FlutterSecureStorage();
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static Future setPassword(String password) async =>
      await _storage.write(key: _keyPassword, value: password);
  static Future setUsername(String username) async =>
      await _storage.write(key: _keyUsername, value: username);
  static Future<String?> getPassword() async =>
      await _storage.read(key: _keyPassword);
  static Future<String?> getUsername() async =>
      await _storage.read(key: _keyUsername);
}

class HomePage extends StatefulWidget {
  String? url;
  HomePage({Key? key, required this.url}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> logOut() async {
    await controller.runJavaScript("__doPostBack('btnLogout','');");
  }

  void goToLoginPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  late final WebViewController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url.toString()));
    // #enddocregion webview_controller
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        } else {
          logOut();
          Future.delayed(Duration(seconds: 2), () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginPage()));
          });
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: WebViewWidget(
            controller: controller,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              logOut();
              Future.delayed(Duration(seconds: 2), () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              });
            },
            child: Icon(Icons.logout_sharp),
          ),
        ),
      ),
    );
  }
}
