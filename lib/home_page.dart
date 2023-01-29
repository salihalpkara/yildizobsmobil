import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
  DateTime timeBackPressed = DateTime.now();
  bool exitWarningOpacity = false;
  List navItems = [];
  int bottomNavIndex = 2;

  void logOut() async {
    await webViewController.evaluateJavascript(
        source: "__doPostBack('btnRefresh',''); __doPostBack('btnLogout','');");
  }

  void goToLoginPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return false;
        } else {
          final difference = DateTime.now().difference(timeBackPressed);
          final isExitWarning = difference >= const Duration(seconds: 2);
          timeBackPressed = DateTime.now();

          if (isExitWarning) {
            setState(() {
              exitWarningOpacity = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                exitWarningOpacity = false;
              });
            });
            return false;
          } else {
            logOut();
            return false;
          }
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
                    child: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    )),
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
          child: Stack(children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest:
                  URLRequest(url: Uri.parse(widget.redirecturl.toString())),
              onWebViewCreated: (InAppWebViewController controller) {
                webViewController = controller;
              },
              onLoadStart: (InAppWebViewController controller, Uri? url) {},
              onLoadStop: (InAppWebViewController controller, Uri? url) async {
                if (url.toString() == obsLink) {
                  goToLoginPage();
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedOpacity(
                    opacity: exitWarningOpacity ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      height: 36,
                      width: 160,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Çıkmak için tekrar basın",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
