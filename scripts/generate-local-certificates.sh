#!/bin/bash
# Generate self-signed certificates for *.local domains
# Creates: CA cert, server cert, JKS keystores, and updates truststore

set -e

DOMAIN="*.local"
PASSWORD="wso2carbon"
OUTPUT_DIR="./certificates"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

echo "Generating CA private key..."
openssl genrsa -out ca.key 2048

echo "Generating CA certificate..."
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt \
  -subj "/C=US/ST=CA/L=Mountain View/O=WSO2/OU=WSO2/CN=WSO2 Local CA"

echo "Generating server private key..."
openssl genrsa -out server.key 2048

echo "Generating server certificate signing request..."
openssl req -new -key server.key -out server.csr \
  -subj "/C=US/ST=CA/L=Mountain View/O=WSO2/OU=WSO2/CN=*.local" \
  -addext "subjectAltName = DNS:*.local,DNS:localhost,DNS:apim.local,DNS:gw.local,DNS:websocket.local,DNS:websub.local"

echo "Signing server certificate with CA..."
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out server.crt -days 3650 -sha256 \
  -extfile <(printf "subjectAltName = DNS:*.local,DNS:localhost,DNS:apim.local,DNS:gw.local,DNS:websocket.local,DNS:websub.local")

echo "Creating PKCS12 keystore..."
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 \
  -name wso2carbon -password pass:"$PASSWORD"

echo "Files created:"
echo "  ca.crt - CA certificate"
echo "  ca.key - CA private key"
echo "  server.crt - Server certificate"
echo "  server.key - Server private key"
