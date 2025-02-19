import 'dart:convert';

import 'package:app/main.dart';
import 'package:app/model/learningmaterial.dart';
import 'package:app/service/chapterService.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/assessment.dart';

class Chapterscreen extends StatefulWidget {
  final int idChapter;
  const Chapterscreen({super.key, required this.idChapter});

  @override
  State<Chapterscreen> createState() => _ChapterScreen();
}

class _ChapterScreen extends State<Chapterscreen> with TickerProviderStateMixin {
  FilePickerResult? result;
  PlatformFile? file;
  int navIndex = 1;
  late final TabController _tabController;
  late ScrollController _scrollController;
  final MultiSelectController<String> _controller = MultiSelectController();
  double progressValue = 0.0;
  bool allQuestionsAnswered = false;
  bool tapped = false;
  Assessment? question;
  LearningMaterial? material;

  @override
  void initState() {
    getMaterial(widget.idChapter);
    getAssessment(widget.idChapter);
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    double currentProgressValue = _scrollController.offset / _scrollController.position.maxScrollExtent;

    if (currentProgressValue < 0.0) {
      currentProgressValue = 0.0;
    } else if (currentProgressValue > 1.0) {
      currentProgressValue = 1.0;
    }

    setState(() {
      progressValue = currentProgressValue;
    });
  }

  void getMaterial(int id) async {
    final resultMaterial = await ChapterService.getMaterialByChapterId(id);
    setState(() {
      material = resultMaterial;
    });
  }

  void getAssessment(int id) async {
    final resultAssessment = await ChapterService.getAssessmentByChapterId(id);
    setState(() {
      question = resultAssessment;
    });
  }

  Future<void> saveFile(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert PlatformFile to a JSON string
    Map<String, dynamic> fileData = {
      'name': file.name,
      'size': file.size,
      'path': file.path, // Only available on mobile
      'extension': file.extension,
    };

    await prefs.setString('selectedFile', jsonEncode(fileData));
  }

  Future<PlatformFile?> loadFile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? fileJson = prefs.getString('selectedFile');

    if (fileJson == null) return null;

    final Map<String, dynamic> fileData = jsonDecode(fileJson);

    return PlatformFile(
      name: fileData['name'],
      size: fileData['size'],
      path: fileData['path'] ?? '', // Ensure path is not null
      bytes: null, // Cannot save bytes in SharedPreferences
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, {
            'progress': progressValue,
            'allAnswered': allQuestionsAnswered,
            'file': file,
            }
            );

          return true;
          },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 80,
            backgroundColor: purple,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Detail',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Progress Bar
              LinearPercentIndicator(
                width: MediaQuery.of(context).size.width,
                lineHeight: 15,
                progressColor: Color(0xFF1AAD21),
                backgroundColor: Color(0xFFDDC8FF),
                percent: progressValue,
                center: Text('${(100 * progressValue).toInt()}'),
              ),

              TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(child: Text('Material'),),
                  Tab(child: Text('Assessment'),),
                  Tab(child: Text('Assignment'),),
                ],
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: progressValue < 1.0
                      ? const NeverScrollableScrollPhysics() // Disable swipe when progress < 100%
                      : const AlwaysScrollableScrollPhysics(), // Enable swipe when progress = 100%
                  children: <Widget>[
                    _buildMaterialContent(),
                    progressValue >= 1.0 ? _buildAssessmentContent() : _lockedContent(),
                    allQuestionsAnswered ? _buildAssignmentContent() : _lockedAssignmentContent(),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildMaterialContent() {
    return material != null ? Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildHTMLContent(material != null ? material!.content : '''There is no Material yet!'''),
        )
    ) : Center(
        child: Column(
          children: [
            Image.asset('lib/assets/empty.png', width: 100, height: 100,),
            SizedBox(height: 20,),
            Text('Mohon maaf belum ada materi'),
          ],
        )
    );
  }

  Widget _lockedContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Baca Materi terlebih dahulu!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _lockedAssignmentContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Kerjakan terlebih dahulu Assessment!",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHTMLContent(String material) {
    return HtmlWidget(material);
  }

  Widget _buildAssessmentContent() {
    return question != null ?
        question!.questions.isNotEmpty ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: question?.questions.length,
                itemBuilder: (context, count) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: _buildQuestion(count),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed:() {
                        setState(() {
                          tapped = true;
                          allQuestionsAnswered = question!.questions.every((question) => question.selectedAnswer != '' || question.selectedMultAnswer.isNotEmpty);
                          print(allQuestionsAnswered);
                        });
                      },
                      style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
                      child: Text('Done', style: TextStyle(fontSize: 20, color: Colors.white),)
                  ),
                  allQuestionsAnswered && tapped?
                  Text('Bagus! Kamu sudah menjawab semuanya', style: TextStyle(color: Colors.green, fontSize: 13),)
                      : tapped ? Text('Kamu belum menjawab semuanya, Ayo cek kembali!', style: TextStyle(color: Colors.red, fontSize: 13)) : SizedBox()
                ],
              ),
            )
          ],
        ) : Center(
            child: Column(
              children: [
                Image.asset('lib/assets/empty.png', width: 100, height: 100,),
                SizedBox(height: 20,),
                Text('Mohon maaf belum ada pertanyaan'),
              ],
            )
        )
        : Center(
        child: Column(
          children: [
            Image.asset('lib/assets/empty.png', width: 100, height: 100,),
            SizedBox(height: 20,),
            Text('Mohon maaf belum ada pertanyaan'),
          ],
        )
    );
  }

  Widget _buildQuestion(int number) {
    switch (question?.questions[number].type) {
      case 'pg' || 'tf':
        return Card(
          child: ListTile(
              leading: Text('${number + 1}', style: TextStyle(fontSize: 20),),
              isThreeLine: true,
              title: Text(question!.questions[number].question),
              subtitle: question!.questions[number].option.isNotEmpty
                  ? _buildChoiceAnswer(question!.questions[number])
                  : null
          ),
        );
      case 'sa' || 'es':
        return Card(
          child: ListTile(
            leading: Text('${number + 1}', style: TextStyle(fontSize: 20),),
            isThreeLine: true,
            title: Text(question!.questions[number].question),
            subtitle: _buildTextAnswer(question!.questions[number]),
          ),
        );
      case 'mc' :
        return Card(
          child: ListTile(
            leading: Text('${number + 1}', style: TextStyle(fontSize: 20),),
            isThreeLine: true,
            title: Text(question!.questions[number].question),
            subtitle: _buildMultiSelectAnswer(question!.questions[number]),
          ),
        );
      default:
        return const SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Text('There is no Question yet'),
          ),
        );
    }
  }


  Widget _buildChoiceAnswer(Question question) {
    return Column(
      children: question.option.map((answer) {
        return RadioListTile<String>(
          title: Text(answer),
          value: answer,
          groupValue: question.selectedAnswer, // ✅ Group all radio buttons
          onChanged: (String? value) {
            setState(() {
              question.selectedAnswer = value!;
              print(question.selectedAnswer);// ✅ Update selected value
            });
          },
        );
      }).toList(), // ✅ Convert to List<Widget>
    );
  }

  Widget _buildTextAnswer(Question question) {
    return Column(
      children: [
        SizedBox(height: 13,),
        TextField(
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration.collapsed(hintText: "Enter your answer here"),
          onChanged: (String answer) {
            setState(() {
              question.selectedAnswer = answer;
            });
          },
        )
      ],
    );
  }

  Widget _buildMultiSelectAnswer(Question question) {
    return SizedBox(
        child: MultiSelectCheckList(
            controller: _controller,
            items: List.generate(question.option.length,
                    (index) =>
                    CheckListCard(
                      value: question.option.elementAt(index),
                      title: Text(question.option.elementAt(index)),
                      enabled: true,
                    )),
            onChange: (allSelectedItems, selectedItem) {
              setState(() {
                question.selectedMultiAnswer = allSelectedItems;
              });
            }
        )
    );
  }

  Widget _buildAssignmentContent() {
    return Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              _buildHTMLAssigment(),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: file == null ?
                DottedBorder(
                  borderType: BorderType.RRect,
                  radius: Radius.circular(12),
                  color: Colors.grey.shade400,
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.file_present, color: Colors.grey.shade400, size: 80,),
                            Text('Belum ada file yang di upload', style: TextStyle(fontSize: 10, color: Colors.grey.shade400),)
                          ],
                        )
                      ),
                    ),
                ) : SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(image: AssetImage(
                            file?.extension == 'pdf' 
                                ? 'lib/assets/iconpdf.png'
                                : file?.extension == 'jpg' 
                                ? 'lib/assets/iconjpg.png'
                                : ''
                          ), width: 80, height: 80,
                        ),
                        Text(file!.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),)
                      ],
                    ),
                  ),
                )
              ),
              ElevatedButton.icon(
                  onPressed:() async {
                    result = await FilePicker.platform.pickFiles();
                    if (result == null)
                      return;
                    else {
                      setState(() {
                        file = result?.files.first;
                        saveFile(file!);
                      });
                    }
                  },
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
                  icon: Icon(Icons.insert_drive_file_sharp, size: 20, color: Colors.white,),
                  label: Text('Pick File', style: TextStyle(fontSize: 20, color: Colors.white),)
              ),
            ],
          ),
        )
    );
  }

  Widget _buildHTMLAssigment() {
    return SizedBox(
      width: double.infinity,
      child: HtmlWidget(
          r'''
      <p>Buatlah Resume mengenai pembelajaran HCI. Sertakan juga penjelasan mengenai bagan ini</p>
      <p><img src='asset:lib/assets/baganHCI.png'></p>
      '''
      ),
    );
  }

}
