# __________CONFIGURE THESE VARS______________
# P4TARGET MUST be set. All others are optional.
P4TARGET="ssl:<address-of-parent-master-or-edge>:1666" # the master server (or edge) that this will be a proxy for

P4PNAME="p4proxy" # The name for the proxy service in p4dctl
P4PCACHE=/opt/perforce/servers/p4proxy # local directory to store the cache
P4PORT=1666 # The port to open on the proxy that users will connect to
#---------------------------------------------

# Setup Perforce Depots and Install Proxy and CLI
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    
    if [[ $OS =~ "buntu" ]]; then
        VER=$VERSION_CODENAME
        wget -qO - https://package.perforce.com/perforce.pubkey | sudo apt-key add -
        echo "deb http://package.perforce.com/apt/ubuntu $VER release" > /etc/apt/sources.list.d/perforce.list
        apt-get update
        apt-get install -y helix-cli helix-proxy
    elif [[ $OS =~ "ent" ]]; then
        VER=$VERSION_ID
        sudo rpm --import https://package.perforce.com/perforce.pubkey
        echo -e "[perforce]\nname=Perforce\nbaseurl=http://package.perforce.com/yum/rhel/$VERSION_ID/x86_64\nenabled=1\ngpgcheck=1" > /etc/yum.repos.d/perforce.repo
        sudo yum install -y helix-cli helix-proxy
    fi
else
    echo "Can't auto-detect version. Follow the instructions at https://www.perforce.com/manuals/p4sag/Content/P4SAG/install.linux.packages.install.html"
fi

# Make our server directory
mkdir -p $P4PCACHE
chown perforce:perforce $P4PCACHE

# Make our config file for p4dctl
sudo cat > /etc/perforce/p4dctl.conf.d/p4p.conf <<- EOF
# Config File for p4proxy

p4p $P4PNAME
{
    Owner       =       perforce
    Execute     =       /usr/sbin/p4p
    Umask       =       077

    Environment
    {
        P4PCACHE=$P4PCACHE
        P4TARGET=$P4TARGET
        P4PORT=$P4PORT
        PATH=/bin:/usr/bin:/usr/local/bin
    }
}
EOF

# Need to establish trust 
if [[ $P4TARGET =~ 'ssl:' ]]; then
    echo "Establishing trust with 'p4 -p $P4TARGET trust -y'"
    runuser -l perforce -c "p4 -p $P4TARGET trust -y"
fi

p4dctl start $P4PNAME

IPV4=$(ip addr | awk '{sub(/\/[0-9]+/,"") };/inet .+global/ {print $2}')

echo -e "Proxy Service Name: $P4PNAME
The p4dctl utility is used to start and stop p4 services.
p4dctl status $P4PNAME
p4dctl start $P4PNAME
p4dctl stop $P4PNAME

Your local IP address is $IPV4
From the same LAN, try connecting to this proxy server with at $IPV4:$P4PORT"
