import 'package:eng2yo/src/resources/api_provider.dart';

class Repository {
  ApiProvider provider = ApiProvider();
  Future<String> fetchTranslation(String word) =>
      provider.fetchTranslation(word);
}
