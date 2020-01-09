import 'package:flutter/material.dart';
import 'package:flutter_contact_list/helpers/contact_helper.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  Contact _editedContact;
  bool _userEdited=false;
  final _nameControler = TextEditingController();
  final _emailControler = TextEditingController();
  final _phoneControler = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.contact == null)
      _editedContact = Contact();
    else
      _editedContact = Contact.fromMap(widget.contact.toMap());

    _nameControler.text = _editedContact.name;
    _emailControler.text = _editedContact.email;
    _phoneControler.text = _editedContact.phone;

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            if(_editedContact.name.isNotEmpty && _editedContact.name != null)
              Navigator.pop(context, _editedContact);
            else
              FocusScope.of(context).requestFocus(_nameFocus);

            if(_editedContact.phone.isNotEmpty && _editedContact.phone != null)
              Navigator.pop(context, _editedContact);
            else
              FocusScope.of(context).requestFocus(_phoneFocus);

          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _editedContact.img != null? FileImage(File(_editedContact.img)) :
                        AssetImage("images/person.png")
                    ),
                  ),
                ),
                onTap: (){
                  ImagePicker.pickImage(source: ImageSource.camera).then((file){
                    if(file == null) return;
                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameControler,
                focusNode: _nameFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text){
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailControler,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "Email"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.email = text;
                },
              ),
              TextField(
                focusNode: _phoneFocus,
                controller: _phoneControler,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text){
                  _userEdited = true;
                  _editedContact.phone = text;
                },
              ),
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  Future<bool> _requestPop(){
      if(_userEdited){
        showDialog(context: context,
        builder: (c){
          return AlertDialog(
            title: Text("Descartar as alterações"),
            content: Text("Se sair as alterações serão perdidas."),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancelar"),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("Sim"),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
        return Future.value(false);
      }else{
        return Future.value(true);
      }
  }
}
