import 'dart:io';
import 'package:app/main.dart';
import 'package:app/model/assignment.dart';
import 'package:app/model/chapter_status.dart';
import 'package:app/model/learning_material.dart';
import 'package:app/model/user_course.dart';
import 'package:app/service/chapter_service.dart';
import 'package:app/service/user_chapter_service.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:open_filex/open_filex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/assessment.dart';
import '../service/user_course_service.dart';

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
  Assignment? assignment;
  LearningMaterial? material;
  double downloadProgress = 0.0;
  String lastestSubmissionUrl = '';
  bool complete = false;

  @override
  void initState() {
    getMaterial(widget.status.chapterId);
    getAssessment(widget.status.chapterId);
    getAssignment(widget.status.chapterId);
    progressValue = widget.status.materialDone ? 1.0 : 0;
    allQuestionsAnswered = widget.status.assessmentDone;
    assignmentDone = widget.status.assignmentDone;
    showDialogMaterialOnce = widget.status.materialDone;
    showDialogAssessmentOnce = widget.status.assessmentDone;
    showDialogAssignmentOnce = widget.status.assignmentDone;
    status = widget.status;
    uc = widget.uc;
    chLength = widget.chLength;
    if (status.submission != null && status.submission != '') {
      lastestSubmissionUrl = status.submission!;
    }
    complete = status.isCompleted;
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(updateProgressMaterial);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  updateProgressMaterial() {
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
          showCompletionDialog(context, "Yeay kamu berhasil menyelesaikan Materi, Ayo lanjutkan ke bagian Assessment", false);
        });
        showDialogMaterialOnce = true;
      }
    });

    if (progressValue >= 1.0) {
      status.materialDone = true;
      updateStatus();
    }
  }

  updateProgressAssessment() {
    if (status.assessmentDone && !showDialogAssessmentOnce) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCompletionDialog(context, "Yeay kamu berhasil menyelesaikan Assessment, Ayo lanjutkan ke bagian Assignment", false);
      });
      showDialogAssessmentOnce = true;
    }
  }

  updateProgressAssignment() {
    if (status.assignmentDone && status.isCompleted && !showDialogAssignmentOnce) {
      showDialogAssignmentOnce = true; // Set before calling dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCompletionDialog(context, "Yeay kamu berhasil menyelesaikan Chapter ini, Ayo lanjutkan pelajari chapter yang lain", true);
      });
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

  void getAssignment(int id) async {
    final resultAssignment = await ChapterService.getAssignmentByChapterId(id);
    setState(() {
      assignment = resultAssignment;
    });
  }

  Future<void> uploadFile(PlatformFile file) async {
    final filename = '${file.name.split('.').first}_${status.userId}_${status.chapterId}.${file.extension}';
    final path = 'uploads/$filename';

    Uint8List bytes = file.bytes ?? await File(file.path!).readAsBytes();

    try {
      await Supabase.instance.client.storage.from('assigment').uploadBinary(path, bytes);
      final publicUrl = getPublicUrl(path);

      setState(() {
        status.submission = publicUrl;
        status.isCompleted = true;
        status.assignmentDone = true;
      });
      await updateStatus();
    } catch (e) {
      if (kDebugMode) {
        print('Upload error: $e');
      }
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

  void showCompletionDialog(BuildContext context, message, bool isAssignment) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Progress Completed!"),
          content: Text("$message"),
        actions: [
        TextButton(
              onPressed: () {
                if(!isAssignment) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                  complete = true;
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _openFile(String filePath) {
    OpenFilex.open(filePath);
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
                      onPressed: () {
                        setState(() {
                          tapped = true;
                          allQuestionsAnswered = question!.questions.every(
                                (question) => question.selectedAnswer != '' || question.selectedMultAnswer.isNotEmpty,
                          );
                        });

                        if (allQuestionsAnswered && tapped) {
                          if (question!.answers == null) {
                            question!.answers = [];
                          }
                          for (var q in question!.questions) {
                            question!.answers!.add(q.selectedAnswer);
                          }
                          status.assessmentDone = true;
                          status.assessmentAnswer = question!.answers!;
                          updateProgressAssessment();
                        }

                        updateStatus();
                      },
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.purple[900])),
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
      case 'PG':
      case 'TF':
      case 'MC':
        return Card(
          child: ListTile(
            leading: Text('${number + 1}', style: TextStyle(fontSize: 20)),
            isThreeLine: true,
            title: Text(question?.questions[number].question ?? 'No question available', style: TextStyle(fontSize: 12)),
            subtitle: question?.questions[number].option.isNotEmpty ?? false
                ? _buildChoiceAnswer(question!.questions[number])
                : null,
          ),
        );
      case 'EY':
        return Card(
          child: ListTile(
            leading: Text('${number + 1}', style: TextStyle(fontSize: 20)),
            isThreeLine: true,
            title: Text(question?.questions[number].question ?? 'No question available'),
            subtitle: _buildTextAnswer(question!.questions[number]),
          ),
        );
      default:
        return const SizedBox(
          width: double.infinity,
          height: 100,
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
            if (value != null) {
              setState(() {
                question.selectedAnswer = value;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswer(Question question) {
    return Column(
      children: [
        SizedBox(height: 13),
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

  // Widget _buildMultiSelectAnswer(Question question) {
  //   return SizedBox(
  //       child: MultiSelectCheckList(
  //           controller: _controller,
  //           items: List.generate(question.option.length,
  //                   (index) =>
  //                   CheckListCard(
  //                     value: question.option.elementAt(index),
  //                     title: Text(question.option.elementAt(index)),
  //                     enabled: true,
  //                   )),
  //           onChange: (allSelectedItems, selectedItem) {
  //             setState(() {
  //               question.selectedMultiAnswer = allSelectedItems;
  //             });
  //           }
  //       )
  //   );
  // }

  Widget _buildAssignmentContent() {
    return Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Column(
            children: [
              assignment?.instruction == null ? CircularProgressIndicator() : _buildHTMLAssignment(),
              assignment?.fileUrl != null && assignment?.fileUrl != "" ? ListTile(
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.download_rounded, size: 30, color: Colors.deepPurple.shade700),
                    if (downloadProgress > 0.0 && downloadProgress < 1.0) // Show progress only while downloading
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: downloadProgress,
                          strokeWidth: 3,
                          backgroundColor: Colors.grey[300],
                          color: Colors.deepPurple,
                        ),
                      ),
                  ],
                ),
                title: Text("Unduh file assignment disini"),
                onTap: () async {
                  FileDownloader.downloadFile(
                      url: assignment!.fileUrl!,
                    onProgress: (name, progress) {
                      setState(() {
                        debugPrint("Download Progress: $progress");
                        downloadProgress = progress / 100;
                      });
                    },
                    onDownloadCompleted: (filePath) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Download Complete, saved in $filePath"),
                          action: SnackBarAction(
                            label: "Open",
                            onPressed: () => _openFile(filePath),
                          ),
                        ),
                      );
                      setState(() {
                        downloadProgress = 0;
                      });
                    },
                  );
                }
              ) : SizedBox(),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: GestureDetector(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );

                    if (result == null) return;

                    final fileSizeInMB = result.files.first.size / (1024 * 1024); // Convert bytes to MB

                    if (fileSizeInMB > 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('File size must be 5MB or less')),
                      );
                    } else {
                      setState(() {
                        file = result.files.first; // Ensure file updates
                      });
                    }
                  },
                  child: file == null
                      ? _buildUploadBox()  // UI before file selection
                      : _buildFilePreview(file!), // Updated file preview
                ),
              ),
              lastestSubmissionUrl != '' ? _buildExistingFile(lastestSubmissionUrl) : SizedBox(),
              file == null ? SizedBox() : Row(
                children: [
                  ElevatedButton.icon(
                    onPressed:() {
                      setState(() {
                        file = null;
                      });
                    },
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.purple[900])),
                    icon: Icon(Icons.delete, size: 20, color: Colors.white,),
                    label: Text('Delete', style: TextStyle(fontSize: 10, color: Colors.white),)
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await uploadFile(file!);
                      uc.progress = (((uc.currentChapter - 1) / chLength) * 100).toInt();
                      updateUserCourse();

                      updateProgressAssignment();

                      Future.delayed(Duration(milliseconds: 200), () {
                        if (complete) {
                          Navigator.pop(context);
                        }
                      });
                    },
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.purple[900])),
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

  Widget _buildHTMLAssignment() {
    return SizedBox(
      width: double.infinity,
      child: Text(assignment!.instruction)
    );
  }

  Widget _buildUploadBox() {
    return DottedBorder(
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
              Icon(Icons.file_present, color: Colors.grey.shade400, size: 80),
              Text(
                'Tap untuk mengunggah file',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(PlatformFile file) {
    return DottedBorder(
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
              Image(image: AssetImage(
                  file.extension == 'pdf'
                      ? 'lib/assets/iconpdf.png'
                      : file.extension == 'jpg'
                      ? 'lib/assets/iconjpg.png'
                      : ''
              ), width: 80, height: 80,
              ),
              Text(
                file.name,
                style: TextStyle(fontSize: 12, color: Colors.deepPurple.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingFile(String url) {
    return GestureDetector(
      onTap: () async {
        FileDownloader.downloadFile(
          url: url,
          onDownloadCompleted: (filePath) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Download Complete, saved in $filePath"),
                action: SnackBarAction(
                  label: "Open",
                  onPressed: () => _openFile(filePath),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.deepPurple),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                url.split('/').last.replaceAll('%20', ' '),
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
