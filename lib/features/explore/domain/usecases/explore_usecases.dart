import '../entities/topic_item.dart';
import '../repositories/explore_repository.dart';
import '../entities/category.dart';

/// Use cases for the Explore feature.
///
/// These are simple wrappers around [ExploreRepository] that can be
/// injected into the UI layer (e.g., via Riverpod providers).

class GetTopicsWithStatus {
  final ExploreRepository _repository;

  GetTopicsWithStatus(this._repository);

  Future<List<TopicWithStatus>> call() {
    return _repository.getTopicsWithStatus();
  }
}

class SearchTopics {
  final ExploreRepository _repository;

  SearchTopics(this._repository);

  Future<List<TopicWithStatus>> call({String? query, TopicLevel? level}) {
    return _repository.searchTopics(query: query, level: level);
  }
}


class GetCategoriesWithTopics {
  final ExploreRepository _repository;
  GetCategoriesWithTopics(this._repository);

  Future<List<CategoryWithTopics>> call() {
    return _repository.getCategoriesWithTopics();
  }
}