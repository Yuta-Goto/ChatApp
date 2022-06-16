import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Firebase初期化
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyBBvUnIhKMchDpUOO0LylQaY9X8macPLRk", appId: "1:644868127836:web:6b437cb5b0e2ca513d3a99", messagingSenderId: "644868127836", projectId: "connect-project-4b031",authDomain: "connect-project-4b031.firebaseapp.com",storageBucket: "connect-project-4b031.appspot.com")
  );
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '失敗してなんぼ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}




class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  // 入力されたメールアドレス
  String newUserEmail = "";
  // 入力されたパスワード
  String newUserPassword = "";
  // 登録・ログインに関する情報を表示
  String infoText = "";

  String loginUserEmail="";

  String loginUserPassword="";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              TextFormField(
                // テキスト入力のラベルを設定
                decoration: InputDecoration(labelText: "メールアドレス"),
                onChanged: (String value) {
                  setState(() {
                    newUserEmail = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              TextFormField(
                decoration: InputDecoration(labelText: "パスワード(6文字以上)"),
                // パスワードが見えないようにする
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    newUserPassword = value;
                  });
                },
              ),
              const SizedBox(height: 8),

              ElevatedButton(
                onPressed: () async {
                  try {
                    // メール/パスワードでユーザー登録
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final UserCredential result =
                        await auth.createUserWithEmailAndPassword(
                      email: newUserEmail,
                      password: newUserPassword,
                    );

                    //追加
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context){
                        return ChatPage(result.user!);
                      }),
                    );

                    // 登録したユーザー情報
                    //final User user = result.user!;
                    //setState(() {
                    //  infoText = "登録OK:${user.email}";
                    //});
                  } catch (e) {
                    // 登録に失敗した場合
                    setState(() {
                      infoText = "登録NG:${e.toString()}";
                    });
                  }
                },
                child: Text("ユーザー登録"),
              ),
              const SizedBox(height: 8),

              //Login action

              TextFormField(
                decoration: InputDecoration(labelText: "メールアドレス"),
                onChanged: (String value){
                  setState(() {
                    loginUserEmail=value;
                  });
                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "パスワード"),
                obscureText: true,
                onChanged: (String value){
                  setState(() {
                    loginUserPassword=value;
                  });
                },
              ),
              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: () async {
                  try {
                    // メール/パスワードでログイン
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final UserCredential result =
                        await auth.signInWithEmailAndPassword(
                      email: loginUserEmail,
                      password: loginUserPassword,
                    );

                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context){
                        return ChatPage(result.user!);
                      }),
                    );
                    // ログインに成功した場合
                    //final User user = result.user!;
                    //setState(() {
                    //  infoText = "login OK:${user.email}";
                    //});
                  } catch (e) {
                    // ログインに失敗した場合
                    setState(() {
                      infoText = "ログインNG:${e.toString()}";
                    });
                  }
                },
                child: Text("ログイン"),
              ),
              const SizedBox(height: 8),

              Text(infoText),
            ],
          ),
        ),
      ),
    );
  }
}







class ChatPage extends StatelessWidget{

  ChatPage(this.user);

  final User user;

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('一覧'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async{

              await FirebaseAuth.instance.signOut();
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context){
                  return LoginPage();
                }),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(32),
            child: Text('ログイン情報 ${user.email}'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('date',descending: true)
                .snapshots(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView(
                    children: documents.map((documents) {
                      return Card(
                        child: ListTile(

                          leading: ((){
                            if(documents['email'] == user.email){
                             
                             return IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context){
                                    return EditPage(user);
                                  }),
                                );
                              },
                            );
                            
                          }
                          })(),

                          title: (documents['email'] == user.email) ? Text(documents['text']): null,
                          //subtitle: Text(documents['email']),

                          
                          
                          trailing: ((){
                            if(documents['email'] == user.email){
                             
                             return IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(documents.id)
                                  .delete();
                              },
                            );
                            
                          }
                          })(),
                          //:null,
                        ),
                      );
                    }).toList(),
                  );
                }
                //データ読み込み中
                return Center(
                  child: Text('読み込み中...'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context){
              return AddPostPage(user);
            }),
          );
        },
      ),
    );
  }
}

class AddPostPage extends StatefulWidget{
  AddPostPage(this.user);
  final User user;

  @override 
  _AddPostPageState createState() => _AddPostPageState();
}


class _AddPostPageState extends State<AddPostPage> {

  String messageText='';

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('失敗書き出しスペース'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '全て受け入れます'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (String value){
                  setState(() {
                    messageText=value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text('投稿'),
                  onPressed: () async {
                    final date= DateTime.now().toLocal().toIso8601String();
                    final email = widget.user.email;
                    //firestore用のドキュメント作成
                    await FirebaseFirestore.instance
                      .collection('posts')
                      .doc()
                      .set({
                        'text': messageText,
                        'email': email,
                        'date': date
                      });
                      Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}












class EditPage extends StatefulWidget{
  EditPage(this.user);
  final User user;

  @override 
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {

  String messageText='';

  var _controller = TextEditingController();

  @override 
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('深ぼり'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async{
              Navigator.of(context).pop();
            }
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                    .collection('details')
                    .orderBy('date',descending: true)
                    .snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      final List<DocumentSnapshot> documents=snapshot.data!.docs;

                      
                      return ListView(
                        children: documents.map((documents){
                          
                          return Card(
                            child: ListTile(
                              title: (documents['email']==widget.user.email) ? Text(documents['text']):null,
                            ),
                          );
                          
                        }).toList(),
                      );
                      
                      
                    }
                    return Center(
                      child: Text('読み込み中...'),
                    );
                  },
                ),
              ),
              
              TextFormField(
                
                controller: _controller,
                decoration: InputDecoration(labelText: 'ひたすら深ぼりましょう！'),
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                onChanged: (String value){
                  setState(() {
                    messageText=value;
                  });
                  
                },
              ),
              const SizedBox(height: 8),
              Container(
                
                width: double.infinity,
                child: ElevatedButton(
                  
                  child: Text('投稿'),
                  onPressed: () async {
                    final date= DateTime.now().toLocal().toIso8601String();
                    final email = widget.user.email;
                    //firestore用のドキュメント作成
                    await FirebaseFirestore.instance
                      .collection('details')
                      .doc()
                      .set({
                        'text': messageText,
                        'email': email,
                        'date': date
                      });
                      _controller.clear();
                      //Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}