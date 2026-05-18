# SAKA OS — Kurulum

**SAKA Havacılık Çok-İHA Sürü Kontrol İstasyonu**  
Ubuntu 22.04+ / Debian 12+ desteklenir

---

## ⬇️ 1. Adım — setup.sh Dosyasını İndir

**[→ setup.sh İNDİR (sağ tık → Farklı Kaydet)](https://github.com/kaanozcan4-star/SAKA_OS_Setup/raw/main/setup.sh)**

---

## 🔑 2. Adım — GitHub Personal Access Token Oluştur

SAKA_OS kaynak kodu private repoda. İndirmek için bir kerelik token gerekiyor.

1. **[github.com/settings/tokens](https://github.com/settings/tokens)** adresine git
2. **"Generate new token (classic)"** tıkla
3. Note: `SAKA_OS_Kurulum` yaz
4. Scope: **`repo`** kutucuğunu işaretle
5. **Generate token** → çıkan kodu kopyala (bir daha göremezsin, şimdi kopyala)

---

## ▶️ 3. Adım — Çalıştır

```bash
bash ~/Downloads/setup.sh
```

Script kurulum sırasında token isteyecek — kopyaladığın token'ı yapıştır ve Enter'a bas.

---

## Terminal ile Tek Satırda (alternatif)

```bash
wget -qO- https://github.com/kaanozcan4-star/SAKA_OS_Setup/raw/main/setup.sh | bash
```

---

## Kurulum Sonrası

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
