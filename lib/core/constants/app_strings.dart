/// String konstan aplikasi NearBite.
class AppStrings {
  const AppStrings._();

  // App
  static const String appTitle = 'NearBite';
  static const String appSubtitle =
      'Cari Resto Terdekat, Nikmati Hidangan Terbaik';

  // Home/List Resto
  static const String homeTitle = 'Daftar Resto Terdekat';
  static const String searchRestaurantHint = 'Cari resto atau menu...';
  static const String emptyRestaurantList = 'Belum ada resto tersedia.';
  static const String locationPermissionDenied =
      'Izin lokasi ditolak. Menampilkan daftar resto tanpa urutan jarak.';
  static const String locationUnavailable =
      'Layanan lokasi tidak tersedia. Menampilkan daftar tanpa jarak.';
  static const String loadingRestaurants = 'Memuat daftar resto...';
  static const String errorLoadingRestaurants = 'Gagal memuat daftar resto.';

  // Restaurant Detail
  static const String detailTitle = 'Detail Resto';
  static const String restaurantMenu = 'Menu';
  static const String restaurantAddress = 'Alamat';
  static const String restaurantHours = 'Jam Buka';
  static const String restaurantDistance = 'Jarak';
  static const String noMenuAvailable = 'Belum ada menu tersedia.';

  // Menu
  static const String price = 'Harga';
  static const String description = 'Deskripsi';
  static const String noDescription = 'Tidak ada deskripsi';

  // Authentication
  static const String login = 'Masuk sebagai Pemilik';
  static const String loginTitle = 'Masuk';
  static const String register = 'Daftar Akun Baru';
  static const String registerTitle = 'Daftar Pemilik Resto';
  static const String logout = 'Keluar';
  static const String fieldEmail = 'Email';
  static const String fieldEmailHint = 'contoh@email.com';
  static const String fieldPassword = 'Password';
  static const String fieldPasswordHint = 'Minimal 6 karakter';
  static const String fieldName = 'Nama';
  static const String fieldNameHint = 'Nama Anda';
  static const String actionLogin = 'Masuk';
  static const String actionRegister = 'Daftar';
  static const String actionCancel = 'Batal';
  static const String haveAccount = 'Sudah punya akun? ';
  static const String dontHaveAccount = 'Belum punya akun? ';
  static const String loginToManageRestaurant =
      'Masuk untuk mengelola restoran Anda.';
  static const String loginSuccessful = 'Login berhasil!';
  static const String registerSuccessful =
      'Pendaftaran berhasil! Silakan login.';
  static const String logoutSuccessful = 'Logout berhasil.';
  static const String invalidEmail = 'Email tidak valid.';
  static const String passwordTooShort = 'Password minimal 6 karakter.';
  static const String passwordsNotMatch = 'Password tidak cocok.';
  static const String fieldConfirmPassword = 'Konfirmasi Password';
  static const String fieldConfirmPasswordHint = 'Ulangi password';

  // Owner - Restaurant Profile
  static const String ownerProfile = 'Profil Restoku';
  static const String restaurantProfileTitle = 'Profil Resto';
  static const String restaurantName = 'Nama Resto';
  static const String restaurantNameHint = 'Minimal 3 karakter';
  static const String restaurantDescription = 'Deskripsi';
  static const String restaurantDescriptionHint =
      'Ceritakan tentang resto Anda';
  static const String restaurantAddress2 = 'Alamat Lengkap';
  static const String restaurantAddressHint = 'Jalan, Kota, Provinsi';
  static const String restaurantHours2 = 'Jam Operasional';
  static const String restaurantHoursHint = 'Misal: 10:00 - 22:00';
  static const String restaurantPhoto = 'Foto Resto';
  static const String restaurantCoordinates = 'Koordinat (GPS)';
  static const String latitude = 'Latitude';
  static const String longitude = 'Longitude';
  static const String useCurrentLocation = 'Gunakan Lokasi Saya';
  static const String pickFromGallery = 'Pilih dari Galeri';
  static const String useCamera = 'Ambil Foto';
  static const String savedSuccessfully = 'Tersimpan berhasil!';
  static const String restaurantNameRequired =
      'Nama resto wajib diisi (minimal 3 karakter).';
  static const String coordinatesRequired = 'Koordinat GPS wajib diisi.';

  // Owner - Menu Management
  static const String manageMenu = 'Kelola Menu';
  static const String addMenu = 'Tambah Menu';
  static const String editMenu = 'Edit Menu';
  static const String deleteMenu = 'Hapus Menu';
  static const String menuName = 'Nama Menu';
  static const String menuNameHint = 'Misal: Nasi Goreng Spesial';
  static const String menuPrice = 'Harga (Rp)';
  static const String menuPriceHint = 'Misal: 25000';
  static const String menuPhoto = 'Foto Menu';
  static const String menuDescription2 = 'Deskripsi Menu';
  static const String menuDescriptionHint = 'Ceritakan tentang menu ini';
  static const String menuNameRequired = 'Nama menu wajib diisi.';
  static const String menuPriceRequired = 'Harga wajib diisi.';
  static const String menuPriceInvalid = 'Harga harus berupa angka positif.';
  static const String noMenuItems = 'Belum ada item menu.';
  static const String confirmDeleteMenu = 'Hapus menu ini?';
  static const String menuDeletedSuccessfully = 'Menu berhasil dihapus.';
  static const String menuAddedSuccessfully = 'Menu berhasil ditambahkan.';
  static const String menuUpdatedSuccessfully = 'Menu berhasil diperbarui.';
  static const String deleteConfirmation = 'Yakin ingin menghapus?';
  static const String yes = 'Ya';
  static const String no = 'Tidak';
  static const String actionSave = 'Simpan';
  static const String actionDelete = 'Hapus';
  static const String fieldDescription = 'Deskripsi';

  // Error & Status Messages
  static const String errorOccurred = 'Terjadi kesalahan.';
  static const String tryAgain = 'Coba lagi';
  static const String retry = 'Ulangi';
  static const String loading = 'Memuat...';
  static const String noData = 'Tidak ada data.';
  static const String noResults = 'Tidak ada hasil pencarian.';

  // Connectivity
  static const String noInternetConnection = 'Tidak ada koneksi internet';
  static const String noInternetMessage =
      'Aplikasi memerlukan koneksi internet untuk berfungsi. Periksa pengaturan jaringan Anda.';
  static const String connectionError = 'Gagal terhubung ke server.';
  static const String serverError = 'Error server. Coba lagi nanti.';
  static const String authError = 'Autentikasi gagal.';
  static const String validationError = 'Data tidak valid.';

  // Distance & Location
  static const String km = 'km';
  static const String miles = 'mi';
  static const String gettingLocation = 'Mendapatkan lokasi...';

  static const String dueLabel = 'Due';
  static const String priorityLabel = 'Priority';
  static const String statusLabel = 'Status';
  static const String statusPending = 'Pending';
  static const String statusOverdue = 'Overdue';
  static const String statusCompleted = 'Completed';
  static const String statusUnknown = 'Unknown';
  static const String priorityHigh = 'High';
  static const String priorityMedium = 'Medium';
  static const String priorityLow = 'Low';
  static const String detailNotFound = 'Task not found or has been deleted.';

  static const String emptyAll = 'No tasks yet. Tap + to add one.';
  static const String deleteConfirm = 'Delete this task?';

  static const String errTitleRequired = 'Title is required.';
  static const String errTitleTooShort = 'Title must be at least 3 characters.';
  static const String errDueDateInPast =
      'Tenggat waktu tidak boleh di masa lalu';

  // Mode indicator strings
  static const String modeMock = 'MOCK API';
  static const String modeLive = 'LIVE API';
}
