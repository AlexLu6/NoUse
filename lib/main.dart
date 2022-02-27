import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

int _golferID = 0;
SharedPreferences prefs;
String _name = '', _phone = '';
enum gendre { Male, Female }
gendre _sex = gendre.Male;
String _golferAvatar;
double _handicap = 18;
bool isRegistered = false;

Future<void> main() async {
  prefs = await SharedPreferences.getInstance();
  int uid = prefs.getInt('golferID');
  _golferID = uid ?? 0;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseOptions(apiKey: "AIzaSyB2g9-ydkWCwzQ3f-8mUi1MQ7yIpOUeCwM", appId: "1:301278524425:android:62e1cf964c940e6b4074d8", messagingSenderId: "301278524425-9ogenbrbtruncb07nk8e009v6b61pjbm.apps.googleusercontent.com", projectId: "golferclub-fce89"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Application name
      title: 'Golfer Club',

      // A widget which will be started on application startup
      home: MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({@required this.title});

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  String homeString = 'Home Page';

  void switchHome(String name) {
    this.setState(() {
      homeString = name;
    });
    Navigator.of(context).pop();
  }

  final fireGolfers = FirebaseFirestore.instance.collection('Golfers');
  @override
  void initState() {
    fireGolfers.where('uid', isEqualTo: _golferID).get().then((value) {
      value.docs.forEach((result) {
        var items = result.data();
        _name = items['name'];
        _phone = items['phone'];
        _sex = items['sex'] == 1 ? gendre.Male : gendre.Female;
        setState(() => isRegistered = true);
        print(_name);
        print(_golferID);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isRegistered = (_golferID != 0) ? true : false;

    return Scaffold(
        appBar: AppBar(
          // The title text which will be shown on the action bar
          title: Text('Golfers Club'),
        ),
        drawer: !isRegistered ? null : golfDrawer(),
        body: Center(child: !isRegistered ? registerBody() : homeBodies()));
  }

  Drawer golfDrawer() {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(_name),
            accountEmail: Text(_phone),
            currentAccountPicture: GestureDetector(
                onTap: () =>
                    //ImagePicker().pickImage(source: ImageSource.gallery),
                    switchHome("Golfer Info"),
                child: CircleAvatar(backgroundImage: NetworkImage(_golferAvatar ?? maleGolfer))
                //"https://desk-fd.zol-img.com.cn/t_s144x90c5/g5/M00/02/07/ChMkJlbKy5GIKHO3AAXx0E0tcL8AALIsgMfpwoABfHo739.jpg"))
                ),
            decoration: BoxDecoration(
                image: DecorationImage(fit: BoxFit.fill, image: NetworkImage("https://images.unsplash.com/photo-1622482594949-a2ea0c800edd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80")
                    //("https://desk-fd.zol-img.com.cn/t_s208x130c5/g4/M00/0F/02/Cg-4zFT5Wj-IQxAKABhgu3KD_twAAWK_ANBmYUAGGDT047.jpg")
                    )),
            onDetailsPressed: () => switchHome("Golfer Info"),
          ),
          ListTile(title: Text("Groups"), leading: Icon(Icons.arrow_right), onTap: () => switchHome('Groups')),
          ListTile(title: Text("Activities"), leading: Icon(Icons.sports_golf), onTap: () => switchHome('Activities')),
          ListTile(title: Text("Golf Courses"), leading: Icon(Icons.golf_course)),
          ListTile(title: Text("My scores"), leading: Icon(Icons.format_list_numbered)),
          ListTile(
              title: Text("Log out"),
              trailing: Icon(Icons.exit_to_app),
              onTap: () {
                setState(() {
                  isRegistered = false;
                  _name = '';
                  _phone = '';
                  _golferID = 0;
                });
                Navigator.of(context).pop();
              }),
        ],
      ),
    );
  }

  final String maleGolfer = 'https://images.unsplash.com/photo-1494249120761-ea1225b46c05?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=713&q=80';
//final String femaleGolfer = 'http://www.golfcare.co.uk/wp-content/uploads/sites/6/2017/04/female-golfer.jpg';
  final String femaleGolfer = 'https://images.unsplash.com/photo-1622819219010-7721328f050b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=415&q=80';

  ListView registerBody({bool isUpdate = false}) {
    final logo = Hero(
      tag: 'golfer',
      child: CircleAvatar(backgroundImage: NetworkImage(_golferAvatar ?? maleGolfer), radius: 140),
    );

    final golferName = TextFormField(
      initialValue: _name,
      showCursor: true,
      onChanged: (String value) => setState(() => _name = value),
      //keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Name:", hintText: 'Real Name:', border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );

    final golferPhone = TextFormField(
      initialValue: _phone,
      onChanged: (String value) => setState(() => _phone = value),
      //keyboardType: TextInputType.phone,
      decoration: InputDecoration(labelText: "Mobile:", hintText: 'Mobile:', border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final golferSex = Row(children: <Widget>[
      Flexible(
          child: RadioListTile<gendre>(
              title: const Text('Male'),
              value: gendre.Male,
              groupValue: _sex,
              onChanged: (gendre value) => setState(() {
                    _sex = value;
                    _golferAvatar = maleGolfer;
                  }))),
      Flexible(
          child: RadioListTile<gendre>(
              title: const Text('Female'),
              value: gendre.Female,
              groupValue: _sex,
              onChanged: (gendre value) => setState(() {
                    _sex = value;
                    _golferAvatar = femaleGolfer;
                  }))),
    ], mainAxisAlignment: MainAxisAlignment.center);

    Future<int> checkGolfer() async {
      if (_name != '' && _phone != '') {
        fireGolfers.where('name', isEqualTo: _name).where('phone', isEqualTo: _phone).get().then((value) {
          value.docs.forEach((result) {
            var items = result.data();
            _golferID = items['uid'];
            print(_name + '(' + _phone + ') already registered!');
            print(_golferID);
          });
        });
      }
      return _golferID;
    }

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        borderRadius: BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () async {
            if (isUpdate) {
              if (_name != '' && _phone != '') {
                fireGolfers.doc().update({
                  "name": _name,
                  "phone": _phone,
                  "sex": _sex == gendre.Male ? 1 : 2,
                });
              }
            } else {
              await checkGolfer();
              // should wait for query finished
              if (_golferID == 0) {
                _golferID = DateTime.now().millisecondsSinceEpoch;

                fireGolfers.add({
                  "name": _name,
                  "phone": _phone,
                  "sex": _sex == gendre.Male ? 1 : 2,
                  "uid": _golferID
                });
                await prefs.setInt('golferID', _golferID);
                print('Add new goler ' + _name);
                print(_golferID);
              }
              setState(() => isRegistered = true);
            }
          },
          color: Colors.green,
          child: Text(
            isUpdate ? 'Modify' : 'Register',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
      ),
    );
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(left: 24.0, right: 24.0),
      children: <Widget>[
        SizedBox(
          height: 8.0,
        ),
        logo,
        SizedBox(
          height: 24.0,
        ),
        golferName,
        SizedBox(
          height: 8.0,
        ),
        golferPhone,
        SizedBox(
          height: 8.0,
        ),
        golferSex,
        SizedBox(
          height: 8.0,
        ),
        Text(isRegistered ? "Handicap: ${_handicap}" : '', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 10.0,
        ),
        loginButton
      ],
    );
  }

  ListView homeBodies() {
    if (homeString == 'Activities')
      return ActivityBody();
    else if (homeString == 'Golfer Info') return registerBody(isUpdate: true);
    return ListView(children: <Widget>[
      Text(homeString, style: TextStyle(fontSize: 35.0)),
      Image.network("https://images.unsplash.com/photo-1622482594949-a2ea0c800edd?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=774&q=80"),
      SizedBox(
        height: 10.0,
      ),
      Text('Name: ' + _name + '  Handicap: ${_handicap}', style: TextStyle(fontSize: 20.0)),
    ]);
  }

  ListView ActivityBody() {
    return ListView(children: <Widget>[
      Text(homeString, style: TextStyle(fontSize: 20.0)),
    ]);
  }
}
