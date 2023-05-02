#!/bin/bash
productID=7D61
scriptPath=`pwd`

os=`cat /etc/os-release | grep  "NAME" | cut -f2 -d"=" | head -1| cut -f2 -d'"' | cut -f1 -d '"'`
if [ "${os}" == "Red Hat Enterprise Linux" ]
then
	os="RHEL"
	echo "Operating System : Red Hat"
	OpenSsl="openssl-devel-1:1.1.1k-7.el8_6.i686"
	LibAtomic="libatomic-8.5.*.i686"
	LibCurl="libcurl-7.61.1-22.el8_6.3.i686"
	NetSnmp="net-snmp-agent-libs-1:5.8-25.el8.i686"
	RedisCLI="redis-5.0.3-1.module+el8+2566+19ca22c8.x86_64"
    NetSnmplib="net-snmp-libs-1:5.8-25.el8.i686"
	subscription-manager auto-attach
elif [ "${os}" == "AlmaLinux" ]
then
	os="ALMA"
	echo "Operating System : AlmaLinux"
    OpenSsl="openssl-devel-1:1.1.1k-7.el8_6.i686"
	LibAtomic="libatomic-8.5.*.i686"
	LibCurl="libcurl-7.61.1-22.el8_6.3.i686"
	NetSnmp="net-snmp-agent-libs-1:5.8-25.el8.i686"
	RedisCLI="redis-5.0.3-2.module_el8.2.0+318+3d7e67ea.x86_64"
	NetSnmplib="net-snmp-libs-1:5.8-25.el8.i686"
	dnf config-manager --add-repo ./crestron.repo
	dnf config-manager --add-repo ./crestron1.repo
elif [ "${os}" == "CentOS Linux" ]
then
	os="CENTOS"
	echo "Operating System : CentOS"
	OpenSsl="openssl-devel-1:1.1.1k-7.el8_6.i686"
	LibAtomic="libatomic-8.5.*.i686"
	LibCurl="libcurl-7.61.1-22.el8_6.3.i686"
	NetSnmp="net-snmp-agent-libs-1:5.8-25.el8.i686"
	RedisCLI="redis-5.0.3-2.module_el8.2.0+318+3d7e67ea.x86_64"
    NetSnmplib="net-snmp-libs-1:5.8-25.el8.i686"
	dnf config-manager --add-repo ./crestron.repo
	dnf config-manager --add-repo ./crestron1.repo
elif [ "${os}" == "Oracle Linux Server" ]
then
	os="ORACLE-LINUX"
	echo "Operating System : ORACLE-LINUX"
	OpenSsl="openssl-devel-1:1.1.1k-7.el8_6.i686"
	LibAtomic="libatomic-8.5.*.i686"
	LibCurl="libcurl-7.61.1-22.el8_6.3.i686"
	NetSnmp="net-snmp-agent-libs-1:5.8-25.el8.i686"
	RedisCLI="redis-5.0.3-2.module_el8.2.0+318+3d7e67ea.x86_64"
	NetSnmplib="net-snmp-libs-1:5.8-25.el8.i686"
	dnf config-manager --add-repo ./crestron.repo
	dnf config-manager --add-repo ./crestron1.repo
elif [ "${os}" == "Rocky Linux" ]
then
	os="ROCKY"
	echo "Operating System : RockyLinux"
    OpenSsl="openssl-devel-1:1.1.1k-7.el8_6.i686"
	LibAtomic="libatomic-8.5.*.i686"
	LibCurl="libcurl-7.61.1-22.el8_6.3.i686"
	NetSnmp="net-snmp-agent-libs-1:5.8-25.el8.i686"
	RedisCLI="redis-5.0.3-2.module_el8.2.0+318+3d7e67ea.x86_64"
	NetSnmplib="net-snmp-libs-1:5.8-25.el8.i686"
	dnf config-manager --add-repo ./crestron.repo
	dnf config-manager --add-repo ./crestron1.repo
else
	echo "RPM Not Compatible In This Operating System!!!"
	exit

fi
echo " " > /tmp/.vc4InstallationLog.txt

if [ $productID == "7D62" ]
then
	echo "Product : Xio Cloud Gateway" >> /tmp/.vc4InstallationLog.txt
	if [ -f /etc/systemd/system/virtualcontrol.service ] 
	then 	
		install_path=`cat /etc/systemd/system/virtualcontrol.service | grep install_path | cut -f2 -d"="`
		freshInstall="False"
	elif [ -f /etc/systemd/system/xiocloudgateway.service ] 
	then 	
		install_path=`cat /etc/systemd/system/xiocloudgateway.service | grep install_path | cut -f2 -d"="`
		freshInstall="False"
	else
		freshInstall="True"
	fi
		
	if [ "$freshInstall" = "False" ]
	then
		if [ -d $install_path ]
		then 
			source $install_path/virtualcontrol/CrestronApps/bin/ProductID
			if [ "$PRODUCT_ID" == "7D62" ]
			then
				echo "Proceeding for upgrade ... " >> /tmp/.vc4InstallationLog.txt
			else
				installXIO="False"
				while [ "${installXIO}" = "False" ]
				do
					echo "You are installing  the 'XIO-CLOUD-GATEWAY' over 'VC4'. After this, you will not be able to create rooms on this server."  
					read -p "Do you want to proceed (Y/N): " installXIO ;
					if [ "$installXIO" == 'Y' ] || [ "$installXIO" == 'y' ]
					then
						echo "Installing VC4 on XIO" >> /tmp/.vc4InstallationLog.txt
						installXIO="True"
					elif [ "$installXIO" == 'N' ] || [ "$installXIO" == 'n' ]
					then
						exit
						installXIO="False"
					else
						echo "Invalid Option"
						installXIO="False"
					fi
				done
				source $install_path/virtualcontrol/conf/database_connect.cfg
				programInstances=`mysql --user=$DB_USER --password=$DB_PASSWORD -e "use $DB_NAME ; SELECT * FROM ProgramLibrary ;" | wc -l`
				if [ $programInstances -eq 0 ]
				then 
					echo "No Program Instances Running.." >> /tmp/.vc4InstallationLog.txt
					echo "Proceeding Installation from VC4 to XIO-CLOUD-GATEWAY.." >> /tmp/.vc4InstallationLog.txt
				else
					echo "There are programs defined for this install. Please delete all programs and then run the installer to convert the VC-4 to an XIO-CLOUD-GATEWAY"
					echo "There are programs defined for this install. Please delete all programs and then run the installer to convert the VC-4 to an XIO-CLOUD-GATEWAY" >> /tmp/.vc4InstallationLog.txt
					exit
				fi
				licenses=`mysql --user=$DB_USER --password=$DB_PASSWORD -e "use $DB_NAME ; SELECT * FROM LicenseRegistry ;" |grep ProgramInstances | wc -l`
				if [ $licenses -eq 0 ]
				then 
					echo "No Crestron Virtual Control licenses applied to the server.." >> /tmp/.vc4InstallationLog.txt
					echo "Proceeding Installation from VC4 to XIO-CLOUD-GATEWAY.." >> /tmp/.vc4InstallationLog.txt
				else
					echo "There are Crestron Virtual Control licenses applied to the server. Please remove the licenses before migrating from Crestron Virtual Control to Crestron XiO Cloud Gateway software. Any licenses that are applied to the server after migration will be lost."
					echo "There are Crestron Virtual Control licenses applied to the server. Please remove the licenses before migrating from Crestron Virtual Control to Crestron XiO Cloud Gateway software. Any licenses that are applied to the server after migration will be lost." >> /tmp/.vc4InstallationLog.txt
					exit
				fi

			fi
		fi
			
	fi	
else	
	echo "Product : Virtual Control" >> /tmp/.vc4InstallationLog.txt
	if [ -f /etc/systemd/system/virtualcontrol.service ] 
	then 	
		install_path=`cat /etc/systemd/system/virtualcontrol.service | grep install_path | cut -f2 -d"="`
		freshInstall="False"
	elif [ -f /etc/systemd/system/xiocloudgateway.service ] 
	then 	
		install_path=`cat /etc/systemd/system/xiocloudgateway.service | grep install_path | cut -f2 -d"="`
		freshInstall="False"
	else
		freshInstall="True"
	fi
		
	if [ "$freshInstall" = "False" ]
	then
		if [ -d $install_path ]
		then 
			source $install_path/virtualcontrol/CrestronApps/bin/ProductID
			if [ "$PRODUCT_ID" == "7D62" ]
			then
				echo "This is an install for XIO-CLOUD-GATEWAY and cannot be upgraded to VC-4"
				echo "This is an install for XIO-CLOUD-GATEWAY and cannot be upgraded to VC-4" >> /tmp/.vc4InstallationLog.txt
				exit
				
			elif [ "$PRODUCT_ID" == "7D61" ]
			then
				echo "Proceeding for upgrade ... " >> /tmp/.vc4InstallationLog.txt
				
			fi
		fi
			
	fi	

fi

echo "Installing Required Packages" >> /tmp/.vc4InstallationLog.txt


cd /opt/ 


if dnf -y  update libstdc++

then
	echo "Updated libstdc++ " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to update libstdc++ " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 


if dnf -y  install make 

then
	echo "Installed make " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install make " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf -y  install gcc 

then
	echo "Installed make " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install make " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf -y  install yum

then
	echo "Installed yum " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install yum " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf -y  install zip unzip

then
	echo "Installed zip unzip " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install zip unzip " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf -y  install tar

then
	echo "Installed tar  " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install tar " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 


if dnf -y  install telnet

then
	echo "Installed telnet  " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install telnet " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf  -y install glibc-devel.i686

then
	echo "Installed glibc-devel.i686 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install glibc-devel.i686 " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if [ "$os" = "CENTOS1" ]
then
	rm -f /var/lib/rpm/__db*
	rm -f /var/lib/rpm/.rpm.lock
	if dnf  -y install selinux-policy-targeted-3.14.3-41.el8_2.5.noarch

	then
		echo "Installed selinux-policy-targeted-3.14.3-41.el8_2.5.noarch " >> /tmp/.vc4InstallationLog.txt
	else
		echo "Failed to install selinux-policy-targeted-3.14.3-41.el8_2.5.noarch " >> /tmp/.vc4InstallationLog.txt
		
	 exit
	fi 
else
	echo""
fi

if dnf  -y install rsync
then
	echo "Installed rsync " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install rsync " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf  -y install policycoreutils-python-utils 
then
	echo "Installed policycoreutils-python-utils  " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install policycoreutils-python-utils  " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 

if dnf  -y install glibc-devel
then
	echo "Installed glibc-devel " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install glibc-devel " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 


if dnf  -y install libstdc++.i686
then
	echo "Installed libstdc++.i686 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install libstdc++.i686 " >> /tmp/.vc4InstallationLog.txt	
 exit
fi 


if dnf  -y install $OpenSsl
then
	echo "Installed $OpenSsl " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install $OpenSsl " >> /tmp/.vc4InstallationLog.txt

 exit
fi 

if dnf  -y install yajl.i686
then
	echo "Installed yajl.i686 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install yajl.i686 " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 


if dnf  -y install libcurl.i686
then
	echo "Installed libcurl.i686 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install libcurl.i686 " >> /tmp/.vc4InstallationLog.txt
 exit
fi 

if dnf  -y install libuuid.i686
then
	echo "Installed libuuid.i686 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install libuuid.i686 " >> /tmp/.vc4InstallationLog.txt
	
 exit
fi 



if dnf  -y install $LibAtomic
then
	echo "Installed $LibAtomic " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install $LibAtomic " >> /tmp/.vc4InstallationLog.txt

 exit
fi 

if dnf  -y install libevent-devel-2.1.8-5.el8.i686
then
	echo "Installed libevent-devel-2.1.8-5.el8.i686 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install libevent-devel-2.1.8-5.el8.i686 " >> /tmp/.vc4InstallationLog.txt
 exit
fi 


if dnf  -y install $NetSnmp
then
	echo "Installed $NetSnmp " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install $NetSnmp " >> /tmp/.vc4InstallationLog.txt
 exit
fi 

if dnf  -y install $NetSnmplib 
then
	echo "Installed net-snmp-libs " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install net-snmp-libs " >> /tmp/.vc4InstallationLog.txt

 exit
fi 


if dnf  -y install mariadb-server
then
	echo "Installed mariadb-server " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install mariadb-server " >> /tmp/.vc4InstallationLog.txt
 exit
fi 

if dnf  -y install httpd
then
	echo "Installed httpd " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install http " >> /tmp/.vc4InstallationLog.txt
 exit
fi 


if systemctl enable httpd
then
	echo "Enabled httpd " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to Enable httpd " >> /tmp/.vc4InstallationLog.txt
 exit
fi 

if dnf  -y install mod_security
then
	echo "Installed mod_security " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install mod_security " >> /tmp/.vc4InstallationLog.txt
 exit
fi 


if dnf  -y install net-tools
then
	echo "Installed net-tools " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install net-tools " >> /tmp/.vc4InstallationLog.txt
fi 



if dnf  -y install net-snmp
then
	echo "Installed net-snmp " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install net-snmp " >> /tmp/.vc4InstallationLog.txt
	exit
fi 

if dnf  -y install net-snmp-utils
then
	echo "Installed net-snmp-utils " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install net-snmp-utils " >> /tmp/.vc4InstallationLog.txt
 exit
fi 

if dnf -y install krb5-workstation 
then
	echo "Installed krb5-workstation " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install krb5-workstation" >> /tmp/.vc4InstallationLog.txt
 exit
fi


if dnf -y install krb5-libs
then
	echo "Installed krb5-libs " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install krb5-libs " >> /tmp/.vc4InstallationLog.txt
 exit
fi


if dnf -y install openldap-clients-2.4.46-11.el8_1.x86_64
then
	echo "Installed openldap-clients-2.4.46-11.el8_1.x86_64 " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install openldap-clients-2.4.46-11.el8_1.x86_64 " >> /tmp/.vc4InstallationLog.txt
 exit
fi

if dnf -y install $RedisCLI
then
	echo "Installed $RedisCLI " >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed to install $RedisCLI " >> /tmp/.vc4InstallationLog.txt
 exit
fi

if dnf -y install python3-virtualenv
then 
	echo "Installed python3-virtualenv " >> /tmp/.vc4InstallationLog.txt
else
	echo " Failed to install python3-virtualenv" >> /tmp/.vc4InstallationLog.txt
fi


if dnf -y install libcgroup-tools
then
        echo "Installed libcgroup-tools" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install libcgroup-tools" >> /tmp/.vc4InstallationLog.txt
fi



if dnf -y install libxml2.i686
then
        echo "Installed libxml2.i686" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install libxml2.i686" >> /tmp/.vc4InstallationLog.txt
fi

if dnf -y install libxml2
then
        echo "Installed libxml2" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install libxml2" >> /tmp/.vc4InstallationLog.txt
fi

if dnf -y install xerces-c.x86_64
then
        echo "Installed xerces-c" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install xerces-c" >> /tmp/.vc4InstallationLog.txt
fi

if dnf -y install python38
then
        echo "Installed python3.8" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install python3.8" >> /tmp/.vc4InstallationLog.txt
fi


cd $scriptPath

if dnf -y install python3-virtualenv
then
        echo "Installed python3-virtualenv" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install python3-virtualenv" >> /tmp/.vc4InstallationLog.txt
fi

if [ -f /etc/systemd/system/virtualcontrol.service ] 
	then 	
		install_path=`cat /etc/systemd/system/virtualcontrol.service | grep install_path | cut -f2 -d"="`
elif [ -f /etc/systemd/system/xiocloudgateway.service ] 
	then 	
		install_path=`cat /etc/systemd/system/xiocloudgateway.service | grep install_path | cut -f2 -d"="`

fi
echo "Install Path : "$install_path
ls /usr/local/bin/virtualenv
if [ $? -eq 0 ] 
then 
	echo "Thus using /usr/local/bin/virtualenv"
	/usr/local/bin/virtualenv -p /usr/bin/python3 /opt/venv/virtualcontrol/virtualcontrolenv
else
	echo "Thus using /usr/bin/virtualenv"
	/usr/bin/virtualenv -p /usr/bin/python3 /opt/venv/virtualcontrol/virtualcontrolenv
fi

cd /opt/venv/virtualcontrol/virtualcontrolenv/
if pip3 install -r $scriptPath/requirement.txt
then
        echo "Installed requirement.txt" >> /tmp/.vc4InstallationLog.txt
else
        echo " Failed to install requirement.txt" >> /tmp/.vc4InstallationLog.txt
fi

cd $scriptPath
echo "Installing virtualcontrol-4.0001.00065-1.noarch.rpm RPM " >> /tmp/.vc4InstallationLog.txt
rpm -Uvh --oldpackage --replacepkgs virtualcontrol-4.0001.00065-1.noarch.rpm 

./DBMigrations.sh
touch /etc/udev/rules.d/80-udisks-crestron.rules
echo 'SUBSYSTEM=="usbmisc",SUBSYSTEMS=="usb" ATTRS{idVendor}=="0529", ATTRS{idProduct}=="*", MODE="0666"' > /etc/udev/rules.d/80-udisks-crestron.rules
echo 'Added SUBSYSTEM=="usbmisc",SUBSYSTEMS=="usb" ATTRS{idVendor}=="0529", ATTRS{idProduct}=="*", MODE="0666" to etc/udev/rules.d/80-udisks-crestron.rules' >> /tmp/.vc4InstallationLog.txt
echo 'SUBSYSTEMS=="usb" ATTRS{idVendor}=="0529", ATTRS{idProduct}=="*", MODE="0666"' >> /etc/udev/rules.d/80-udisks-crestron.rules
echo 'Added SUBSYSTEMS=="usb" ATTRS{idVendor}=="0529", ATTRS{idProduct}=="*", MODE="0666" to etc/udev/rules.d/80-udisks-crestron.rules' >> /tmp/.vc4InstallationLog.txt
if udevadm control --reload-rules
then
	echo "Success: udevadm control --reload-rules" >> /tmp/.vc4InstallationLog.txt
else
	echo "Failed: udevadm control --reload-rules" >> /tmp/.vc4InstallationLog.txt
fi
