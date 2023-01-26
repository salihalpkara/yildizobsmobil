import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

class HomePage extends StatefulWidget {
  final String? redirecturl;
  const HomePage({Key? key, required this.redirecturl}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();
  final _scrollController = ScrollController();
  String framehtml = '';
  String pagehtml = '';
  List navItems = [];

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
    dom.Document html = dom.Document.html(pagehtml);
    final navItems = html
        .querySelectorAll('.nav-item.has-treeview')
        .map((element) => element.innerHtml)
        .toList();

    List topItems = [];
    List subItems = [];



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
          logOut();
          return false;
        }
      },
      child: Scaffold(
        drawer: Drawer(),
        appBar: AppBar(
          actions: [
            SizedBox(
              width: 70,
              child: IconButton(
                  onPressed: () {},
                  icon: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.output),
                        Text(
                          "Sitede aç",
                          style: TextStyle(fontSize: 8),
                        )
                      ],
                    ),
                  )),
            ),
            const ChangeThemeButtonWidget()
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Salih Alp KARA"),
              Text(
                "Matematik Mühendisliği",
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
        body: Stack(children: [
          Center(child: SingleChildScrollView(child: Text(navItems.length>1? navItems[1]: "", softWrap: false,),),),
          Offstage(
            offstage: true,
            child: SafeArea(
              child: Stack(children: [

                InAppWebView(
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
                    } else {
                      framehtml = await controller.evaluateJavascript(
                          source:
                              "var frameObj =document.getElementById('IFRAME1');var frameContent = frameObj.contentWindow.document.body; frameContent.innerHTML.toString();");
                      pagehtml = await controller.evaluateJavascript(
                          source: "document.body.innerHTML;");
                      createItems();
                      setState(() {});
                      print(pagehtml);
                    }
                  },
                )
              ]),
            ),
          ),

          // ListView.builder(
          //     itemBuilder: (context, index) {
          //       LineSplitter ls = const LineSplitter();
          //       List<String> navItemLines = ls.convert(navItems[index])
          //         ..removeWhere(
          //             (element) => !element.contains(RegExp(r'[a-zA-Z]')));
          //
          //       return GridView.count(
          //         crossAxisCount: 2,
          //         children: [
          //           Container(
          //             width: MediaQuery.of(context).size.width / 2 - 20,
          //             height: 100,
          //             decoration: BoxDecoration(
          //                 color: Colors.grey[200],
          //                 borderRadius: BorderRadius.all(Radius.circular(10))),
          //             child: Center(child: Text(navItemLines[0])),
          //           )
          //         ],
          //       );
          //     },
          //     itemCount: navItems.length),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            goToLoginPage();
          },
          child: const Icon(Icons.exit_to_app),
        ),
      ),
    );
  }
}
