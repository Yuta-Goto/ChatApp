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
      title: 'Flutter Demo',
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
                decoration: InputDecoration(labelText: "パスワード（６文字以上）"),
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
                decoration: InputDecoration(labelText: "mail address"),
                onChanged: (String value){
                  setState(() {
                    loginUserEmail=value;
                  });
                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "password"),
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
                      infoText = "login NG:${e.toString()}";
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
        title: Text('chat page'),
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
                .orderBy('date')
                .snapshots(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;

                  return ListView(
                    children: documents.map((documents) {
                      return Card(
                        child: ListTile(
                          title: Text(documents['text']),
                          subtitle: Text(documents['email']),

                          trailing: documents['email'] == user.email
                            ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(documents.id)
                                  .delete();
                              },
                            )
                          :null,
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
        title: Text('チャット投稿'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '投稿メッセージ'),
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