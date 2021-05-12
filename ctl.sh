#!/usr/bin/env bash

case "$1" in
	start)
		echo -n "Start Docker-Registry Cache & CI: "
		docker-compose up -d
	;;
	stop)
		echo -n "Stop Docker-Registry Cache & CI: "
		docker-compose down
	;;
	logs)
		docker-compose logs
	;;
	restart)
		echo -n "Restart Docker-Registry Cache & CI: "
		$0 stop
		$0 start
	;;
  ps)
    docker-compose ps
	;;
  debug)
    docker-compose up
	;;
	*)
		echo "Usage: {start|stop|restart|logs|ps|debug}"
		exit 1
	;;
esac
