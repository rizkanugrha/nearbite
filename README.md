# NearBite

NearBite adalah aplikasi Flutter untuk menemukan restoran terdekat berdasarkan lokasi pengguna. Pengguna publik dapat melihat restoran, mencari restoran/menu, membuka detail, dan melihat menu. Pemilik restoran dapat mendaftar, login, mengelola profil restoran, serta melakukan CRUD menu.

## Cara Menjalankan

### Prasyarat

- Flutter SDK >= 3.22.0
- Dart SDK >= 3.4.0
- Android Studio/Android SDK atau perangkat Android
- Proyek Supabase yang sudah disiapkan

### Instalasi

```powershell
flutter pub get
```

Buat atau siapkan proyek Supabase, jalankan skema tabel sesuai [ERD dan API NearBite](ERD-dan-API-NearBite.md), lalu jalankan data contoh dari [seed_data.sql](seed_data.sql) setelah akun owner tersedia.

### Menjalankan aplikasi

Gunakan URL dan anon key contoh/placeholder berikut. Jangan memasukkan key asli ke README atau version control.

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key
```

Untuk Windows Command Prompt, gunakan satu baris:

```bat
flutter run --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key
```

Build release:

```powershell
flutter build apk --release `
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=your-supabase-anon-key
```

> Konfigurasi dibaca di [main.dart](lib/main.dart) melalui `String.fromEnvironment`. Nilai default URL hanya untuk memudahkan development; anon key sebaiknya selalu diberikan melalui `--dart-define`.

## Backend

Backend menggunakan **Supabase**, yaitu PostgreSQL, Supabase Auth, dan REST API PostgREST. Aplikasi tidak menggunakan server custom terpisah.

Dokumen skema dan kontrak endpoint dirangkum di [ERD-dan-API-NearBite.md](ERD-dan-API-NearBite.md).

### Setup Supabase

1. Buat proyek Supabase.
2. Aktifkan email/password authentication.
3. Buat tabel `users`, `restaurants`, dan `menu_items` sesuai skema ERD.
4. Tambahkan policy Row Level Security untuk membatasi owner pada data restorannya sendiri.
5. Jalankan [seed_data.sql](seed_data.sql) untuk data restoran/menu contoh.
6. Ambil Project URL dan anon key dari Supabase Project Settings.
7. Masukkan keduanya melalui `--dart-define` saat menjalankan aplikasi.

### Kontrak API utama

- `POST /auth/v1/signup` untuk register.
- `POST /auth/v1/token?grant_type=password` untuk login.
- `GET /auth/v1/user` untuk validasi session cached.
- `GET /rest/v1/restaurants` untuk daftar/detail restoran.
- `POST/PATCH /rest/v1/restaurants` untuk profil restoran owner.
- `GET /rest/v1/menu_items` untuk menu publik.
- `POST/PATCH/DELETE /rest/v1/menu_items` untuk CRUD menu owner.

Semua request REST menggunakan header `apikey`; operasi owner juga menggunakan `Authorization: Bearer <access_token>`.

## Arsitektur

Struktur fitur menggunakan pemisahan domain, data, dan presentation dengan Provider sebagai state management.

```text
UI Screen
   |
   v
Provider / ChangeNotifier
   |
   v
Repository boundary / API client
   |
   v
Datasource: Supabase REST/Auth, SharedPreferences, Geolocator, ImagePicker
```

Dalam implementasi saat ini, `AuthApiClient` dan `RestaurantApiClient` menjalankan peran repository sekaligus datasource HTTP. Jadi belum ada class `Repository` dan `Datasource` terpisah; pemisahan folder tetap menjaga model domain tidak bergantung pada Flutter atau SharedPreferences.

- **Presentation:** screens dan providers di `lib/features/*/presentation`.
- **Domain:** model `User`, `Restaurant`, dan `MenuItem` di `lib/features/*/domain`.
- **Data:** API client, local storage, dan location service di `lib/features/*/data`.
- **Dependency injection:** seluruh service didaftarkan melalui `MultiProvider` di [main.dart](lib/main.dart).
- **Session:** `AuthLocalStorage` menyimpan token dan data user di SharedPreferences; `AuthProvider` memulihkan lalu memvalidasi session.

### Error dan hasil device

`ApiError` adalah sealed hierarchy di [api_error.dart](lib/core/errors/api_error.dart), dengan tipe seperti `NetworkError`, `AuthenticationError`, `ForbiddenError`, `NotFoundError`, `ValidationError`, dan `ParseError`. API client menerjemahkan status HTTP dan kegagalan jaringan menjadi tipe error yang dapat ditangani UI.

Hasil akses lokasi juga memakai sealed result di [location_result.dart](lib/core/errors/location_result.dart):

- `LocationSuccess`
- `LocationDenied`
- `LocationUnavailable`
- `LocationError`

Dengan pola ini, UI dapat menangani sukses, permission ditolak, layanan lokasi mati, dan error lain secara eksplisit.

## Device Feature

### GPS

GPS dipakai untuk mengambil latitude/longitude pengguna, menghitung jarak ke restoran dengan Haversine formula, kemudian mengurutkan restoran dari yang terdekat. Permission ditangani untuk kondisi denied, denied forever, dan location service disabled.

Alasannya: fitur utama NearBite adalah menemukan restoran terdekat, sehingga lokasi pengguna merupakan data inti pengalaman aplikasi.

## Fitur Utama

- Daftar restoran publik dari Supabase.
- Sorting berdasarkan jarak GPS.
- Pencarian restoran/menu dan filter radius 3 km.
- Detail restoran dan daftar menu.
- Register/login owner dengan session persistence.
- CRUD profil restoran dan menu.
- Monitoring koneksi serta banner offline.
- Error handling terstruktur dengan sealed class.

## Known Limitations

- Aplikasi membutuhkan koneksi internet untuk mengambil data; belum ada cache offline.
- `connectivity_plus` mendeteksi jenis transport jaringan, bukan jaminan internet benar-benar dapat menjangkau Supabase.
- Akurasi GPS di emulator terbatas dan bergantung pada lokasi virtual yang dikonfigurasi.
- Build release saat ini masih menggunakan debug signing; cocok untuk demo lokal, belum untuk publikasi Play Store.
- Seed restoran menggunakan owner pertama yang tersedia; untuk deployment nyata, owner_id harus diatur eksplisit.
- Harga belum mendukung multi-currency; seluruh harga diperlakukan sebagai Rupiah.
- Pencarian menu publik masih mengambil seluruh menu sehingga perlu pagination/server-side search untuk dataset besar.
- Upload foto memerlukan konfigurasi Supabase Storage yang sesuai; URL gambar yang gagal ditampilkan menggunakan fallback icon.
- Email verification Supabase dapat membuat register tidak langsung login apabila project mewajibkan konfirmasi email.

## Quality Gate dan Bukti Test

Perintah validasi yang digunakan:

```powershell
flutter analyze
flutter test
```

Hasil test terakhir:

```text
00:12 +85: All tests passed!
```

Jumlah kasus: **85 test**. Test mencakup API client/error mapping, model mapper, distance calculator, provider behavior, connectivity state, dan widget form validation.

`flutter analyze` tidak menghasilkan error compile. Pada kondisi audit terakhir masih ada 17 lint/info yang tidak mengubah perilaku aplikasi:

- 7 saran `prefer_const_*` pada `lib/app.dart`.
- 2 saran `avoid_print` pada logging warning API di `auth_api_client.dart`.
- 1 saran `prefer_const_constructors` pada test API.
- 5 saran `prefer_const_declarations` pada test error API.
- 1 saran `unnecessary_cast` pada test error API.
- 1 warning unused import pada `test/widget_test.dart`.

Tidak ada `// ignore:` yang dipakai untuk memaksa analyzer hijau.

Ukuran APK release terakhir:

```text
build/app/outputs/flutter-apk/app-release.apk: 21.0 MB
```

Di Windows, ukuran dapat dicek dengan:

```powershell
Get-Item build\app\outputs\flutter-apk\app-release.apk |
  Select-Object Name, @{Name='SizeMB'; Expression={[math]::Round($_.Length / 1MB, 1)}}
```

Perintah Unix yang setara dengan permintaan evaluasi:

```bash
du -h build/app/outputs/flutter-apk/app-release.apk
```

### Immutability dan `const`

Model domain memakai field `final` dan `copyWith` agar perubahan menghasilkan object baru. Widget subtree yang tidak bergantung pada state memakai `const`, sehingga Flutter dapat memakai kembali instance widget dan mengurangi pekerjaan saat rebuild. `const` tidak menggantikan `notifyListeners`; Provider tetap memberi notifikasi ketika state berubah.

## Narasi Pemanfaatan AI dan AI Log

Narasi final 6.1 dengan panjang 1.275 kata tersedia di [NARASI-AI.md](NARASI-AI.md). Dokumen tersebut memuat evolusi strategi AI, keputusan menerima/menolak saran, verifikasi pemahaman, penjelasan teknis end-to-end, serta refleksi kejujuran akademik.

AI digunakan sebagai asisten pengembangan, bukan sebagai pengganti keputusan teknis atau pengujian. Pemilik proyek tetap meninjau struktur, menjalankan aplikasi, memeriksa hasil test, dan menentukan fitur yang dipresentasikan.

Bagian yang dibantu AI:

- Menyusun dan mereview implementasi Provider, error handling, connectivity monitoring, dan session validation.
- Menemukan risiko lifecycle seperti pemakaian `BuildContext` setelah `await`, stale owner data setelah logout, dan status Bluetooth yang keliru dianggap online.
- Membuat test connectivity dan membantu membaca hasil `flutter analyze`, `flutter test`, serta build Android.
- Menyusun dokumentasi arsitektur, cara setup Supabase, known limitation, dan skenario live demo.

Bagian yang harus dapat dijelaskan saat presentasi:

- `notifyListeners()` memberi tahu Consumer bahwa state berubah.
- `AuthLocalStorage` menyimpan token/session, sedangkan `User` hanya model domain.
- Haversine menghitung jarak berdasarkan koordinat GPS.
- `ApiError` dan `LocationResult` membuat cabang error/sukses eksplisit.
- `MultiProvider` melakukan dependency injection dari `main.dart`.
- Test dijalankan ulang setelah perubahan dan hasil akhirnya tetap 85 test lulus.

### Ringkasan AI log

| Tahap | Bantuan AI | Verifikasi manusia/perintah |
|---|---|---|
| Fitur offline | Menyusun provider, banner, dan test konektivitas | `flutter test test/connectivity_provider_test.dart` |
| Audit pra-release | Meninjau auth/session, logout, GPS lifecycle, dan Android launch | Membaca source, clean build, install APK, dan menjalankan emulator |
| Perbaikan | Menambahkan session validation, clear owner state, mounted guard, dan klasifikasi koneksi | `flutter analyze`, `flutter test` |
| Dokumentasi | Menyusun README, arsitektur, limitation, dan panduan setup | Dicocokkan dengan source, `seed_data.sql`, dan hasil build |

## Demo yang Disarankan

1. Jalankan aplikasi dengan dua `--dart-define`.
2. Tampilkan daftar restoran dan jarak GPS.
3. Cari restoran/menu dan gunakan filter radius.
4. Buka detail restoran serta menu.
5. Login sebagai owner.
6. Tambah, ubah, lalu hapus menu.
7. Logout dan tunjukkan data owner tidak terbawa ke session berikutnya.
8. Matikan jaringan untuk menunjukkan banner offline.
9. Tunjukkan `flutter test` dengan hasil 85 kasus lulus.
