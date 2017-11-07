#!/bin/bash

set -xe

create_user() {
    useradd -m -s /bin/bash -c "Leo Laksmana" -G adm,wheel,systemd-journal beol
    su - beol -c 'mkdir -m 700 .ssh; cat <<-EOF > .ssh/authorized_keys; chmod 600 .ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuYC8Z2jkDqJTT9daDsOJrR1iDsnHA7lwa8GvQRh/rxkKW6TRlDp/OWfMAiPK6vWF3X37zelbPwhHxEkYlFkkb9bWMp0V79u+uNYKJcilKxdt5GNQ8eHyUUEsPUpG4UjBVHgD8DBkUG+LHSilYwpuflGDYvZ+PzkQYflz74FnbvkxjlLH8Y8llWd4FqnWKjkvoAs/N3COGRHUivd0UGm0JoDfJYQZtFfG0im0Gs8IPLGW22w5nCOILz58/Azq7eyNMNJr2zdEgTc+eN5Kv/82bdYSvnGy+KX4RFwjqeViMLrGndfuj2v/ut3fOTgc6yTebdoyIp6yVI6BYqstABZq5 beol@yana-mbp.local
EOF
git clone https://github.com/beol/vimfiles.git .vim && pushd $HOME/.vim && git submodule init && git submodule update && popd;
git clone https://github.com/beol/dotfiles.git .dotfiles && ln -s .dotfiles/gitignore .gitignore && ln -s .dotfiles/gitconfig .gitconfig && ln -s .dotfiles/tmux.conf .tmux.conf'
}

update_sudoers() {
    umask 227
    pushd /etc/sudoers.d
    echo "Defaults	!requiretty" >/etc/sudoers.d/00-require-tty
    echo "beol	ALL=(ALL)	NOPASSWD:ALL" >/etc/sudoers.d/90-beol
    popd
    umask 022
}

disable_ipv6() {
    pushd /etc/sysctl.d
    {
        echo "net.ipv6.conf.all.disable_ipv6 = 1";
        echo "net.ipv6.conf.default.disable_ipv6 = 1";
        echo "net.ipv6.conf.lo.disable_ipv6 = 1"
    } > 60-disable-ipv6.conf
    sysctl -p
    popd
}

disable_selinux() {
    pushd /etc/sysconfig
    setenforce 0
    sed -i 's/^\(SELINUX=\)enforcing/\1disabled/' selinux
    popd
}

install_packages() {
    yum upgrade -y \
    && \
    yum install -y \
                epel-release \
    && \
    yum install -y \
                git \
                python34-pip \
                tmux \
                vim-enhanced \
    && \
    yum clean all \
    && \
    rm -fr /var/cache/yum
}

install_certificates() {
    pushd /etc/pki/ca-trust/source/anchors
    cat <<-EOF > laksmana-family-root-ca.crt
-----BEGIN CERTIFICATE-----
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
lh4BynnE0pSr2kvnFJ3uoROU4DFWCQ==
-----END CERTIFICATE-----
EOF
    popd
    update-ca-trust enable && update-ca-trust extract
}

install_awscli() {
    pip3 install --upgrade pip
    pip3 install awscli
}

configure_sshd() {
    pushd /etc/ssh
    sed -i 's/^#\(AddressFamily \)any/\1inet/' sshd_config
    sed -i 's/^#\(PermitRootLogin \)no/\1without-password/' sshd_config
    sed -i 's/^\(X11Forwarding \)yes/\1no/' sshd_config
    sed -i 's/^#\(UseDNS \)yes/\1no/' sshd_config
    popd
}

disable_default_user() {
    usermod --lock --shell /sbin/nologin centos
}

create_update_dyndns_service() {
    pushd /usr/local/bin
    cat <<-EOF > update-dyndns
#!/bin/env bash

set -e

AWS_DEFAULT_REGION=\$(curl -fsSL http://169.254.169.254/latest/dynamic/instance-identity/document/ | python3 -c 'import json, sys; print(json.load(sys.stdin)["region"])')
INSTANCE_ID=\$(curl -fsSL http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=\$(curl -fsSL http://169.254.169.254/latest/meta-data/public-ipv4)
FQDN=\$(aws ec2 describe-tags --filters "Name=resource-id,Values=\${INSTANCE_ID}" "Name=key,Values=FQDN" --region=\${AWS_DEFAULT_REGION} --output text | awk '{ print \$5 }')

if [ -n "\$FQDN" ]; then
    curl -fsSL -H 'Authorization: Basic bGxha3NtYW5hOjg4MTI2YjlhMWZjNzExZTU4OTRmZTZmOWMxMWZlNzlm' "https://members.dyndns.org/nic/update?hostname=\${FQDN}&myip=\${PUBLIC_IP}"
fi

exit 0
EOF
    chmod 755 update-dyndns
    popd
    pushd /etc/systemd/system
    cat <<-EOF > update-dyndns.service
[Unit]
Description=Update DynDNS
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/update-dyndns
RemainAfterExit=true
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable update-dyndns.service
    popd
}

install_packages
install_certificates
install_awscli
disable_selinux
disable_ipv6
configure_sshd
create_update_dyndns_service
create_user
update_sudoers
disable_default_user

exit 0
