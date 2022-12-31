## Sertifikat Gratis Protokol HTTPS
https://www.openssl.org

### Cara Pengunaan
`./run.sh <HOSTNAME/DOMAIN> <DURATION>`
  - `HOSTNAME/DOMAIN`: Nama Hostname atau Domain
  - `DURATION`: Berapa lama sertifikat akan valid dalam hari

### Validasi HTTPS (localhost)
  1. `sudo cp ./<HOSTNAME/DOMAIN>/ca.crt /usr/local/share/ca-certificates/ca.crt`
  2. `sudo update-ca-certificates`
      **Menghapus .crt (jika diperlukan)**
      2.1. `sudo rm -rf /usr/local/share/ca-certificates/ca.crt`
      2.2. `sudo update-ca-certificates --fresh`
  3. agar protokol HTTPS tidak dicoret oleh browser, masukkan sertifikat ke dalam browser

### Input TLS/SSL (backend/database)
  - `ca = ca.crt`
  - `key = cert-key.pem`
  - `cert = fullchain.pem`

### Bukti Nyata Protainer HTTPS
![Portainer HTTPS 1](SAMPLE1.png)
![Portainer HTTPS 2](SAMPLE2.png)