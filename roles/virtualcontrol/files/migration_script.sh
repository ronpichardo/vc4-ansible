#!/bin/sh
migration_script_version="1.0.2"
scriptPath=`pwd`
echo "Migration Process Initiated"
rm -rf /tmp/VC_Migration_Backup* 

if [ -z $1 ]
then
	echo "Password Parameter Is Empty!!!"
	echo "Usage: sh migration_script.sh zip_password"
	exit
fi
now=$(date +"%m%d%Y_%H%M%S")
zipName="VC_Migration_Backup_"$now"_v"$migration_script_version".zip"
password_len=`echo $1 | wc -c`
if [ $password_len -gt 25 ]
then
	echo "Password Should be less than 25 characters!!!"
	exit
fi

defaultVirtualControlPath="/opt/crestron"
flag="False"
while [ "$flag" = "False" ]
do
	if [ -f /etc/systemd/system/virtualcontrol.service ]
	then
		virtualControlPath=`grep "ExecStart" /etc/systemd/system/virtualcontrol.service | cut -f2 -d "=" | cut -f1 -d"v" | tail -1`
		echo "Virtual Control Path: "$virtualControlPath
	else
		echo "Virtual Control Path Not Found"
		read -p "Enter the path where Virtual Control is installed. Default is (/opt/crestron):  " virtualControlPath
		[ -z "$virtualControlPath" ] && virtualControlPath="$defaultVirtualControlPath"
	fi
	if [ -f $virtualControlPath/virtualcontrol/conf/database_connect.cfg ]
	then
		flag="True"
		mkdir /tmp/VC_Migration_Backup
		echo "Copying Configuration and data files "
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/conf/database_connect.cfg /tmp/VC_Migration_Backup/.
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/conf/device_resolution.cfg /tmp/VC_Migration_Backup/.
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/conf/FlashPolicyServer.conf /tmp/VC_Migration_Backup/.
		rsync -azh --ignore-missing-args --progress --exclude ssl $virtualControlPath/virtualcontrol/data /tmp/VC_Migration_Backup/
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/ProgramLibrary /tmp/VC_Migration_Backup/
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/samples /tmp/VC_Migration_Backup/
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/RunningPrograms /tmp/VC_Migration_Backup/
		mkdir /tmp/VC_Migration_Backup/migrations
		rsync -azh --ignore-missing-args --progress $virtualControlPath/virtualcontrol/migrations/alembic /tmp/VC_Migration_Backup/migrations
		rsync -azh --ignore-missing-args --progress /etc/rsyslog.d/50-default.conf /tmp/VC_Migration_Backup/.
		rsync -azh --ignore-missing-args --progress /etc/rsyslog.d/49-default.conf /tmp/VC_Migration_Backup/.
		rsync -azh --ignore-missing-args --progress /etc/rsyslog.d/keys/ca.d /tmp/VC_Migration_Backup/
		. $virtualControlPath/virtualcontrol/conf/database_connect.cfg
		os=`cat /proc/version |  grep "bos.redhat.com" | cut -f1 -d" "`
		if [ -z $os ] 
		then 
			echo "Operating System : Linux"
			redisPort="6379"
		else	
			os="RHEL"
			echo "Operating System : Red Hat"
			redisPort=`grep REDIS $virtualControlPath/virtualcontrol/conf/env_variables.cfg | cut -f2 -d "="`
		fi

		cd $virtualControlPath/virtualcontrol/CrestronApps/bin
		source ../../conf/env_variables.cfg
		./reg EXPORT HKLM/crestron/start/LogicEngine /tmp/VC_Migration_Backup/logicengine.reg

		cd /tmp/VC_Migration_Backup/
		mkdir global_dump
		count=`redis-cli -p $redisPort llen SIMPLGLOBAL`; 
		echo "count is $count"; 
		for each in $( redis-cli -p $redisPort lrange SIMPLGLOBAL 0 $count ); do result=$(redis-cli -p $redisPort --raw dump $each | head -c -1 > global_dump/$each ); done;
		
		cd /tmp/VC_Migration_Backup/
		mkdir local_dump
		
		count=`redis-cli -p $redisPort llen SIMPLLOCAL`; 
		echo "count is $count"; 
		for each in $( redis-cli -p $redisPort lrange SIMPLLOCAL 0 $count ); do result=$(redis-cli -p $redisPort --raw dump $each | head -c -1 > local_dump/$each ); done;
		
		cd -
		sudo mysqldump --user=$DB_USER --password=$DB_PASSWORD --databases  $DB_NAME  --no-data >  /tmp/VC_Migration_Backup/all_databases.sql
		sudo mysqldump --user=$DB_USER --password=$DB_PASSWORD --databases  $DB_NAME  --ignore-table=$DB_NAME.LicenseRegistry --ignore-table=$DB_NAME.DeviceInfo  --no-create-info >> /tmp/VC_Migration_Backup/all_databases.sql
		
		echo "Created Maria DB Backup"
		cd /tmp/
		zip  --symlinks -r  VC_Migration_Backup.zip VC_Migration_Backup
	#	zip  -r  VC_Migration_Backup.zip VC_Migration_Backup
		zip  -eqr -P $1 $scriptPath/$zipName VC_Migration_Backup.zip
		rm -rf /tmp/VC_Migration_Backup
		echo "Migration Backup ($scriptPath/$zipName) created Successfully"
	else
		echo "Virtual Control not found in $virtualControlPath  !!!"
	fi
	
done
