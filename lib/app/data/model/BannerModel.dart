class BannerModel {
  int? setOrder;
  String? photo;
  String? title;
  String? titleEn;
  bool? isPublish;
  String? redirect_type;
  String? redirect_id;

  BannerModel(
      {this.setOrder,
      this.photo,
      this.title,
      this.titleEn,
      this.redirect_type,
      this.redirect_id,
      this.isPublish});

  BannerModel.fromJson(Map<String, dynamic> json) {
    setOrder = json['set_order'];
    photo = json['photo'];
    title = json['title'];
    titleEn = json['titleEn'];
    isPublish = json['is_publish'];
    redirect_type = json['redirect_type'];
    redirect_id = json['redirect_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['set_order'] = setOrder;
    data['photo'] = photo;
    data['title'] = title;
    data['titleEn'] = titleEn;
    data['is_publish'] = isPublish;
    data['redirect_type'] = redirect_type;
    data['redirect_id'] = redirect_id;
    return data;
  }
}
