# SET DEFAULT GATEWAY FOR CLIENT PUBLIC
docker exec -it --privileged client-public ip route del default
docker exec -it --privileged client-public ip route add default via 192.168.100.2

# SET ROUTING FOR ROUTER 1
docker exec -it --privileged router1 iptables -t nat -F
docker exec -it --privileged router1 iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
docker exec -it --privileged router1 ip route add 200.200.0.0/16 via 100.100.200.200

# SET ROUTING FOR VPN SERVER
docker exec -it --privileged vpn-server iptables -t nat -F
docker exec -it --privileged vpn-server iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
docker exec -it --privileged vpn-server ip route add 100.100.0.0/16 via 200.200.200.2

# SET DEFAULT GATEWAY FOR CLIENT PRIVATE
docker exec -it --privileged client-private ip route del default
docker exec -it --privileged client-private ip route add default via 192.168.50.2

# SET DEFAULT GATEWAY FOR SERVER PRIVATE
docker exec -it --privileged server-private ip route del default
docker exec -it --privileged server-private ip route add default via 192.168.50.2

# SETUP CLIENT SSH
SSH_KEY=$(docker exec -it --privileged client-public bash -c "if test -f "/root/.ssh/id_ed25519"; then echo "1"; else echo "0"; fi")
if [ $SSH_KEY = "0" ]; then
    docker exec -it --privileged client-public ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519
fi
SSH_PUB=$(docker exec -it --privileged client-public cat /root/.ssh/id_ed25519.pub)

# SETUP SERVER SSH
docker exec -it --privileged vpn-server mkdir -p /root/.ssh
docker exec -it --privileged vpn-server bash -c "echo $SSH_PUB > /root/.ssh/authorized_keys"
docker exec -it --privileged vpn-server service ssh restart