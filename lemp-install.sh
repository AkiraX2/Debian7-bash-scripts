#!/bin/bash
# var + function
DECLARE="
***********************************************************************************\n
This is a script for debain 7 to install Nginx + php(php5+ fpm + apc) + MariaDB. \n 
                                                                Author: Michael\n
                                                        E-mail: maketa521@gmail.com\n
***********************************************************************************\n"
OPTIONS="Nginx Php MariaDB Exit"
COMMANDS="Config ReStart Status Return"
APC_CONFIG_SAMPLE="
**************************\n
extension=apc.so\n
\n
apc.enabled=1\n
apc.shm_size=128M\n
apc.ttl=3600\n
apc.user_ttl=7200\n
apc.gc_ttl=3600\n
apc.max_file_size=1M\n
**************************\n"

EXSITSNGINX=`service nginx status|wc -l`
EXSITSMARIADB=`service mysql status|wc -l`
EXSITSPHP=`service php5-fpm status|wc -l`

# yes or no
f_continue() {
        while :; do
                echo -en $1"(Yes | No): "
                read res
                case $res in
                        Yes|yes|Y|y)
                        return 1;;
                        No|no|N|n)
                        return 0;;
                        *)
                        echo "Please input Yes or No, retry: ";;
                esac
        done
}
# nginx install
f_nginx_install(){
        apt-get install nginx
     		
        service nginx start && service nginx status
        
        f_continue "Nginx has been installed. Restart right now?"
        if [[ $? -eq 0 ]]; then
                return 0
        fi
        service nginx restart
}
# nginx config
f_nginx_config(){
        echo "To config Nginx. Press any key..."; read a
        cd /etc/nginx/sites-available && pwd && ls
        while :; do
                echo "Please enter your host name(like google.com):"
                read vhost
                f_continue "Affirm."
                if [[ $? -eq 1 ]]; then
                        if [[ -f $vhost ]]; then
                                echo "Already exsits. Rewrite?"
                                if [[ $? -eq 0 ]]; then
                                        break
                                fi
                        fi
                        cp defaulte $vhost && pwd && ls
                        break
                fi
        done
        echo "To edit $vhost. Press any key..."; read a
        vi $vhost
        f_continue "To copy $vhost to enabled directory. Press any key..."; read a
        cd ../sites-enabled/
        ln -s ../sites-enabled/$vhost &&  pwd && ll
}
# nginx
f_nginx(){
        while :; do
                echo "Nginx:"
                if [[ EXSITSNGINX -eq 0 ]]; then
                        f_continue "Are you sure you want to install Nginx now?"
                        if [[ $? -eq 0 ]]; then
                                break
                        fi
                        f_nginx_install
                fi
                select opt in $COMMANDS; do
                        if [[ "$opt"x =  "ReStart"x ]]; then
                                service nginx status
                                f_continue "Are you sure you want to restart Nginx now?"
                                if [[ $? -eq 0 ]]; then
                                      break
                                fi
                                #restart
                                service nginx restart
                                echo "Nginx has been restarted."
                                break
                        elif [[ "$opt"x =  "Config"x ]]; then
                                f_continue "Are you sure you want to config Nginx now?"
                                if [[ $?="0" ]]; then
                                        break
                                fi
                                f_nginx_config
                                f_continue "Are you sure you want to restart Nginx now?"
                                if [[ $?="0" ]]; then
                                      break
                                fi
                                #restart
                                service nginx restart
                                echo "Nginx has been restarted."
                                break
                        elif [[ "$opt"x =  "Status"x ]]; then
                                service nginx status
                        elif [[ "$opt"x =  "Return"x ]]; then
                                return 0
                        else
                                echo "Please input number. Retry:"
                        fi
                done
        done
}
# php install
f_php_install(){
        apt-get install php5 php5-fpm php-apc
}
# php config
f_php_config(){
        echo "Edit apc.ini by adding this: \n"$APC_CONFIG"Press any key..."; read a
        vi /etc/php5/fpm/conf.d/20-apc.ini
        f_continue "Restart php5-fpm right now?"
        if [[ $?="0" ]]; then
                return
        fi
        service php5-fpm restart
}
# php5 + php5-fpm + apc
f_php(){
        while :; do
                echo "PHP:"
                if [[ EXSITSPHP="0" ]]; then
                        f_continue "Are you sure you want to install PHP component now?"
                        if [[ $?="0" ]]; then
                                break
                        fi
                        f_php_install
                        echo "PHP has been installed."

                fi
                select opt in $COMMANDS; do
                        if [[ "$opt"x =  "ReStart"x ]]; then
                                service php5-fpm status
                                f_continue "Are you sure you want to restart php5-fpm now?"
                                if [[ $?="0" ]]; then
                                      break
                                fi
                                #restart
                                service php5-fpm restart
                                echo "PHP has been restarted."
                                break
                        elif [[ "$opt"x =  "Config"x ]]; then
                                f_continue "Are you sure you want to config PHP now?"
                                if [[ $?="0" ]]; then
                                        break
                                fi
                                f_php_config
                                break
                        elif [[ "$opt"x =  "Status"x ]]; then
                                service php5-fpm status
                        elif [[ "$opt"x =  "Return"x ]]; then
                                return 0
                        else
                             echo "Please input number. Retry:"
                        fi
                done
        done
}
# mariaDB install
f_mariaDB_install(){
        apt-get install python-software-properties
        apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
        add-apt-repository 'deb http://mirrors.fe.up.pt/pub/mariadb/repo/10.0/debian wheezy main'
        apt-get update
        apt-get install mariadb-server mariadb-client php-mysql
}
# mariaDB
f_mariaDB(){
        while :; do
                echo "MariaDB:"
                if [[ EXSITSMARIADB="0" ]]; then
                        f_continue "Are you sure you want to install MariaDB now?"
                        if [[ $?="0" ]]; then
                                break
                        fi
                        f_mariaDB_install
                        echo "MariaDB has been installed."

                fi
                select opt in $COMMANDS; do
                        if [[ "$opt"x =  "ReStart"x ]]; then
                                service mysql status
                                f_continue "Are you sure you want to restart MariaDB now?"
                                if [[ $?="0" ]]; then
                                      break
                                fi
                                #restart
                                service mysql restart
                                echo "MariaDB has been restarted."
                                break
                        elif [[ "$opt"x =  "Config"x ]]; then
                                f_continue "Are you sure you want to config MariaDB now?"
                                if [[ $?="0" ]]; then
                                        break
                                fi
                                cd /etc/mysql/ && ls
                                #config
                                vi my.cnf
                                f_continue "Are you sure you want to restart MariaDB now?"
                                if [[ $?="0" ]]; then
                                      break
                                fi
                                service mysql restart
                                echo "MariaDB has been restarted."
                                break
                        elif [[ "$opt"x =  "Status"x ]]; then
                                service mysql status
                        elif [[ "$opt"x =  "Return"x ]]; then
                                return 0
                        else
                                echo "Please input number. Retry:"
                        fi
                done
        done
}

# entry
clear
echo -e $DECLARE

f_continue "The install script is ready. Seriously start now?"
if [[ $? -eq 0 ]]; then
        exit 0
fi
while :; do        
        select opt in $OPTIONS; do
                if [[ "$opt"x = "Nginx"x ]]; then
                        f_nginx
                        break 
                elif [[ "$opt"x = "Php"x ]]; then
                        f_php
                        break
                elif [[ "$opt"x =  "MariaDB"x ]]; then
                        f_mariaDB
                        break
                elif [[ "$opt"x =  "Exit"x ]]; then
                        echo "Bye."
                        exit 0
                else
                        break;
                fi
        done
done
