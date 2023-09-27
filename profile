# Note: Using positional parameters as makeshift array to use POSIX shell instead of bash for maximum OS compatibility 

# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

api_get_check_battery()
{
    upower -i `upower -e | grep 'BAT'`
}

api_get_ide()
{
    api_set_tmux_kill ide
    api_set_tmux_session ide
    api_set_tmux_send "~/.local/bin/idea/bin/idea.sh"
}

api_get_report()
{
     . ~/.profile
    clear
    neofetch
    date
    api_set_tmux_list
    sudo docker ps
    api_get_virsh_list
    df -BG
}

api_get_secret()
{
    secret_path=$1
    database=~/.local/bin/docs/data/secrets.kdbx
    key_file=~/.local/bin//docs/data/secrets.keyx
    password=$XDG_CONFIG_HOME/keepassxc/.keepassxc.txt
    command="cat $password | keepassxc-cli show -sa password -k $key_file $database $secret_path | set_clipboard"
    eval $command
}

api_get_ssh_acer()
{
    ssh -tt -X HQDEBACER01 "$1"
}

api_get_ssh_any()
{
    api_get_ssh_all $1 "$2"
}

api_get_ssh_helper()
{
    ssh -$1 -p $2 $3 "$4"
}

api_get_ssh_dell()
{
    ssh -tt -X HQDEBDELL01 "$1"
}

api_get_ssh_dev()
{
    ssh -tt -X HQDEBDEV01 "$1"
}

api_get_ssh_ipad()
{
    api_get_ssh_all ipad "$1"
}

api_get_ssh_iphone()
{
    api_get_ssh_all iphone "$1"
}

api_get_ssh_lenovo()
{
    ssh -tt -X HQDEBLENOVO01 "$1"
}

api_get_ssh_localhost()
{
    api_get_ssh_all localhost "$1"
}

api_get_virsh_dhcp()
{
    sudo virsh net-dhcp-leases default
}

api_get_virsh_list() 
{
    sudo virsh list --all
}

api_get_virsh_viewer_debian()
{
    api_get_virsh_list
    VM="KVMDEBPROD01"
    api_get_ssh_prod " . ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

api_get_virsh_viewer_windows()
{
    api_get_virsh_list
    VM="KVMWINPROD02"
    api_get_ssh_dev " . ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

api_get_x_secret()
{
    api_set_tmux_kill secret
    api_set_tmux_session secret
    api_set_tmux_send secret "bash"
    api_set_tmux_send secret " . ~/.profile; ssh_dev"
    api_set_tmux_send secret "secret $1"
}

api_set_apk_setup()
{
    echo "apk: Setup alpine server."
    mkdir -p ~/.local/bin/
    api_set_apk_upgrade
    api_set_apk_upgrade
    api_set_ssh_create
    sudo rc-update add docker
    sudo service docker start
    sudo docker run --rm hello-world
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,flatpak,kvm,libvirt,wheel $USER
}

api_set_apk_setup_ish()
{
    echo "apk: Setup alpine server for iSH iOS app."
    mkdir -p ~/.local/bin/
    api_set_apk_upgrade_ish
    sudo apk add bash dos2unix git git-lfs lynx nano neofetch openrc openssh openssl python3 py3-pip rsync sqlite sudo tmux tree vim x11vnc x11vnc-doc xdpyinfo xdpyinfo-doc xf86-video-dummy
    api_set_ssh_create
    sudo rc-update add sshd || exit 0
    /usr/sbin/sshd
}

api_set_apk_upgrade()
{
    api_set_source_profile
    api_set_venv_create
    api_set_git_update_all
    echo "apk: Upgrading Alpine Linux node"
    sudo apk -U upgrade
}

api_set_apk_upgrade_ish()
{
    api_set_rsync_git_prod
     . ~/.profile
    echo "apk: Upgrading Alpine Linux node"
    sudo apk -U upgrade
}

api_set_apt_install()
{
    echo "apt: Attempting to install or update - $1"
    sudo apt-get install "$1" -y
}


api_set_setup()
{
    echo "apt: Setup debian server. $(hostname)"
    sudo apt-get -y install dos2unix kde-standard keepassxc nano neofetch openssh-client openssh-server python3 python3-pip python3-venv rsync sudo vim virt-manager xclip zsh
    sudo adduser $USER --shell /bin/zsh
    sudo usermod -G kvm,libvirt,audio $USER
    sudo systemctl enable --now libvirtd
    sudo su $USER -c "mkdir -p ~/.local/"
    sudo su $USER -c "mkdir -p ~/.local/bin/"
    sudo su $USER -c "mkdir -p ~/.local/share/"
    sudo su $USER -c "mkdir -p ~/.local/state/"
    sudo su $USER -c "mkdir -p ~/.local/share/tmp"
    sudo su $USER -c " . ~/.profile; api_set_apt_upgrade"
    sudo su $USER -c " . ~/.profile; api_set_ssh_create"
    # sudo su $USER -c " . ~/.profile; api_set_rsync_git_prod"
    sudo cp ~/.local/bin/docs/data/hosts /etc/hosts
    sudo mkdir -p /etc/ansible/
    cd ~/.local/bin
    git clone git@github.com:CorbinBlock/docs.git
    git clone git@github.com:CorbinBlock/ansible.git
    cd ~/.local/bin/docs/
    git pull --no-rebase
    cd ~/.local/bin/ansible/
    git pull --no-rebase
    sudo cp ~/.local/bin/docs/data/ansible_hosts /etc/ansible/hosts
    sudo cp ~/.local/bin/docs/data/sources.list /etc/apt/sources.list
    cp ~/.local/bin/docs/data/.profile ~/.profile
    cp ~/.local/bin/docs/data/.zshrc ~/.zshrc
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBACER01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBARM01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBASUS01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBDELL01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBDEV01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBPROD01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub HQDEBLENOVO01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBPROD01 KVMDEBPROD01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBPROD01 KVMDEBDEV01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBPROD01 KVMDEBTEST02
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBPROD01 KVMDEBLENOVO01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBPROD01 KVMDEBWSL01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBDEV01 KVMDEBTEST01
    # ssh-copy-id -i ~/.ssh/id_rsa.pub -o ProxyJump=HQDEBDELL01 KVMDEBDELL01
}


api_set_setup_all()
{
    api_set_setup
    ssh -tt -J HQDEBDEV01 KVMDEBTEST01 " . ~/.profile; api_set_setup"
    ssh -tt -J HQDEBDEV01,KVMDEBTEST01 192.168.122.195 " . ~/.profile; api_set_setup"
    ssh -tt -J HQDEBDEV01,KVMDEBTEST01 192.168.122.133 " . ~/.profile; api_set_setup"
    ssh -tt -J HQDEBDEV01,KVMDEBTEST01 192.168.122.27 " . ~/.profile; api_set_setup"
    ssh -tt -J HQDEBDEV01,KVMDEBTEST01 192.168.122.140 " . ~/.profile; api_set_setup"
    ssh -tt -J HQDEBDEV01,KVMDEBTEST01 192.168.122.6 " . ~/.profile; api_set_setup"
    ssh -tt HQDEBPROD01  " . ~/.profile; api_set_setup"
    ssh -tt HQDEBDEV01 " . ~/.profile; api_set_setup"
    ssh -tt HQDEBDELL01 " . ~/.profile; api_set_setup"
    # ssh -tt HQDEBACER01 " . ~/.profile; api_set_setup"
    ssh -tt HQDEBASUS01 " . ~/.profile; api_set_setup"
    # ssh -tt HQDEBLENOVO01 " . ~/.profile; api_set_setup"
}

api_set_apt_upgrade()
{
    echo "apt: Update debian server."
    sudo apt-get update
    sudo apt-get --with-new-pkgs upgrade -y
    yes | sudo apt-get autoremove
    api_set_source_profile
    api_set_venv_create
    ansible-playbook ~/.local/bin/ansible/apt_all.yml
    echo "Update complete for node: $(hostname)"
}

api_set_config()
{
    export DEBIAN_FRONTEND=noninteractive
    export EDITOR=/usr/bin/vim
    export PAGER=/usr/bin/less
    export PROD="192.168.0.25"
    export LIBGL_ALWAYS_INDIRECT=1
    export DONT_PROMPT_WSL_INSTALL=1
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
    export PATH="/opt/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/c/Windows/System32/:/c/Windows/System32/WindowsPowershell/v1.0/:/c/Windows/:/home/$USER/.local/bin:/home/$USER/:/c/Windows/System32/OpenSSH/:/c/Program Files (x86)/Microsoft Office/root/Office16/:"
    export PS1="\\s-\\v$ "
    export XDG_CACHE_HOME=$HOME/.cache/
    export XDG_CONFIG_HOME=$HOME/.config/
    export XDG_DATA_HOME=$HOME/.local/share/
    export XDG_STATE_HOME=$HOME/.local/state/
    export XDG_RUNTIME_DIR=/run/user/$UID
    export XAUTHORITY=$HOME/.Xauthority
    export WIN_DOCS=/c/Users/$USER/.local/share/docs/
    export WIN_JAVASCRIPT=/c/Users/$USER/.local/share/docs/javascript/
    export WIN_POWERSHELL=/c/Users/$USER/.local/share/docs/powershell/
    export WIN_PYTHON=/c/Users/$USER/.local/share/docs/python/
    export WIN_SQL=/c/Users/$USER/.local/share/docs/db/General/Scripts/
    export WIN_XDG_CONFIG_HOME=/c/Users/$USER/.config/
    export WIN_XDG_DATA_HOME=/c/Users/$USER/.local/shate/
    export WIN_XDG_STATE_HOME=/c/Users/$USER/.local/state/
    alias py="python"
    alias python="python3"
    alias set_clipboard="xclip -selection c"
    alias get_clipboard="xclip -selection c -o"    
}

api_set_docker_delete()
{
    sudo docker rm$(docker ps --filter status=exited -q)
    sudo docker system prune --all --force --volumes
}

api_set_docker_firefox()
{
    api_set_docker_delete
    cd $XDG_DATA_HOME/docs/docker/docker_firefox/
    ./setup.sh
}

api_set_docker_gentoo()
{
    cd $DOCS_DIR
    cd linux/gentoo
    sudo docker build .
}

api_set_dnf_upgrade()
{
    sudo dnf upgrade -y
}

api_set_email_source_profile()
{
    cd $XDG_DATA_HOME/docs/python
    python3 send_email.py "$(hostname) - The profile was refreshed. - $(date)" " . ~/.profile; api_set_source_profile"
}

api_set_emerge_setup()
{
    sudo eselect profile set default/linux/amd64/17.1/desktop
    api_set_emerge_update
    set -- app-admin/sudo app-admin/keepassxc app-containers/docker app-containers/docker-compose app-editors/vim app-emulation/libvirt app-emulation/qemu app-emulation/virt-viewer app-misc/jq app-misc/neofetch app-misc/tmux app-text/dos2unix app-text/tree dev-java/openjdk dev-java/maven-bin dev-python/pip dev-vcs/git net-analyzer/nmap net-misc/rsync sys-apps/dmidecode sys-apps/flatpak sys-apps/lshw sys-devel/distcc virtual/cron www-client/lynx x11-misc/xclip
    for item in "$@"; do sudo emerge "$item"; done
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || exit 0
    sudo emerge xfce-base/xfce4-meta --autounmask-write --autounmask=y
    sudo eselect news read
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,kvm,wheel $USER
    api_set_ssh_create
}

api_set_emerge_sync()
{
    sudo emaint -a sync
}

api_set_emerge_update()
{
    sudo emerge-webrsync
    sudo emerge --ask --verbose --update --deep --newuse @world
    sudo emerge --depclean
}

api_set_git_pull()
{
    echo "git: Update repo in current directory"
    pwd
    git pull --no-rebase
}

api_set_git_push_ansible()
{
    echo "git: Push ansible repo to main branch + Test on nodes"
    cd ~/.local/bin/ansible/
    cp ~/.local/share/docs/ansible/.profile ~/.local/share/docs/ansible/profile
    cp ~/.local/share/docs/ansible/profile ~/.local/bin/ansible/
    cp ~/.local/share/docs/ansible/apt_all.yml ~/.local/bin/ansible/
    api_set_git_push
}

api_set_git_push()
{
    git add --all
    git add all*
    git add be*
    git add data*
    git add python*
    git add linux*
    git add db*
    git add *
    git commit -m "+"
    pwd
    git push
}

api_set_git_push_docs()
{
    cd $XDG_DATA_HOME/docs
    api_set_git_push
}

api_set_nas_setup()
{
    sudo mount /dev/sdb ~/.local/share/ssd/
    sudo mount /dev/sdc ~/.local/share/hdd/
    sudo mount /dev/sdd ~/.local/share/hdd_two/
}

api_set_reboot()
{
    pkill chromium
    pkill firefox
    pkill keepassxc
    pkill gvim
    sudo reboot
}

api_set_rsync_git_prod()
{
    sudo cp /etc/hosts $XDG_DATA_HOME
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/hosts $XDG_DATA_HOME
    sudo mv $XDG_DATA_HOME/hosts /etc
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/apt/sources.list $XDG_DATA_HOME
    sudo mv $XDG_DATA_HOME/sources.list /etc/apt/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/profile $XDG_DATA_HOME
    sudo mv $XDG_DATA_HOME/profile /etc
    sudo mkdir -p /etc/ansible
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/ansible/hosts $XDG_DATA_HOME/ansible_hosts
    sudo mv $XDG_DATA_HOME/ansible_hosts /etc/ansible/hosts
    ssh -p $PORT $USER@$DOMAIN " . ~/.profile; api_set_source_profile"
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.local/share/docs/ ~/.local/share/docs/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.local/bin/ansible/ ~/.local/bin/ansible/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.profile ~/.profile
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.zshrc ~/.zshrc
}

api_set_rsync_git_dev()
{
    rsync -avP prod:~/.local/share/dev/ ~/.local/share/dev/
}

api_set_rsync_git_dev_push()
{
    rsync -avP ~/.local/share/dev/ prod:~/.local/share/dev/
}

api_set_rsync_git_win()
{
    rsync -avP prod:~/.local/share/docs/ /c/Users/$USER/.local/share/docs/
}

api_set_rsync_nas_two()
{
   api_get_ssh_dev "rsync --archive --inplace --partial --progress --verbose ~/.local/share/hdd/* ~/.local/share/hdd_two/"
}

api_set_rsync_vm_prod()
{
   api_get_ssh_prod "rsync --archive --inplace --partial --progress --verbose ~/.local/state/kvm/* dev:~/.local/share/hdd/kvm/"
}

api_set_source_profile()
{
    echo "git: Update profile from Git and load into session"
    cd ~/.local/bin/
    FILE=~/.local/bin/ansible/
    if [ ! -d "$FILE" ]  ; then
        echo "$FILE does not exist."
        git clone https://github.com/CorbinBlock/ansible.git
    fi
    cd $FILE
    api_set_git_pull
    sudo cp ~/.local/bin/ansible/profile ~/.profile
    dos2unix ~/.profile
     . ~/.profile
}

api_set_ssh_create()
{
    FILE=~/.ssh/id_rsa
    if [ ! -f "$FILE" ]  ; then
        echo "$FILE does not exist. Creating ssh key pair."
        ssh-keygen -t rsa -b 4096
    else
        echo "$FILE exists!"
    fi
}

api_set_ssh_mount()
{
    sudo chown $USER /mnt
    set -- kvm_debian_test dev prod dell lenovo
    for item in "$@"
    do api_set_apt_install "$item"
        echo "$i"
        mkdir -p /mnt/$i
        sshfs -o allow_other,IdentityFile=/home/$USER/.ssh/id_ed25519 $USER@$i:/home/$USER/ /mnt/$i/
    done
}

api_get_ssh_prod()
{
    ssh -X -p 50100 $DOMAIN "$1"
}

api_set_ssh_tunnel()
{
    ssh -X -p 50100 -L 3391:KVMWINPROD01:3389 -L 3392:KVMWINDEV01:3389 -L 3393:KVMWINPROD02:3389  -L 3394:KVMWINDEV02:3389 -L 3395:KVMWINLENOVO01:3389 -L 3396:KVMWINLENOVO02:3389 -L 3397:KVMWINDELL01:3389 -L 3398:KVMWINDELL02:3389 -L 3399:KVMWINACER01:3389 -L 3340:KVMWINACER02:3389  -L 8081:KVMDEBPROD01:8080 -L 9091:KVMDEBPROD01:9090 -L 5911:HQDEBPROD01:5901 -L 5912:HQDEBPROD01:5902 -L 5913:HQDEBPROD01:5903 -L 5914:HQDEBPROD01:5904 -L 5915:HQDEBDEV01:5901 -L 5916:HQDEBDEV01:5902 -L 5917:HQDEBLENOVO01:5901 -L 5918:HQDEBLENOVO01:5902 -L 5919:HQDEBACER01:5901 -L 5920:HQDEBDELL01:5901 -L 5921:HQDEBDELL01:5902 -L 8081:HQDEBPROD01:8080 -L 9091:KVMDEBPROD01:9090 $USER@$DOMAIN "$1"
}

api_set_tmux_all()
{
    api_set_tmux_kill $1
    api_set_tmux_session $1
    api_set_tmux_send "$1" "$1"
    api_set_tmux_attach $1
}

api_set_tmux_attach()
{
    tmux attach -t $1
}

api_set_tmux_env()
{
    api_set_tmux_session update
    api_set_tmux_session ssh_tunnel
    api_set_tmux_send update "api_set_setup; api_set_setup_all"
    api_set_tmux_send ssh_tunnel " . ~/.profile; sleep 20; api_set_ssh_tunnel"
}

api_set_tmux_env_acer()
{
    api_set_tmux_session wifi
    api_set_tmux_session ssh_tunnel
    api_set_tmux_send wifi "sudo wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp0s20f3; sudo dhclient -v wlp0s20f3; sleep 10; api_set_setup; api_set_setup_all"
    api_set_tmux_send ssh_tunnel " . ~/.profile; sleep 20; api_set_ssh_tunnel"
}

api_set_tmux_env_dell()
{
    api_set_tmux_session wifi
    api_set_tmux_session ssh_tunnel
    api_set_tmux_send wifi "sudo wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp2s0; sudo dhclient -v wlp2s0; sleep 10; api_set_setup; api_set_setup_all"
    api_set_tmux_send ssh_tunnel " . ~/.profile; sleep 20; api_set_ssh_tunnel"
}

api_set_tmux_kill()
{
    tmux kill-session -t $1
}

api_set_tmux_list()
{
    tmux ls
}

api_set_tmux_send()
{
    tmux send-keys -t $1 "$2" C-m
}

api_set_tmux_session()
{
    tmux new-session -dt $1
}

api_set_tmux_split()
{
    tmux new-session \; split-window -h \; split-window -v \; attach
}

api_set_venv_create()
{
    api_set_source_profile
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ -d "$FILE" ]  ; then
        echo "$FILE does exist. Renaming to venv_bkp"
        rsync -avP ~/.local/bin/venv/ ~/.local/bin/venv_bkp/
    fi
    python3 -m venv venv
    api_set_venv_activate_source
    python3 -m pip install --upgrade ansible paramiko pip pyspark setuptools wheel
}

api_set_venv_activate()
{
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ ! -d "$FILE" ]  ; then
        echo "$FILE does not exist. Creating venv."
        api_set_venv_create
    fi
    api_set_venv_activate_source
    cd -
}

api_set_venv_activate_source()
{
    . ~/.local/bin/venv/bin/activate
}

api_set_virsh_install_debian()
{
    api_get_virsh_list
    sudo virt-install --name KVMDEBPROD01 --description 'debian' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMDEBPROD01_20230317.qcow2,size=90 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/debian-11.5.0-amd64-netinst.iso --graphics vnc,port=5901,listen=0.0.0.0 --noautoconsole
}

api_set_virsh_install_debian_dev()
{
    api_get_virsh_list
	sudo virt-install --name KVMDEBDEV01 --description 'debian' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMDEBDEV01_20230317.qcow2,size=90 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/debian-11.5.0-amd64-netinst.iso --graphics vnc,port=5902,listen=0.0.0.0 --noautoconsole
}

api_set_virsh_install_windows()
{
    api_get_virsh_list
    sudo virt-install --name KVMWINPROD01 --description 'Windows' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMWINPROD01_20230317.qcow2,size=120 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win10_21H2_English_x64.iso --graphics vnc,port=5903,listen=0.0.0.0 --noautoconsole
}

api_set_virsh_install_windows_dev()
{
    api_get_virsh_list
    sudo virt-install --name KVMWINDEV01 --description 'Windows' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMWINDEV01_20230317.qcow2,size=120 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win10_21H2_English_x64.iso --graphics vnc,port=5904,listen=0.0.0.0 --noautoconsole
}

api_set_virsh_install_windows11()
{
    api_get_virsh_list
    vm="KVMWIN11TEST01_20230210.qcow2"
    vm_size=300
    sudo virt-install --name KVMWIN11TEST01 --description 'Windows' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/kvm/$VM,size=$VM_SIZE --os-variant win11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win11_22H2_English_x64v1.iso --video virtio --features kvm_hidden=on,smm=on --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd --noautoconsole
}

api_set_virsh_start_network() 
{
    api_get_virsh_list
    sudo virsh net-create ~/.local/share/docs/data/default.xml
    sudo virsh net-start default
}

api_set_apk_install()
{
    echo "apk: Attempting to install or update - $1"
    sudo apk add $1
}

main ()
{
    api_set_config
     . /etc/profile
}
main
# End profile
