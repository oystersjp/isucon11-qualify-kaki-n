.PHONY: gogo build stop-services start-services truncate-logs kataribe

gogo: stop-services build truncate-logs start-services

build:
	cd webapp/go && go build .

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isucondition.go
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sleep 5
	sudo systemctl start isucondition.go
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log
	sudo truncate --size 0 /var/log/mysql/error.log
	sudo truncate --size 0 /var/log/mysql/mysql-slow.log

kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe