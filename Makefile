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

save-log: TS=$(shell date "+%Y%m%d_%H%M%S")
save-log: 
	mkdir /home/isucon/logs/$(TS)
	sudo  cp -p /var/log/nginx/access.log  /home/isucon/logs/$(TS)/access.log
	sudo  cp -p /var/log/mysql/mysql-slow.log  /home/isucon/logs/$(TS)/mysql-slow.log
	sudo chmod -R 777 /home/isucon/logs/*
sync-log:
	scp -C kataribe.toml ubuntu@52.197.80.133:~/
	rsync -av -e ssh /home/isucon/logs ubuntu@52.197.80.133:/home/ubuntu  
analysis-log:
	ssh ubuntu@52.197.80.133 "sh push_github.sh"
gogo-log: save-log sync-log analysis-log
