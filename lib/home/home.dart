import 'package:flutter/material.dart';
import 'package:food/database/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> allData = [];
  bool isloading = true;
  void refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      allData = data;
      isloading = false;
    });
  }

  Future<void> addData() async {
    await SQLHelper.createData(titleControler.text, descControler.text);
    refreshData();
  }

  Future<void> updateData(int id) async {
    await SQLHelper.updateDate(id, titleControler.text, descControler.text);
    refreshData();
  }

  Future<void> deleteData(int id) async {
    await SQLHelper.deleteData(id);
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Data đã xóa ')));
    refreshData();
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  final TextEditingController titleControler = TextEditingController();
  final TextEditingController descControler = TextEditingController();
  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData = allData.firstWhere((element) => element['id'] == id);
      titleControler.text = existingData['title'];
      descControler.text = existingData['desc'];
    }
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 30,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: titleControler,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "title",
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            TextField(
              controller: descControler,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Description",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await addData();
                    }
                    if (id != null) {
                      await updateData(id);
                    }
                    titleControler.text = "";
                    descControler.text = "";
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  },
                  child: Text(id == null ? "Add Data" : "Update Data")),
            )
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(String title, String desc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(title)),
          content: Text(desc),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Map<int, bool> completedTasks = {};
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(Icons.menu),
                  Text(
                    'Danh Sách Mua Sắm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.dark_mode)
                ],
              ),
            ),
            isloading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: allData.length,
                      itemBuilder: (context, index) => Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: CheckboxListTile(
                            title: Text(
                              allData[index]['title'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              allData[index]['desc'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: completedTasks[index] ?? false,
                            onChanged: (value) {
                              setState(() {
                                completedTasks[index] = value!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          onLongPress: () {
                            _showDetailsDialog(allData[index]['title'],
                                allData[index]['desc']);
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showBottomSheet(allData[index]['id']);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteData(allData[index]['id']);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => showBottomSheet(null),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
