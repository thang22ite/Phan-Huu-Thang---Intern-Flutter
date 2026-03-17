import '../../domain/entities/region.dart';
import '../../domain/entities/university.dart';
import '../../domain/repositories/i_university_repository.dart';
import '../datasources/university_mock_datasource.dart';

class UniversityRepositoryImpl implements IUniversityRepository {
  final UniversityMockDatasource _datasource;

  UniversityRepositoryImpl({UniversityMockDatasource? datasource})
      : _datasource = datasource ?? UniversityMockDatasource();

  @override
  Future<List<University>> getUniversities() async {
    // Simulate async network/db call
    await Future.delayed(const Duration(milliseconds: 300));
    return _datasource.getUniversities();
  }

  @override
  Future<List<Region>> getRegions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _datasource.getRegions();
  }
}
