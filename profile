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
    # GIT_USER=X
    # GIT_EMAIL=X
    apk_upgrade
    sudo apk update
    sudo apk add bash docker docker-compose dos2unix flatpak git git-lfs keepassxc nano
    sudo rc-update add docker
    sudo service docker start
    docker version
    # git config --global user.name $GIT_USER
    # git config --global user.email $GIT_EMAIL
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo apk add neofetch openssh python3 py3-pip sudo tmux
    sudo apk add vim tree lynx openjdk17 xfce4 xfce4-terminal
    sudo apk add xfce4-screensaver lightdm-gtk-greeter dbus
    sudo apk add pipewire wireplumber nmap rust go
    sudo adduser $USER --shell /bin/bash
    sudo usermod -G docker,flatpak,kvm,libvirt,wheel $USER
}

function apk_upgrade() {
    source_profile
    venv_create
    sudo apk -U upgrade
}

function apk_upgrade_ish() {
    source_profile_nogit
    # venv_create
    sudo apk -U upgrade
}

function apt_upgrade() {
    sudo apt-get update
	sudo apt-get --with-new-pkgs upgrade -y
	sudo apt-get autoremove -y
	source_profile
	venv_create
	ansible-playbook ~/.local/share/docs/python/ansible/apt_all.yml
}

function apt_upgrade_wsl() {
    sudo apt-get update
	sudo apt-get --with-new-pkgs upgrade -y
	sudo apt-get autoremove -y
	source_profile
	venv_create
	ansible-playbook ~/.local/share/docs/python/ansible/apt_all.yml
}

function config() {
    # USER=X
    # DOMAIN_URL=X
    SEARCH_URL=duckduckgo.com
    JAVA_WIN=/c/Users/$USER/.local/share/docs/java/bin/
    JAVA_LINUX=/home/$USER/.local/share/docs/java/bin/
    export DEBIAN_FRONTEND=noninteractive
    export DOCS_DIR=~/.local/share/docs
    export EDITOR=/usr/bin/vim
    export PAGER=/usr/bin/less
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
    # sudo dnf upgrade --skipbroken --allowerasing --nobest -y
}

function emerge_setup {
    # USER=cblock
    # GIT_USER=X
    # GIT_EMAIL=X
    sudo eselect profile set default/linux/amd64/17.1/desktop
    sudo emerge app-admin/sudo
    sudo emerge-webrsync
    sudo emerge --verbose --update --deep --newuse @world
    sudo emerge --depclean
    sudo emerge app-admin/keepassxc
    sudo emerge app-containers/docker
    sudo emerge app-containers/docker-compose
    sudo emerge app-editors/vim
    sudo emerge app-emulation/libvirt
    sudo emerge app-emulation/qemu
    sudo emerge app-emulation/virt-viewer
    sudo emerge app-misc/jq
    sudo emerge app-misc/neofetch
    sudo emerge app-misc/tmux
    sudo emerge app-text/dos2unix
    sudo emerge app-text/tree
    sudo emerge dev-java/openjdk
    sudo emerge dev-java/maven-bin
    sudo emerge dev-python/pip
    sudo emerge dev-vcs/git
     # git config --global user.name $GIT_USER
     # git config --global user.email $GIT_EMAIL
     sudo emerge net-analyzer/nmap
     sudo emerge net-misc/rsync
     sudo emerge sys-apps/dmidecode
     sudo emerge sys-apps/flatpak
     sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || exit 0
     sudo emerge sys-apps/lshw
     # sudo emerge net-vpn/openvpn
     # sudo emerge app-admin/terraform
     sudo emerge sys-devel/distcc
     sudo emerge virtual/cron
     sudo emerge www-client/lynx
     sudo emerge x11-misc/xclip
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
}

function git_update_all() {
    rsync_git_dev
    rsync_git_prod
}

function git_pull() {
    secret git
    pwd
    git pull --no-rebase
}

function git_push() {
    secret git
    git add --all
    git add *
    git commit -m "+"
    pwd
    git push
}

function gpl() {
    secret git
    cd $DOCS_DIR
    git pull --no-rebase
    pwd
}

function gpu() {
    secret git
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
    tmux ls
    sudo docker ps
    df -BG
}

function rsync_git_prod {
    rsync -avP prod:~/.local/share/docs/ ~/.local/share/docs/
}

function rsync_git_dev {
    rsync -avP prod:~/.local/share/dev/ ~/.local/share/dev/
}

function rsync_git_win {
    rsync -avP prod:~/.local/share/docs/ /c/Users/$USER/.local/share/docs/
}

function rsync_nas_two {
   ssh dev "rsync --archive --inplace --partial --progress --verbose ~/.local/share/hdd/* ~/.local/share/hdd_two/"
}

function rsync_vm_prod {
   ssh prod "rsync --archive --inplace --partial --progress --verbose ~/.local/state/kvm/* dev:~/.local/share/hdd/kvm/"
}

function secret() {
    secret_path=$1
    database=$XDG_DATA_HOME/docs/data/secrets.kdbx
    key_file=$XDG_DATA_HOME/docs/data/secrets.keyx
    password=$XDG_CONFIG_HOME/keepassxc/.keepassxc.txt
    # command="cat $password | keepassxc-cli show -sa password -k $key_file $database $secret_path | clip.exe"
    command="cat $password | keepassxc-cli show -sa password -k $key_file $database $secret_path | set_clipboard"
    eval $command
}


function source_profile() {
    cd $XDG_STATE_HOME
    rm -rf ansible
    git clone https://github.com/CorbinBlock/ansible.git
    sudo cp ~/.local/bin/ansible/profile ~/.profile
	dos2unix ~/.profile
	source ~/.profile
}

function source_profile_nogit() {
    # cd $XDG_STATE_HOME
    # rm -rf ansible
    # git clone https://github.com/CorbinBlock/ansible.git
    sudo cp ~/.local/bin/ansible/profile ~/.profile
	dos2unix ~/.profile
	source ~/.profile
}

function ssh_tunnel() {
    ssh -p 50100 -L 3390:KVM_WIN:3389 -L 5902:PROD:5902 -L 8081:KVM_DEB_TEST:8080 -L 9091:KVM_DEB_TEST:9090 $USER@$DOMAIN
}

function stop_lockscreen() {
    xset -dpms
	xset s off
}

function tmux_attach() {
    tmux attach -t $1
}

function tmux_env {
    session_list=(firefox ide prod ssh_tunnel wifi )
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

function tmux_send() {
    tmux send-keys -t $1 "$2" C-m
}

function tmux_session() {
    tmux new-session -dt $1
}

function tmux_wsl() {
    pkill tmux
    tmux new-session -dt emerge
    tmux new-session -dt powershell
    tmux new-session -dt htop
    tmux new-session -dt scroll
    tmux new-session -dt ssh
    tmux new-session -dt prod
    tmux new-session -dt vim
    tmux ls
    tmux send-keys -t powershell "source ~/.profile; powershell.exe -c pwsh.exe -nologo" C-m
    tmux send-keys -t powershell "secret ad" C-m
    tmux send-keys -t emerge "source ~/.profile; sudo emerge-webrsync" C-m
    tmux send-keys -t htop "source ~/.profile; htop" C-m
    tmux send-keys -t prod "source ~/.profile; powershell.exe -c prod" C-m
    tmux send-keys -t ssh "source ~/.profile; powershell.exe -c ssh_tunnel" C-m
    tmux send-keys -t scroll "source ~/.profile; powershell.exe -c scroll" C-m
    tmux send-keys -t vim "source ~/.profile; vim" C-m
}


function tmux_split() {
    tmux new-session \; split-window -h \; split-window -v \; attach
}

function venv_create() {
    source_profile
    rm -rf venv/
    python3 -m pip install --upgrade --user pip
    python3 -m venv venv
    venv_activate
    python3 -m pip install --upgrade pip
    python3 -m pip install --upgrade setuptools
    python3 -m pip install --upgrade wheel
    python3 -m pip install --upgrade paramiko
    python3 -m pip install --upgrade ansible
    python3 -m pip install --upgrade pyspark
}

function venv_activate() {
    cd ~/.local/bin/
    source venv/bin/activate
    cd -
}

function vm_import_debian() {
    sudo virt-install --name KVMDEBPROD01 --memory 2048 --vcpus 1 --disk ~/.local/state/kvm/debian-11.5.0-amd64-netinst_20221029.qcow2 --import --os-variant debian11 --network default
}

function vm_import_windows() {
    sudo virt-install --name KVMWINPROD01 --memory 16384 --vcpus 4 --disk ~/.local/state/kvm/Win10_21H2_English_x64_20221112.qcow2 --import --os-variant debian11 --network default
}

function vm_install_debian() {
    vm_list
    sudo virt-install --name KVMDEBPROD01 --description 'debian' --ram 2048 --vcpus 1 --disk path=/home/$USER/.local/state/kvm/debian-11.5.0-amd64-netinst_20221112.qcow2,size=120 --os-variant debian11 --network bridge=virbr0 --cdrom /home/$USER/.local/state/kvm/debian-11.5.0-amd64-netinst.iso --noautoconsole
}

function vm_install_windows() {
    vm_list
    sudo virt-install --name KVMWINPROD01 --description 'Windows' --ram 16384 --vcpus 4 --disk path=/home/$USER/.local/state/kvm/Win10_21H2_English_x64_20221112.qcow2,size=300 --os-variant win10 --network bridge=virbr0 --cdrom /home/$USER/.local/state/kvm/Win10_21H2_English_x64.iso --noautoconsole
}

function vm_list() {
     sudo virsh list --all
}

function vm_shutdown() {
    vm_list
    sudo virsh shutdown KVMALPINEPROD01
	sudo virsh shutdown KVMDEBPROD01
	# sudo virsh shutdown KVMDEBTEST01
	sudo virsh shutdown KVMFEDPROD01
	sudo virsh shutdown KVMWINPROD01
	sudo virsh shutdown KVMWINTEST01
	sudo chown cblock ~/.local/state/kvm/*
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
	VM="KVMDEBPROD01"
	ssh -X prod "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"
}

function vm_viewer_windows() {
    vm_list
	VM="KVMWINTEST01"
    ssh -X prod "source ~/.profile; sudo virt-viewer --connect qemu:///system $VM"

}


# Purpose: Call functions

config
neofetch

if [ "$#" -eq 1 ] ; then
        secret $1
fi
