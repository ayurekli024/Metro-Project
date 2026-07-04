# 🚇 Ankara Metro Tracker (Yeraltı Otonom Navigasyon Sistemi)

Ankara Metro Tracker, GPS sinyalinin ulaşamadığı yeraltı tünellerinde akıllı telefon sensörlerini kullanarak **tamamen çevrimdışı** ve **otonom** çalışan bir mobil navigasyon ve raylı sistem takip uygulamasıdır. 

Uygulama, standart "tren kaç dakika sonra gelecek" uygulamalarından farklı olarak, kullanıcının cebindeki ivmeölçer, pusula ve Wi-Fi donanımlarını birer radar gibi kullanarak yeraltında kendi konumunu gerçek zamanlı olarak hesaplar.

## ✨ Temel Özellikler

*   **📍 GPS Bağımsız Takip (Dead Reckoning):** İvmeölçer (Accelerometer) verilerini Low-Pass filtreden geçirerek tünel içindeki hızlanma ve frenlemeleri yakalar, saniye saniye konum hesaplar.
*   **🚅 Hibrit Durum Makinesi:** Ankara Metrosu'ndaki CRRC trenlerinin çok düşük kalkış ivmelerini (pürüzsüz kalkışları) algılayabilen ve *Akköprü-AKM* arasındaki M4 bağlantı makası gibi bilinen bölgesel darboğazlarda otomatik hız düşüren "Bölgesel Zeka" (Heuristic) algoritması.
*   **📡 Wi-Fi Parmak İzi (Fingerprinting):** Yeraltı istasyonlarındaki (örn. ABB Wi-Fi) modemlerin fiziksel donanım adreslerini (BSSID) arka planda tarayarak, tren istasyona girdiği an donanımsal ivme kaymalarını (drift) milisaniyeler içinde sıfırlar.
*   **🧲 Manyetik Tünel Haritalaması:** Ankaray (A1) ve metro tünellerindeki cer trafolarından kaynaklanan manyetik dalgalanmaları (Manyetometre ile) okuyarak tünel içi kesin konum doğrulaması yapar.
*   **🗄️ Devrimsel Veritabanı:** Tüm Kızılay ve Batıkent aktarmaları dahil, 121 istasyonluk detaylı süre, mesafe ve yön bilgilerini içeren yerel SQLite veritabanı.
*   **🛠️ Dahili Saha Laboratuvarı:** Geliştiriciler için ortamdaki BSSID ve Manyetik Alan (μT) verilerini `$B = \sqrt{B_x^2 + B_y^2 + B_z^2}$` vektörel formülüyle hesaplayıp telefona `.csv` olarak kaydeden gizli veri madenciliği modülü.

## 🛠️ Kullanılan Teknolojiler

*   **Dil:** Dart
*   **Framework:** Flutter
*   **Donanım Entegrasyonları:** `sensors_plus` (İvmeölçer ve Manyetometre), `wifi_scan` (BSSID Taraması)
*   **Veritabanı:** `sqflite`
*   **Durum Yönetimi:** Provider

## 🚀 Kurulum

Projeyi yerel ortamında çalıştırmak için aşağıdaki adımları izleyin.

**Not:** Proje, donanım sensörlerine doğrudan erişim sağladığı için bilgisayar emülatörlerinde (x86) **sağlıklı çalışmaz**. Doğrudan fiziksel bir ARM64 Android cihaz (Örn: S24 Ultra vb.) kullanılmalıdır.

1. Depoyu klonlayın:
   ```bash
   git clone [https://github.com/kullaniciadin/ankara_metro_tracker.git](https://github.com/kullaniciadin/ankara_metro_tracker.git)
