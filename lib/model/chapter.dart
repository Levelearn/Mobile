import 'package:app/model/assessment.dart';

import 'assessment.dart';
import 'assignment.dart';

class Chapter {
  String _material;
  Set<Assessment> _assessment;
  Assignment _assignment;

  Chapter (this._material, this._assessment, this._assignment);

  String getMaterial(){
    return this._material;
  }

  Set<Assessment> getAssessment() {
    return this._assessment;
  }

  Assignment getAssignment() {
    return this._assignment;
  }

  void setMaterial(String material) {
    this._material = material;
  }

  void setAssessment(Set<Assessment> assesment) {
    this._assessment = assesment;
  }

  void setAssignment(Assignment assignment){
    this._assignment = assignment;
  }
}