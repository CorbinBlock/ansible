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

function apk_setup() {
    mkdir -p ~/.local/bin/
    apk_upgrade
    package_list=( bash docker docker-compose dos2unix flatpak git git-lfs keepassxc nano neofetch openssh openrc python3 py3-pip sudo tmux vim tree lynx openjdk17 xfce4 xfce4-terminal xfce4-screensaver lightdm-gtk-greeter dbus pipewire wireplumber nmap rust go)
    for i in "${package_list[@]}"
    do
        echo "$i"
        sudo apk add $i
    done
    apk_upgrade
    sudo rc-update add docker
    sudo service docker start
    sudo docker run --rm hello-world
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,flatpak,kvm,libvirt,wheel $USER
}

function apk_setup_ish() {
    mkdir -p ~/.local/bin/
    apk_upgrade_ish
    package_list=( bash dos2unix git git-lfs i3lock i3lock-doc i3status i3status-doc i3wm i3wm-doc lynx nano neofetch nmap openrc openssh python3 py3-pip rsync sqlite sshfs sudo tmux tree ttf-dejavu vim x11vnc x11vnc-doc xdpyinfo xdpyinfo-doc xf86-video-dummy xorg-server xterm xvfb)
    for i in "${package_list[@]}"
    do
        echo $i
        sudo apk add $i
    done
    sudo rc-update add sshd
    /usr/sbin/sshd
}

function apk_upgrade() {
    source_profile
    venv_create
    git_update_all
    sudo apk -U upgrade
}

function apk_upgrade_ish() {
    source_profile_nogit
    sudo apk -U upgrade
}

function apt_install () {
    sudo apt-get install "$1"
}

function apt_setup() {
    package_list=(dos2unix git python3)
    for i in "${package_list[@]}"
    do
        echo "$i"
        apt_install $i
    done
    mkdir -p ~/.local/bin/
    apt_upgrade
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
     file=/etc/pipewire/media-session.d/with-pulseaudio
     if [ ! -f $file ]; then
     echo "$file not found!"
     sudo su $USER -c "sudo touch $file"
     sudo su $USER -c "sudo cp /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* /etc/systemd/user/"
     sudo su $USER -c "systemctl --user daemon-reload"
     sudo su $USER -c "systemctl --user --now disable pulseaudio.service pulseaudio.socket"
     sudo su $USER -c "systemctl --user --now enable pipewire pipewire-pulse"
     fi
}

function apt_setup_all {
    node_list=(kvm_debian_test dev localhost prod dell lenovo acer)
    for i in "${node_list[@]}"
    do
        echo "$i"
        ssh_$i "source ~/.profile; apt_setup"
    done
}

function apt_upgrade() {
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

function git_pull() {
    x_secret git
    pwd
    git pull --no-rebase
}

function git_push_ansible() {
    cd ~/.local/share/dev/ansible/
    x_secret git
    git add --all
    git add *
    git commit -m "+"
    pwd
    git push
    source_profile
    rsync_git_dev_push
    ssh_prod "source ~/.profile; source_profile; ssh -p 2222 iphone 'source ~/.profile; apk_setup_ish'"
}

function git_push() {
    x_secret git
    git add --all
    git add *
    git commit -m "+"
    pwd
    git push
}

function git_push_docs() {
    x_secret git
    cd $DOCS_DIR
	git add --all
	git add all*
	git add be*
	git add data*
	git add python*
	git add linux*
	git add db*
	git commit -m "+"
	git push
}

function report() {
    source ~/.profile
    clear
    neofetch
    date
    tmux_list
    sudo docker ps
    df -BG
}

function rsync_git_prod {
    rsync -avP prod:~/.local/share/docs/ ~/.local/share/docs/
}

function rsync_git_dev {
    rsync -avP prod:~/.local/share/dev/ ~/.local/share/dev/
}

function rsync_git_dev_push {
    rsync -avP ~/.local/share/dev/ prod:~/.local/share/dev/
}

function rsync_git_ish {
    ssh 10.83.1.111 "source ~/.profile; source_profile"
    rsync -avP 10.83.1.111:~/.local/share/docs/ ~/.local/share/docs/
    rsync -avP 10.83.1.111:~/.local/bin/ansible/ ~/.local/bin/ansible/
    rsync -avP 10.83.1.111:~/.profile ~/.profile
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
    rsync_git_ish
	source ~/.profile
}

function ssh_acer() {
    ssh_all acer "$1"
}

function ssh_all() {
    port=22
    if ssh_helper "$port" "$1" "$2" ; then
        echo "Connection succeeded"
    elif
        echo "Connection failed, retrying."
        port=2222
        ssh_helper "$port" "$1" "$2"
    else
        echo "Connection failed, retrying."
        port=3333
        ssh_helper "$port" "$1" "$2"
    fi
}

function ssh_helper() {
    ssh -p $1 -X $2 "$3"
}

function ssh_terminal() {
    ssh_prod "ssh -tt $1 '$2'"
}

function ssh_create() {
    ssh-keygen -t ed25519 -b 4096
}

function ssh_dell() {
    ssh_all dell "$1"
}

function ssh_dev() {
    ssh_all dev "$1"
}

function ssh_kvm_debian_prod() {
    ssh_terminal KVMDEBPROD01 "$1"
}

function ssh_kvm_debian_test() {
    ssh_terminal KVMDEBTEST01 "$1"
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
    ssh_all prod "$1"
}

function ssh_tunnel() {
    ssh -p 50100 -L 3390:KVM_WIN:3389 -L 5902:PROD:5902 -L 8081:KVM_DEB_TEST:8080 -L 9091:KVM_DEB_TEST:9090 $USER@$DOMAIN
}

function tmux_attach() {
    tmux attach -t $1
}

function tmux_env {
    # ssh tunnel session created in crontab
    session_list=(firefox ide prod wifi )
    for i in "${session_list[@]}"
    do
       echo "$i"
       tmux_session $i
    done
    tmux_send wifi "bash"
    tmux_send wifi "sudo wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp0s20f3; sudo dhclient -v wlp0s20f3"
    sleep 20
    tmux_send ssh_tunnel "bash"
    # USER and DOMAIN environment variable required
    tmux_send ssh_tunnel "source ~/.profile; sleep 10; ssh_tunnel"
    tmux_send firefox "bash"
    tmux_send firefox "sleep 5; export DISPLAY=:0; flatpak run org.mozilla.firefox"
    tmux_send ide "bash"
    tmux_send ide "source ~/.profile; sleep 5; export DISPLAY=:0; flatpak run com.jetbrains.IntelliJ-IDEA-Community"
    tmux_send prod "bash"
    tmux_send prod "sleep 100; ssh -p 50100 \$DOMAIN"
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
    session_list=(emerge htop prod powershell prod scroll ssh vim)
    for i in "${session_list[@]}"
    do
        echo "$i"
        tmux_session $i
    done
    tmux_list
    tmux_send powershell "source ~/.profile; powershell.exe -c pwsh.exe -nologo"
    tmux_send powershell "secret ad"
    tmux_send emerge "source ~/.profile; sudo emerge-webrsync"
    tmux_send htop "source ~/.profile; htop"
    tmux_send prod "source ~/.profile; powershell.exe -c prod"
    tmux_send ssh "source ~/.profile; powershell.exe -c ssh_tunnel"
    tmux_send scroll "source ~/.profile; powershell.exe -c scroll"
    tmux_send vim "source ~/.profile; vim"
}

function venv_create() {
    source_profile
    cd ~/.local/bin/
    FILE=~/.local/bin/venv/
    if [ -d "$FILE" ]  ; then
        echo "$FILE does exist. Renaming to venv_bkp"
        mv ~/.local/bin/venv/ ~/.local/bin/venv_bkp/
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

function vm_import_debian() {
    vm_list
    vm="KVMDEBTEST01_20230201.qcow2"
    sudo virt-install --name KVMDEBPROD01 --memory 2048 --vcpus 1 --disk ~/.local/state/kvm/$VM --import --os-variant debian11 --network default
}

function vm_import_windows() {
    vm_list
    vm="KVMDEBTEST01_20230201.qcow2"
    sudo virt-install --name KVMWINPROD01 --memory 16384 --vcpus 4 --disk ~/.local/state/kvm/$VM --import --os-variant debian11 --network default
}

function vm_install_debian() {
    vm_list
    vm="KVMDEBTEST01_20230201.qcow2"
    vm_size=120
    sudo virt-install --name KVMDEBPROD01 --description 'debian' --ram 4096 --vcpus 1 --disk path=/home/$USER/.local/state/kvm/$VM,size=$VM_SIZE --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/kvm/debian-11.5.0-amd64-netinst.iso --noautoconsole
}

function vm_install_windows() {
    vm_list
    vm="KVMWINTEST01_20230119.qcow2"
    vm_size=300
    sudo virt-install --name KVMWINPROD01 --description 'Windows' --ram 16384 --vcpus 4 --disk path=/home/$USER/.local/state/kvm/$VM,size=$VM_SIZE --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/kvm/Win10_21H2_English_x64.iso --noautoconsole
}

function vm_list() {
     sudo virsh list --all
}

function vm_shutdown() {
    vm_list
    session_list=(KVMALPINEPROD01 KVMDEBPROD01 KVMFEDPROD01 KVMWINPROD01 KVMWINTEST01)
    for i in "${session_list[@]}"
    do
        echo "$i"
        sudo virsh shutdown $i
    done
	sudo chown cblock ~/.local/state/kvm/*
}

function vm_start {
    vm_list
    session_list=(KVMALPINEPROD01 KVMDEBTEST01 KVMFEDPROD01 KVMWINTEST01)
    for i in "${session_list[@]}"
    do
        echo "$i"
        sudo virsh start $i
    done
}

function vm_start_debian() {
    vm_list
    sudo virsh start KVMDEBPROD01
}

function vm_start_network() {
    vm_list
    sudo virsh net-create ~/.local/share/docs/data/default.xml
	sudo virsh net-start default
}

function vm_start_windows() {
    vm_list
	sudo virsh start KVMWINPROD01
}

function vm_viewer_debian() {
    vm_list
	VM="KVMDEBTEST01"
	ssh_prod "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

function vm_viewer_windows() {
    vm_list
	VM="KVMWINTEST01"
    ssh_prod "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
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

# Purpose: Call functions

function main () {
    config
    # neofetch
}
main
# End profile