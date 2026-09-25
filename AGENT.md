# AGENT.md — Mobile Vieguard App (Flutter + Dart)

## 1. Konteks Proyek

**VieGuard Mobile** adalah aplikasi native berbasis framework Flutter (Dart) khusus untuk **Admin, Owner, dan Staff Toko VieGuard**.
Aplikasi ini memfasilitasi operasional konveksi seragam, custom order batch, sewa kostum/drumband, verifikasi pelunasan, tracking progres produksi, live chat pelanggan, serta laporan analitik bisnis secara teratur.

## 2. Struktur Folder Clean Architecture (Feature-First)

Struktur direktori `lib/` disusun menggunakan **Modular Clean Architecture (Feature-First)** untuk memastikan pemisahan tanggung jawab (separation of concerns), skala pengembangan tinggi, dan keterbacaan kode yang rapi.

```
lib/
├── main.dart                          # Entry Point Utama Aplikasi
│
├── core/                              # Layer Shared Core Component
│   ├── theme/
│   │   └── app_theme.dart             # Palette Warna, Google Fonts Inter, & ThemeData
│   └── widgets/
│       ├── app_badge.dart             # Status Badge Widget (Primary, Success, Warning, Danger, Info)
│       ├── app_button.dart            # Standard Button Component (Primary, Secondary, Outline, Icons)
│       ├── bottom_nav_bar.dart        # Custom 5-Tab Navigation Bar Component
│       └── custom_app_bar.dart        # Header App Bar Admin (Search, Notification, Avatar)
│
└── features/                          # Layer Fitur / Domain Modul
    ├── navigation/
    │   └── presentation/screens/
    │       └── main_navigation_screen.dart    # Shell Root Navigation Controller (5 Tab Utama)
    │
    ├── home/
    │   └── presentation/screens/
    │       └── home_screen.dart               # Dashboard Utama KPI & Quick Actions Admin
    │
    ├── orders/
    │   └── presentation/screens/
    │       ├── order_list_screen.dart            # 1. Daftar Pesanan Konveksi & Filter Status
    │       ├── order_detail_standard_screen.dart # 2. Detail Pesanan Standar & Timeline
    │       ├── order_detail_custom_screen.dart   # 3. Detail Pesanan Custom Batch
    │       ├── input_custom_price_screen.dart    # 4. Form Input Estimasi Harga Custom
    │       └── production_progress_screen.dart   # 5. Form & Stepper Progres Produksi Workshop
    │
    ├── payments/
    │   └── presentation/screens/
    │       └── payment_verification_screen.dart  # 6. Verifikasi Pelunasan & Bukti Transfer
    │
    ├── rentals/
    │   └── presentation/screens/
    │       ├── rental_list_screen.dart           # 7. Daftar Penyewaan Kostum & Drumband
    │       ├── rental_detail_screen.dart         # 8. Detail Penyewaan & Denda Keterlambatan
    │       ├── item_condition_form_screen.dart   # 9. Form Catat Kondisi Barang (Return QC)
    │       ├── rental_calendar_screen.dart       # 10. Kalender Operasional Sewa & Event
    │       ├── rental_stock_management_screen.dart # 11. Katalog & Stok Kostum Rental
    │       └── rental_stock_detail_screen.dart   # 12. Detail Stok Item & Status Sanitasi
    │
    ├── chat/
    │   └── presentation/screens/
    │       ├── chat_list_screen.dart             # 13. Daftar Pesan Chat Pelanggan
    │       └── chat_detail_screen.dart           # 14. Ruang Chat Multi-Lampiran Produk/Sewa
    │
    ├── account/
    │   └── presentation/screens/
    │       └── account_screen.dart               # 15. Profil Admin, Shift, & Pengaturan Sistem
    │
    ├── notifications/
    │   └── presentation/screens/
    │       └── notification_list_screen.dart     # 16. Pusat Notifikasi Realtime & Audit Log
    │
    ├── reports/
    │   └── presentation/screens/
    │       └── business_report_screen.dart       # 17. Analitik Pendapatan & Laporan Direksi
    │
    └── tools/
        └── presentation/screens/
            ├── size_data_preview_screen.dart     # 18. Pratinjau Data Ukuran Siswa (AI Validated)
            └── excel_template_info_screen.dart   # 19. SOP & Panduan Excel Data Ukuran Siswa
```

## 3. Aturan Arsitektur & Pemisahan Modul

1. **Core Independence**: Komponen di `core/` (seperti `app_theme.dart`, `app_badge.dart`, dll) bersifat *agnostic* terhadap bisnis modul dan dapat diimpor oleh seluruh fitur.
2. **Feature Isolation**: Setiap modul di `features/<feature_name>` terisolasi dengan struktur layer `presentation/screens/`.
3. **Route & Navigation**: Routing internal antar modul dilakukan melalui `MaterialPageRoute` atau Shell Router di `features/navigation/presentation/screens/main_navigation_screen.dart`.
