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
  rm -rf ./$HD
  exit 1
}

echo
info "MULAI"

openssl version

mkdir $HD

echo
info "BUAT PASSWORD PEM PHRASE, TUNGGU SEBENTAR..."

sleep 1s

openssl genrsa -aes256 \
  -out ./$HD/ca-key.pem \
  4096 || throw_error

echo
info "VERIFIKASI KEMBALI PASSWORD PEM PHRASE"

openssl req -new -x509 -sha256 \
  -days $DURATION \
  -key ./$HD/ca-key.pem \
  -out ./$HD/ca.pem || throw_error

openssl genrsa \
  -out ./$HD/cert-key.pem \
  4096 || throw_error

openssl req -new -sha256 \
  -subj "/CN=$HD" \
  -key ./$HD/cert-key.pem \
  -out ./$HD/cert.csr || throw_error

echo "subjectAltName=DNS:$HD" > ./$HD/extfile.cnf

echo
info "OK, VERIFIKASI KEMBALI PASSWORD PEM PHRASE"

openssl x509 -req -sha256 \
  -days $DURATION \
  -in ./$HD/cert.csr \
  -CA ./$HD/ca.pem \
  -CAkey ./$HD/ca-key.pem \
  -out ./$HD/cert.pem \
  -extfile ./$HD/extfile.cnf \
  -CAcreateserial || throw_error

cat ./$HD/cert.pem > ./$HD/fullchain.pem
cat ./$HD/ca.pem >> ./$HD/fullchain.pem

cp ./$HD/ca.pem ./$HD/ca.crt

# Optional step
echo
info "VERIFIKASI CA FILE"

openssl verify \
  -CAfile ./$HD/ca.pem ./$HD/cert.pem || throw_error

# End
echo
info "SELESAI"
echo "ca=$HD/ca.crt"
echo "key=$HD/cert-key.pem"
echo "cert=$HD/fullchain.pem"
echo
echo "AGAR PROTOKOL HTTPS TIDAK DICORET OLEH BROWSER"
echo "LANGKAH TERAKHIR, MASUKKAN SERTIFIKAT KE DALAM BROWSER"
echo
echo "Google Chrome"
link "https://support.google.com/chrome/a/answer/3505249?hl=en"
echo
echo "Mozilla Firefox"
link "https://docs.vmware.com/en/VMware-Adapter-for-SAP-Landscape-Management/2.1.0/Installation-and-Administration-Guide-for-VLA-Administrators/GUID-0CED691F-79D3-43A4-B90D-CD97650C13A0.html"