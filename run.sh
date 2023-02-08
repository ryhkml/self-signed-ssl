#!/usr/bin/zsh

set -e

INFO="\033[0;32m"
LINK="\033[4;34m"
ERROR="\033[0;31m"
NORMAL="\033[0m"

# NAMA HOSTNAME ATAU DOMAIN
HD=$1
# BERAPA LAMA SERTIFIKAT AKAN VALID DALAM HARI
DURATION=$2

if [[ -z $HD || -z $DURATION ]]; then
  error "SEMUA ARGUMEN HARUS DIISI"
  exit 1
fi

info() {
  local TEXT="${INFO}$1${NORMAL}"
  echo $TEXT
}

link() {
  local TEXT="${LINK}$1${NORMAL}"
  echo $TEXT
}

error() {
  local TEXT="${ERROR}$1${NORMAL}"
  echo $TEXT
}

throw_error() {
  error "TERJADI KESALAHAN"
  rm -rf list/$HD
  exit 1
}

echo
info "MULAI"

openssl version

mkdir list/$HD

echo
info "BUAT PASSWORD PEM PHRASE, TUNGGU SEBENTAR..."

sleep 1s

openssl genrsa -aes256 \
  -out list/$HD/ca-key.pem \
  4096 || throw_error

echo
info "VERIFIKASI KEMBALI PASSWORD PEM PHRASE"

openssl req -new -x509 -sha256 \
  -days $DURATION \
  -key list/$HD/ca-key.pem \
  -out list/$HD/ca.pem || throw_error

openssl genrsa \
  -out list/$HD/cert-key.pem \
  4096 || throw_error

openssl req -new -sha256 \
  -subj "/CN=$HD" \
  -key list/$HD/cert-key.pem \
  -out list/$HD/cert.csr || throw_error

echo "subjectAltName=DNS:localhost,DNS:$HD,IP:127.0.0.1" > list/$HD/extfile.cnf

echo
info "OK, VERIFIKASI KEMBALI PASSWORD PEM PHRASE"

openssl x509 -req -sha256 \
  -days $DURATION \
  -in list/$HD/cert.csr \
  -CA list/$HD/ca.pem \
  -CAkey list/$HD/ca-key.pem \
  -out list/$HD/cert.pem \
  -extfile list/$HD/extfile.cnf \
  -CAcreateserial || throw_error

cat list/$HD/cert.pem > list/$HD/fullchain.pem
cat list/$HD/ca.pem >> list/$HD/fullchain.pem

cp list/$HD/ca.pem list/$HD/ca.crt

# Optional step
echo
info "VERIFIKASI CA FILE"

openssl verify \
  -CAfile list/$HD/ca.pem list/$HD/cert.pem || throw_error

chmod 0444 list/$HD/*

# End
echo
info "SELESAI"
info "LANGKAH TERAKHIR, LAKUKAN VALIDASI CLIENT SERTIFIKAT"
link "https://github.com/ryhkml/self-signed-ssl#validasi-sertifikat"