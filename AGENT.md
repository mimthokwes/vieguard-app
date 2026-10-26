# PROMPT UNTUK ANTIGRAVITY — Setup Struktur Project Flutter "Vieguard Mobile"

## KONTEKS PROJECT

Kita sedang membangun aplikasi mobile **Vieguard** menggunakan **Flutter (Dart)**.
Vieguard adalah platform jual & sewa kostum (drumband, parade, karnaval, acara agustusan).
App mobile ini adalah **aplikasi owner/admin** yang mengelola data yang sama dengan
backend & website customer (backend: Express + TypeScript + Prisma, repo referensi:
`https://github.com/mimthokwes/vieguard-back`).

Sebelum menulis kode UI apa pun, kamu harus:
1. Membaca & memetakan seluruh hasil desain Figma.
2. Menyusun struktur folder project berbasis **per-fitur (feature-based)**, meniru pola
   yang biasa dipakai di backend/project lain milik saya (setiap fitur punya folder
   sendiri berisi layer-nya masing-masing, bukan dikelompokkan per jenis file secara global).

Kerjakan dalam tahap terpisah, tunggu konfirmasi saya di setiap tahap sebelum lanjut
ke tahap berikutnya.

---

## TAHAP 1 — Inventarisasi Desain Figma

Buka dan telusuri folder:

```
/mobile_vie/Figmas/VIEGUARD
```

Folder ini berisi hasil export high-fidelity dari semua halaman & fitur yang akan
diimplementasikan ke aplikasi.

Untuk tahap ini, JANGAN menulis kode apa pun. Yang perlu kamu lakukan:

1. List semua file/gambar di dalam folder tersebut (termasuk subfolder jika ada).
2. Kelompokkan gambar-gambar itu menjadi **fitur/modul**, bukan sekadar per halaman.
   Contoh pengelompokan (sesuaikan dengan yang benar-benar kamu temukan di Figma,
   ini hanya referensi awal berdasarkan skema database Vieguard yang sudah ada):
   - `auth` → login, register, forgot password
   - `dashboard` → home/overview admin
   - `products` → daftar produk, detail produk, varian, aksesoris, kategori
   - `orders` → daftar order (beli/sewa/custom), detail order, status history
   - `rentals` → khusus alur sewa (jadwal, pengembalian)
   - `payments` → DP, pelunasan, riwayat pembayaran
   - `chat` → conversations & messages
   - `notifications` → daftar notifikasi
   - `testimonials` → daftar & moderasi testimoni
   - `profile` / `store_settings` → profil admin & pengaturan toko
3. Untuk tiap fitur, sebutkan:
   - Nama-nama file/screen yang termasuk di dalamnya
   - Ada berapa state/varian untuk screen yang sama (misal: empty state, loading, error)
   - Komponen yang keliatan berulang dipakai di banyak screen (kandidat shared widget)
4. Tampilkan hasil inventarisasi ini ke saya dalam bentuk list per fitur.
   **Berhenti di sini dan tunggu saya review sebelum lanjut ke Tahap 2.**

---

## TAHAP 2 — Rancang & Terapkan Struktur Folder (Feature-Based)

Setelah saya konfirmasi hasil inventarisasi, buat struktur folder Flutter dengan pola
**feature-first**, mirip pola modular yang dipakai di backend (`vieguard-back`):
tiap fitur berdiri sendiri dengan layer-nya sendiri, bukan folder global `screens/`,
`widgets/`, `models/` yang isinya campur semua fitur.

Struktur target:

```
lib/
├── core/
│   ├── constants/        # warna, ukuran, string, api base url
│   ├── theme/            # ThemeData, text styles
│   ├── network/          # dio/http client, interceptor, error handler
│   ├── router/           # go_router / route config
│   └── utils/            # helper functions, formatter, validator
│
├── shared/
│   ├── widgets/          # widget reusable lintas fitur (button, input, card, dsb)
│   └── models/           # model/DTO yang dipakai lintas fitur (mis. Pagination, ApiResponse)
│
├── features/
│   ├── auth/
│   │   ├── data/         # service/repository (call API), model request-response
│   │   ├── domain/       # entity/model murni fitur ini
│   │   └── presentation/
│   │       ├── screens/  # LoginScreen, RegisterScreen, dst
│   │       ├── widgets/  # widget khusus fitur auth
│   │       └── providers/ # state management khusus fitur ini (riverpod/bloc/provider)
│   │
│   ├── dashboard/
│   │   └── ... (pola sama)
│   │
│   ├── products/
│   │   └── ... (pola sama, termasuk sub untuk variants & accessories jika perlu)
│   │
│   ├── orders/
│   ├── rentals/
│   ├── payments/
│   ├── chat/
│   ├── notifications/
│   ├── testimonials/
│   └── profile/
│
└── main.dart
```

Aturan penerapan:

1. Setiap fitur = 1 folder di `lib/features/<nama_fitur>/`, dengan sub-folder
   `data/`, `domain/`, `presentation/` (screens, widgets, providers) di dalamnya.
   Jangan buat folder kosong untuk sub-layer yang memang belum dipakai fitur itu.
2. Widget/model yang dipakai oleh **lebih dari satu fitur** baru masuk ke `shared/`,
   bukan didefinisikan ulang di tiap fitur.
3. Penamaan file: `snake_case.dart`, penamaan class: `PascalCase`.
4. Untuk sekarang, buat dulu **struktur folder + file kosong/stub** per screen yang
   sudah teridentifikasi di Tahap 1 (misalnya `login_screen.dart` berisi widget
   `StatelessWidget`/`StatefulWidget` kosong dengan `Scaffold` placeholder). Belum
   perlu menerapkan tampilan detail dari Figma di tahap ini.
5. Tunjukkan ke saya hasil struktur folder final (tree) sebelum mulai
   mengisi tampilan detail tiap screen di tahap berikutnya.

---

## TAHAP 3 — Implementasi Tampilan (baru dikerjakan setelah Tahap 1 & 2 disetujui)

Setelah struktur folder disetujui, saya akan minta kamu mengisi tampilan tiap screen
satu per satu (per fitur), mengikuti desain di `/mobile_vie/Figmas/VIEGUARD` secara
pixel-accurate (spacing, warna, tipografi, komponen), menggunakan widget Flutter murni
(Dart) sesuai struktur folder yang sudah dibuat di Tahap 2.

---

## CATATAN UMUM

- Framework: **Flutter**, bahasa: **Dart**.
- State management: sebutkan dulu pilihanmu (Riverpod/Bloc/Provider) sebelum dipakai,
  saya yang putuskan.
- Jangan install package baru tanpa bilang dulu ke saya package apa dan kenapa perlu.
- Kerjakan bertahap sesuai 3 tahap di atas, jangan loncat ke Tahap 2/3 sebelum saya
  konfirmasi tahap sebelumnya selesai dan benar.