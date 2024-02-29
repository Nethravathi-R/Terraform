#!/bin/bash
    apt update
    sleep 5
    sudo apt install default-jre -y
    cd "/opt/"
    wget  https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.19/bin/apache-tomcat-10.1.19.tar.gz               
    tarfile=$(ls -rt /opt/ | grep "tar.gz")
    tar -xvzf $tarfile
    apache=$(echo "$tarfile" | sed 's/.tar.gz//g')
    sed -i 's/8080/8082/g' /opt/$apache/conf/server.xml
    sed -i  '21s/^/<!--/g' "/opt/$apache/webapps/host-manager/META-INF/context.xml"
    sed -i  '22s/$/-->/g' "/opt/$apache/webapps/host-manager/META-INF/context.xml"
    sed -i  '21s/^/<!--/g' "/opt/$apache/webapps/manager/META-INF/context.xml"
    sed -i  '22s/$/-->/g' "/opt/$apache/webapps/manager/META-INF/context.xml"
    sed -i -e '55 a\<role rolename="manager-gui" /> \n<user username="tarun" password="99490" roles="manager-gui" /> \n<!-- user admin can access manager and admin section both --> \n<role rolename="admin-gui" /> \n<user username="tarun" password="99490" roles="manager-gui, admin-gui" />' "/opt/$apache/conf/tomcat-users.xml"
    cd "/opt/$apache/bin/"
    /opt/$apache/bin/shutdown.sh
    /opt/$apache/bin/startup.sh
    echo "use instance pub ip:8082 to check the tomcat server"
    /opt/$apache/bin/shutdown.sh
    sleep 10
    /opt/$apache/bin/startup.sh 
