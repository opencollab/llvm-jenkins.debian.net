sudo apt-get install jenkins  jenkins-debian-glue
install of the copy artifact jenkins plugin
visudo
ln -s /var/lib/jenkins/pbuilderrc .pbuilderrc
copy the key
on the slave, mount the fs

import the keys:
gpg --recv-keys AF4F7421

