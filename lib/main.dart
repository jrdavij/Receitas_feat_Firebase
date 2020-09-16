//import 'dart:html';
//import 'dart:typed_data';
import 'package:faker/faker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp().whenComplete(() => print("FirebaseApp initialized @ ${new DateTime.now()}"));
    //2 widgets, um pra antes de carregar o app e outro depois ?
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        final FirebaseFirestore db = FirebaseFirestore.instance;

        return MaterialApp(
            initialRoute: '/',
            routes: {
              '/': (context) => Tester(db),
              '/add': (context) => addNovo(),
            },
            title: 'Panela Nova',
            theme: ThemeData(
              primarySwatch: Colors.orange,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
        );
      }
    );
  }
}
class Cores{
  static Color Coral = Color.fromARGB(255, 255, 127, 80);
  static Color LightCoral = Color.fromARGB(255, 240, 128, 128);
  static Color IndianRed = Color.fromARGB(255, 205, 92, 92);
}
class Fontes{
  static TextStyle Titulo = GoogleFonts.amaticSc(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white);
}
class DefaultScreen extends StatelessWidget {
  int _selectedIndex = 0;
  List<Widget> _widgetsOptions;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class Tester extends StatefulWidget {
  final FirebaseFirestore db;
  Tester(this.db);
  @override
  _TesterState createState() => _TesterState();
}
class _TesterState extends State<Tester> {

  static TextStyle f = GoogleFonts.workSans(color: Colors.white, fontSize: 20);
  Wrap lista = Wrap(children: [Container(width:100, height: 100, alignment: Alignment.center,child: CircularProgressIndicator())]);
  DateTime dt = new DateTime.now(); //hora de atualização

  updateList() async{
    Wrap temp;
    //print("Refreshing @ ${new DateTime.now()}");
    await widget.db.collection("Receitas").get().then((value) {
      temp = Wrap(children: List<rcards>.generate(value.size, (i) => rcards(value.docs[i].data()["autor"],value.docs[i].data()["titulo"], value.docs[i].data()["img"])).toList());
    });
    lista = temp;
    dt = DateTime.now();
    //print("${lista.children.length} cards loaded at ${new DateTime.now()}");
  }

  @override
  void initState(){
    //updateList();
    super.initState();
  }

  Future<void> update() async {
    updateList();
  }
  
  @override
  Widget build(BuildContext context) {
    //imgg = Image.network("https://firebasestorage.googleapis.com/v0/b/adssit3.appspot.com/o/Images%2Fa.jpg?alt=media&token=d9f12475-50d2-4d67-8883-fed2dff3b5c7");
    //widget.db.collection("Receitas").doc("EX5xPgN9ZIZmNeYe3cSq").get().then((value) => url = .child(value.data()["img"]).getDownloadURL(););

    return Scaffold(
      appBar: AppBar(backgroundColor: Cores.Coral,title: Text("Receitas disponíveis", style: Fontes.Titulo)),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, "/add");
          },
          child: Icon(Icons.add)),
      body: FutureBuilder(
        future: updateList(),
        builder: (context, snapshot) {
          return Container(
          color: Cores.LightCoral,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: new BorderRadius.circular(30)),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                            flex: 8,
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: TextField(
                                  decoration: new InputDecoration(
                                    hintText: 'Pesquisar receita...',
                                    fillColor: Colors.white.withOpacity(0.5),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(fontSize: 20)),
                            )),
                        Flexible(flex: 1, child: Icon(Icons.search)),
                      ],
                    ),
                  )),
              //Text("${lista.children.length} receitas disponíveis em $dt", style: f, textAlign: TextAlign.center),
              Expanded(
                  child: RefreshIndicator(
                      onRefresh: update,
                      child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: lista))),
            ],
          )
        );
        }
      ),

    );
  }
}

class addNovo extends StatefulWidget {
  @override
  _addNovoState createState() => _addNovoState();
}

class _addNovoState extends State<addNovo> {
  String titulo = "Clique aqui para mudar o título";
  String autor = "Clique aqui para mudar o autor";
  String img = "https://firebasestorage.googleapis.com/v0/b/adssit3.appspot.com/o/Images%2Fexample.png?alt=media&token=d7d62f23-454b-41ac-b83e-f7cccb8da35b";

  /*
  Uint8List imgdata;
  Image imgg;
  final picker = ImagePicker();
  adddata() async{
    var widget;
    widget.db.collection("Receitas").add(
          {
            "autor": "autoradd",
            "titulo": "tituloadd",// https://firebasestorage.googleapis.com/v0/b/adssit3.appspot.com/o/Images%2Fk.jpg?alt=media&token=d8a156e7-b1bb-4193-878e-bafeb88591bc
            "img": "https://static.independent.co.uk/s3fs-public/thumbnails/image/2017/11/24/17/istock-537640710.jpg"
          }
      ).then((value) => print(value));

  }
  Future getImage() async{
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    //url = pickedFile.path.toString();
  }*/

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    TextStyle s = GoogleFonts.dancingScript(fontSize: 25, fontWeight: FontWeight.bold);
    DateTime now = new DateTime.now();
    Color ct = Color.fromARGB(255, 255, 127, 80); //cor botões
    Color cf = Color.fromARGB(255, 240, 128, 128); //cor titulo
    Color cb = Color.fromARGB(255, 205, 92, 92); //cor fundo
    Widget img = ClipRRect(borderRadius: BorderRadius.circular(10), child:Image(image: NetworkImage("https://www.agoda.com/wp-content/uploads/2019/05/Seoul-food-Seoul-Korean-BBQ-family-style-meal.jpg"),height: 50, width: 50, fit: BoxFit.cover));

    return Scaffold(
      appBar: AppBar(backgroundColor: Cores.Coral, title: Text("Criar nova receita", style: Fontes.Titulo)),
      body: Container(
        decoration: BoxDecoration(
          color: cf
        ),
        alignment: Alignment.topCenter,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.only(bottom: 50, top: 20, left: 20, right: 20),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black54)],
                    ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ListTile(
                            leading: Image(image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/adssit3.appspot.com/o/dummyface.jpg?alt=media&token=1fd446e4-6647-44a1-affe-ac4ab002f3b7")),
                            title: Text("Por ${faker.person.name()}", style: GoogleFonts.dmSerifDisplay(fontSize: 20, shadows: [Shadow(blurRadius: 1, color: Colors.black54)])),
                            subtitle: Text("${now.day} de agosto de 2020", style: GoogleFonts.gentiumBookBasic(fontSize: 15, shadows: [Shadow(blurRadius: 1, color: Colors.black54)]))),
                        SizedBox(height: 30),
                        ListTile(
                            title: Text("Qual o título da sua receita?", style: s),
                            subtitle: TextFormField()),
                        SizedBox(height: 30),
                        ListTile(
                          title: RaisedButton(
                            color: cb,
                            onPressed: (){},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [Icon(Icons.file_upload, color: Colors.white,),SizedBox(width: 10),Text("Carregar fotos", style: GoogleFonts.dmSerifDisplay(color: Colors.white))],
                            ),
                          ),
                          subtitle: SingleChildScrollView(scrollDirection: Axis.horizontal,child: Wrap(children: [img, img, img, img, img, img, img, img, img], spacing: 10,)),
                        ),
                        SizedBox(height: 30),
                        ListTile(
                          title: Text("Ingredientes", style: s),
                          subtitle: Container(padding: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  ListTile(leading: Icon(Icons.trip_origin), title: Text("2kg de ${faker.food.cuisine()}")),
                                  ListTile(leading: Icon(Icons.trip_origin), title: Text("2kg de ${faker.food.cuisine()}")),
                                  ListTile(leading: Icon(Icons.trip_origin), title: Text("2kg de ${faker.food.cuisine()}")),
                                  ListTile(title: RaisedButton(
                                    color: cb,
                                    onPressed: (){},
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [Icon(Icons.add, color: Colors.white,),SizedBox(width: 10),Text("Ingrediente", style: GoogleFonts.dmSerifDisplay(color: Colors.white))],
                                    ),
                                  )
                                  )
                                ])
                        ),
                        )
                        ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [BoxShadow(blurRadius: 15, color: Colors.white54), BoxShadow(blurRadius: 10, color: Colors.white)]
                  ),
                  child: FlatButton(
                    onPressed: (){},
                    child: Text("Confirmar", style: GoogleFonts.bubblegumSans(fontSize: 20, color: Colors.brown)),
                  ),
                ), //botão confirmar
                Container(
                  margin: EdgeInsets.all(20),
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: cb,
                      boxShadow: [BoxShadow(blurRadius: 15, color: Colors.white54), BoxShadow(blurRadius: 10, color: Colors.white)]
                  ),
                  child: FlatButton(
                    onPressed: () {Navigator.pop(context);},
                    child: Text("Cancelar", style: GoogleFonts.bubblegumSans(fontSize: 20, color: Colors.white)),
                  ),
                ), //botão cancelar
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class rcards extends StatelessWidget {
  final String titulo, autor, img;
  rcards(this.titulo, this.autor, this.img);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              Image(
                image: NetworkImage(img),
              ),
              Container(
                  height: 100,
                  color: Colors.white,
                  padding: EdgeInsets.all(8),
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(titulo, style: GoogleFonts.satisfy(fontSize: 20, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            children: [
                              Icon(Icons.account_circle),
                              Text(autor, style: GoogleFonts.workSans(fontSize: 15)),],
                          ),
                          FlatButton(child: Text("Ler mais", style: GoogleFonts.workSans(color: Colors.lightBlueAccent, fontSize: 15),), onPressed: (){},)
                        ],
                      ),
                    ],
                  )
              )
            ],
          ),
        )
    );
  }
}