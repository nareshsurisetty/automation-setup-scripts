#!/bin/bash

# Install Terraform and set environment path
function terraform-install() {
    [[ -f ${HOME}/bin/terraform ]] && echo "`${HOME}/bin/terraform version` already installed at ${HOME}/bin/terraform" && return 0
    LATEST_URL=$(curl -sL https://releases.hashicorp.com/terraform/index.json |
        jq -r '.versions[].builds[].url | select(.|test("alpha|beta|rc")|not) | select(.|contains("linux_amd64"))' |
        sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n |
        tail -n1)
    curl ${LATEST_URL} > /tmp/terraform.zip
    mkdir -p ${HOME}/bin
    (cd ${HOME}/bin && unzip /tmp/terraform.zip)
    if [[ -z $(grep 'export PATH=${HOME}/bin:${PATH}' ~/.bashrc) ]]; then
  	    echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
    fi
    echo "Terraform Installed: `${HOME}/bin/terraform version`"
    source ~/.bashrc
}

# Install python3, python3 packages, Ansible and Azure modules for Ansible
function ansible-install() {
    [[ $(which ansible-playbook) ]] && echo "$(ansible-playbook --version)" && echo "ansible-playbook already installed at $(which ansible-playbook)" && return 0
    if [ ! "$(which ansible-playbook)" ]; then
        if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/oracle-release ] || [ -f /etc/system-release ]; then
            yum -y install gcc python36-devel python3-PyMySQL python3-pip python3-paramiko
            pip3 install ansible[azure]
            ansible-galaxy collection install azure.azcollection
            wget https://raw.githubusercontent.com/nareshsurisetty/automation-setup-scripts/master/ansible-requirements.txt
            pip3 install -r ansible-requirements.txt
            echo "Ansible Installed: `ansible --version`"
            source ~/.bashrc
        fi
    fi
}

# Install required os packages
function os-packages-install() {
    if [ -f /etc/centos-release ] || [ -f /etc/redhat-release ] || [ -f /etc/oracle-release ] || [ -f /etc/system-release ]; then
        yum -y install epel-release 
        yum -y install which ncurses curl wget jq unzip git
    fi
}

# Install OS packages, Ansible Package and Terraform Package
os-packages-install
terraform-install
ansible-install