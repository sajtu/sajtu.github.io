#!/bin/bash

# last updated: 2024-06-21

enableVerbose="";

build_log_dir="logs";
buildlog="pre-req__`date +%Y%m%d\_%H%M%S`.log";

tmpRCFile="/tmp/tmp.$$";

# Setup secho (time stamped echo to stdout) routine without debug log writing.
secho () {
        tstamp=`date +%Y-%m-%d\ %H:%M\:%S 2>/dev/null`;
        echo "${tstamp} | $@" 2>/dev/null;
        }

CurrentPWD=$(pwd);
chkFPN=`echo "${build_log_dir}" 2>/dev/null | grep "^/" 2>/dev/null`;
if [ -z "${chkFPN}" ]; then
	build_log_dir="${CurrentPWD}/${build_log_dir}";
fi

echo "";
# Setup log directory if applicable
if [ -n "${build_log_dir}" ] && [ ! -d "${build_log_dir}" ]; then 

	build_log_dir=`echo ${build_log_dir} 2>/dev/null | sed 's/\/$//'`;

	tstamp=`date +%Y-%m-%d\ %H:%M\:%S 2>/dev/null`;
	secho "Log directory, '${build_log_dir}', does not exist.";
	secho "Attempting to create log directory, '${build_log_dir}'.";

	mkdir -p ${build_log_dir} 1>/dev/null 2>&1;
	mkdirRC=$?;
	if [ "${mkdirRC}" ne "0" ]; then
		secho "ERROR! Could not create log directory, '${build_log_dir}'!" 2>/dev/null;
	else
		tstamp=`date +%Y-%m-%d\ %H:%M\:%S 2>/dev/null`;
		echo "${tstamp} | Successfully created log directory, '${build_log_dir}'!" 1>${build_log_dir}/${buildlog} 2>/dev/null;
		echo "${tstamp} | Successfully created log directory, '${build_log_dir}'!" 
	fi
fi

WRITE_LOGFILE="${buildlog}";
if [ -d "${build_log_dir}" ]; then
	build_log_dir=`echo ${build_log_dir} 2>/dev/null | sed 's/\/$//'`;
	WRITE_LOGFILE="${build_log_dir}/${buildlog}";
fi


# Setup techo (time stamped echo to stdout) routine.
techo () {
        tstamp=`date +%Y-%m-%d\ %H:%M\:%S 2>/dev/null`;
        # write to debug build log first
        echo "${tstamp} | $@" 1>>${WRITE_LOGFILE} 2>/dev/null;
        # then write to stdout
        echo "${tstamp} | $@" 2>/dev/null;
        }

# Setup decho (time stamp echo to stderr for debug) routine.
decho () {
        tstamp=`date +%Y-%m-%d\ %H:%M\:%S 2>/dev/null`;
        # write to debug build log first
        echo "${tstamp} | $@" 1>>${WRITE_LOGFILE} 2>/dev/null;
        # then write to stderr
        echo "${tstamp} | $@" 1>&2;
        }

# Setup vecho (verbosed time stamp echo to stderr for verbosed debug messages) routine.
vecho () {
        if [ -n "${enableVerbose}" ]; then
                if [ "${enableVerbose}" != "0" ]; then
                        tstamp=`date +%Y-%m-%d\ %H:%M\:%S 2>/dev/null`;
                        # write to debug build log first
                        echo "${tstamp} | $@" 1>>${WRITE_LOGFILE} 2>/dev/null;
                        # then write to stderr
                        echo "${tstamp} | $@" 1>&2;
                fi
        fi
        }

# Exit
ExitError () {
	exitRC=$1;
	techo "Subroutine or function did not exit correctly.";
	techo "Exiting with code, '${exitRC}'.";
	exit ${exitRC};
	}

############################################################################################

VerifyRoot () {

	IsRootUser=`whoami 2>/dev/null | grep "^root$" 2>/dev/null`;
	if [ -z "${IsRootUser}" ]; then
		techo "Must be root user to run this or use 'sudo'".
		techo "Exiting with code 2.";
		ExitError 2;
	fi
	}

VerifyRoot;
tmpFilTS=`date +%Y%m%d%H%M%S 2>/dev/null`;

############################################################################################

OSNAME="Unknown";
if [ -f "/etc/os-release" ]; then
	OSNAME=`grep "^NAME=" /etc/os-release | sed 's/\"//g' | awk -F\= '{print $NF}'`;
fi
techo "OS: ${OSNAME}";

UPDATE_MODE="";
SUBMODE="";
if [ -f "/etc/redhat-release" ]; then
	UPDATE_MODE="RHEL";
	techo "Package update mode: ${UPDATE_MODE}";
elif [ -n `grep "ID_LIKE=debian" /etc/os-release` ] || [ -n `grep "ID_LIKE=ubuntu" /etc/os-release` ]; then
	UPDATE_MODE="DEBIAN";
	SUBMODE="DEBIAN";
	techo "Package update mode: ${UPDATE_MODE}";

	if [ -n `grep "ID_LIKE=ubuntu" /etc/os-release` ]; then
		SUBMODE="UBUNTU";
	elif [ -n `grep -i "^NAME=\"Ubuntu\"" /etc/os-release` ]; then
		SUBMODE="UBUNTU";
	fi
	techo "Package update sub-mode: ${SUBMODE}";
fi




if [ "${UPDATE_MODE}" = "RHEL" ]; then

	techo "RHEL not yet supported.";


# Debian based distro
elif [ "${UPDATE_MODE}" = "DEBIAN" ]; then

	techo "Performing apt update.";
	#check for latest updates and update local DB
	(/usr/bin/apt update 2>&1 && aptRC=$? && echo "[EXIT_CODE] ${aptRC}") | while read stdout;
	do

		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi

	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi



	techo "Installing pre-requisite packages.";
	PRE_PACKAGES_LIST="curl wget";

	#do installtion of pre-requisits 
	(/usr/bin/apt -y install ${PRE_PACKAGES_LIST} 2>&1 && aptRC=$? && echo "[EXIT_CODE] ${aptRC}") | while read stdout;
	do
		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi
	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi
	techo "Installed pre-requisite packages.";


	#Fetching https://repo.percona.com/apt/percona-release_latest.generic_all.deb
	PERCONA_REPO_URL="https://repo.percona.com/apt/percona-release_latest.generic_all.deb";
	PERCONA_REPO_FILE=`echo "${PERCONA_REPO_URL}" 2>/dev/null | awk -F\/ '{print $NF}' 2>/dev/null`;
	(/usr/bin/curl -O ${PERCONA_REPO_URL} 2>&1 && wgetRC=$? && echo "[EXIT_CODE] ${wgetRC}") | while read stdout;
	do
		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi
	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		
		# if percona-release_latest.generic_all.deb not found, force error code to 58.
		if [ ! -f "${PERCONA_REPO_FILE}" ]; then
			techo "${PERCONA_REPO_FILE} not found!";
			ExitCode=58;
		fi
		
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi
	techo "Downloaded ${PERCONA_REPO_FILE} from ${PERCONA_REPO_URL}.";


	#Adding repo
	(/usr/bin/dpkg -i ${PERCONA_REPO_FILE} 2>&1 && dpkgRC=$? && echo "[EXIT_CODE] ${dpkgRC}") | while read stdout;
	do
		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi
	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi


	# Setup percona release
	PERCONA_SELECTION="ps80";
	(/usr/bin/percona-release setup ${PERCONA_SELECTION} 2>&1 && psetupRC=$? && echo "[EXIT_CODE] ${psetupRC}") | while read stdout;
	do
		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi
	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi


	techo "Performing apt update after adding repo ${PERCONA_REPO_FILE}.";
	#check for latest updates and update local DB
	(/usr/bin/apt update 2>&1 && aptRC=$? && echo "[EXIT_CODE] ${aptRC}") | while read stdout;
	do

		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi

	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi


	# Installing percona MySQL 
	PERCONA_SELECTION="ps80";
	(/usr/bin/apt install  percona-server-server 2>&1 && aptRC=$? && echo "[EXIT_CODE] ${aptRC}") | while read stdout;
	do
		chkforRC=`echo "${stdout}" 2>/dev/null | grep "^\[EXIT_CODE]" 2>/dev/null`;
		if [ -n "${chkforRC}" ]; then
			exitCode=`echo "${chkforRC}" 2>/dev/null | awk '{print \$2}' 2>/dev/null`;
			#echo "exitCode: ${exitCode}";
			echo "${exitCode}" 1>${tmpRCFile}.${tmpFilTS} 2>/dev/null;
		else
			techo "${stdout}"
		fi
	done;
	ExitCode=59;
	if [ -f "${tmpRCFile}.${tmpFilTS}" ]; then
		ExitCode=`cat ${tmpRCFile}.${tmpFilTS} 2>/dev/null | grep "^[0-9]" 2>/dev/null | tail -1 2>/dev/null`;
		techo "Exit Code was: '${ExitCode}'";
		rm -f ${tmpRCFile}.${tmpFilTS} 1>/dev/null 2>&1;
	fi
	if [ "${ExitCode}" != "0" ]; then
		ExitError ${ExitCode};
	fi

	#SETUP PERMISSIONS AND CONF DIRECTORIES
	mkdir -p /etc/mysql/certs 2>/dev/null;
	mkdir -p /etc/mysql/mysql.conf.d 2>/dev/null;
	chown -R mysql:mysql /etc/mysql 2>/dev/null;
	chmod ug+rw /etc/mysql/certs 2>/dev/null;
	NETCONFFILE="/etc/mysql/mysql.conf.d/network-access.cnf";

	techo "Creating file ${NETCONFFILE}";
	echo "[mysqld]" 1>${NETCONFFILE} 2>/dev/null;
	echo "bind-address = 0.0.0.0" 1>>${NETCONFFILE} 2>/dev/null;
	if [ -f "${NETCONFFILE}" ]; then

		(cat ${NETCONFFILE} 2>/dev/null) | while read stdout;
		do
			techo "${stdout}"
		done;
	else 
		techo "Failed to create ${NETCONFFILE}."
	fi
	
	
	techo "Creating sample /etc/mysql/certs/san.cnf file";
	SSL_SANCNF="/etc/mysql/certs/san.cnf";
	NODENAME=`uname -n 2>/dev/null`;
	NODEIP=`hostname -I 2>/dev/null | awk '{print $1}' 2>/dev/null`;

	echo "[req]" 1>${SSL_SANCNF} 2>/dev/null;
	echo "distinguished_name = req_distinguished_name" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "x509_extensions = v3_req" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "prompt = no" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "[req_distinguished_name]" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "CN = ${NODENAME}" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "[v3_req]" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "subjectAltName = @alt_names" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "[alt_names]" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "DNS.1 = ${NODENAME}" 1>>${SSL_SANCNF} 2>/dev/null;
	echo "IP.1  = ${NODEIP}" 1>>${SSL_SANCNF} 2>/dev/null;

	if [ -f "${SSL_SANCNF}" ]; then

		(cat ${SSL_SANCNF} 2>/dev/null) | while read stdout;
		do
			techo "${stdout}"
		done;
	else 
		techo "Failed to create ${SSL_SANCNF}."
	fi


	techo "Creating sample file: sample_insert_my.cnf";
	SAMPLE_myCNF="sample_SSL_insert_my.cnf";
	echo "### Sample, examples to add to  /etc/mysql/my.cnf under [mysqld]" 1>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "## Master SSL:" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "[mysqld]" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "ssl-ca=/etc/mysql/certs/self-ca.pem" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "ssl-cert=/etc/mysql/certs/self-master-cert.pem" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "ssl-key=/etc/mysql/certs/self-master-key.pem" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "## SLAVE SSL:" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "[mysqld]" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "ssl-ca=/etc/mysql/certs/self-ca.pem" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "ssl-cert=/etc/mysql/certs/self-slave-cert.pem" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "ssl-key=/etc/mysql/certs/self-slave-key.pem" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "## Master REPLICATION:" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "[mysqld]" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "server-id = 1" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "log_bin = mysql-bin" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "binlog_format = ROW" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "gtid_mode = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "enforce_gtid_consistency = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "binlog_row_image = FULL" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "log_slave_updates = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "binlog_expire_logs_seconds = 604800   # optional, keep binlogs 7 days" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "## Slave REPLICATION:" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "[mysqld]" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "server-id = 2" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "gtid_mode = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "enforce_gtid_consistency = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "binlog_format = ROW" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "log_slave_updates = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "relay_log = relay-bin" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "read_only = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "super_read_only = ON" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "slave_parallel_type = LOGICAL_CLOCK" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "slave_parallel_workers = 4" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	echo "" 1>>${SAMPLE_myCNF} 2>/dev/null;
	if [ -f "${SAMPLE_myCNF}" ]; then

		(cat ${SAMPLE_myCNF} 2>/dev/null) | while read stdout;
		do
			techo "${stdout}"
		done;
	else 
		techo "Failed to create ${SAMPLE_myCNF}."
	fi


	techo "Creating sample file: setup_slave_replication.sql";
	SAMPLE_slavesql="setup_slave_replication.sql";
	echo "STOP SLAVE;" 1>${SAMPLE_slavesql} 2>/dev/null;
	echo "" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "RESET SLAVE ALL;" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "RESET SLAVE ALL;" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "CHANGE MASTER TO" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_HOST='${NODEIP}'," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_USER='replicator'," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_PASSWORD='12345678'," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_AUTO_POSITION=1," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_SSL=1," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_SSL_CA='/etc/mysql/certs/self-ca.pem'," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_SSL_CERT='/etc/mysql/certs/self-slave-cert.pem'," 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "  MASTER_SSL_KEY='/etc/mysql/certs/self-slave-key.pem';" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "" 1>>${SAMPLE_slavesql} 2>/dev/null;
	echo "START SLAVE;" 1>>${SAMPLE_slavesql} 2>/dev/null;
	if [ -f "${SAMPLE_slavesql}" ]; then

		(cat ${SAMPLE_slavesql} 2>/dev/null) | while read stdout;
		do
			techo "${stdout}"
		done;
	else 
		techo "Failed to create ${SAMPLE_slavesql}."
	fi

	techo "Creating sample file: setup_users.sql";
	SAMPLE_userssql="setup_users.sql";
	echo "-- Edit before using." 1>${SAMPLE_userssql} 2>/dev/null;
	echo "-- Create User(s)" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'mypassword';" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "CREATE USER 'replicator'@'%' IDENTIFIED BY '12345678';" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "-- Full Admin Rights" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "GRANT ALL PRIVILEGES ON *.* TO 'myuser'@'localhost' WITH GRANT OPTION;" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "-- Replication Rights" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "GRANT REPLICATION SLAVE ON *.* TO 'replicator'@'%';" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "" 1>>${SAMPLE_userssql} 2>/dev/null;
	echo "FLUSH PRIVILEGES;" 1>>${SAMPLE_userssql} 2>/dev/null;
	if [ -f "${SAMPLE_userssql}" ]; then
		(cat ${SAMPLE_userssql} 2>/dev/null) | while read stdout;
		do
			techo "${stdout}"
		done;
	else 
		techo "Failed to create ${SAMPLE_userssql}."
	fi

	techo "Creating sample file: create_testdb.sql";
	SAMPLE_testdbsql="create_testdb.sql";
	echo "-- Edit before using." 1>${SAMPLE_testdbsql} 2>/dev/null;
	echo "" 1>>${SAMPLE_testdbsql} 2>/dev/null;
	echo "CREATE DATABASE IF NOT EXISTS testdb;" 1>>${SAMPLE_testdbsql} 2>/dev/null;
	echo "USE testdb;" 1>>${SAMPLE_testdbsql} 2>/dev/null;
	echo "CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100), email VARCHAR(100), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);" 1>>${SAMPLE_testdbsql} 2>/dev/null;
	echo "INSERT INTO users (name, email) VALUES ('Alice', 'alice@example.com'), ('Bob', 'bob@example.com'), ('Charlie', 'charlie@example.com');" 1>>${SAMPLE_testdbsql} 2>/dev/null;
	if [ -f "${SAMPLE_testdbsql}" ]; then
		(cat ${SAMPLE_testdbsql} 2>/dev/null) | while read stdout;
		do
			techo "${stdout}"
		done;
	else 
		techo "Failed to create ${SAMPLE_testdbsql}."
	fi



	
	techo "Successfully installed Percona MySQL.";
	techo "";
	techo "To enable MySQL during init: sudo systemctl enable mysql";
	techo "             To start MySQL: sudo systemctl start mysql";
	techo "              To stop MySQL: sudo systemctl stop mysql";
	techo "           To restart MySQL: sudo systemctl restart mysql";
	techo "      To check status MySQL: sudo systemctl status mysql";

fi


echo "";
exit 0;
 
