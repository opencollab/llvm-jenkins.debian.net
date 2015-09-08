cd /opt
VERSION=7.5.0
rm -rf cov-analysis
tar zxvf cov-analysis-linux64-$VERSION.tar.gz
mv cov-analysis-linux64-$VERSION cov-analysis
chown -R root. cov-analysis
find cov-analysis/ -type d -exec chmod 777 {} \;
find cov-analysis/ -type f -exec chmod og+w {} \;
