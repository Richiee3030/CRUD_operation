import 'package:crud_sqlite/screens/addUser.dart';
import 'package:crud_sqlite/screens/editUser.dart';
import 'package:crud_sqlite/screens/viewUser.dart';
import 'package:crud_sqlite/services/userService.dart';
import 'package:flutter/material.dart';
import 'model/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<User> _userList = <User>[];
  final _userService = UserService();

  getAllUserDetails() async {
    var users = await _userService.readAllUsers();
    _userList = <User>[];
    users.forEach((user) {
      setState(() {
        var userModel = User();
        userModel.id = user['id'];
        userModel.name = user['name'];
        userModel.contact = user['contact'];
        userModel.description = user['description'];
        _userList.add(userModel);
      });
    });
  }

  @override
  void initState() {
    getAllUserDetails();
    super.initState();

  }

  _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  _deleteFormDialog(BuildContext context, userId) {
    return showDialog(
        context: context,
        builder: (param) {
          return AlertDialog(
            title: const Text(
              'Are You Sure to Delete',
              style: TextStyle(color: Colors.teal, fontSize: 20),
            ),
            actions: [
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: ()  {
                    var result= _userService.deleteUser(userId);

                    if (result != null) {
                      Navigator.pop(context);
                      // getAllUserDetails();
                      _showSuccessSnackBar(
                          'User Detail Deleted Success' );
                    }
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.white))),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(context);


                  },
                  child: const Text('Close',style: TextStyle(color: Colors.white)))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQLITE CRUD"),
      ),
      body: FutureBuilder(
        future: getAllUserDetails(),
        builder: (context,state) {
          return RefreshIndicator(

            onRefresh: () {
               return getAllUserDetails();
            },
            child: ListView.builder(
                itemCount: _userList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewUser(
                                  user: _userList[index],
                                )));
                      },
                      leading: const Icon(Icons.person),
                      title: Text(_userList[index].name ?? ''),
                      subtitle: Text(_userList[index].contact ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => EditUser(
                                          user: _userList[index],
                                        ))).then((data) {
                                  if (data != null) {
                                    // getAllUserDetails();
                                    _showSuccessSnackBar(
                                        'User Detail Updated Success');
                                  }
                                });
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.teal,
                              )),
                          IconButton(
                              onPressed: () {
                                _deleteFormDialog(context, _userList[index].id);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ))
                        ],
                      ),
                    ),
                  );
                }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()  {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddUser()))
              .then((data) {
            if (data != null) {
              getAllUserDetails();
              _showSuccessSnackBar('User Detail Added Success');
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
