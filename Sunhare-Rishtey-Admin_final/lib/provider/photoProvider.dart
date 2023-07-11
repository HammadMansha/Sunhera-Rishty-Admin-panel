import 'package:flutter/cupertino.dart';
import 'package:sunhare_rishtey_new_admin/models/photoModel.dart';

class PhotoProvider with ChangeNotifier {
  List<PhotoModel> allPhotos = [];
  setPhotoList(List<PhotoModel> pho) {
    allPhotos = pho;
  }

  updateList(String id) {
    allPhotos.removeWhere((element) => element.photoId == id);
    notifyListeners();
  }
}
