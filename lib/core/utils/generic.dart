// lib/core/utils/generic.dart
// Enum untuk status
enum Status { loading, success, error }

// Kelas Generic untuk membungkus hasil dari operasi async
// <T> adalah tipe data yang akan dibungkus, bisa berupa List<Recipe>, Recipe, dll.
class Resource<T> {
  final Status status;
  final T? data;
  final String? message;

  Resource.loading(this.message) : status = Status.loading, data = null;
  Resource.success(this.data) : status = Status.success, message = null;
  Resource.error(this.message) : status = Status.error, data = null;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}