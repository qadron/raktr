#!/bin/bash

# tls-cert-generator.sh
# Generates CA, server cert, client cert with private/public keys

set -e  # Exit on any error

# Configuration
CA_KEY="ca-key.pem"
CA_CERT="ca-cert.pem"
SERVER_KEY="server-key.pem"
SERVER_CSR="server.csr"
SERVER_CERT="server-cert.pem"
CLIENT_KEY="client-key.pem"
CLIENT_CSR="client.csr"
CLIENT_CERT="client-cert.pem"

CA_SUBJECT="/C=US/ST=State/L=City/O=MyOrganization/OU=IT/CN=MyRootCA"
SERVER_SUBJECT="/C=US/ST=State/L=City/O=MyOrganization/OU=Server/CN=localhost"
CLIENT_SUBJECT="/C=US/ST=State/L=City/O=MyOrganization/OU=Client/CN=client.example.com"

echo "Generating TLS Certificate Authority and Client/Server Certificates..."

# 1. Generate CA private key and self-signed certificate
echo "1. Creating CA key and certificate..."
openssl genrsa -out "$CA_KEY" 4096
chmod 600 "$CA_KEY"
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 3650 -out "$CA_CERT" -subj "$CA_SUBJECT"

# 2. Generate Server key and certificate
echo "2. Creating server key and certificate..."
openssl genrsa -out "$SERVER_KEY" 4096
chmod 600 "$SERVER_KEY"
openssl req -new -key "$SERVER_KEY" -out "$SERVER_CSR" -subj "$SERVER_SUBJECT"

# Server extensions (for TLS server)
cat > server-ext.cnf << EOF
extendedKeyUsage = serverAuth
subjectAltName = DNS:localhost, IP:127.0.0.1
EOF

openssl x509 -req -in "$SERVER_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial \
    -out "$SERVER_CERT" -days 365 -sha256 -extfile server-ext.cnf

# 3. Generate Client key and certificate
echo "3. Creating client key and certificate..."
openssl genrsa -out "$CLIENT_KEY" 4096
chmod 600 "$CLIENT_KEY"
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" -subj "$CLIENT_SUBJECT"

# Client extensions (for TLS client)
cat > client-ext.cnf << EOF
extendedKeyUsage = clientAuth
EOF

openssl x509 -req -in "$CLIENT_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial \
    -out "$CLIENT_CERT" -days 365 -sha256 -extfile client-ext.cnf

# 4. Extract public keys
echo "4. Extracting public keys..."
openssl rsa -in "$SERVER_KEY" -pubout -out server-pubkey.pem
openssl rsa -in "$CLIENT_KEY" -pubout -out client-pubkey.pem

# 5. Cleanup temporary files
rm -f "$SERVER_CSR" "$CLIENT_CSR" server-ext.cnf client-ext.cnf ca.srl

# 6. Set proper permissions
chmod 644 *.pem
chmod 600 *key.pem

echo ""
echo "Generation complete!"
echo ""
echo "Files created:"
echo "   CA:           $CA_CERT, $CA_KEY"
echo "   Server:       $SERVER_CERT, $SERVER_KEY, server-pubkey.pem"
echo "   Client:       $CLIENT_CERT, $CLIENT_KEY, client-pubkey.pem"
echo ""
echo "Usage:"
echo "   - For server: use $SERVER_CERT and $SERVER_KEY"
echo "   - For client: use $CLIENT_CERT and $CLIENT_KEY"
echo "   - Trust CA:   distribute $CA_CERT to clients"
