class ImageUploadModel {
  bool uploadingImage;
  String? imageLink;
  final int id;

  ImageUploadModel(
      {required this.id, this.imageLink, this.uploadingImage = true});

  ImageUploadModel copyWith({String? imageLink, bool? uploadingImage}) {
    return ImageUploadModel(
        id: id,
        imageLink: imageLink ?? this.imageLink,
        uploadingImage: uploadingImage ?? this.uploadingImage);
  }
}