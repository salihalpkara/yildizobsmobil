import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  final String? redirecturl;
  const HomePage({Key? key, required this.redirecturl}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();
  String framehtml = '';
  String pagehtml = '';
  List navItems = [];
  int bottomNavIndex = 2;

  // List<String> branches = [];
  // List<String> subjectCodes = [];
  // List<String> subjects = [];
  // List<String> lastState = [];
  // List<String> grades = [];
  // List<String> averages = [];
  // List<String> letterGrades = [];
  // List<String> states = [];

  // Future getWebsiteData(String rawHtml) async {
  //   dom.Document html = parse(rawHtml);
  //   final navlinks = html.getElementsByClassName('nav-link');
  //   print(navlinks[1]);
  // }

  void logOut() async {
    await webViewController.evaluateJavascript(
        source: "__doPostBack('btnRefresh',''); __doPostBack('btnLogout','');");
  }

  void goToLoginPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void createItems() async {
    LineSplitter ls = const LineSplitter();
    dom.Document html = dom.Document.html(pagehtml);
    final navItems = html
        .querySelectorAll('.nav-item.has-treeview')
        .map((element) => element.text)
        .toList();
    setState(() {
      this.navItems = navItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return false;
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                        TextButton(
                            onPressed: () {
                              logOut();
                              Navigator.of(context).pop();
                            },
                            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.red, decoration: TextDecoration.underline),)),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Sitede Kal")),
                      ]),
                    ],
                    title: const Text("Çıkış yapmak istiyor musunuz?"),
                  ));
          return false;
        }
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              bottomNavIndex = index;
            });
            switch (index) {
              case 0:
                logOut();
                break;
              case 1:
                webViewController.evaluateJavascript(
                    source:
                        "menu_close(this,'start.aspx?gkm=00233219833291388643775636606311143523032194333453444836720385043439638936355703756034388388243330337427341963524035280');");
                break;
              case 2:
                webViewController.evaluateJavascript(
                    source: "__doPostBack('','');");
                break;
              case 3:
                webViewController.evaluateJavascript(
                    source:
                        "menu_close(this,'start.aspx?gkm=00233219833291388643775636606311143523032194333453444836720385043439638936355703756034388388243330337427341963524035275');");
                break;
              case 4:
                webViewController.evaluateJavascript(
                    source:
                        "menu_close(this,'start.aspx?gkm=00233219833291388643775636606311143523032194333453444836720385043439638936355703756034388388243330337427341963524535260');");
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          currentIndex: bottomNavIndex,
          items: [
            BottomNavigationBarItem(
                icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: const Icon(Icons.logout, color: Colors.red,)),
                label: "Çıkış"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month), label: "Ders Programı"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.home_sharp), label: "Ana Sayfa"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.note_alt_outlined), label: "Not Listesi"),
            const BottomNavigationBarItem(
                icon: Icon(Icons.mail), label: "Gelen Mesajlar"),
          ],
        ),
        body: SafeArea(
          child: InAppWebView(
            onConsoleMessage: (controller, consoleMessage) {
              print('Console Message: ${consoleMessage.message}');
              framehtml = consoleMessage.message;
              setState(() {});
            },
            key: webViewKey,
            initialUrlRequest:
                URLRequest(url: Uri.parse(widget.redirecturl.toString())),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (InAppWebViewController controller, Uri? url) {},
            onLoadStop:
                (InAppWebViewController controller, Uri? url) async {
              if (url.toString() == link) {
                goToLoginPage();
              }
              // else {
              //   framehtml = await controller.evaluateJavascript(
              //       source:
              //           "var frameObj =document.getElementById('IFRAME1');var frameContent = frameObj.contentWindow.document.body; frameContent.innerHTML.toString();");
              //   pagehtml = await controller.evaluateJavascript(
              //       source: "document.body.innerHTML;");
              //   createItems();
              //   setState(() {});
              //   print(pagehtml);
              // }
            },
          ),
        ),
      ),
    );
  }
}
