import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:register_login/model/profile.dart';
import 'package:form_field_validator/form_field_validator.dart';
// import 'package:register_login/screen/home.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          /* --------------------------------ถ้าเชื่อม firebase ไม่สำเร็จ------------------------------------------ */
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Error'),
              ),
              body: Center(
                child: Text('${snapshot.error}'),
              ),
            );
          }

          /* --------------------------------ถ้าเชื่อม firebase สำเร็จ------------------------------------------ */
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text("สร้างบัญชีผู้ใช้"),
              ),
              body: Container(
                child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            methodEmail(),
                            SizedBox(
                              height: 20,
                            ),
                            methodpassword(),
                            SizedBox(
                              width: double.infinity,
                              child: methodSubmit(),
                            )
                          ],
                        ),
                      ),
                    )),
              ),
            );
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  ElevatedButton methodSubmit() {
    return ElevatedButton(
      child: Text('ลงทะเบียน', style: TextStyle(fontSize: 20.0)),
      onPressed: () async {
        if (this._formKey.currentState!.validate()) {
          this._formKey.currentState!.save();
          Profile profile = Profile(email: _email.text, password: _password.text);
          try {
            await FirebaseAuth.instance
                .createUserWithEmailAndPassword(email: profile.email, password: profile.password)
                .then((value) {
              this._formKey.currentState!.reset();
              Fluttertoast.showToast(
                msg: "สร้างบัญชีผู้ใช้สำเร็จ",
                gravity: ToastGravity.CENTER,
              );
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            });
          } on FirebaseAuthException catch (e) {
            var message;
            if (e.code == 'weak-password') {
              message = "รหัสผ่านต้องมีอย่างน้อย 6 ตัว";
            } else if (e.code == 'email-already-in-use') {
              message = "อีเมลนี้ถูกใช้ไปแล้ว";
            } else {
              message = e.message;
            }
            Fluttertoast.showToast(
              msg: message,
              gravity: ToastGravity.CENTER,
            );
          }
        }
      },
    );
  }

  TextFormField methodEmail() {
    return TextFormField(
      decoration:
          InputDecoration(labelText: 'อีเมล', hintText: 'abcd@mail.com', icon: Icon(Icons.email)),
      keyboardType: TextInputType.emailAddress,
      controller: _email,
      validator: MultiValidator([
        RequiredValidator(errorText: 'กรุณากรอก อีเมล'),
        EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
      ]),
    );
  }

  TextFormField methodpassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'รหัสผ่าน', icon: Icon(Icons.password)),
      obscureText: true,
      controller: _password,
      validator: RequiredValidator(errorText: "กรุณากรอก รหัสผ่าน"),
    );
  }
}
