# SAKA OS — Kurulum

**SAKA Havacılık Çok-İHA Sürü Kontrol İstasyonu**  
Ubuntu 22.04+ / Debian 12+ desteklenir

---

## Yöntem 1 — Tek Tıkla Kur (Tavsiye)

1. **[⬇️ SAKA_OS_Kur.desktop indir](https://raw.githubusercontent.com/kaanozcan4-star/SAKA_OS_Setup/main/SAKA_OS_Kur.desktop)**
2. İndirilen dosyaya **sağ tık → "Çalıştırılabilir olarak işaretle"**  
   *(veya: sağ tık → Özellikler → İzinler → "Program olarak çalıştırmaya izin ver")*
3. Dosyaya **çift tıkla** → terminal açılır, kurulum otomatik başlar

---

## Yöntem 2 — Terminal Komutu

```bash
curl -fsSL https://raw.githubusercontent.com/kaanozcan4-star/SAKA_OS_Setup/main/setup.sh | bash
```

---

## Kurulum Sonrası

Kurulum tamamlandıktan sonra uygulamayı başlatmak için:

```bash
~/SAKA_OS/run.sh
```

veya masaüstündeki / uygulama menüsündeki **SAKA OS** ikonuna tıkla.

---

## Gereksinimler

| Bileşen | Minimum |
|---|---|
| İşletim Sistemi | Ubuntu 22.04+ / Debian 12+ |
| RAM | 8 GB |
| Disk | 3 GB boş alan |
| İnternet | ~400 MB indirme |

> GPU önerilir (NVIDIA). GPU olmadan da çalışır ama harita performansı düşük olabilir.
