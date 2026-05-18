#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  SAKA OS — Kurulum Scripti
#  Ubuntu 22.04+ / Debian 12+ desteklenir
#  Kullanım: ./setup.sh
#  Uzaktan: curl -fsSL https://raw.githubusercontent.com/kaanozcan4-star/SAKA_OS/main/setup.sh | bash
# ═══════════════════════════════════════════════════════════

set -e

# ─── Renkler ────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

# ─── Sabitler ───────────────────────────────────────────────
REPO_URL="https://github.com/kaanozcan4-star/SAKA_OS.git"
INSTALL_DIR="$HOME/SAKA_OS"
NODE_VERSION="20"
NVM_VERSION="v0.39.7"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh"

# ─── Yardımcı fonksiyonlar ──────────────────────────────────
step()  { echo -e "\n${BLUE}${BOLD}▶${NC} $1"; }
ok()    { echo -e "  ${GREEN}✓${NC} $1"; }
warn()  { echo -e "  ${YELLOW}⚠${NC}  $1"; }
err()   { echo -e "\n${RED}${BOLD}✗ HATA:${NC} $1"; exit 1; }
info()  { echo -e "  ${DIM}→ $1${NC}"; }

# ─── Banner ─────────────────────────────────────────────────
echo ""
echo -e "${BLUE}${BOLD}"
echo "  ███████╗ █████╗ ██╗  ██╗ █████╗      ██████╗ ███████╗"
echo "  ██╔════╝██╔══██╗██║ ██╔╝██╔══██╗    ██╔═══██╗██╔════╝"
echo "  ███████╗███████║█████╔╝ ███████║    ██║   ██║███████╗"
echo "  ╚════██║██╔══██║██╔═██╗ ██╔══██║    ██║   ██║╚════██║"
echo "  ███████║██║  ██║██║  ██╗██║  ██║    ╚██████╔╝███████║"
echo "  ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝     ╚═════╝ ╚══════╝"
echo -e "${NC}"
echo -e "  ${BOLD}SAKA Havacılık — Çok-İHA Sürü Kontrol İstasyonu${NC}"
echo -e "  ${DIM}Kurulum scripti v1.1 | Ubuntu/Debian${NC}"
echo ""
echo -e "  Bu script şunları indirecek ve kuracak (~350-400 MB):"
echo -e "   • Node.js ${NODE_VERSION} (nvm üzerinden)"
echo -e "   • Python bağımlılıkları (FastAPI, PyMAVLink vb.)"
echo -e "   • Frontend bağımlılıkları (Electron, CesiumJS vb.)"
echo ""

# /dev/tty: curl|bash modunda stdin pipe'a bağlıdır, klavye için /dev/tty şart.
read -p "  Devam etmek istiyor musunuz? (E/h) " -n 1 -r < /dev/tty; echo
if [[ ! $REPLY =~ ^[Ee]$ ]] && [[ -n $REPLY ]]; then
    echo "  Kurulum iptal edildi."
    exit 0
fi

# ═══════════════════════════════════════════════════════════
# 1. OS Kontrolü
# ═══════════════════════════════════════════════════════════
step "İşletim sistemi kontrol ediliyor..."

if ! command -v apt-get &>/dev/null; then
    err "Bu script sadece Ubuntu/Debian üzerinde çalışır. apt-get bulunamadı."
fi

if command -v lsb_release &>/dev/null; then
    DISTRO=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    ok "$DISTRO $VERSION tespit edildi"
else
    ok "Debian tabanlı sistem tespit edildi"
fi

# ═══════════════════════════════════════════════════════════
# 2. Sistem Paketleri
# ═══════════════════════════════════════════════════════════
step "Sistem paketleri güncelleniyor..."
info "sudo şifresi istenebilir"
sudo apt-get update -qq

REQUIRED_PKGS=(curl unzip build-essential python3-dev python3-venv python3-pip)
TO_INSTALL=()

for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
        TO_INSTALL+=("$pkg")
    fi
done

if [ ${#TO_INSTALL[@]} -gt 0 ]; then
    info "Kuruluyor: ${TO_INSTALL[*]}"
    sudo apt-get install -y -qq "${TO_INSTALL[@]}"
    ok "Sistem paketleri kuruldu"
else
    ok "Sistem paketleri zaten mevcut"
fi

# ═══════════════════════════════════════════════════════════
# 3. Python 3.10+ Kontrolü
# ═══════════════════════════════════════════════════════════
step "Python versiyonu kontrol ediliyor..."

PYTHON_CMD=""
for cmd in python3.12 python3.11 python3.10 python3; do
    if command -v "$cmd" &>/dev/null; then
        # head -1: birden fazla eşleşme olursa ilkini al
        VER=$("$cmd" --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
        # BUG FIX: VER boşsa integer karşılaştırması crash eder
        if [ -z "$VER" ]; then continue; fi
        MAJOR=$(echo "$VER" | cut -d. -f1)
        MINOR=$(echo "$VER" | cut -d. -f2)
        if [ "$MAJOR" -ge 3 ] && [ "$MINOR" -ge 10 ]; then
            PYTHON_CMD="$cmd"
            ok "Python $VER bulundu ($cmd)"
            break
        fi
    fi
done

if [ -z "$PYTHON_CMD" ]; then
    warn "Python 3.10+ bulunamadı. deadsnakes PPA'dan kuruluyor..."
    sudo apt-get install -y -qq software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update -qq
    sudo apt-get install -y -qq python3.10 python3.10-venv python3.10-dev
    PYTHON_CMD="python3.10"
    ok "Python 3.10 kuruldu"
fi

# Seçilen Python için venv paketinin kurulu olduğundan emin ol
# (Örn: sistem python3.11 varsa ama python3.11-venv yoksa venv oluşturulamaz)
PYTHON_MINOR_VER=$("$PYTHON_CMD" --version 2>&1 | grep -oP '\d+\.\d+' | head -1)
VENV_PKG="python${PYTHON_MINOR_VER}-venv"
if ! dpkg -s "$VENV_PKG" &>/dev/null 2>&1; then
    info "$VENV_PKG kuruluyor..."
    sudo apt-get install -y -qq "$VENV_PKG" 2>/dev/null || true
fi

# ═══════════════════════════════════════════════════════════
# 4. Node.js 20 (nvm)
# ═══════════════════════════════════════════════════════════
step "Node.js ${NODE_VERSION} kuruluyor (nvm)..."

export NVM_DIR="$HOME/.nvm"

if [ ! -d "$NVM_DIR" ]; then
    info "nvm ${NVM_VERSION} indiriliyor..."
    curl -o- "$NVM_INSTALL_URL" | bash
    ok "nvm kuruldu"
else
    ok "nvm zaten mevcut: $NVM_DIR"
fi

# nvm shell fonksiyonu olarak yükle
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if ! command -v nvm &>/dev/null; then
    err "nvm yüklenemedi. Terminali kapatıp açın ve tekrar deneyin."
fi

if ! nvm ls "$NODE_VERSION" &>/dev/null 2>&1; then
    info "Node.js ${NODE_VERSION} indiriliyor (~25 MB)..."
    nvm install "$NODE_VERSION"
else
    ok "Node.js ${NODE_VERSION} zaten mevcut"
fi

nvm use "$NODE_VERSION" --silent
# BUG FIX: nvm alias --silent geçersiz flag, kaldırıldı
nvm alias default "$NODE_VERSION" > /dev/null
ok "Node.js $(node --version) aktif | npm $(npm --version)"

# ═══════════════════════════════════════════════════════════
# 5. SAKA_OS Kaynak Kodu
# ═══════════════════════════════════════════════════════════
step "SAKA_OS kaynak kodu hazırlanıyor..."

# git clone yerine ZIP indirme: public repo için auth hiç gerekmiyor,
# credential manager / GUI popup sorunu tamamen ortadan kalkar.
ARCHIVE_URL="https://github.com/kaanozcan4-star/SAKA_OS/archive/refs/heads/main.zip"
TMP_ZIP="/tmp/saka_os_$$.zip"

# Script SAKA_OS dizininin içinden mi çalışıyor?
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [ -f "$SCRIPT_DIR/backend/requirements.txt" ] && [ -d "$SCRIPT_DIR/frontend" ]; then
    INSTALL_DIR="$SCRIPT_DIR"
    ok "Mevcut dizinde SAKA_OS tespit edildi: $INSTALL_DIR"
else
    if [ -d "$INSTALL_DIR" ]; then
        info "Mevcut kurulum siliniyor, güncelleniyor..."
        rm -rf "$INSTALL_DIR"
    fi
    info "İndiriliyor: $ARCHIVE_URL"
    curl -fsSL "$ARCHIVE_URL" -o "$TMP_ZIP"
    info "Açılıyor..."
    unzip -q "$TMP_ZIP" -d /tmp/
    mv "/tmp/SAKA_OS-main" "$INSTALL_DIR"
    rm -f "$TMP_ZIP"
    ok "SAKA_OS indirildi: $INSTALL_DIR"
fi

# ═══════════════════════════════════════════════════════════
# 6. Python Sanal Ortam + Bağımlılıklar
# ═══════════════════════════════════════════════════════════
step "Python bağımlılıkları kuruluyor (~23 MB)..."

BACKEND_DIR="$INSTALL_DIR/backend"
VENV_DIR="$BACKEND_DIR/venv"

# BUG FIX: venv var ama bin/pip yoksa (kırık venv) → sil ve yeniden oluştur
if [ -d "$VENV_DIR" ] && [ ! -f "$VENV_DIR/bin/pip" ]; then
    warn "Kırık venv tespit edildi, yeniden oluşturuluyor..."
    rm -rf "$VENV_DIR"
fi

if [ ! -d "$VENV_DIR" ]; then
    info "Sanal ortam oluşturuluyor..."
    "$PYTHON_CMD" -m venv "$VENV_DIR"
fi

info "pip paketleri kuruluyor (fastapi, uvicorn, pymavlink vb.)..."
"$VENV_DIR/bin/pip" install --quiet --upgrade pip
"$VENV_DIR/bin/pip" install --quiet -r "$BACKEND_DIR/requirements.txt"
ok "Python bağımlılıkları kuruldu"

# ═══════════════════════════════════════════════════════════
# 7. Frontend Bağımlılıkları (npm install)
# ═══════════════════════════════════════════════════════════
step "Frontend bağımlılıkları kuruluyor (~250 MB, birkaç dakika sürebilir)..."
info "Electron + CesiumJS + React indiriliyor..."

cd "$INSTALL_DIR/frontend"
# BUG FIX: --silent hataları tamamen gizler; --loglevel warn ile hatalar görünür
npm install --loglevel warn
ok "npm bağımlılıkları kuruldu"

# ═══════════════════════════════════════════════════════════
# 8. Başlatıcı Script (run.sh)
# ═══════════════════════════════════════════════════════════
step "Başlatıcı script oluşturuluyor..."

# INSTALL_DIR'in kesin yolunu al (symlink veya cd sonrası değişmiş olabilir)
REAL_INSTALL_DIR="$(cd "$INSTALL_DIR" && pwd)"

cat > "$REAL_INSTALL_DIR/run.sh" << RUNEOF
#!/bin/bash
# SAKA OS Başlatıcı — otomatik oluşturuldu
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
nvm use ${NODE_VERSION} --silent 2>/dev/null || true
cd "${REAL_INSTALL_DIR}/frontend"
npm run dev
RUNEOF
chmod +x "$REAL_INSTALL_DIR/run.sh"
ok "run.sh oluşturuldu: $REAL_INSTALL_DIR/run.sh"

# ═══════════════════════════════════════════════════════════
# 9. Masaüstü Kısayolu (.desktop)
# ═══════════════════════════════════════════════════════════
step "Masaüstü kısayolu oluşturuluyor..."

DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

ICON_PATH="$REAL_INSTALL_DIR/frontend/public/saka_logo.png"
if [ ! -f "$ICON_PATH" ]; then
    ICON_PATH="$REAL_INSTALL_DIR/frontend/public/drone-icon.png"
fi
if [ ! -f "$ICON_PATH" ]; then
    ICON_PATH="utilities-terminal"
fi

DESKTOP_FILE="$DESKTOP_DIR/saka-os.desktop"

# BUG FIX: Önceki sürümde \$HOME heredoc'tan literal $HOME üretiyordu,
# bash -c '...' içinde tek tırnak $HOME'u expand etmez → source başarısız.
# Çözüm: $NVM_DIR ve $REAL_INSTALL_DIR heredoc zamanında expand edilir
# (setup.sh hedef makinede çalıştığı için yollar doğrudur).
cat > "$DESKTOP_FILE" << DESKTOPEOF
[Desktop Entry]
Version=1.0
Name=SAKA OS
GenericName=Sürü Kontrol İstasyonu
Comment=SAKA Havacılık Çok-İHA Taktik Kontrol Yazılımı
Exec=bash -c '. ${NVM_DIR}/nvm.sh && nvm use ${NODE_VERSION} --silent && cd ${REAL_INSTALL_DIR}/frontend && npm run dev'
Icon=${ICON_PATH}
Terminal=true
Type=Application
Categories=Science;Engineering;
StartupNotify=true
Keywords=drone;iha;uav;saka;sürü;kontrol;
DESKTOPEOF
chmod +x "$DESKTOP_FILE"
ok "Uygulama menüsüne eklendi"

if [ -d "$HOME/Desktop" ]; then
    cp "$DESKTOP_FILE" "$HOME/Desktop/SAKA_OS.desktop"
    chmod +x "$HOME/Desktop/SAKA_OS.desktop"
    ok "Masaüstü kısayolu oluşturuldu"
fi

# ═══════════════════════════════════════════════════════════
# 10. Doğrulama
# ═══════════════════════════════════════════════════════════
step "Kurulum doğrulanıyor..."

ERRORS=0

if ! node --version &>/dev/null; then
    warn "Node.js doğrulanamadı"; ERRORS=$((ERRORS+1))
else
    ok "Node.js: $(node --version)"
fi

if ! "$VENV_DIR/bin/python" --version &>/dev/null; then
    warn "Python venv doğrulanamadı"; ERRORS=$((ERRORS+1))
else
    ok "Python: $("$VENV_DIR/bin/python" --version)"
fi

if [ ! -d "$REAL_INSTALL_DIR/frontend/node_modules/electron" ]; then
    warn "Electron (node_modules) eksik — npm install başarısız olmuş olabilir"; ERRORS=$((ERRORS+1))
else
    ok "node_modules: mevcut ($(du -sh "$REAL_INSTALL_DIR/frontend/node_modules" 2>/dev/null | cut -f1))"
fi

if [ ! -f "$REAL_INSTALL_DIR/run.sh" ]; then
    warn "run.sh oluşturulamadı"; ERRORS=$((ERRORS+1))
else
    ok "run.sh: mevcut"
fi

# ═══════════════════════════════════════════════════════════
# Tamamlandı
# ═══════════════════════════════════════════════════════════
echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}  ✅ SAKA OS kurulumu başarıyla tamamlandı!${NC}"
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════${NC}"
else
    echo -e "${YELLOW}${BOLD}  ⚠  Kurulum tamamlandı (${ERRORS} uyarı var)${NC}"
fi
echo ""
echo -e "  ${BOLD}Başlatmak için:${NC}"
echo -e "    ${CYAN}${REAL_INSTALL_DIR}/run.sh${NC}"
echo -e "    veya uygulama menüsünden ${BOLD}SAKA OS${NC}"
echo ""
echo -e "  ${BOLD}Drone bağlantısı:${NC}"
echo -e "    MAVLink UDP → 0.0.0.0:14651 (drone 1)"
echo -e "    MAVLink UDP → 0.0.0.0:14661 (drone 2)"
echo -e "    Her ek drone: port +10"
echo ""
echo -e "  ${DIM}Disk kullanımı: ~1.5 GB (node_modules ağırlıklı)${NC}"
echo ""
