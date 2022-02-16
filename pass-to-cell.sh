#!/bin/bash

# Autor: César Voginski <cesarvog@cesarvog.dev>
# Sends pass managed passwords to git with one more crypto layer with keybase crypto

#Params
key=F4F588AB77B45391C7248689A86892594EF0ECDD #GnuPG key id
kbid=cesarvoginski #Keybase username


# Being sure to link the real passwords (the pass managed)
unlink ~/.password-store
ln -s ~/.password-store-pc ~/.password-store

# Asking for password before it starts so you can take a cup of coffe while running
#WARN passwords are gpg(keybase(plain)) for integration with cell apps
#So all passwords are decrypt to keybase them
senha=$(pass eu/dev/bitbucket/pass)

#Remove all prior passwords sent to git
#That is no worries about moved passwords
rm -rf ~/.password-store-cell/*

#Copy all passwords to cell dir
rsync -av --exclude=".*" ~/.password-store/* ~/.password-store-cell/

#Crypto works begins
for f in $(find ~/.password-store/ -name *.gpg)
do
	dest_name=${f/password-store/password-store-cell} 
	echo "enviando para $dest_name"

	gpg --decrypt $f | keybase encrypt $kbid | gpg --encrypt -r $key > $dest_name
done


#Points pass dir to pass-store-cell now we can use pass git
unlink ~/.password-store
ln -s ~/.password-store-cell ~/.password-store

pass git add .
pass git commit -m "update"
echo "Git password $senha" #TODO make this optional
pass git push

#Put passwords like in intial state
unlink ~/.password-store
ln -s ~/.password-store-pc ~/.password-store
