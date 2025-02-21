import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app/main.dart';
import 'package:app/model/chapterStatus.dart';
import 'package:app/model/learningmaterial.dart';
import 'package:app/model/userCourse.dart';
import 'package:app/service/chapterService.dart';
import 'package:app/service/userChapterService.dart';
import 'package:app/view/courseDetailScreen.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/assessment.dart';
import '../service/userCourseService.dart';

class Chapterscreen extends StatefulWidget {
  final ChapterStatus status;
  final int chapterIndexInList;
  final UserCourse uc;
  final int chLength;
  const Chapterscreen({
    super.key,
    required this.status,
    required this.chapterIndexInList,
    required this.uc,
    required this.chLength,
  });

  @override
  State<Chapterscreen> createState() => _ChapterScreen();
}

class _ChapterScreen extends State<Chapterscreen> with TickerProviderStateMixin {
  FilePickerResult? result;
  PlatformFile? file;
  int navIndex = 1;
  late ChapterStatus status;
  late UserCourse uc;
  int chLength = 0;
  late final TabController _tabController;
  late ScrollController _scrollController;
  final MultiSelectController<String> _controller = MultiSelectController();
  double progressValue = 0.0;
  bool allQuestionsAnswered = false;
  bool assignmentDone = false;
  bool showDialogMaterialOnce = false;
  bool showDialogAssessmentOnce = false;
  bool showDialogAssignmentOnce = false;
  bool tapped = false;
  Assessment? question;
  LearningMaterial? material;

  @override
  void initState() {
    getMaterial(widget.status.chapterId);
    getAssessment(widget.status.chapterId);
    progressValue = widget.status.materialDone ? 1.0 : 0;
    allQuestionsAnswered = widget.status.assessmentDone;
    assignmentDone = widget.status.assignmentDone;
    showDialogMaterialOnce = widget.status.materialDone;
    showDialogAssessmentOnce = widget.status.assessmentDone;
    showDialogAssignmentOnce = widget.status.assignmentDone;
    status = widget.status;
    uc = widget.uc;
    chLength = widget.chLength;
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
      progressValue = currentProgressValue <= progressValue ? progressValue : currentProgressValue;
      if (progressValue >= 1.0 && !showDialogMaterialOnce) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCompletionDialog(context, "Yeay kamu berhasil menyelesaikan Materi, Ayo lanjutkan ke bagian Assessment");
        });
        showDialogMaterialOnce = true;
      }

      if (status.assessmentDone && !showDialogAssessmentOnce) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCompletionDialog(context, "Yeay kamu berhasil menyelesaikan Assessment, Ayo lanjutkan ke bagian Assignment");
        });
        showDialogAssessmentOnce = true;
      }

      if (status.assignmentDone && status.isCompleted && !showDialogAssignmentOnce) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showCompletionDialog(context, "Yeay kamu berhasil menyelesaikan Chapter ini, Ayo lanjutkan pelajari chapter yang lain");
        });
        showDialogAssignmentOnce = true;
      }
    });

    if (progressValue >= 1.0) {
      status.materialDone = true;
      updateStatus();
    }
  }

  Future<void> updateStatus() async {
    status = await UserChapterService.updateChapterStatus(status.id, status);
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

  Future<void> uploadFile(PlatformFile file) async {
    final filename = '${DateTime.now().millisecondsSinceEpoch}_${status.userId}_${status.chapterId}.${file.extension}';
    final path = 'uploads/$filename';

    Uint8List bytes;
    if (file.bytes != null) {
      bytes = file.bytes!;
    } else {
      bytes = await File(file.path!).readAsBytes();
    }

    try {
      final response = await Supabase.instance.client.storage
          .from('assigment') // Make sure bucket name is correct
          .uploadBinary(path, bytes);

      if (response != null) {
        final publicUrl = getPublicUrl(path);
        print('Public URL: $publicUrl');

        setState(() {
          status.submission = publicUrl;
          status.isCompleted = true;
          status.assignmentDone = true;
        });
        updateStatus();
      } else {
        print('Upload failed: No response');
      }
    } catch (e) {
      print('Upload error: $e');
    }
  }

  String getPublicUrl(String filePath) {
    return Supabase.instance.client.storage
        .from('assigment')
        .getPublicUrl(filePath);
  }

  void updateUserCourse() async {
    await UserCourseService.updateUserCourse(uc.id, uc);
  }

  void showCompletionDialog(BuildContext context, message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Progress Completed!"),
          content: Text("${message}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, {
            'status': status.toJson(),
            'index': widget.chapterIndexInList
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
              TabBar(
                controller: _tabController,
                tabs: const <Widget>[
                  Tab(child: Text('Material', style: TextStyle(fontSize: 12),),),
                  Tab(child: Text('Assessment', style: TextStyle(fontSize: 12)),),
                  Tab(child: Text('Assignment', style: TextStyle(fontSize: 12)),),
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
            "Kerjakan Assessment terlebih dahulu Assessment!",
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
                        if(allQuestionsAnswered && tapped) {
                          for (var q in question!.questions) {
                            question!.answers.add(q.selectedAnswer);
                          }
                          status.assessmentDone = true;
                          status.assessmentAnswer = question!.answers;
                        }
                        updateStatus();
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
              title: Text(question!.questions[number].question, style: TextStyle(fontSize: 12)),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: question.option.map((answer) {
        return RadioListTile<String>(
          title: Text(answer, style: TextStyle(fontSize: 12)),
          value: answer,
          groupValue: question.selectedAnswer,
          onChanged: (String? value) {
            setState(() {
              question.selectedAnswer = value!;
            });
          },
        );
      }).toList(),
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
              file == null ? ElevatedButton.icon(
                  onPressed:()  async {
                    result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']
                    );
                    if (result == null) return; // User canceled file selection

                    final fileSizeInMB = result!.files.first.size / (1024 * 1024); // Convert bytes to MB

                    if (fileSizeInMB > 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File size must be 5MB or less')),
                      );
                    } else {
                      setState(() {
                        file = result?.files.first;
                      });
                    }
                  },
                  style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
                  icon: Icon(Icons.insert_drive_file_sharp, size: 20, color: Colors.white,),
                  label: Text('Pick File', style: TextStyle(fontSize: 20, color: Colors.white),)
              ) : Row(
                children: [
                  ElevatedButton.icon(
                    onPressed:() {
                      setState(() {
                        file = null;
                      });
                    },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
                    icon: Icon(Icons.delete, size: 20, color: Colors.white,),
                    label: Text('Delete', style: TextStyle(fontSize: 10, color: Colors.white),)
                  ),
                  ElevatedButton.icon(
                    onPressed:() async {
                      result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png']
                      );
                      if (result == null) return; // User canceled file selection

                      final fileSizeInMB = result!.files.first.size / (1024 * 1024); // Convert bytes to MB

                      if (fileSizeInMB > 5) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('File size must be 5MB or less')),
                        );
                      } else {
                        setState(() {
                          file = result?.files.first;
                        });
                      }
                    },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
                    icon: Icon(Icons.insert_drive_file_sharp, size: 20, color: Colors.white,),
                    label: Text('Change File', style: TextStyle(fontSize: 10, color: Colors.white),),
                  ),
                  ElevatedButton.icon(
                    onPressed:() async {
                      uploadFile(file!);
                      uc.progress = (uc.currentChapter / chLength).toInt();
                      updateUserCourse();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailScreen(id: status.id),
                        ),
                      );
                    },
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
                    icon: Icon(Icons.done, size: 20, color: Colors.white,),
                    label: Text('Submit', style: TextStyle(fontSize: 10, color: Colors.white),),
                  ),
                ],
              )
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
