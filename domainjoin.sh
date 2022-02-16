#!/bin/bash

#switch as a root user
apt-get update
apt-get install vim -y
apt-get install clamtk -y

# Providing hostname to system here
echo "Enter the new hostname"
read hostname
hostnamectl set-hostname $hostname
echo "New hostname is $hostname"

#Adding entry in hosts file for zentyal
echo "192.168.4.2 idmspune.local" >>/etc/hosts

#Editing /etc/nsswitch.conf file
sed -i '11 i hosts:           files dns' /etc/nsswitch.conf

#Installing required packages
apt-get install winbind -y
apt-get install libpam-winbind -y
apt-get install libnss-winbind -y
apt-get install krb5-config -y

#Modifying /etc/samba/smb.conf file now
sed -i '/workgroup = WORKGROUP/d' /etc/samba/smb.conf
sed -i '28a workgroup = IDMSPUNE' /etc/samba/smb.conf
sed -i '29a password server = zentyal.idmspune.local' /etc/samba/smb.conf
sed -i '30a realm = IDMSPUNE.LOCAL' /etc/samba/smb.conf
sed -i '31a security = ads' /etc/samba/smb.conf
sed -i '32a idmap config * : range = 16777216-33554431' /etc/samba/smb.conf
sed -i '33a template homedir = /h/%U' /etc/samba/smb.conf
sed -i '34a template shell = /bin/bash' /etc/samba/smb.conf
sed -i '35a winbind use default domain = true' /etc/samba/smb.conf
sed -i '36a winbind offline logon = true' /etc/samba/smb.conf


#Modifying /etc/nsswitch.conf file
sed -i '/passwd/d' /etc/nsswitch.conf
sed -i '/group/d' /etc/nsswitch.conf
sed -i '/shadow/d' /etc/nsswitch.conf
sed -i '6a passwd:          compat winbind' /etc/nsswitch.conf
sed -i '7a group:           compat winbind' /etc/nsswitch.conf
sed -i '8a shadow:          compat winbind' /etc/nsswitch.conf

#Making home directory
mkdir /home
#Making changes in config file so that home directory will be autocreated
sed -i '$ a  session optional        pam_mkhomedir.so skel=/etc/skel umask=077' /etc/pam.d/common-session

# installing additional packages
apt-get install samba-dsdb-modules -y
apt-get install samba-vfs-modules -y

#Now joining Domain
echo "Enter the domain admin user"
read username
net ads join -U $username

# Disable media access
chmod 000 /media

#Adding standard user
echo "Enter the username you want to add as standard user"
read username
useradd $username
echo "Enter the password for $username"
passwd $username

