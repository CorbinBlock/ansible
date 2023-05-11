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

api_secret()
{
    secret_path=$1
    database=$XDG_DATA_HOME/docs/data/secrets.kdbx
    key_file=$XDG_DATA_HOME/docs/data/secrets.keyx
    password=$XDG_CONFIG_HOME/keepassxc/.keepassxc.txt
    command="cat $password | keepassxc-cli show -sa password -k $key_file $database $secret_path | set_clipboard"
    eval $command
}

api_virsh_dhcp()
{
    sudo virsh net-dhcp-leases default
}

api_virsh_import_debian()
{
    api_virsh_list
    sudo virt-install --name KVMDEBPROD01 --memory 6000 --vcpus 4 --disk ~/.local/state/KVMDEBPROD01_20230211.qcow2 --import --os-variant debian11 --network default --graphics vnc,port=5901,listen=0.0.0.0 --noautoconsole
}

api_virsh_import_debian_dev()
{
    api_virsh_list
    sudo virt-install --name KVMDEBDEV01 --memory 6000 --vcpus 4 --disk ~/.local/state/KVMDEBDEV01_20230211.qcow2 --import --os-variant debian11 --network default --graphics vnc,port=5902,listen=0.0.0.0 --noautoconsole
}

api_virsh_import_windows() 
{
    api_virsh_list
    sudo virt-install --name KVMWINPROD01 --memory 6000 --vcpus 4 --disk ~/.local/state/KVMWINPROD01_20230317.qcow2 --import --os-variant win10 --network default --graphics vnc,port=5903,listen=0.0.0.0 --noautoconsole
}

api_virsh_import_windows_dev()
{
    api_virsh_list
    sudo virt-install --name KVMWINDEV01 --memory 6000 --vcpus 4 --disk ~/.local/state/KVMWINDEV01_20230317.qcow2 --import --os-variant win10 --network default --graphics vnc,port=5904,listen=0.0.0.0 --noautoconsole
}

api_virsh_install_debian()
{
    api_virsh_list
	sudo virt-install --name KVMDEBPROD01 --description 'debian' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMDEBPROD01_20230317.qcow2,size=90 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/debian-11.5.0-amd64-netinst.iso --graphics vnc,port=5901,listen=0.0.0.0 --noautoconsole
}

api_virsh_install_debian_dev()
{
    api_virsh_list
	sudo virt-install --name KVMDEBDEV01 --description 'debian' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMDEBDEV01_20230317.qcow2,size=90 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/debian-11.5.0-amd64-netinst.iso --graphics vnc,port=5902,listen=0.0.0.0 --noautoconsole
}

api_virsh_install_windows()
{
    api_virsh_list
    sudo virt-install --name KVMWINPROD01 --description 'Windows' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMWINPROD01_20230317.qcow2,size=120 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win10_21H2_English_x64.iso --graphics vnc,port=5903,listen=0.0.0.0 --noautoconsole
}

api_virsh_install_windows_dev()
{
    api_virsh_list
    sudo virt-install --name KVMWINDEV01 --description 'Windows' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMWINDEV01_20230317.qcow2,size=120 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win10_21H2_English_x64.iso --graphics vnc,port=5904,listen=0.0.0.0 --noautoconsole
}

api_virsh_install_windows11()
{
    api_virsh_list
    vm="KVMWIN11TEST01_20230210.qcow2"
    vm_size=300
    sudo virt-install --name KVMWIN11TEST01 --description 'Windows' --ram 6000 --vcpus 4 --disk path=/home/$USER/.local/state/kvm/$VM,size=$VM_SIZE --os-variant win11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win11_22H2_English_x64v1.iso --video virtio --features kvm_hidden=on,smm=on --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd --noautoconsole
}

api_virsh_list() 
{
    sudo virsh list --all
}

api_virsh_start_network() 
{
    api_virsh_list
    sudo virsh net-create ~/.local/share/docs/data/default.xml
	sudo virsh net-start default
}

api_virsh_viewer_debian()
{
    api_virsh_list
    VM="KVMDEBPROD01"
    system_ssh_prod "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

api_virsh_viewer_windows()
{
    api_virsh_list
    VM="KVMWINPROD02"
    system_ssh_dev "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

api_x_secret()
{
    system_tmux_kill secret
    system_tmux_session secret
    system_tmux_send secret "bash"
    system_tmux_send secret "source ~/.profile; ssh_dev"
    system_tmux_send secret "secret $1"
}

system_apk_install()
{
    echo "apk: Attempting to install or update - $1"
    sudo apk add $1
}

system_apk_setup()
{
    echo "apk: Setup alpine server."
    mkdir -p ~/.local/bin/
    system_apk_upgrade
    package_list=( bash docker docker-compose dos2unix flatpak git git-lfs keepassxc nano neofetch openssh openrc python3 py3-pip sudo tmux vim tree lynx openjdk17 xfce4 xfce4-terminal xfce4-screensaver lightdm-gtk-greeter dbus pipewire wireplumber nmap rust go)
    for i in "${package_list[@]}"
    do
        system_apk_install $i
    done
    system_apk_upgrade
    system_ssh_create
    sudo rc-update add docker
    sudo service docker start
    sudo docker run --rm hello-world
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,flatpak,kvm,libvirt,wheel $USER
}

system_apk_setup_ish()
{
    echo "apk: Setup alpine server for iSH iOS app."
    mkdir -p ~/.local/bin/
    system_apk_upgrade_ish
    # i3status i3status-doc i3wm i3wm-doc i3lock i3lock-doc sshfs ttf-dejavu xorg-server xterm xvfb
    # package_list=( bash dos2unix git git-lfs lynx nano neofetch openrc openssh openssl python3 py3-pip rsync sqlite sudo tmux tree vim x11vnc x11vnc-doc xdpyinfo xdpyinfo-doc xf86-video-dummy)
    #for i in "${package_list[@]}"
    #do
    #    apk_install $i
    # done
    sudo apk add bash dos2unix git git-lfs lynx nano neofetch openrc openssh openssl python3 py3-pip rsync sqlite sudo tmux tree vim x11vnc x11vnc-doc xdpyinfo xdpyinfo-doc xf86-video-dummy
    system_ssh_create
    # sudo rc-update add sshd
    /usr/sbin/sshd
}

system_apk_upgrade()
{
    system_source_profile
    system_venv_create
    system_git_update_all
    echo "apk: Upgrading Alpine Linux node"
    sudo apk -U upgrade
}

system_apk_upgrade_ish()
{
    system_rsync_git_prod
    source ~/.profile
    echo "apk: Upgrading Alpine Linux node"
    sudo apk -U upgrade
}

system_apt_install()
{
    echo "apt: Attempting to install or update - $1"
    sudo apt-get install "$1"
}


system_apt_setup()
{
    echo "apt: Setup debian server."
    package_list=(dos2unix git python3 sudo vim)
    for i in "${package_list[@]}"
    do
        system_apt_install $i
    done
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G kvm,libvirt,audio $USER
    sudo systemctl enable --now libvirtd
    file=/opt/maven/bin/mvn
     if [ ! -f $file ]; then
     echo "$file not found!"
     cd /tmp
     curl -O https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
     sudo tar -zxvf apache-maven-3.8.6-bin.tar.gz
     sudo mv apache-maven-3.8.6 /opt/maven
     ls /opt/maven
     mvn -version
     fi
     echo "apt: Setup $user."
     file=/etc/pipewire/media-session.d/with-pulseaudio
     if [ ! -f $file ]; then
     echo "$file not found!"
     sudo su $USER -c "sudo touch $file"
     sudo su $USER -c "sudo cp /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* /etc/systemd/user/"
     sudo su $USER -c "systemctl --user daemon-reload"
     sudo su $USER -c "systemctl --user --now disable pulseaudio.service pulseaudio.socket"
     sudo su $USER -c "systemctl --user --now enable pipewire pipewire-pulse"
     fi
     sudo su $USER -c "mkdir -p ~/.local/"
     sudo su $USER -c "mkdir -p ~/.local/bin/"
     sudo su $USER -c "mkdir -p ~/.local/share/"
     sudo su $USER -c "mkdir -p ~/.local/state/"
     sudo su $USER -c "mkdir -p ~/.local/share/tmp"
     sudo su $USER -c "source ~/.profile; system_apt_upgrade"
     sudo su $USER -c "source ~/.profile; system_ssh_create"
     sudo su $USER -c "source ~/.profile; system_x_stop_lockscreen"
     sudo su $USER -c "source ~/.profile; system_rsync_git_prod"
     sudo su $USER -c "sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

}


system_apt_setup_all()
{
    node_list=(KVMDEBPROD01 KVMDEBACER01 KVMDEBDELL01 KVMDEBDEV01 KVMDEBTEST01 KVMDEBTEST02 KVMDEBLENOVO01 HQDEBPROD01 HQDEBDEV01 HQDEBDELL01 HQDEBACER01 HQDEBLENOVO01)
    for i in "${node_list[@]}"
    do
        echo "apt - Updating all debian nodes - Current node: $i"
        system_ssh_helper "X" "22" "$i" "source ~/.profile; system_apt_setup"
    done
    system_ssh_dev "ssh KVMDEBTEST01 'source ~/.profile; system_apt_setup'"
    system_ssh_prod "source ~/.profile; system_apt_setup"
    # system_ssh_dev "source ~/.profile; system_apt_setup"
    system_ssh_dell "source ~/.profile; system_apt_setup"
    system_ssh_lenovo "source ~/.profile; system_apt_setup"
    system_ssh_acer "source ~/.profile; system_apt_setup"
}

system_apt_upgrade()
{
    echo "apt: Update debian server."
    sudo apt-get update
    sudo apt-get --with-new-pkgs upgrade -y
    yes | sudo apt-get autoremove
    system_source_profile
    system_venv_create
    ansible-playbook ~/.local/bin/ansible/apt_all.yml
}

system_apt_upgrade_wsl()
{
    sudo apt-get update
    sudo apt-get --with-new-pkgs upgrade -y
    sudo apt-get autoremove -y
    system_source_profile
    system_venv_create
    system_git_update_all
    ansible-playbook ~/.local/share/docs/python/ansible/apt_all.yml
}

system_config()
{
    SEARCH_URL=duckduckgo.com
    JAVA_WIN=/c/Users/$USER/.local/share/docs/java/bin/
    JAVA_LINUX=/home/$USER/.local/share/docs/java/bin/
    export DEBIAN_FRONTEND=noninteractive
    export DOCS_DIR=~/.local/share/docs
    export EDITOR=/usr/bin/vim
    export PAGER=/usr/bin/less
    export PROD="10.83.1.111"
    export LIBGL_ALWAYS_INDIRECT=1
    export DONT_PROMPT_WSL_INSTALL=1
    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
    export PATH="/opt/maven/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/c/Windows/System32/:/c/Windows/System32/WindowsPowershell/v1.0/:/c/Windows/:/home/$USER/.local/bin:/home/$USER/:/c/Windows/System32/OpenSSH/:/c/Program Files (x86)/Microsoft Office/root/Office16/:"
    export PS1="\\s-\\v$ "
    export XDG_CACHE_HOME=$HOME/.cache
    export XDG_CONFIG_HOME=$HOME/.config
    export XDG_DATA_HOME=$HOME/.local/share
    export XDG_STATE_HOME=$HOME/.local/state
    export XDG_RUNTIME_DIR=/run/user/$UID
    export XAUTHORITY=$HOME/.Xauthority
    alias py="python"
    alias python="python3"
    alias set_clipboard="xclip -selection c"
    alias get_clipboard="xclip -selection c -o"    
}

system_docker_delete()
{
    sudo docker rm$(docker ps --filter status=exited -q)
    sudo docker system prune --all --force --volumes
}

system_docker_firefox()
{
    system_docker_delete
    cd $XDG_DATA_HOME/docs/docker/docker_firefox/
    ./setup.sh
}

system_docker_gentoo()
{
    cd $DOCS_DIR
    cd linux/gentoo
    sudo docker build .
}

system_dnf_upgrade()
{
    sudo dnf upgrade -y
}

system_email_source_profile()
{
    cd $XDG_DATA_HOME/docs/python
    python3 send_email.py "$(hostname) - The profile was refreshed. - $(date)" " . ~/.profile; system_source_profile"
}

system_emerge_setup()
{
    sudo eselect profile set default/linux/amd64/17.1/desktop
    system_emerge_update
    package_list=(app-admin/sudo app-admin/keepassxc app-containers/docker app-containers/docker-compose app-editors/vim app-emulation/libvirt app-emulation/qemu app-emulation/virt-viewer app-misc/jq app-misc/neofetch app-misc/tmux app-text/dos2unix app-text/tree dev-java/openjdk dev-java/maven-bin dev-python/pip dev-vcs/git net-analyzer/nmap net-misc/rsync sys-apps/dmidecode sys-apps/flatpak sys-apps/lshw sys-devel/distcc virtual/cron www-client/lynx x11-misc/xclip)
    for i in "${package_list[@]}"
    do
        echo "$i"
        sudo emerge $i
    done
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || exit 0
    sudo emerge xfce-base/xfce4-meta --autounmask-write --autounmask=y
    sudo eselect news read
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,kvm,wheel $USER
    system_ssh_create
}

system_emerge_sync()
{
    sudo emaint -a sync
}

system_emerge_update()
{
    sudo emerge-webrsync
    sudo emerge --ask --verbose --update --deep --newuse @world
    sudo emerge --depclean
}

system_ide()
{
    system_tmux_kill ide
    system_tmux_session ide
	system_tmux_send "~/.local/bin/idea/bin/idea.sh"
}

system_git_pull()
{
    echo "git: Update repo in current directory"
    api_x_secret git
    pwd
    git pull --no-rebase
}

system_git_push_ansible()
{
    echo "git: Push ansible repo to main branch + Test on nodes"
    cd ~/.local/bin/ansible/
    cp ~/.local/share/docs/ansible/.profile ~/.local/share/docs/ansible/profile
    cp ~/.local/share/docs/ansible/profile ~/.local/bin/ansible/
	cp ~/.local/share/docs/ansible/apt_all.yml ~/.local/bin/ansible/
    system_git_push
}

system_git_push()
{
    api_x_secret git
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

system_git_push_docs()
{
    api_x_secret git
    cd $DOCS_DIR
    system_git_push
}

system_nas_setup()
{
    sudo mount /dev/sdb ~/.local/share/ssd/
    sudo mount /dev/sdc ~/.local/share/hdd/
    sudo mount /dev/sdd ~/.local/share/hdd_two/
}

system_report()
{
    source ~/.profile
    clear
    neofetch
    date
    system_tmux_list
    sudo docker ps
    api_virsh_list
    df -BG
}

system_rsync_git_prod()
{
    sudo cp /etc/hosts $XDG_DATA_HOME
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/hosts $XDG_DATA_HOME
    sudo mv $XDG_DATA_HOME/hosts /etc
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/profile $XDG_DATA_HOME
    sudo mv $XDG_DATA_HOME/profile /etc
    sudo mkdir -p /etc/ansible
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/ansible/hosts $XDG_DATA_HOME
    sudo mv $XDG_DATA_HOME/hosts /etc/ansible
    ssh -p $PORT $USER@$DOMAIN "source ~/.profile; system_source_profile"
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.local/share/docs/ ~/.local/share/docs/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.local/bin/ansible/ ~/.local/bin/ansible/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.profile ~/.profile
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.zshrc ~/.zshrc
}

system_rsync_git_dev()
{
    rsync -avP prod:~/.local/share/dev/ ~/.local/share/dev/
}

system_rsync_git_dev_push()
{
    rsync -avP ~/.local/share/dev/ prod:~/.local/share/dev/
}

system_rsync_git_win()
{
    rsync -avP prod:~/.local/share/docs/ /c/Users/$USER/.local/share/docs/
}

system_rsync_nas_two()
{
   system_ssh_dev "rsync --archive --inplace --partial --progress --verbose ~/.local/share/hdd/* ~/.local/share/hdd_two/"
}

system_rsync_vm_prod()
{
   system_ssh_prod "rsync --archive --inplace --partial --progress --verbose ~/.local/state/kvm/* dev:~/.local/share/hdd/kvm/"
}

system_source_profile()
{
    echo "git: Update profile from Git and load into session"
    cd ~/.local/bin/
    FILE=~/.local/bin/ansible/
    if [ ! -d "$FILE" ]  ; then
        echo "$FILE does not exist."
        git clone https://github.com/CorbinBlock/ansible.git
    fi
    cd $FILE
    system_git_pull
    sudo cp ~/.local/bin/ansible/profile ~/.profile
    dos2unix ~/.profile
    source ~/.profile
}

system_ssh_acer()
{
    ssh -X -p 50500 $DOMAIN  "$1"
}

system_ssh_any()
{
    system_ssh_all $1 "$2"
}

system_ssh_all()
{
    port_list=( 22 2222 3333 50200 50100 50300 50400 50500 )
    for i in "${port_list[@]}"
    do
    echo "ssh: Attempt connection via port $i"
    if system_ssh_helper "X" "$i" "$1" "$2" ; then
        echo "ssh: Connection succeeded"
        break
    else
        echo "ssh: Connection failed, retrying."
    fi
    done
    echo "ssh: Exiting!"
}

system_ssh_helper()
{
    ssh -$1 -p $2 $3 "$4"
}

system_ssh_terminal()
{
    system_ssh_prod "ssh_helper 'tt' $1 $2 '$3'"
}

system_ssh_create()
{
    FILE=~/.ssh/id_ed25519
    if [ ! -f "$FILE" ]  ; then
        echo "$FILE does not exist. Creating ssh key pair."
        ssh-keygen -t ed25519 -b 4096
    else
        echo "$FILE exists!"
    fi
}

system_ssh_dell()
{
    ssh -X -p 50400 $DOMAIN  "$1"
}

system_ssh_dev()
{
    ssh -X -p 50200 $DOMAIN "$1"
}

system_ssh_ipad()
{
    system_ssh_all ipad "$1"
}

system_ssh_iphone()
{
    system_ssh_all iphone "$1"
}

system_ssh_lenovo()
{
    ssh -X -p 50300 $DOMAIN  "$1"
}

system_ssh_localhost()
{
    system_ssh_all localhost "$1"
}

system_ssh_mount()
{
    sudo chown $USER /mnt
    node_list=(kvm_debian_test dev prod dell lenovo)
    for i in "${node_list[@]}"
    do
        echo "$i"
        mkdir -p /mnt/$i
        sshfs -o allow_other,IdentityFile=/home/$USER/.ssh/id_ed25519 $USER@$i:/home/$USER/ /mnt/$i/
    done
}

system_ssh_unmount()
{
    sudo chown $USER /mnt
    node_list=(kvm_debian_test dev prod dell lenovo)
    for i in "${node_list[@]}"
    do
        echo "$i"
        sudo umount /mnt/$i
    done
}

system_ssh_prod()
{
    ssh -X -p 50100 $DOMAIN "$1"
}

system_ssh_tunnel()
{
    ssh -X -p 50100 -L 3391:KVMWINPROD01:3389 -L 3392:KVMWINDEV01:3389 -L 3393:KVMWINPROD02:3389  -L 3394:KVMWINDEV02:3389 -L 3395:KVMWINLENOVO01:3389 -L 3396:KVMWINLENOVO02:3389 -L 3397:KVMWINDELL01:3389 -L 3398:KVMWINDELL02:3389 -L 3399:KVMWINACER01:3389 -L 3340:KVMWINACER02:3389  -L 8081:KVMDEBPROD01:8080 -L 9091:KVMDEBPROD01:9090 -L 5911:HQDEBPROD01:5901 -L 5912:HQDEBPROD01:5902 -L 5913:HQDEBPROD01:5903 -L 5914:HQDEBPROD01:5904 -L 5915:HQDEBDEV01:5901 -L 5916:HQDEBDEV01:5902 -L 5917:HQDEBLENOVO01:5901 -L 5918:HQDEBLENOVO01:5902 -L 5919:HQDEBACER01:5901 -L 5920:HQDEBDELL01:5901 -L 5921:HQDEBDELL01:5902 -L 8081:HQDEBPROD01:8080 -L 9091:KVMDEBPROD01:9090 $USER@$DOMAIN "$1"
}

system_tmux_attach()
{
    tmux attach -t $1
}

system_tmux_env()
{
    # ssh tunnel session created in crontab
    session_list=(firefox ide prod ssh_tunnel_vm wifi )
    for i in "${session_list[@]}"
    do
       echo "$i"
       system_tmux_session $i
    done
    system_tmux_send wifi "bash"
    system_tmux_send wifi "sudo wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp0s20f3; sudo dhclient -v wlp0s20f3"
    sleep 20
    system_tmux_send ssh_tunnel_vm "bash"
    # USER and DOMAIN environment variable required
    system_tmux_send ssh_tunnel_vm "source ~/.profile; sleep 3; api_virsh_viewer_debian"
    system_tmux_send firefox "bash"
    # tmux_send firefox "sleep 3; export DISPLAY=:0; flatpak run org.mozilla.firefox"
    system_tmux_send ide "bash"
    # tmux_send ide "source ~/.profile; sleep 3; export DISPLAY=:0; flatpak run com.jetbrains.IntelliJ-IDEA-Community"
    system_tmux_send prod "bash"
}

system_tmux_kill()
{
    tmux kill-session -t $1
}

system_tmux_list()
{
    tmux ls
}

system_tmux_send()
{
    tmux send-keys -t $1 "$2" C-m
}

system_tmux_session()
{
    tmux new-session -dt $1
}

system_tmux_split()
{
    tmux new-session \; split-window -h \; split-window -v \; attach
}

system_tmux_wsl()
{
    pkill tmux
    session_list=(emerge powershell scroll ssh)
    for i in "${session_list[@]}"
    do
        echo "$i"
        system_tmux_session $i
    done
    system_tmux_list
    system_tmux_send powershell "source ~/.profile; powershell.exe -c pwsh.exe -nologo"
    system_tmux_send emerge "source ~/.profile; sudo emerge-webrsync"
    system_tmux_send ssh "source ~/.profile; powershell.exe -c ssh_tunnel"
    system_tmux_send scroll "source ~/.profile; powershell.exe -c scroll"
    system_tmux_session wsl
    system_tmux_send wsl "source ~/.profile; powershell.exe -c pwsh.exe -nologo"
}

system_venv_create()
{
    system_source_profile
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ -d "$FILE" ]  ; then
        echo "$FILE does exist. Renaming to venv_bkp"
        rsync -avP ~/.local/bin/venv/ ~/.local/bin/venv_bkp/
    fi
    python3 -m pip install --upgrade --user pip
    python3 -m venv venv
    system_venv_activate_source
    package_list=(pip setuptools wheel paramiko ansible pyspark)
    for i in "${package_list[@]}"
    do
         echo "$i"
         python3 -m pip install --upgrade $i
    done
}

system_venv_activate()
{
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ ! -d "$FILE" ]  ; then
        echo "$FILE does not exist. Creating venv."
        venv_create
    fi
    venv_activate_source
    cd -
}

system_venv_activate_source()
{
    source ~/.local/bin/venv/bin/activate
}

system_spice_all()
{
    remote-viewer --full-screen spice://localhost:5911 &
    remote-viewer --full-screen spice://localhost:5912 &
    remote-viewer --full-screen spice://localhost:5913 &
    remote-viewer --full-screen spice://localhost:5914 &
    remote-viewer --full-screen spice://localhost:5915 &
    remote-viewer --full-screen spice://localhost:5916 &
    remote-viewer --full-screen spice://localhost:5917 &
    remote-viewer --full-screen spice://localhost:5918 &
    remote-viewer --full-screen spice://localhost:5919 &
    remote-viewer --full-screen spice://localhost:5920 &
    remote-viewer --full-screen spice://localhost:5921 &
}

system_x_check_battery()
{
    upower -i `upower -e | grep 'BAT'`
}

system_x_stop_lockscreen()
{
    xset -dpms
    xset s off
}

main ()
{
    system_config
    neofetch
	source /etc/profile
}
main
# End profile
