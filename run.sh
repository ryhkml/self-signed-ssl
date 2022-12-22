#!/usr/bin/zsh

set -e

# NAMA DOMAIN
DOMAIN=$1
# BERAPA LAMA SERTIFIKAT AKAN VALID DALAM HARI
DURATION=$2

if [[ -z $DOMAIN || -z $DURATION ]]; then
  echo "Semua argumen harus diisi"
  exit 1
fi

mkdir $DOMAIN

openssl genrsa -aes256 \
  -out ./$DOMAIN/ca-key.pem \
  4096 || rm -rf ./$DOMAIN

openssl req -new -x509 -sha256 \
  -days $DURATION \
  -key ./$DOMAIN/ca-key.pem \
  -out ./$DOMAIN/ca.pem || rm -rf ./$DOMAIN

openssl genrsa \
  -out ./$DOMAIN/cert-key.pem \
  4096 || rm -rf $DOMAIN

openssl req -new -sha256 \
  -subj "/CN=$DOMAIN" \
  -key ./$DOMAIN/cert-key.pem \
  -out ./$DOMAIN/cert.csr || rm -rf ./$DOMAIN

echo "subjectAltName=DNS:$DOMAIN" > ./$DOMAIN/extfile.cnf

openssl x509 -req -sha256 \
  -days $DURATION \
  -in ./$DOMAIN/cert.csr \
  -CA ./$DOMAIN/ca.pem \
  -CAkey ./$DOMAIN/ca-key.pem \
  -out ./$DOMAIN/cert.pem \
  -extfile ./$DOMAIN/extfile.cnf \
  -CAcreateserial || rm -rf ./$DOMAIN

cat ./$DOMAIN/cert.pem > ./$DOMAIN/fullchain.pem
cat ./$DOMAIN/ca.pem >> ./$DOMAIN/fullchain.pem

echo "\n"
echo "> SELESAI!"
echo "\n"
echo "> key=$DOMAIN/cert-key.pem"
echo "> csr/cert=$DOMAIN/fullchain.pem"
echo "\n"
echo "> AGAR PROTOKOL HTTPS TIDAK DICORET OLEH BROWSER"
echo "> LANGKAH TERAKHIR, MASUKKAN SERTIFIKAT KE DALAM BROWSER"
echo "\n"
echo "> Google Chrome -> https://support.google.com/chrome/a/answer/3505249?hl=en"
echo "> Mozilla Firefox -> https://docs.vmware.com/en/VMware-Adapter-for-SAP-Landscape-Management/2.1.0/Installation-and-Administration-Guide-for-VLA-Administrators/GUID-0CED691F-79D3-43A4-B90D-CD97650C13A0.html"
echo "\n"