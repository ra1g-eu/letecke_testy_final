import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/database/category_provider.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/model/category_model.dart';
import 'package:letecky_testy/model/user_answer_model.dart';

final categoryListProvider = StateNotifierProvider((ref) => new CategoryList([]));
final questionCategoryState = StateProvider((ref) => new Category());
final isTestMode = StateProvider((ref) => false);
final currentReadPage = StateProvider((ref) => 0);
final userAnswerSelected = StateProvider((ref) => new UserAnswer());
final isEnableShowAnswer = StateProvider((ref) => false);
final isReadMode = StateProvider((ref) => false);
final userListAnswer = StateProvider((ref) => List<UserAnswer>());
final userViewQuestionState = StateProvider((ref) => new Question());
final userListQuestion = StateProvider((ref) => List<UserCategory>());