import 'package:app/view/chapterScreen.dart';
import 'package:flutter/cupertino.dart';

class Assessment {
  String _question;
  String _questionType;
  Set<String>? _listanswer;
  List<String>? _correctAnswer;
  String? _selectedAnswer;
  List<String>? _selectedMultiAnswer;

  Assessment(
      this._questionType,
      this._question, {
        Set<String>? listAnswer,  // Optional with default value
        List<String>? correctAnswer,    // Optional
      })  : _listanswer = listAnswer ?? {},
        _correctAnswer = correctAnswer;


  String getQuestion(){
    return this._question;
  }

  String getQuestionType(){
    return this._questionType;
  }

  Set<String>? getListAnswer() {
    return this._listanswer;
  }

  List<String>? getCorrectAnswer() {
    return this._correctAnswer;
  }

  String? getSelectedAnswer(){
    return this._selectedAnswer;
  }

  List<String>? getSelectedMultiAnswer() {
    return this._selectedMultiAnswer;
  }

  void setQuestion(String question) {
    this._question = question;
  }

  void setQuestionType(String type) {
    this._questionType = type;
  }

  void setListAnswer(Set<String> answer) {
    this._listanswer = answer;
  }

  void setCorrectAnswer(List<String>? correct){
    this._correctAnswer = correct;
  }

  void setSelectedAnswer(String? answer) {
    this._selectedAnswer = answer;
  }

  void setSelectedMultiAnswer(List<String>? listAnswer){
    this._selectedMultiAnswer = listAnswer;
  }
}