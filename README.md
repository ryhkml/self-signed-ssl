## Buat Sertifikat Gratis
Sumber https://www.openssl.org

### Cara Pengunaan
  1. `wget https://raw.githubusercontent.com/ryhkml/self-signed-ssl/main/run.sh -O run.sh`
  2. `chmod +x run.sh`
  3. `./run.sh <HOSTNAME/DOMAIN> <DURATION>`

### Validasi HTTPS (localhost)
  1. `sudo cp ./<HOSTNAME/DOMAIN>/ca.crt /usr/local/share/ca-certificates/ca.crt`
  2. `sudo update-ca-certificates`\
      &nbsp; **Menghapus ca.crt (jika diperlukan)**\
      &nbsp; 2.1. `sudo rm -rf /usr/local/share/ca-certificates/ca.crt`\
      &nbsp; 2.2. `sudo update-ca-certificates --fresh`
  3. agar protokol HTTPS tidak dicoret oleh browser, masukkan sertifikat ke dalam browser

### Input TLS/SSL (backend/database)
  - `ca = ca.crt`
  - `key = cert-key.pem`
  - `cert = fullchain.pem`

### Bukti Nyata Protainer HTTPS
![Portainer HTTPS 1](SAMPLE1.png)
![Portainer HTTPS 2](SAMPLE2.png)

### Contoh Redis TLS/SSL Konfigurasi
![Redis 6 Config](SAMPLE3.png)