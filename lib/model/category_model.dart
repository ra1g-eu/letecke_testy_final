class UserCategory {
  int questionId;
  int categoryId;

  UserCategory({this.questionId, this.categoryId});

  UserCategory.fromJson(Map<String, dynamic> json)
      : questionId = json['questionId'],
        categoryId = json['categoryId'];

  Map<String, dynamic> toJson() => {
    'questionId':questionId,
    'categoryId':categoryId,
  };
}