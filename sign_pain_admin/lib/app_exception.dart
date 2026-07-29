// Custom exception to be used to pass around custom error messages within the app

class AppException implements Exception {
  final String message;
  
  AppException(this.message);

  @override
  String toString() => message; 
}