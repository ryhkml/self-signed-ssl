## Sertifikat Gratis Protokol HTTPS
https://www.openssl.org

### Cara Penggunaan
  1. `chmod +x run.sh`
  2. `./run.sh <DOMAIN> <DAYS>`
  3. `sudo cp ./<DOMAIN>/ca.pem /usr/local/share/ca-certificates/ca.crt`
  4. `sudo update-ca-certificates`
  5. `masukkan sertifikat ke dalam browser`

### Menghapus .crt (jika diperlukan)
  1. `sudo rm -rf /usr/local/share/ca-certificates/ca.crt`
  2. `sudo update-ca-certificates --fresh`

### Bukti Nyata Protainer HTTPS
![Portainer HTTPS 1](SAMPLE1.png)
![Portainer HTTPS 2](SAMPLE2.png)