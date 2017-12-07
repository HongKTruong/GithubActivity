#/bin/bash
# docker ps -a  > /tmp/yy_xx$$
# if grep --quiet "web1" /tmp/yy_xx$$
# docker ps --filter "name=web"  > /tmp/yy_xx$$
# if (docker ps --filter "name=web1" | grep $1)
function killitif {
    docker ps -a  > /tmp/yy_xx$$
    if grep --quiet $1 /tmp/yy_xx$$
     then
     echo "killing older version of $1"
     docker rm -f `docker ps -a | grep $1  | sed -e 's: .*$::'`
   fi
}

docker ps  > /tmp/yy_xx$$
w1="web1"
w2="web2"

# container web1 exists, so we will run the image on web2
if grep --quiet $w1 /tmp/yy_xx$$
then
  # Remove any existing web2 containers
  killitif web2

  # Run the image in web2
  docker run -itd --name=web2 -p:8080 $1

  # Add web2 to the network so it can talk with web1 and
  # the proxy so that the port 8888 points to web2's image
  docker network connect ecs189_default web2

  # Map port 8888 to web2's image
  docker exec ecs189_proxy_1 /bin/bash /bin/swap2.sh

  # Remove the now useless web1
  killitif ecs189_web1_1
  killitif web1

  # docker rm -f ecs189_web1_1
  # docker rm -f web1
elif grep --quiet $w2 /tmp/yy_xx$$
then
	# Remove any existing web1 containers
  killitif web1

  # Launch the image in container web1 with the proxy's network
  docker run -itd --name=web1 -p:8080 $1
  docker network connect ecs189_default web1

  # Point the current webpage to the new web1's image
  docker exec ecs189_proxy_1 /bin/bash /bin/swap1.sh

  # Remove the now useless web2
  killitif ecs189_web2_1
  killitif web2
fi
