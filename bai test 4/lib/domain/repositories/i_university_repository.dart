import '../entities/region.dart';
import '../entities/university.dart';

abstract class IUniversityRepository {
  Future<List<University>> getUniversities();
  Future<List<Region>> getRegions();
}
