class MyCourse {
  String _imageUrl;
  String _surnameCourse;
  String _courseName;
  String _description;
  int _progress;

  MyCourse (this._imageUrl, this._surnameCourse, this._courseName, this._description, this._progress);

  String getImageUrl(){
    return this._imageUrl;
  }

  String getSurnameCourse() {
    return this._surnameCourse;
  }

  String getCourseName() {
    return this._courseName;
  }

  String getDescription() {
    return this._description;
  }

  int getProgress() {
    return this._progress;
  }

  void setImageUrl(String url) {
    this._imageUrl = url;
  }

  void setSurnameCourse(String surnameCourse) {
    this._surnameCourse = surnameCourse.toUpperCase();
  }

  void setCourseName(String course){
    this._courseName = course;
  }

  void setDescription(String desc) {
    this._description = desc;
  }

  void setProgress(int progress) {
    this._progress = progress;
  }
}