#! /bin/bash
CERT_DOMAIN=vpn.example.com
CLOUDFLARE_CREDENTIALS='/root/letsencrypt/cloudflarednsapi.conf'
LE_EMAIL='example@gmail.com'


function checkcertbot(){
if [ -z "`pip list certbot-dns-cloudflare |grep certbot-dns-cloudflare`" ];
then
pip install certbot-dns-cloudflare
fi
}

function checkcert(){
if [ ! -f "/etc/letsencrypt/live/${CERT_DOMAIN}/cert.pem" ];
then renewipseccert
else
CERT_EXPIRE=$(openssl x509 -checkend 1728000 -noout -in /etc/letsencrypt/live/$CERT_DOMAIN/cert.pem|grep not)
if [ -z "$CERT_EXPIRE" ];
then
renewipseccert
else
echo "The cert will not expire in 20 days,nothing to do."
fi
fi
}


function renewipseccert(){
/usr/local/bin/certbot  certonly -d ${CERT_DOMAIN} \
--agree-tos \
--non-interactive \
--email $LE_EMAIL  \
--dns-cloudflare \
--dns-cloudflare-credentials ${CLOUDFLARE_CREDENTIALS}
cp /etc/letsencrypt/live/$CERT_DOMAIN/chain.pem /usr/local/etc/ipsec.d/cacerts/ca.cert.pem
cp /etc/letsencrypt/live/$CERT_DOMAIN/cert.pem /usr/local/etc/ipsec.d/certs/server.cert.pem
cp /etc/letsencrypt/live/$CERT_DOMAIN/privkey.pem /usr/local/etc/ipsec.d/private/server.pem
systemctl restart ipsec
}

checkcertbot
checkcert
