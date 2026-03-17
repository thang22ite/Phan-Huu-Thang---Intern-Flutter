import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'domain/repositories/i_prediction_repository.dart';
import 'data/repositories/prediction_repository_impl.dart';
import 'presentation/bloc/prediction_bloc.dart';

final sl = GetIt.instance; // sl = Service Locator

void init() {
  // Bloc
  sl.registerFactory(() => PredictionBloc(repository: sl()));

  // Repository
  sl.registerLazySingleton<IPredictionRepository>(
      () => PredictionRepositoryImpl(client: sl()));

  // External
  sl.registerLazySingleton(() => http.Client());
}
