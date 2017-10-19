#!/bin/sh

echo "Script started: " $(date)

ORACLE_HOME=/home/oracle/Oracle/Middleware/Oracle_Home
JAVA_HOME=/opt/java/jdk1.8.0_131
DOMAIN_ROOT=/home/oracle/Oracle/Middleware/Oracle_Home/user_projects/domains
DOMAIN_NAME=frm_domain
ADMIN_USER=weblogic
ADMIN_PASSWORD=welcome1
CONNECTION_STRING=192.168.0.23:1527/pdb1.localdomain
RCUPREFIX=DEV
DB_SCHEMA_PASSWORD=welcome1

echo "Stopping Admin server ..."
if [ "$(pgrep -f AdminServer)" != "" ]; then  
	kill $(pgrep -f AdminServer) 
    echo "Admin server stopped."
else 
	echo "Admin server is not running." 
fi

echo "Stopping Node manager ..."
if [ "$(pgrep -f NodeManager)" != "" ]; then
    kill $(pgrep -f NodeManager)
    echo "Node manager stopped."
else
    echo "Node manager is not running."
fi

echo "Removing domain ..."
rm -rf $DOMAIN_ROOT/$DOMAIN_NAME
echo "Domain removed."

echo "Removing repository ..."
rcu -silent -dropRepository -connectString host_ol73:1527:pdb1.localdomain -dbUser sys -dbRole sysdba -schemaPrefix DEV \
-component IAU \
-component IAU_APPEND \
-component IAU_VIEWER \
-component OPSS \
-component STB \
-component MDS \
-component WLS \
-f < /home/oracle/rcu/passwords
echo "Repository removed."

echo "Creating repository ..."
rcu -silent -createRepository -connectString host_ol73:1527:pdb1.localdomain -dbUser sys -dbRole sysdba -useSamePasswordForAllSchemaUsers true -schemaPrefix DEV \
-component IAU \
-component IAU_APPEND \
-component IAU_VIEWER \
-component OPSS \
-component STB \
-component MDS \
-component WLS \
-f < /home/oracle/rcu/passwords
echo "Repository created."

echo "Creating domain ..."
/home/oracle/Oracle/Middleware/Oracle_Home/oracle_common/common/bin/wlst.sh -skipWLSModuleScanning /u01/oracle/container-scripts/createDomain.py -oh $ORACLE_HOME -jh $JAVA_HOME -parent $DOMAIN_ROOT -name $DOMAIN_NAME -user $ADMIN_USER -password $ADMIN_PASSWORD -rcuDb $CONNECTION_STRING -rcuPrefix $RCUPREFIX -rcuSchemaPwd $DB_SCHEMA_PASSWORD
echo "Domain created."

echo "Script finished: " $(date)

