#!/bin/bash
# mk (c) 2019
set -x -e -o pipefail

test $(whoami) = root || echo "[!] Need root to work"

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
S_CONF=${MYDIR}/server/server.conf
C_KEYS_DIR=${MYDIR}/client/keys
C_OUT_DIR=${MYDIR}/client/generated
C_TEMPL=${MYDIR}/client/template.ovpn
ls $MYDIR $S_CONF $C_KEYS_DIR $C_OUT_DIR $C_TEMPL 1>/dev/null

EASYRSA_DIR=${MYDIR}/easyrsa

prepare_server() {
  yum update -y
  yum install openvpn -y
}

get_easyrsa() {
  cd $MYDIR

  wget ${EASYRSA_URL}
  wget ${EASYRSA_SIG_URL}
  gpg --keyserver "hkp://keyserver.ubuntu.com:80" --recv-keys "390D0D0E"
  gpg --verify EasyRSA-unix-${EASYRSA_VER}.tgz.sig
  tar xfz EasyRSA-unix-${EASYRSA_VER}.tgz
  ln -f -s EasyRSA-${EASYRSA_VER} ${EASYRSA_DIR}
}

gen_server_files() {
  cd $EASYRSA_DIR
  
  ./easyrsa init-pki
  printf "\n" | ./easyrsa build-ca nopass
  ./easyrsa build-server-full server nopass
  ./easyrsa gen-dh
  
  openvpn --genkey --secret /etc/openvpn/ta.key
}

setup_server() {
  cp ${EASYRSA_DIR}/pki/ca.crt \
     ${EASYRSA_DIR}/pki/issued/server.crt \
     ${EASYRSA_DIR}/pki/private/server.key \
     ${EASYRSA_DIR}/pki/dh.pem \
     $S_CONF \
     /etc/openvpn

  chown openvpn /etc/openvpn -R
  chmod 400 /etc/openvpn/server.key 
  chmod 400 /etc/openvpn/ta.key 
  
  chown openvpn /var/run/openvpn
  mkdir -p /var/log/openvpn
  chown openvpn /var/log/openvpn/
  service openvpn restart
  
  sleep 5
  tail /var/log/messages | grep openvpn 
}

gen_client_files(){
  cp /etc/openvpn/ta.key $C_KEYS_DIR
  cp ${EASYRSA_DIR}/pki/ca.crt ${C_KEYS_DIR}

  cd ${MYDIR}/easyrsa
  for C in $CLIENTS ; do
    ./easyrsa build-client-full ${C} nopass
    cp ${EASYRSA_DIR}/pki/issued/${C}.crt \
       ${EASYRSA_DIR}/pki/private/${C}.key \
       ${C_KEYS_DIR}
    
    OUT=${C_OUT_DIR}/${C}.ovpn
    cat ${C_TEMPL} \
        <(echo -e '<ca>') \
        ${C_KEYS_DIR}/ca.crt \
        <(echo -e '</ca>\n<cert>') \
        ${C_KEYS_DIR}/${C}.crt \
        <(echo -e '</cert>\n<key>') \
        ${C_KEYS_DIR}/${C}.key \
        <(echo -e '</key>\n<tls-auth>') \
        ${C_KEYS_DIR}/ta.key \
        <(echo -e '</tls-auth>') \
        > $OUT

    sed -i "s/openvpn.example.com/${DOMAIN}/" $OUT
    printf "[+] Generated %s \n" $OUT
  done
}

upload_to_s3(){
  aws s3 cp --recursive $C_OUT_DIR $S3_TARGET 
}

prepare_server
get_easyrsa
gen_server_files
setup_server
gen_client_files
upload_to_s3
