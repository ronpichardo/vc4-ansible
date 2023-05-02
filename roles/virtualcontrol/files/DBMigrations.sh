#!/usr/bin/bash


if [ -f /etc/systemd/system/virtualcontrol.service ]
then
        install_path=`cat /etc/systemd/system/virtualcontrol.service | grep install_path | cut -f2 -d"="`
		service_name="virtualcontrol"
		pushd $install_path/virtualcontrol/migrations
		InstallType=`cat $install_path/virtualcontrol/data/vc4InstallationLog.txt  | grep InstallType | tail -1 | cut -f2 -d":"`
		bash ./migrations.sh $InstallType

elif [ -f /etc/systemd/system/xiocloudgateway.service ]
then
        install_path=`cat /etc/systemd/system/xiocloudgateway.service | grep install_path | cut -f2 -d"="`
		service_name="xiocloudgateway"
		pushd $install_path/virtualcontrol/migrations
		InstallType=`cat $install_path/virtualcontrol/data/vc4InstallationLog.txt  | grep InstallType | tail -1 | cut -f2 -d":"`
		bash ./migrations.sh $InstallType

fi

sleep 60

if systemctl start $service_name
then
        echo "Started App Watch Dog Service" >> /tmp/.vc4InstallationLog.txt
else
        echo "Failed to start App Watch Dog Service " >> /tmp/.vc4InstallationLog.txt

 exit
fi
