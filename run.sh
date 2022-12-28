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
  echo "${ERROR}SEMUA ARGUMEN HARUS DIISI"
  exit 1
fi

function throw_err() {
  echo "${ERROR}TERJADI KESALAHAN"
  rm -rf ./$DOMAIN
  exit 1
}

echo
echo "${INFO}OK${NORMAL}"

openssl version

mkdir $DOMAIN

echo
echo "${INFO}BUAT PASSWORD PEM PHRASE, TUNGGU SEBENTAR...${NORMAL}"

sleep 1s

openssl genrsa -aes256 \
  -out ./$DOMAIN/ca-key.pem \
  4096 || throw_err

echo
echo "${INFO}VERIFIKASI KEMBALI PASSWORD PEM PHRASE${NORMAL}"

openssl req -new -x509 -sha256 \
  -days $DURATION \
  -key ./$DOMAIN/ca-key.pem \
  -out ./$DOMAIN/ca.pem || throw_err

openssl genrsa \
  -out ./$DOMAIN/cert-key.pem \
  4096 || throw_err

openssl req -new -sha256 \
  -subj "/CN=$DOMAIN" \
  -key ./$DOMAIN/cert-key.pem \
  -out ./$DOMAIN/cert.csr || throw_err

echo "subjectAltName=DNS:$DOMAIN" > ./$DOMAIN/extfile.cnf

echo
echo "${INFO}OK, VERIFIKASI KEMBALI PASSWORD PEM PHRASE${NORMAL}"

openssl x509 -req -sha256 \
  -days $DURATION \
  -in ./$DOMAIN/cert.csr \
  -CA ./$DOMAIN/ca.pem \
  -CAkey ./$DOMAIN/ca-key.pem \
  -out ./$DOMAIN/cert.pem \
  -extfile ./$DOMAIN/extfile.cnf \
  -CAcreateserial || throw_err

cat ./$DOMAIN/cert.pem > ./$DOMAIN/fullchain.pem
cat ./$DOMAIN/ca.pem >> ./$DOMAIN/fullchain.pem

echo
echo "${INFO}SELESAI${NORMAL}"
echo "key=$DOMAIN/cert-key.pem"
echo "csr/cert=$DOMAIN/fullchain.pem"
echo
echo "AGAR PROTOKOL HTTPS TIDAK DICORET OLEH BROWSER"
echo "LANGKAH TERAKHIR, MASUKKAN SERTIFIKAT KE DALAM BROWSER"
echo
echo "Google Chrome"
echo "${LINK}https://support.google.com/chrome/a/answer/3505249?hl=en${NORMAL}"
echo
echo "Mozilla Firefox"
echo "${LINK}https://docs.vmware.com/en/VMware-Adapter-for-SAP-Landscape-Management/2.1.0/Installation-and-Administration-Guide-for-VLA-Administrators/GUID-0CED691F-79D3-43A4-B90D-CD97650C13A0.html${NORMAL}"