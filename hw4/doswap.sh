#/bin/bash
function killitif {
    docker ps -a  > /tmp/yy_xx$$
    if grep --quiet $1 /tmp/yy_xx$$
     then
     echo "killing older version of $1"
     docker rm -f `docker ps -a | grep $1  | sed -e 's: .*$::'`
   fi
}

function swap {
	docker ps  > /tmp/yy_xx$$
	w1="web1"
	w2="web2"

	if grep --quiet $w1 /tmp/yy_xx$$
	then
	 	killitif web2
	  docker run -itd --name=web2 -p:8080 $1
	  docker network connect ecs189_default web2
	 	sleep 5 && docker exec ecs189_proxy_1 /bin/bash /bin/swap2.sh
	 	killitif web1
	elif grep --quiet $w2 /tmp/yy_xx$$
	then
	 	killitif web1
	  docker run -itd --name=web1 -p:8080 $1
	  docker network connect ecs189_default web1
	 	sleep 5 && docker exec ecs189_proxy_1 /bin/bash /bin/swap1.sh
	 	killitif web2
	fi
}

swap $1
