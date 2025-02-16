import 'dart:convert';

import 'package:app/main.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/assessment.dart';

class Chapterscreen extends StatefulWidget {
  const Chapterscreen({super.key});

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
  double progressValue = 0.0; // Track progress
  bool allQuestionsAnswered = false;
  bool tapped = false;
  final typeQuestion = [
    Assessment(
        'pg',
        'Di bawah ini, manakah yang bukan merupakan elemen utama dalam HCI?',
        listAnswer: Set.of(['Manusia', 'Komputer', 'Jaringan', 'Interaksi']),
        correctAnswer: ['Jaringan']
    ),
    Assessment(
      'sa',
      'Sebutkan tiga elemen utama dalam HCI!',
    ),
    Assessment(
        'tf',
        'HCI hanya berfokus pada desain antarmuka grafis (GUI) dan tidak mempertimbangkan faktor manusia seperti kognisi dan ergonomi.',
        listAnswer: Set.of(['True', 'False']),
        correctAnswer: ['false']
    ),
    Assessment(
        'mc',
        'Dalam HCI, apa yang menjadi tantangan utama dalam mendesain sistem interaktif? (Pilih dua)',
        listAnswer: Set.of([
          'Memastikan sistem memiliki fitur yang benar-benar dibutuhkan pengguna',
          'Mengasumsikan bahwa semua pengguna berpikir seperti desainer',
          'Mengembangkan sistem tanpa mempertimbangkan usability',
          'Memastikan sistem mudah dipelajari dan digunakan'
        ]),
        correctAnswer: [
          'Memastikan sistem memiliki fitur yang benar-benar dibutuhkan pengguna',
          'Memastikan sistem mudah dipelajari dan digunakan'
        ]
    ),
    Assessment(
      'es',
      'Jelaskan bagaimana pendekatan Human-Centered Design dalam HCI dapat meningkatkan pengalaman pengguna dalam menggunakan suatu sistem interaktif!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress(); // Load saved progress
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _saveProgress(); // Save progress before disposing
    super.dispose();
  }

  void _updateProgress() {
    double currentProgressValue = _scrollController.offset / _scrollController.position.maxScrollExtent;

    // Fix: Replace switch-case with proper conditionals
    if (currentProgressValue < 0.0) {
      currentProgressValue = 0.0;
    } else if (currentProgressValue > 1.0) {
      currentProgressValue = 1.0;
    }
    // Only increase progress, never decrease
    // progressValue = currentProgressValue > progressValue ? currentProgressValue : progressValue;
    setState(() {
      progressValue = currentProgressValue;
    });
  }

  void _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('progressValue', progressValue);
    await prefs.setBool('allQuestionsAnswered', allQuestionsAnswered);

    if (file != null) await saveFile(file!);
  }

  void _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      progressValue = prefs.getDouble('progressValue') ?? 0.0;
      allQuestionsAnswered = prefs.getBool('allQuestionsAnswered') ?? false;
    });

    // Load file separately (since it's async)
    file = await loadFile();
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
    return Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _buildHTMLContent(),
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

  Widget _buildHTMLContent() {
    return HtmlWidget(
        r'''<p>HCI adalah bidang studi yang mulai 
      berkembang pada tahun 1980-an, tetapi 
      konsep interaksi manusia dan mesin 
      sudah ada sebelumnya dengan berbagai 
      istilah seperti Man-Machine Interaction 
      (MMI) pada 1970-an, Computer and Human 
      Interaction (CHI), dan Human-Machine 
      Interaction (HMI). HCI mempelajari 
      cara manusia dan komputer bekerja 
      bersama untuk menyelesaikan tugas 
      tertentu. Fokus utama HCI adalah 
      perancangan, evaluasi, dan implementasi 
      sistem interaktif yang digunakan manusia. 
      HCI juga berhubungan dengan usability 
      (daya guna), yang berarti sistem harus 
      mudah digunakan, dipelajari, dan memberikan 
      keamanan bagi pengguna.</p>
      <p>HCI terdiri dari tiga elemen utama, 
      yaitu <strong>manusia, komputer, dan interaksi</strong></p>
      <ul>
        <li><strong>Manusia</strong> sebagai pengguna memiliki 
        kebutuhan dan keterbatasan yang harus 
        dipertimbangkan dalam desain sistem. </li>
        <li><strong>Komputer </strong> mencakup 
        perangkat keras dan lunak yang digunakan 
        untuk berinteraksi dengan manusia.  </li>
        <li><strong>Interaksi </strong>terjadi 
        melalui antarmuka yang harus dirancang 
        agar nyaman dan efisien. </li>
      </ul>
      <p>
        Fokus utama HCI adalah perancangan dan 
        evaluasi user interface (UI), yaitu bagian 
        dari sistem komputer yang memungkinkan manusia 
        berinteraksi dengan komputer. 
      </p>
      <p><img src="asset:lib/assets/alurHCI.png"></p>
      <p>
        UI harus dirancang dengan mempertimbangkan <strong>human factors</strong>, seperti kognisi dan ergonomi, agar pengguna dapat berinteraksi dengan nyaman dan efektif.
      </p>
      <p>
        Dalam desain sistem interaktif, sering 
        kali desainer atau programmer tidak memahami 
        dengan tepat kebutuhan dan lingkungan kerja 
        pengguna. Masalah lain yang sering terjadi 
        adalah sistem komputer yang mengharuskan 
        pengguna mengingat terlalu banyak informasi, 
        kurang toleran terhadap kesalahan pengguna, 
        serta tidak mempertimbangkan variasi 
        pengguna yang berbeda-beda. Kesalahan 
        utama dalam desain HCI adalah mengasumsikan 
        bahwa <strong>semua pengguna itu sama</strong> 
        dan bahwa <strong>pengguna memiliki cara berpikir 
        yang sama dengan desainer</strong>. Untuk menciptakan 
        sistem yang baik, penting untuk mempertanyakan 
        desain yang buruk dan memastikan bahwa 
        sistem memungkinkan pengguna menyelesaikan 
        tugas dengan aman, efektif, efisien, dan 
        menyenangkan.
      </p>
      <p>
        Tujuan utama HCI adalah meningkatkan <strong>kualitas hidup pengguna</strong> dengan membuat sistem interaktif yang baik dan mudah digunakan. Sebuah sistem yang baik memiliki beberapa karakteristik <strong>user-friendly</strong>, seperti tampilan yang menarik, kemudahan penggunaan, cepat dipelajari, memberikan pengalaman positif, dan direkomendasikan oleh pengguna lain. Tujuan dalam rekayasa sistem meliputi beberapa aspek penting:
      </p>
      <ol>
        <li><strong>Fungsionalitas yang sesuai</strong>, yaitu memastikan sistem memiliki fitur yang benar-benar dibutuhkan pengguna.</li>
        <li><strong>Keandalan, ketersediaan, keamanan, dan integritas data</strong>, sehingga sistem dapat digunakan kapan saja tanpa risiko kehilangan atau pencurian data.</li>
        <li><strong>Standardisasi, integrasi, konsistensi, dan portabilitas</strong>, yang memastikan antarmuka mudah dipahami dan data dapat digunakan di berbagai perangkat.</li>
        <li><strong>Penjadwalan dan anggaran</strong>, agar proyek selesai tepat waktu dan sesuai dengan biaya yang telah direncanakan.</li>
      </ol>
      <p>
        HCI adalah bidang multidisipliner yang dipengaruhi oleh berbagai bidang ilmu, termasuk:
      </p>
      <ul>
        <li><strong>Psikologi dan ilmu kognitif </strong> untuk memahami persepsi dan pemrosesan informasi oleh manusia. </li>
        <li><strong>Ergonomi </strong>untuk mempertimbangkan aspek fisik pengguna.</li>
        <li><strong>Sosiologi </strong>untuk memahami interaksi sosial dalam penggunaan teknologi.</li>
        <li><strong>Ilmu komputer dan teknik </strong>untuk mengembangkan sistem teknologi.</li>
        <li><strong>Bisnis dan pemasaran </strong>untuk memahami kebutuhan pasar.</li>
        <li><strong>Desain grafis </strong>untuk menciptakan antarmuka yang menarik dan fungsional.</li>
      </ul>
      <p>
        HCI telah berkembang sejak 1960-an, dimulai dengan komputer mainframe dan interaksi berbasis teks. Pada 1970-an, muncul konsep Graphical User Interface (GUI) yang lebih visual dan intuitif. Pada 1990-an, perhatian lebih difokuskan pada usability dan pendekatan desain yang berpusat pada pengguna (user-centered design). Hingga kini, HCI terus berkembang dengan kemajuan teknologi seperti mobile computing, AI, dan interaksi berbasis sensor. Human-centered design adalah pendekatan dalam HCI yang menempatkan manusia sebagai fokus utama dalam pengembangan sistem. Prinsip utama dalam pendekatan ini meliputi memahami kebutuhan pengguna, melibatkan pengguna dalam proses desain, dan mengevaluasi sistem berdasarkan pengalaman pengguna.
      </p>''');
  }

  Widget _buildAssessmentContent() {
    return Column(
      children: [
        Expanded(
            child: ListView.builder(
              itemCount: typeQuestion.length,
              itemBuilder: (context, count) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildQuestion(count),
                );
              },
            ),
        ),
        SizedBox(height: 10),
        ElevatedButton(
            onPressed:() {
              setState(() {
                tapped = true;
                allQuestionsAnswered = typeQuestion.every((question) => question.getSelectedAnswer() != null || question.getSelectedMultiAnswer() != null);
              });
            },
            style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.purple[900])),
            child: Text('Done', style: TextStyle(fontSize: 20, color: Colors.white),)
        ),
        allQuestionsAnswered && tapped?
            Text('Bagus! Kamu sudah menjawab semuanya', style: TextStyle(color: Colors.green, fontSize: 13),)
            : tapped ? Text('Kamu belum menjawab semuanya, Ayo cek kembali!', style: TextStyle(color: Colors.red, fontSize: 13)) : SizedBox()
      ],
    );
  }

  Widget _buildQuestion(int number) {
    switch (typeQuestion[number].getQuestionType()) {
      case 'pg' || 'tf':
        return Card(
          child: ListTile(
              leading: Text('${number + 1}', style: TextStyle(fontSize: 20),),
              isThreeLine: true,
              title: Text(typeQuestion[number].getQuestion()),
              subtitle: typeQuestion[number].getListAnswer()!.isNotEmpty
                  ? _buildChoiceAnswer(typeQuestion[number])
                  : null
          ),
        );
      case 'sa' || 'es':
        return Card(
          child: ListTile(
            leading: Text('${number + 1}', style: TextStyle(fontSize: 20),),
            isThreeLine: true,
            title: Text(typeQuestion[number].getQuestion()),
            subtitle: _buildTextAnswer(typeQuestion[number]),
          ),
        );
      case 'mc' :
        return Card(
          child: ListTile(
            leading: Text('${number + 1}', style: TextStyle(fontSize: 20),),
            isThreeLine: true,
            title: Text(typeQuestion[number].getQuestion()),
            subtitle: _buildMultiSelectAnswer(typeQuestion[number]),
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


  Widget _buildChoiceAnswer(Assessment question) {
    return Column(
      children: question.getListAnswer()!.map((answer) {
        return RadioListTile<String>(
          title: Text(answer),
          value: answer,
          groupValue: question.getSelectedAnswer(), // ✅ Group all radio buttons
          onChanged: (String? value) {
            setState(() {
              question.setSelectedAnswer(value);
              print(question.getSelectedAnswer());// ✅ Update selected value
            });
          },
        );
      }).toList(), // ✅ Convert to List<Widget>
    );
  }

  Widget _buildTextAnswer(Assessment question) {
    return Column(
      children: [
        SizedBox(height: 13,),
        TextField(
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration.collapsed(hintText: "Enter your answer here"),
          onChanged: (String answer) {
            setState(() {
              question.setSelectedAnswer(answer);
            });
          },
        )
      ],
    );
  }

  Widget _buildMultiSelectAnswer(Assessment question) {
    return SizedBox(
        child: MultiSelectCheckList(
            controller: _controller,
            items: List.generate(question.getListAnswer()!.length,
                    (index) =>
                    CheckListCard(
                      value: question.getListAnswer()!.elementAt(index),
                      title: Text(question.getListAnswer()!.elementAt(index)),
                      enabled: true,
                    )),
            onChange: (allSelectedItems, selectedItem) {
              setState(() {
                question.setSelectedMultiAnswer(allSelectedItems);
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
