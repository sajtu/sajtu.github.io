#!/bin/bash

# last updated: 2024-06-25

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

	# setup directories
	mkdir -p /etc/mysql/certs 2>/dev/null
	chown -R mysql:mysql /etc/mysql 2>/dev/null
	chmod -R ug+rw /etc/mysql/certs 2>/dev/null
	
	if [ -f "/etc/mysql/certs/master-san.cnf" ]; then

		# create CA 
		openssl genrsa -out /etc/mysql/certs/self-ca-key.pem 2048;
		openssl req -new -x509 -nodes -days 3650 -key /etc/mysql/certs/self-ca-key.pem -out  /etc/mysql/certs/self-ca.pem -subj "/CN=MySQL-CA";
		techo "Created: /etc/mysql/certs/self-ca-key.pem (delete this if this is not CA host.)"	
		techo "Created: /etc/mysql/certs/self-ca.pem (delete this if this is not CA host.)"
		echo "";

		openssl genrsa -out /etc/mysql/certs/self-master-key.pem 2048;
		
		openssl req -new -key /etc/mysql/certs/self-master-key.pem -out /etc/mysql/certs/self-master-CSR.pem -config /etc/mysql/certs/master-san.cnf;
	
		openssl x509 -req -in /etc/mysql/certs/self-master-CSR.pem -days 3650 -CA /etc/mysql/certs/self-ca.pem -CAkey /etc/mysql/certs/self-ca-key.pem -set_serial 03 -out /etc/mysql/certs/self-master-cert.pem -extensions v3_req -extfile /etc/mysql/certs/master-san.cnf;

		chown mysql:mysql /etc/mysql/certs/*.pem
		chmod 600 /etc/mysql/certs/*-key.pem


		if [ -f "/etc/mysql/certs/self-slave-CSR.pem" ] && [ -f "/etc/mysql/certs/slave-san.cnf" ]; then
			openssl x509 -req -in /etc/mysql/certs/self-slave-CSR.pem -days 3650 -CA /etc/mysql/certs/self-ca.pem -CAkey /etc/mysql/certs/self-ca-key.pem -set_serial 03 -out /etc/mysql/certs/self-slave-cert.pem -extensions v3_req -extfile /etc/mysql/certs/slave-san.cnf;

			chown mysql:mysql /etc/mysql/certs/self-slave-cert.pem
			chmod 600 /etc/mysql/certs/self-slave-cert.pem

			echo "";
			techo "Copy /etc/mysql/certs/self-ca.pem and /etc/mysql/certs/self-slave-cert.pem back to slave."
			echo "";
		fi

	elif [ -f "/etc/mysql/certs/slave-san.cnf" ]; then

		openssl genrsa -out /etc/mysql/certs/self-slave-key.pem 2048
		openssl req -new -key /etc/mysql/certs/self-slave-key.pem -out /etc/mysql/certs/self-slave-CSR.pem -config /etc/mysql/certs/slave-san.cnf 

		techo "Copy /etc/mysql/certs/self-slave-CSR.pem and /etc/mysql/certs/slave-san.cnf  to CA host for signing."

		chown mysql:mysql /etc/mysql/certs/*.cnf
		chown mysql:mysql /etc/mysql/certs/*.pem
		chmod 600 /etc/mysql/certs/*CSR.pem
		chmod 600 /etc/mysql/certs/*.cnf

	else
		echo "";
		techo "/etc/mysql/certs/master-san.cnf or /etc/mysql/certs/slave-san.cnf not exist.  Please create it."
		echo "";
		exit 59;
	fi

fi

echo "";
exit 0; 