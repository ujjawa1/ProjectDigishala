import 'package:digishala/aboutUs/aboutUs.dart';
import 'package:digishala/messaging/broadCast.dart';
import 'package:digishala/messaging/chats.dart';
import 'package:digishala/student/docsList.dart';
import 'package:digishala/student/videoList.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:digishala/CustomWidgets/subjectContainer.dart';

class StudentZone extends StatefulWidget {
  static const String id = 'stuZone';

  @override
  _StudentZoneState createState() => _StudentZoneState();
}

class _StudentZoneState extends State<StudentZone> {
  String isLoading = "false";
  String studentClass;
  String studentEmail;
  User loggedInUser;
  Future<void> signOut() async {
    setState(() {
      isLoading = 'true';
    });
    await FirebaseAuth.instance.signOut();
    setState(() {
      isLoading = 'false';
    });
  }

  studentClassGetter() async {
    setState(() {
      isLoading = 'true';
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    setState(() {
      studentEmail = user.email.toString();
    });
    final uid = user.uid;

    final db =
        FirebaseDatabase.instance.reference().child("studentInfos").child(uid);
    db.onValue.listen((event) {
      var values = event.snapshot;

      if (values == null) {
        Fluttertoast.showToast(
            msg: 'Login with Correct Account',
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            toastLength: Toast.LENGTH_LONG);
      } else {
        setState(() {
          studentClass = values.value['class'].toString();
        });

        prefs.remove('selectedClass');
        prefs.setString("selectedClass", studentClass);
        setState(() {
          isLoading = 'false';
        });
      }
    });
  }

  void docsOrVideo(sub) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          title: Text('Select your option',
              style: TextStyle(color: Colors.red, fontSize: 25.0)),
          content: Text(
              'Select "Docs" for provided Documents, "Videos" for Video Lectures.',
              style: TextStyle(fontSize: 17.0)),
          actions: [
            FlatButton(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35.0),
                    side: BorderSide(color: Colors.red, width: 2)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return DocsList(sub: sub);
                  }));
                },
                child: Text("Docs", style: TextStyle(fontSize: 20.0))),
            FlatButton(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    side: BorderSide(color: Colors.red, width: 2)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return VideosList(sub: sub);
                  }));
                },
                child: Text("Videos", style: TextStyle(fontSize: 20.0)))
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    studentClassGetter();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == 'true'
        ? Container(
            color: Color(0xff4834DF),
            height: MediaQuery.of(context).size.height * 1,
            width: MediaQuery.of(context).size.width * 1,
            child: Center(child: SpinKitFadingCube(
                itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                  decoration: BoxDecoration(
                      color: index.isEven ? Colors.red : Colors.yellow));
            })))
        : Scaffold(
            appBar: AppBar(
                actions: <Widget>[
                  Image(
                    image: AssetImage('assets/mascot.png'),
                  ),
                ],
                backgroundColor: kThemeColor, //value is in constants file
                title: Text("Subjects",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.08,
                        fontWeight: FontWeight.bold)),
                titleSpacing: 2.5,
                centerTitle: true),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: kThemeColor,
                        // gradient: LinearGradient(
                        // colors: [kThemeColor, Colors.amberAccent]),
                      ),
                      currentAccountPicture:
                          Image(image: AssetImage('assets/mascot.png')),
                      accountName: Text("Class ${studentClass}"),
                      // onDetailsPressed: () {
                      //   studentClassGetter();
                      // },
                      accountEmail: Text(studentEmail)),
                  ListTile(
                    title: Text("Subjects"),
                    leading: FaIcon(
                      Icons.subject,
                      color: kThemeColor,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text("Refresh class"),
                    leading: FaIcon(
                      Icons.class_,
                      color: kThemeColor,
                    ),
                    onTap: () {
                      studentClassGetter();
                    },
                    subtitle: Text("class ${studentClass}"),
                  ),
                  Divider(color: kThemeColor),
                  ListTile(
                      title: Text("Chats/Discussion"),
                      leading: FaIcon(
                        Icons.chat,
                        color: kThemeColor,
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ChatScreen(studentClass: studentClass);
                          },
                        ));
                      }),
                  ListTile(
                    title: Text("Notice/Announcements"),
                    leading:
                        FaIcon(FontAwesomeIcons.bullhorn, color: kThemeColor),
                    onTap: () {
                      Navigator.pushNamed(context, BroadCast.id);
                    },
                  ),
                  Divider(color: kThemeColor),
                  ListTile(
                    title: Text("About us"),
                    leading:
                        FaIcon(FontAwesomeIcons.infoCircle, color: kThemeColor),
                    onTap: () {
                      Navigator.pushNamed(context, AboutUs.id);
                    },
                    onLongPress: () {},
                  ),
                  Divider(color: kThemeColor),
                  ListTile(
                    title: Text("Logout"),
                    leading:
                        FaIcon(FontAwesomeIcons.signOutAlt, color: kThemeColor),
                    onTap: () {
                      signOut();
                    },
                  ),
                ],
              ),
            ),
            body: Container(
              decoration: kContainerThemeDecoration,
              width: double.infinity,
              height: double.infinity,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          //////=====================
                          ///subjects ===============
                          ////=======================
                          SubjectContainer(
                            color: Colors.redAccent,
                            title: 'English',
                            onPressed: () {
                              docsOrVideo('English');
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SubjectContainer(
                            color: Colors.orange,
                            title: 'Hindi',
                            onPressed: () {
                              docsOrVideo('Hindi');
                            },
                          ),
                          SubjectContainer(
                            color: Colors.blueAccent,
                            title: 'Maths',
                            onPressed: () {
                              docsOrVideo('Maths');
                            },
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.deepOrangeAccent,
                      ),
                      Row(
                        children: <Widget>[
                          SubjectContainer(
                            color: Colors.cyanAccent,
                            title: "Physics",
                            onPressed: () {
                              docsOrVideo('Physics');
                            },
                          ),
                        ],
                      ),
                      Row(children: <Widget>[
                        SubjectContainer(
                          color: Colors.greenAccent,
                          title: 'Chemistry',
                          onPressed: () {
                            docsOrVideo('Chemistry');
                          },
                        ),
                        SubjectContainer(
                          color: Colors.tealAccent,
                          title: "Biology",
                          onPressed: () {
                            docsOrVideo('Biology');
                          },
                        )
                      ]),
                      Divider(color: Colors.deepPurpleAccent),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SubjectContainer(
                            color: Colors.deepPurpleAccent,
                            title: 'Computer',
                            onPressed: () {
                              docsOrVideo('Computer');
                            },
                          ),
                        ],
                      ),
                      Divider(color: Colors.deepOrangeAccent),
                      Row(
                        children: <Widget>[
                          SubjectContainer(
                            color: Colors.green,
                            title: "Geography",
                            onPressed: () {
                              docsOrVideo('Geography');
                            },
                          ),
                          SubjectContainer(
                            color: Colors.pinkAccent,
                            title: "History",
                            onPressed: () {
                              docsOrVideo('History');
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          SubjectContainer(
                            color: Colors.amberAccent,
                            title: "Civics",
                            onPressed: () {
                              docsOrVideo('Civics');
                            },
                          ),
                          SubjectContainer(
                            color: Colors.indigo,
                            title: 'Economics',
                            onPressed: () {
                              docsOrVideo('Economics');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
