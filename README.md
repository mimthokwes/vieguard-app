# Vieguard App

Aplikasi mobile untuk **pemilik / admin** usaha penjualan dan penyewaan kostum (drumband, parade, karnaval, dan acara 17 Agustusan). Aplikasi ini dibuat dengan Flutter dan terhubung ke backend [vieguard-back](https://github.com/mimthokwes/vieguard-back) yang juga dipakai oleh website pelanggan.

> Status: dalam pengembangan aktif.

## Latar Belakang

Usaha kostum ini melayani penjualan, penyewaan, dan pesanan custom dalam jumlah besar (satuan sampai borongan untuk satu kelompok). Pencatatan manual membuat stok, jadwal sewa, pembayaran, dan komunikasi dengan pelanggan sulit dipantau. Vieguard menyatukan semuanya dalam satu sistem:

- **Website** untuk pelanggan: melihat katalog, memesan, dan membayar.
- **Aplikasi mobile (repo ini)** untuk pemilik/admin: mengelola pesanan, stok, chat, dan laporan dari satu tempat.
- **Backend** (Express.js + Prisma + MySQL) sebagai sumber data bersama.

## Fitur

### Pesanan
- Daftar pesanan dengan tipe **beli**, **sewa**, dan **custom**.
- Pesanan sewa dibayar penuh di awal, sedangkan pesanan standar/custom melalui alur **DP -> progres produksi -> pelunasan**.
- Riwayat perubahan status pesanan.
- Surat perjanjian sewa (rental agreement).

### Kalender Rental
- Kalender jadwal sewa untuk melihat kostum yang sedang keluar dan tanggal pengembaliannya.

### Manajemen Stok
- Kelola barang: kategori, produk, varian (ukuran), foto, dan aksesori.
- Detail stok per item.
- Pratinjau data ukuran dan **template Excel** untuk input stok/ukuran secara massal.

### Chat
- Daftar percakapan dan detail chat dengan pelanggan.

### Keuangan dan Laporan
- Pencatatan pemasukan dari pembayaran (DP, pelunasan, pembayaran penuh).
- Laporan dan analitik bisnis.

### Akun dan Notifikasi
- Login admin dan pengaturan akun.
- Notifikasi admin dan log aktivitas.

<!-- TODO: cocokkan daftar fitur di atas dengan layar yang benar-benar sudah jadi di lib/ -->

## Teknologi

| Bagian | Teknologi |
| --- | --- |
| Mobile | Flutter (Dart) |
| Backend | Express.js, TypeScript, Prisma |
| Database | MySQL |

<!-- TODO: tambahkan state management, HTTP client, dan package utama dari pubspec.yaml -->

## Prasyarat

Pastikan sudah terpasang:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (cek dengan `flutter --version`)
- Android Studio atau Android SDK, plus emulator atau perangkat fisik
- Git
- Backend `vieguard-back` yang sudah berjalan (lihat README repo tersebut)

Cek kesiapan lingkungan:

```bash
flutter doctor
```

## Instalasi

```bash
# 1. Clone repository
git clone https://github.com/mimthokwes/vieguard-app.git
cd vieguard-app

# 2. Install dependency
flutter pub get
```

## Konfigurasi

Aplikasi perlu tahu alamat backend.

<!-- TODO: sesuaikan dengan cara konfigurasi yang dipakai (file .env, dart-define, atau konstanta) -->
Backend set on `http://localhost:5000`.


## Menjalankan Aplikasi

```bash
# Run in debug mode
flutter run

# Build a release APK
flutter build apk --release
```

## Struktur Folder

<!-- TODO: ganti dengan struktur asli dari `tree lib -L 2` -->

```text
lib/
  core/        # shared config, theme, network client
  features/    # one folder per feature (orders, stock, chat, reports, ...)
```

## Desain

File desain Figma (hi-fi) proyek ini dibuat per layar: daftar pesanan, kalender rental, manajemen stok, chat, akun admin, notifikasi, dan laporan.

**Link Figma:** [Buka desain Vieguard di Figma](https://www.figma.com/design/kJ9njYqxmDqaJa6lErq6Lg/VIEGUARD?node-id=1-4&t=xfoYTBeZivROWaDM-1)

<!-- TODO: replace GANTI_DENGAN_LINK_FIGMA_KAMU with the real Figma share link (set the file to "Anyone with the link can view") -->


## Tim

Proyek ini berawal dari tugas kelompok (Kelompok 9, kelas T3B) dan dikembangkan lebih lanjut untuk kebutuhan usaha yang sebenarnya.

<!-- TODO: isi nama anggota tim jika ingin dicantumkan -->

## Lisensi

<!-- TODO: pilih lisensi, atau hapus bagian ini jika repo bersifat privat -->
