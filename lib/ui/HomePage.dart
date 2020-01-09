import 'package:flutter/material.dart';
import 'package:flutter_contact_list/helpers/contact_helper.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contact_list/ui/contact_page.dart';

enum OrderOptions{orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getAllContacts();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contatos"),
          actions: <Widget>[
            PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                  const PopupMenuItem<OrderOptions>(child: Text("Ordenar de A - Z"), value: OrderOptions.orderaz),
                  const PopupMenuItem<OrderOptions>(child: Text("Ordenar de Z - A"), value: OrderOptions.orderza),
              ],
             onSelected: _orderList,
            )
          ],
          backgroundColor: Colors.red, centerTitle: true),
      body: ListView.builder(
        itemBuilder: (context, index){
            return _contactCard(context, index);
        },
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            _showContactPage();
          },
          backgroundColor: Colors.red,
          child: Icon(Icons.add)),
      backgroundColor: Colors.white,

    );
  }

  Widget _contactCard(BuildContext c, int index){
    return GestureDetector(
      onTap: (){
        _showOptions(c,index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != null? FileImage(File(contacts[index].img)) :
                            AssetImage("images/person.png")
                    ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(
                          fontSize: 18.0),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: TextStyle(
                          fontSize: 18.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _getAllContacts(){
    helper.gettAllContacts().then((l){
      setState(() {
        contacts = l;
      });
    });
  }

  void _orderList(OrderOptions results){

    switch(results){
      case OrderOptions.orderaz:
        contacts.sort((a,b){
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a,b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;

        setState(() {

        });

    }

  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(context: context, builder: (context){
      return BottomSheet(
        onClosing: (){

        },
        builder: (context){
          return Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text("Ligar", style:  TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                      launch("tel:${contacts[index].phone}");
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text("Editar", style:  TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                    onPressed: (){
                      _showContactPage(contact: contacts[index]);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: FlatButton(
                    child: Text("Excluir", style:  TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                    onPressed: (){
                      helper.deleteContact(contacts[index].id);
                      setState(() {
                        Navigator.pop(context);
                        contacts.removeAt(index);
                      });
                    },
                  ),
                )
              ],
            ),
          );
        },
      );
    });
  }

  void _showContactPage({Contact contact}) async{
   final racContact =  await Navigator.push(context, MaterialPageRoute(builder: (c)=>ContactPage(contact: contact,)));
   if(racContact != null){
     if(contact != null) {
       await helper.updateContact(racContact);
     }else{
       await helper.saveContact(racContact);
     }
     _getAllContacts();
   }
  }

}
