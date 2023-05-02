#!/bin/bash
#set -x
set -e

if [ -f /etc/systemd/system/virtualcontrol.service ] 
then 	
	install_path=`cat /etc/systemd/system/virtualcontrol.service | grep install_path | cut -f2 -d"="`
	old_service_file="virtualcontrol.service" 
	product_name="Virtual Control"
	echo "Product : "$product_name
elif [ -f /etc/systemd/system/xiocloudgateway.service ] 
then 	
	install_path=`cat /etc/systemd/system/xiocloudgateway.service | grep install_path | cut -f2 -d"="`
	old_service_file="xiocloudgateway.service" 
	product_name="XiO Cloud Gateway"
	echo "Product : "$product_name
else
	echo "VirtualControl not found!!!"
	exit
fi


if systemctl stop $old_service_file
then
	echo "Stopping $old_service_file : Pass "
else
	echo "Stopping $old_service_file : Fail"
	exit
fi

valid_db_config_found=''
if [ -f "$install_path/virtualcontrol/conf/database_connect.cfg" ]
then
	. $install_path/virtualcontrol/conf/database_connect.cfg
	export valid_db_config_found=yes		
	mysqlshow  --user=$DB_USER --password="$DB_PASSWORD" $DB_NAME >/dev/null 2>&1 || export valid_db_config_found=no 
fi	 

if [ "$valid_db_config_found" = yes ]
then
	echo "Mysql DB Login Verification: Pass"
else
	echo "Mysql DB Login Verification: Fail"
	exit
fi

ProgramLibraryCount=`mysql -u$DB_USER --password="$DB_PASSWORD" -e "use VirtualControl;select id from ProgramLibrary where ProgramType = 'SIMPL Windows' ;" |wc -l`
if [ $ProgramLibraryCount -eq 0 ]
then
	echo "ProgramLibrary with Program Type SIMPL Windows Not Found..."
	exit
else
	echo "ProgramLibrary with Program Type SIMPL Windows Count : "$ProgramLibraryCount
	
fi

if mysql -u$DB_USER --password="$DB_PASSWORD" -e "use VirtualControl;select id from ProgramLibrary where ProgramType = 'SIMPL Windows' ;" > /tmp/output.txt 
then
	echo "Found Below ProgramLibrary with Program Type SIMPL Windows"
	cat /tmp/output.txt 
else
	echo "Error Finding ProgramLibrary with Program Type SIMPL Windows"
	exit
fi
tail -n 1 /tmp/output.txt > /tmp/program_library_id.txt

if cat /tmp/program_library_id.txt | xargs -I {}  mysql -u$DB_USER --password="$DB_PASSWORD" -e "use VirtualControl;select id from ProgramInstance where program_library_id = '{}' ;"  > /tmp/program_instance_id.txt
then
	echo "Found Below ProgramInstance with Program Type SIMPL Windows"
	cat /tmp/program_instance_id.txt 
else
	echo "Error Finding ProgramInstance with Program Type SIMPL Windows"
	exit
fi

if cat /tmp/program_library_id.txt | xargs -I {}  mysql -u$DB_USER --password="$DB_PASSWORD" -e "use VirtualControl;DELETE from ProgramInstance where program_library_id = '{}' ;" 
then
	echo "Mysql DB Delete ProgramInstance: Completed"
else
	echo "Mysql DB Delete ProgramInstance: Failed"
	exit
fi
if mysql -u$DB_USER --password="$DB_PASSWORD" -e "use VirtualControl;Delete from ProgramLibrary where ProgramType = 'SIMPL Windows' ;"
then
	echo "Mysql DB Delete SIMPL Windows ProgramLibrary: Completed"
else
	echo "Mysql DB Delete SIMPL Windows ProgramLibrary: Failed"
	exit
fi

ProgramLibraryCount=`mysql -u$DB_USER --password="$DB_PASSWORD" -e "use VirtualControl;select id from ProgramLibrary where ProgramType = 'SIMPL Windows' ;" |wc -l`
if [ $ProgramLibraryCount -eq 0 ]
then
	echo "Downgrade Verification : Pass"
else
	echo "Downgrade Verification : Fail"
	exit
fi


echo "Preperation for downgrade completed..."
