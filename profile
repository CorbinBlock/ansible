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

function apk_install () {
    echo "apk: Attempting to install or update - $1"
    sudo apk add $1
}

function apk_setup() {
    echo "apk: Setup alpine server."
    mkdir -p ~/.local/bin/
    apk_upgrade
    package_list=( bash docker docker-compose dos2unix flatpak git git-lfs keepassxc nano neofetch openssh openrc python3 py3-pip sudo tmux vim tree lynx openjdk17 xfce4 xfce4-terminal xfce4-screensaver lightdm-gtk-greeter dbus pipewire wireplumber nmap rust go)
    for i in "${package_list[@]}"
    do
        apk_install $i
    done
    apk_upgrade
    ssh_create
    sudo rc-update add docker
    sudo service docker start
    sudo docker run --rm hello-world
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,flatpak,kvm,libvirt,wheel $USER
}

function apk_setup_ish() {
    echo "apk: Setup alpine server for iSH iOS app."
    mkdir -p ~/.local/bin/
    apk_upgrade_ish
    # i3status i3status-doc i3wm i3wm-doc i3lock i3lock-doc sshfs ttf-dejavu xorg-server xterm xvfb
    # package_list=( bash dos2unix git git-lfs lynx nano neofetch openrc openssh openssl python3 py3-pip rsync sqlite sudo tmux tree vim x11vnc x11vnc-doc xdpyinfo xdpyinfo-doc xf86-video-dummy)
    #for i in "${package_list[@]}"
    #do
    #    apk_install $i
    # done
    sudo apk add bash dos2unix git git-lfs lynx nano neofetch openrc openssh openssl python3 py3-pip rsync sqlite sudo tmux tree vim x11vnc x11vnc-doc xdpyinfo xdpyinfo-doc xf86-video-dummy
    ssh_create
    sudo rc-update add sshd
    /usr/sbin/sshd
}

function apk_upgrade() {
    source_profile
    venv_create
    git_update_all
    echo "apk: Upgrading Alpine Linux node"
    sudo apk -U upgrade
}

function apk_upgrade_ish() {
    source_profile_nogit
    echo "apk: Upgrading Alpine Linux node"
    sudo apk -U upgrade
}

function apt_install () {
    echo "apt: Attempting to install or update - $1"
    sudo apt-get install "$1"
}


function apt_setup() {
    echo "apt: Setup debian server."
    package_list=(dos2unix git python3 sudo vim)
    for i in "${package_list[@]}"
    do
        apt_install $i
    done
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G kvm,libvirt $USER
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
     sudo su $USER -c "source ~/.profile; apt_upgrade"
     sudo su $USER -c "source ~/.profile; ssh_create"
     sudo su $USER -c "source ~/.profile; x_stop_lockscreen"
     # sudo su $USER -c "source ~/.profile; x_secret firefox"
     # sudo su $USER -c "source ~/.profile; ide"
}


function apt_setup_all {
    node_list=(kvm_debian_test dev localhost prod dell lenovo acer)
    for i in "${node_list[@]}"
    do
        echo "apt - Updating all debian nodes - Current node: $i"
        ssh_helper "X" "22" "$i" "source ~/.profile; apt_setup"
    done
}

function apt_upgrade() {
    echo "apt: Update debian server."
    sudo apt-get update
    sudo apt-get --with-new-pkgs upgrade -y
    sudo apt-get autoremove -y
    source_profile
    venv_create
    ansible-playbook ~/.local/bin/ansible/apt_all.yml
}

function apt_upgrade_wsl() {
    sudo apt-get update
    sudo apt-get --with-new-pkgs upgrade -y
    sudo apt-get autoremove -y
    source_profile
    venv_create
    git_update_all
    ansible-playbook ~/.local/share/docs/python/ansible/apt_all.yml
}

function config() {
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

function docker_delete {
    sudo docker rm$(docker ps --filter status=exited -q)
    sudo docker system prune --all --force --volumes
}

function docker_firefox {
    docker_delete
    cd $XDG_DATA_HOME/docs/docker/docker_firefox/
    ./setup.sh
}

function docker_gentoo {
    cd $DOCS_DIR
    cd linux/gentoo
    sudo docker build .
}

function dnf_upgrade() {
    sudo dnf upgrade -y
}

function emerge_setup {
    sudo eselect profile set default/linux/amd64/17.1/desktop
    emerge_update
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
    ssh_create
}

function emerge_sync {
    sudo emaint -a sync
}

function emerge_update {
    sudo emerge-webrsync
    sudo emerge --ask --verbose --update --deep --newuse @world
    sudo emerge --depclean
}

function git_update_all() {
    rsync_git_dev
    rsync_git_prod
}

function ide() {
    tmux_kill ide
    tmux_session ide
	tmux_send "~/.local/bin/idea/bin/idea.sh"
}

function git_pull() {
    echo "git: Update repo in current directory"
    x_secret git
    pwd
    git pull --no-rebase
}

function git_push_ansible() {
    echo "git: Push ansible repo to main branch + Test on nodes"
    cd ~/.local/share/dev/ansible/
    git_push
    source_profile
    rsync_git_dev_push
    ssh_prod "source ~/.profile; source_profile; ssh_iphone 'source ~/.profile; apk_setup_ish'"
}

function git_push() {
    x_secret git
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

function git_push_docs() {
    x_secret git
    cd $DOCS_DIR
    git_push
}

function nas_setup () {
    sudo mount /dev/sdb ~/.local/share/ssd/
    sudo mount /dev/sdc ~/.local/share/hdd/
    sudo mount /dev/sdd ~/.local/share/hdd_two/
}

function report() {
    source ~/.profile
    clear
    neofetch
    date
    tmux_list
    sudo docker ps
    virsh_list
    df -BG
}

function rsync_git_prod {
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/hosts /tmp
    sudo mv /tmp/hosts /etc
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:/etc/profile /tmp
    sudo mv /tmp/profile /etc
    ssh -p $PORT $USER@$DOMAIN "source ~/.profile; source_profile"
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.local/share/docs/ ~/.local/share/docs/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.local/bin/ansible/ ~/.local/bin/ansible/
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.profile ~/.profile
    rsync -e "ssh -p $PORT" -avP $USER@$DOMAIN:~/.zshrc ~/.zshrc
}

function rsync_git_dev {
    rsync -avP prod:~/.local/share/dev/ ~/.local/share/dev/
}

function rsync_git_dev_push {
    rsync -avP ~/.local/share/dev/ prod:~/.local/share/dev/
}

function rsync_git_win {
    rsync -avP prod:~/.local/share/docs/ /c/Users/$USER/.local/share/docs/
}

function rsync_nas_two {
   ssh_dev "rsync --archive --inplace --partial --progress --verbose ~/.local/share/hdd/* ~/.local/share/hdd_two/"
}

function rsync_vm_prod {
   ssh_prod "rsync --archive --inplace --partial --progress --verbose ~/.local/state/kvm/* dev:~/.local/share/hdd/kvm/"
}

function secret() {
    secret_path=$1
    database=$XDG_DATA_HOME/docs/data/secrets.kdbx
    key_file=$XDG_DATA_HOME/docs/data/secrets.keyx
    password=$XDG_CONFIG_HOME/keepassxc/.keepassxc.txt
    command="cat $password | keepassxc-cli show -sa password -k $key_file $database $secret_path | set_clipboard"
    eval $command
}

function secret_wsl() {
    secret_path=$1
    database=$XDG_DATA_HOME/docs/data/secrets.kdbx
    key_file=$XDG_DATA_HOME/docs/data/secrets.keyx
    password=$XDG_CONFIG_HOME/keepassxc/.keepassxc.txt
    command="cat $password | keepassxc-cli show -sa password -k $key_file $database $secret_path | clip.exe"
    eval $command
}

function source_profile() {
    echo "git: Update profile from Git and load into session"
    cd ~/.local/bin/
    FILE=~/.local/bin/ansible/
    if [ ! -d "$FILE" ]  ; then
        echo "$FILE does not exist."
        git clone https://github.com/CorbinBlock/ansible.git
    fi
    cd $FILE
    git_pull
    sudo cp ~/.local/bin/ansible/profile ~/.profile
    dos2unix ~/.profile
    source ~/.profile
}

function source_profile_nogit() {
    echo "git: Update profile from Git and load into session"
    rsync_git_prod
    source ~/.profile
}

function ssh_acer() {
    ssh_all acer "$1"
}

function ssh_any() {
    ssh_all $1 "$2"
}

function ssh_all() {
    port_list=( 22 2222 3333 50200 50100 50300 50400 50500 )
    for i in "${port_list[@]}"
    do
    echo "ssh: Attempt connection via port $i"
    if ssh_helper "X" "$i" "$1" "$2" ; then
        echo "ssh: Connection succeeded"
        break
    else
        echo "ssh: Connection failed, retrying."
    fi
    done
    echo "ssh: Exiting!"
}

function ssh_helper() {
    ssh -$1 -p $2 $3 "$4"
}

function ssh_terminal() {
    ssh_prod "ssh_helper 'tt' $1 $2 '$3'"
}

function ssh_create() {
    FILE=~/.ssh/id_ed25519
    if [ ! -f "$FILE" ]  ; then
        echo "$FILE does not exist. Creating ssh key pair."
        ssh-keygen -t ed25519 -b 4096
    else
        echo "$FILE exists!"
    fi
}

function ssh_dell() {
    ssh_all dell "$1"
}

function ssh_dev() {
    ssh -X -p 50200 $DOMAIN "$1"
}

function ssh_ipad() {
    ssh_all ipad "$1"
}

function ssh_iphone() {
    ssh_all iphone "$1"
}

function ssh_kvm_debian_prod() {
    ssh_terminal KVMDEBPROD01 "$1"
}

function ssh_kvm_alpine_prod() {
    ssh_terminal KVMALPINEPROD01 "$1"
}

function ssh_lenovo() {
    ssh_all lenovo "$1"
}

function ssh_localhost() {
    ssh_all localhost "$1"
}

function ssh_mount {
    sudo chown $USER /mnt
    node_list=(kvm_debian_test dev prod dell lenovo)
    for i in "${node_list[@]}"
    do
        echo "$i"
        mkdir -p /mnt/$i
        sshfs -o allow_other,IdentityFile=/home/$USER/.ssh/id_ed25519 $USER@$i:/home/$USER/ /mnt/$i/
    done
}

function ssh_unmount {
    sudo chown $USER /mnt
    node_list=(kvm_debian_test dev prod dell lenovo)
    for i in "${node_list[@]}"
    do
        echo "$i"
        sudo umount /mnt/$i
    done
}

function ssh_prod() {
    ssh -X -p 50100 $DOMAIN "$1"
}

function ssh_tunnel() {
    ssh -X -p 50100 -L 3391:KVMWINPROD01:3389 -L 3392:KVMWINDEV01:3389 -L 3393:KVMWINPROD02:3389  -L 3394:KVMWINDEV02:3389 -L 3395:KVMWINLENOVO01:3389 -L 3396:KVMWINLENOVO02:3389 -L 3397:KVMWINDELL01:3389 -L 3398:KVMWINDELL02:3389 -L 3399:KVMWINACER01:3389 -L 3340:KVMWINACER02:3389  -L 8081:KVMDEBPROD01:8080 -L 9091:KVMDEBPROD01:9090 -L 5911:HQDEBPROD01:5901 -L 5912:HQDEBPROD01:5902 -L 5913:HQDEBPROD01:5903 -L 5914:HQDEBPROD01:5904 -L 5915:HQDEBDEV01:5901 -L 5916:HQDEBDEV01:5902 -L 5917:HQDEBLENOVO01:5901 -L 5918:HQDEBLENOVO01:5902 -L 5919:HQDEBACER01:5901 -L 5920:HQDEBDELL01:5901 -L 5921:HQDEBDELL01:5902 -L 8081:HQDEBPROD01:8080 -L 9091:KVMDEBPROD01:9090 $USER@$DOMAIN "$1"
}

function tmux_attach() {
    tmux attach -t $1
}

function tmux_cygwin() {
    powershell.exe -c "test_process_kill('tmux')"
    session_list=(alpine debian gentoo powershell rsync vim scroll ssh_tunnel)
    for i in "${session_list[@]}"
    do
        echo "$i"
        tmux_session $i
    done
    tmux_list
    tmux_send powershell "powershell.exe -c pwsh.exe -nologo" C-m
    tmux_send alpine "wsl.exe -d WSLALPINEPROD01" C-m
    tmux_send debian "wsl.exe -d WSLDEBPROD01" C-m
    tmux_send gentoo "wsl.exe -d WSLGENTOOPROD01" C-m
    tmux_send ssh_tunnel "powershell.exe -c ssh_tunnel" C-m
    tmux_send scroll "powershell.exe -c scroll" C-m
    tmux_send rsync "powershell.exe -c rsync_git" C-m
    tmux_send vim "wsl.exe vim" C-m
}

function tmux_env {
    # ssh tunnel session created in crontab
    session_list=(firefox ide prod ssh_tunnel_vm wifi )
    for i in "${session_list[@]}"
    do
       echo "$i"
       tmux_session $i
    done
    tmux_send wifi "bash"
    tmux_send wifi "sudo wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp0s20f3; sudo dhclient -v wlp0s20f3"
    sleep 20
    tmux_send ssh_tunnel_vm "bash"
    # USER and DOMAIN environment variable required
    tmux_send ssh_tunnel_vm "source ~/.profile; sleep 3; vm_viewer_debian"
    tmux_send firefox "bash"
    # tmux_send firefox "sleep 3; export DISPLAY=:0; flatpak run org.mozilla.firefox"
    tmux_send ide "bash"
    # tmux_send ide "source ~/.profile; sleep 3; export DISPLAY=:0; flatpak run com.jetbrains.IntelliJ-IDEA-Community"
    tmux_send prod "bash"
}

function tmux_kill() {
    tmux kill-session -t $1
}

function tmux_list() {
    tmux ls
}

function tmux_send() {
    tmux send-keys -t $1 "$2" C-m
}

function tmux_session() {
    tmux new-session -dt $1
}

function tmux_split() {
    tmux new-session \; split-window -h \; split-window -v \; attach
}

function tmux_wsl() {
    pkill tmux
    session_list=(emerge powershell scroll ssh)
    for i in "${session_list[@]}"
    do
        echo "$i"
        tmux_session $i
    done
    tmux_list
    tmux_send powershell "source ~/.profile; powershell.exe -c pwsh.exe -nologo"
    tmux_send emerge "source ~/.profile; sudo emerge-webrsync"
    tmux_send ssh "source ~/.profile; powershell.exe -c ssh_tunnel"
    tmux_send scroll "source ~/.profile; powershell.exe -c scroll"
    tmux_session wsl
    tmux_send wsl "source ~/.profile; powershell.exe -c pwsh.exe -nologo"
}

function venv_create() {
    source_profile
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ -d "$FILE" ]  ; then
        echo "$FILE does exist. Renaming to venv_bkp"
        rsync -avP ~/.local/bin/venv/ ~/.local/bin/venv_bkp/
    fi
    python3 -m pip install --upgrade --user pip
    python3 -m venv venv
    venv_activate_source
    package_list=(pip setuptools wheel paramiko ansible pyspark)
    for i in "${package_list[@]}"
    do
         echo "$i"
         python3 -m pip install --upgrade $i
    done
}

function venv_activate() {
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ ! -d "$FILE" ]  ; then
        echo "$FILE does not exist. Creating venv."
        venv_create
    fi
    venv_activate_source
    cd -
}

function venv_activate_source {
    source ~/.local/bin/venv/bin/activate
}

function virsh_dhcp {
    sudo virsh net-dhcp-leases default
}

function virsh_import_debian() {
    virsh_list
    vm="KVMDEBTEST01_20230201.qcow2"
    sudo virt-install --name KVMDEBPROD01 --memory 2048 --vcpus 1 --disk ~/.local/state/kvm/$VM --import --os-variant debian11 --network default
}

function virsh_import_windows() {
    virsh_list
    vm="KVMDEBTEST01_20230201.qcow2"
    sudo virt-install --name KVMWINPROD01 --memory 16384 --vcpus 4 --disk ~/.local/state/kvm/$VM --import --os-variant debian11 --network default
}

function virsh_install_debian() {
    virsh_list
	sudo virt-install --name KVMDEBPROD01 --description 'debian' --ram 400 --vcpus 4 --disk path=/home/$USER/.local/state/KVMDEBPROD01_20230317.qcow2,size=90 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/debian-11.5.0-amd64-netinst.iso --graphics vnc,port=5901,listen=0.0.0.0 --noautoconsole
}

function virsh_install_debian_dev() {
    virsh_list
	sudo virt-install --name KVMDEBDEV01 --description 'debian' --ram 400 --vcpus 4 --disk path=/home/$USER/.local/state/KVMDEBDEV01_20230317.qcow2,size=90 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/debian-11.5.0-amd64-netinst.iso --graphics vnc,port=5902,listen=0.0.0.0 --noautoconsole
}

function virsh_install_windows() {
    virsh_list
    sudo virt-install --name KVMWINPROD01 --description 'Windows' --ram 8000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMWINPROD01_20230317.qcow2,size=120 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win10_21H2_English_x64.iso --graphics vnc,port=5903,listen=0.0.0.0 --noautoconsole
}

function virsh_install_windows_dev() {
    virsh_list
    sudo virt-install --name KVMWINDEV01 --description 'Windows' --ram 8000 --vcpus 4 --disk path=/home/$USER/.local/state/KVMWINDEV01_20230317.qcow2,size=120 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win10_21H2_English_x64.iso --graphics vnc,port=5904,listen=0.0.0.0 --noautoconsole
}

function virsh_install_windows11() {
    virsh_list
    vm="KVMWIN11TEST01_20230210.qcow2"
    vm_size=300
    sudo virt-install --name KVMWIN11TEST01 --description 'Windows' --ram 16384 --vcpus 4 --disk path=/home/$USER/.local/state/kvm/$VM,size=$VM_SIZE --os-variant win11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/Win11_22H2_English_x64v1.iso --video virtio --features kvm_hidden=on,smm=on --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.secboot.fd,loader_ro=yes,loader_type=pflash,nvram_template=/usr/share/edk2/ovmf/OVMF_VARS.secboot.fd --noautoconsole
}

function virsh_list() {
     sudo virsh list --all
}

function virsh_start_network() {
    virsh_list
    sudo virsh net-create ~/.local/share/docs/data/default.xml
	sudo virsh net-start default
}

function virsh_viewer_debian() {
    virsh_list
    VM="KVMDEBPROD01"
    ssh_prod "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

function virsh_viewer_windows() {
    virsh_list
    VM="KVMWINPROD02"
    ssh_dev "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

function vnc_all {
    remote-viewer --full-screen vnc://localhost:5911 &
    remote-viewer --full-screen vnc://localhost:5912 &
    remote-viewer --full-screen vnc://localhost:5913 &
    remote-viewer --full-screen vnc://localhost:5914 &
    remote-viewer --full-screen vnc://localhost:5915 &
    remote-viewer --full-screen vnc://localhost:5916 &
	remote-viewer --full-screen vnc://localhost:5917 &
	remote-viewer --full-screen vnc://localhost:5918 &
	remote-viewer --full-screen vnc://localhost:5919 &
	remote-viewer --full-screen vnc://localhost:5920 &
	remote-viewer --full-screen vnc://localhost:5921 &
}

function x_check_battery() {
    upower -i `upower -e | grep 'BAT'`
}

function x_secret() {
    tmux_kill secret
    tmux_session secret
    tmux_send secret "bash"
    tmux_send secret "source ~/.profile; ssh_dev"
    tmux_send secret "secret $1"
}

function x_stop_lockscreen() {
    xset -dpms
    xset s off
}

function main () {
    config
    neofetch
	source /etc/profile
}
main
# End profile
