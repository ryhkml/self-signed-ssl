#!/usr/bin/zsh

set -e

INFO="\033[0;32m"
LINK="\033[4;34m"
ERROR="\033[0;31m"
NORMAL="\033[0m"

# NAMA DOMAIN
DOMAIN=$1
# BERAPA LAMA SERTIFIKAT AKAN VALID DALAM HARI
DURATION=$2

if [[ -z $DOMAIN || -z $DURATION ]]; then
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
  rm -rf ./$DOMAIN
  exit 1
}

echo
info "MULAI"

openssl version

mkdir $DOMAIN

echo
info "BUAT PASSWORD PEM PHRASE, TUNGGU SEBENTAR..."

sleep 1s

openssl genrsa -aes256 \
  -out ./$DOMAIN/ca-key.pem \
  4096 || throw_error

echo
info "VERIFIKASI KEMBALI PASSWORD PEM PHRASE"

openssl req -new -x509 -sha256 \
  -days $DURATION \
  -key ./$DOMAIN/ca-key.pem \
  -out ./$DOMAIN/ca.pem || throw_error

openssl genrsa \
  -out ./$DOMAIN/cert-key.pem \
  4096 || throw_error

openssl req -new -sha256 \
  -subj "/CN=$DOMAIN" \
  -key ./$DOMAIN/cert-key.pem \
  -out ./$DOMAIN/cert.csr || throw_error

echo "subjectAltName=DNS:$DOMAIN" > ./$DOMAIN/extfile.cnf

echo
info "OK, VERIFIKASI KEMBALI PASSWORD PEM PHRASE"

openssl x509 -req -sha256 \
  -days $DURATION \
  -in ./$DOMAIN/cert.csr \
  -CA ./$DOMAIN/ca.pem \
  -CAkey ./$DOMAIN/ca-key.pem \
  -out ./$DOMAIN/cert.pem \
  -extfile ./$DOMAIN/extfile.cnf \
  -CAcreateserial || throw_error

cat ./$DOMAIN/cert.pem > ./$DOMAIN/fullchain.pem
cat ./$DOMAIN/ca.pem >> ./$DOMAIN/fullchain.pem

# Optional step
echo
info "VERIFIKASI CA FILE"

openssl verify \
  -CAfile ./$DOMAIN/ca.pem ./$DOMAIN/cert.pem || throw_error

# End
echo
info "SELESAI"
echo "key=$DOMAIN/cert-key.pem"
echo "csr/cert=$DOMAIN/fullchain.pem"
echo
echo "AGAR PROTOKOL HTTPS TIDAK DICORET OLEH BROWSER"
echo "LANGKAH TERAKHIR, MASUKKAN SERTIFIKAT KE DALAM BROWSER"
echo
echo "Google Chrome"
link "https://support.google.com/chrome/a/answer/3505249?hl=en"
echo
echo "Mozilla Firefox"
link "https://docs.vmware.com/en/VMware-Adapter-for-SAP-Landscape-Management/2.1.0/Installation-and-Administration-Guide-for-VLA-Administrators/GUID-0CED691F-79D3-43A4-B90D-CD97650C13A0.html"