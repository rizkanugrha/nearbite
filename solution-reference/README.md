# Solution Reference, p03-provider-crud

> **KHUSUS DOSEN. Jangan dibagikan ke mahasiswa sebelum sesi P03 selesai.**

## Lokasi solusi lengkap

Repo/tag privat dosen: `solution/p03`. File ini ringkasan pendekatan.

## Implementasi CRUD yang diharapkan

`lib/features/tasks/presentation/providers/task_provider.dart`:

```dart
void addTask(Task task) {
 _tasks = [..._tasks, task];
 notifyListeners();
}

void updateTask(Task task) {
 _tasks = [
 for (final t in _tasks)
 if (t.id == task.id) task else t,
 ];
 notifyListeners();
}

void deleteTask(String id) {
 _tasks = _tasks.where((t) => t.id != id).toList();
 notifyListeners();
}

void toggleComplete(String id) {
 _tasks = [
 for (final t in _tasks)
 if (t.id == id) t.copyWith(isCompleted: !t.isCompleted) else t,
 ];
 notifyListeners();
}
```

## Validasi form

```dart
String? _validateTitle(String? value) {
 final v = value?.trim() ?? '';
 if (v.isEmpty) return AppStrings.errTitleRequired;
 if (v.length < 3) return AppStrings.errTitleTooShort;
 return null;
}
```

## Titik pengajaran

- Immutability: ganti seluruh list, bukan `list[i] =...` (bisa, tapi gaya immutable lebih aman untuk reaktivitas).
- `notifyListeners()` wajib di setiap mutasi.
- State UI: loading/error/empty/list, empat cabang render di `TaskListScreen`.
- Form: `GlobalKey<FormState>` + `validator` per field.

## Koneksi ke tugas

Setelah CRUD hijau, ini menjadi baseline Assignment 1, Task Tracker Core. Mahasiswa
menambah search + filter (lihat P01) pada versi Provider ini.
