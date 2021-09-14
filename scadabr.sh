#  scadabr - Script de ajuda do ScadaBR. Inicia, Para ou informa se o ScadaBR esta rodando.
#  Autor: Wagner de Queiroz (wagnerdequeiroz@gmail.com)
#  
#!/bin/bash

#Check if you have root rights..
if [[ $EUID -ne 0 ]]; then
   echo "Sorry! This script must be run as root" 
   exit 1
fi

NAME="ScadaBR"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
ENDCOLOR="\e[0m"
TOMCAT_PID=$(ps -ef | awk '/[t]omcat/{print $2}')
INSTALL_DIR="/opt/ScadaBR"

d_status ()
{

if [ ! -z "$TOMCAT_PID" ]; then
  echo -e " * Your $NAME is ${GREEN} RUNNING ${ENDCOLOR} with PID $TOMCAT_PID"
else
  echo -e " * Your $NAME is ${RED}DOWN ${ENDCOLOR}"
fi
}


d_start ()
{
    if [ ! -z "$TOMCAT_PID" ]; then
      # Tomcat is running does nothing... (Tomcat esta rodando, nao faz nada...)
      echo -e " * $NAME is ${GREEN}RUNNING ${ENDCOLOR}with PID $TOMCAT_PID"
    else 
     echo -e " * Starting $NAME ... "
     $INSTALL_DIR/tomcat/bin/catalina.sh start 2>/tmp/null 
     #check again if the Tomcat is up
     TOMCAT_PID=$(ps -ef | awk '/[t]omcat/{print $2}')

      if [ ! -z "$TOMCAT_PID" ]; then 
        echo -e "${GREEN}[ SUCESS !! ]${ENDCOLOR} $NAME Running NOW!"
      else
        echo -e "${RED}[ FAILURE! ]${ENDCOLOR} $NAME is not running!" 
      fi
    fi
}
d_stop ()
{
    if [ ! -z "$TOMCAT_PID" ]; then
      # Tomcat is running! Closing Tomcat (Tomcat esta rodando, encerra-o)
      echo -e " * Stopping $NAME ..."
      sleep 1
      $INSTALL_DIR/tomcat/bin/catalina.sh stop 2>/tmp/null
      # Check if ScadaBR is down (verifica se o ScadaBR encerrou)
     TOMCAT_PID=$(ps -ef | awk '/[t]omcat/{print $2}')

     if [ -z "$TOMCAT_PID" ]; then
        echo -e "${GREEN}[ SUCESS ! ]${ENDCOLOR} $NAME DOWN!"
      else
       echo -e "${RED}[ FAILURE ! ]${ENDCOLOR} $NAME still Running! Hiring a Hitman..."
       # If tomcat is running yet, call a hitman to make the job! (O cabra nao caiu, Mete o Tiro de 12 no cabra!)
        kill ${TOMCAT_PID} 
         if [ -z "$TOMCAT_PID" ]; then 
          echo -e "${RED}[ FAILURE ! ]${ENDCOLOR} $NAME still ${YELLOW}Running! ${ENDCOLOR}"
          else 
           echo -e "${GREEN}[ SUCESS ! ]${ENDCOLOR} $NAME is DOWN! I repeat! $NAME is DOWN! "
         fi
      fi # else If hitman shutdown tomcat... ( else da verificacao de Obito)
    else
      echo -e "$NAME is DOWN!"
    fi 
}
      
# Check Parametes, if don't have one, show how use this script 
#  (Faz a magica de ler os parametros:)

case  "$1"  in 
        start)
            d_start
            ;; 

        stop)
            d_stop
            ;;

        restart)
            d_stop
            d_start
            ;;
        help)
            echo "This program can Start, Stop or show status if the ScadaBR server is running. You need be root to work"
            echo "by Wagner de Queiroz (wagnerdequeiroz@gmail.com)\n\t"
            echo  "Usage: $0 {help|start|stop|restart|status}"
            ;;            
        status)
            d_status
            ;;
        *)
        echo  "Usage: $0 {start|stop|restart|status}"
        exit 1 
        ;; 
esac
