import 'package:eng2yo/src/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class TranslateBloc {
  final _repo = Repository();
  final _translationFetcher = PublishSubject<String>();
  Stream<String> get translation => _translationFetcher.stream;

  fetchTranslation(String word) async {
    var translation = await _repo.fetchTranslation(word);
    _translationFetcher.sink.add(translation);
  }

  void dispose() {
    _translationFetcher.close();
  }
}

final bloc = TranslateBloc();
