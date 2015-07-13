###
# BASICS
###

HOME_DIR=$1

cd $HOME_DIR

# Update
apt-get -y update && apt-get -y upgrade

# SSH
apt-get -y install openssh-server

# Build tools
apt-get -y install build-essential

# Git vim
apt-get -y install git vim

# Java
# apt-get -y install openjdk-7-jdk
## There is no Java8 OpenJDK right now in the Ubuntu repos
## http://askubuntu.com/questions/464755/how-to-install-openjdk-8-on-14-04-lts
## We'll use Oracle Java8 for now.

# Java (Oracle)
sudo apt-get install -y software-properties-common
sudo apt-get install -y python-software-properties
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get install -y oracle-java8-installer
sudo update-java-alternatives -s java-8-oracle
sudo apt-get install -y oracle-java8-set-default
export JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Maven
apt-get -y install maven

# Tomcat
apt-get -y install tomcat7 tomcat7-admin
usermod -a -G tomcat7 vagrant
sed -i '$i<user username="islandora" password="islandora" roles="manager-gui"/>' /etc/tomcat7/tomcat-users.xml

# Make the ingest directory
mkdir /mnt/ingest
chown -R tomcat7:tomcat7 /mnt/ingest

# Wget and curl
apt-get -y install wget curl

# More helpful packages
apt-get -y install htop tree zsh fish

# Set some params so it's non-interactive for the lamp-server install
debconf-set-selections <<< 'mysql-server mysql-server/root_password password islandora'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password islandora'
debconf-set-selections <<< "postfix postfix/mailname string islandora-fedora4.org"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"

# Lamp server
tasksel install lamp-server
usermod -a -G www-data vagrant

# Get the repo
git clone -b 7.x-2.x https://github.com/Islandora-Labs/islandora.git
chown -R vagrant:vagrant islandora

# Set JAVA_HOME -- Java8 set-default does not seem to do this.
sed -i 's|#JAVA_HOME=/usr/lib/jvm/openjdk-6-jdk|JAVA_HOME=/usr/lib/jvm/java-8-oracle|g' /etc/default/tomcat7
