#!/bin/bash
# SAKA OS — Hızlı Başlatıcı
# Kullanım: ./run.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm use 20 --silent 2>/dev/null || true

cd "$(dirname "$(realpath "$0")")/frontend"
npm run dev
