# B2 Réseau 2018 - Rendu-type TP1

# TP 1 - Remise dans le bain 

# Sommaire

* [I. Exploration du réseau d'une machine CentOS](#i-exploration-du-réseau-dune-machine-centos)
  * [1. Mise en place](#1-mise-en-place)
  * [2. Basics](#2-basics)
    * [Routes](#routes)
    * [Table ARP](#table-arp)
    * [Capture réseau](#capture-réseau)
* [II. Communication simple entre deux machines](#ii-communication-simple-entre-deux-machines)
  * [1. Mise en place](#1-mise-en-place-1)
  * [2. Basics](#2-basics-1)
    * [`ping` et ARP](#ping-et-arp)
    * [`netcat` : TCP et UDP](#netcat)
  * [3. Bonus : ARP spoofing](#3-bonus--arp-spoofing)
* [III. Routage statique simple](#iii-routage-statique-simple)


---

# I. Exploration du réseau d'une machine CentOS

## 1. Mise en place

Toute la mise en place est faite à l'aide de [Vagrant](https://www.vagrantup.com/) :
* vagrant 2.2.4
* virtualbox 6.0
* box `centos/7`
* [Vagrantfile](./vagrant/Vagrantfile)


* `net1` est un `/24`
  * il y a 256 IP possibles dans un /24
  * donc 254 IP disponibles (en enlevant l'adresse de réseau et l'adresse de broadcast car on ne peut pas les utiliser pour assigner des IPs)
* `net2` est un `/30`
  * il y a 4 IP possibles, donc 2 IP disponibles dans un `/30`
  * les avantages sont multiples :
    * clarté : on sait tout de suite qu'il n'y a que 2 hôtes dans ce réseau, c'est une connexion de point à point entre deux machines
    * sécurité : une fois les deux IPs prises par des machines, il n'est pas possible pour un tiers de s'infiltrer dans ce réseau de façon simple

### Allumage et configuration de la VM
Toute la configuration est faite dans le [Vagrantfile](./vagrant/Vagrantfile) et les [scripts d'initialisation](./vagrant/scripts).  

On s'assure ques les interfaces fonctionnent :
* `client1`
```
[vagrant@client1 ~]$ ping -c 2 host.tp1.b2
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=1 ttl=64 time=2.11 ms
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=2 ttl=64 time=0.473 ms
2 packets transmitted, 2 received, 0% packet loss, time 1002ms

[vagrant@client1 ~]$ ping -c 2 client1.tp1.b2
64 bytes from client1.tp1.b2 (127.0.0.1): icmp_seq=1 ttl=64 time=0.036 ms
64 bytes from client1.tp1.b2 (127.0.0.1): icmp_seq=2 ttl=64 time=0.085 ms
2 packets transmitted, 2 received, 0% packet loss, time 999ms

[vagrant@client1 ~]$ ping -c 2 client2.tp1.b2
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=1 ttl=64 time=1.17 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=2 ttl=64 time=0.878 ms
2 packets transmitted, 2 received, 0% packet loss, time 1002ms

[vagrant@client1 ~]$ ping -c 2 10.1.2.1
64 bytes from 10.1.2.1: icmp_seq=1 ttl=64 time=1.33 ms
64 bytes from 10.1.2.1: icmp_seq=2 ttl=64 time=0.391 ms
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
```

* `client2`
```
[vagrant@client2 ~]$ ping -c 2 host.tp1.b2
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=1 ttl=64 time=0.419 ms
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=2 ttl=64 time=0.439 ms
2 packets transmitted, 2 received, 0% packet loss, time 1000ms

[vagrant@client2 ~]$ ping -c 2 client1.tp1.b2
64 bytes from client1.tp1.b2 (10.1.1.2): icmp_seq=1 ttl=64 time=0.760 ms
64 bytes from client1.tp1.b2 (10.1.1.2): icmp_seq=2 ttl=64 time=0.938 ms
2 packets transmitted, 2 received, 0% packet loss, time 1002ms

[vagrant@client2 ~]$ ping -c 2 client2.tp1.b2
64 bytes from client2.tp1.b2 (127.0.0.1): icmp_seq=1 ttl=64 time=0.035 ms
64 bytes from client2.tp1.b2 (127.0.0.1): icmp_seq=2 ttl=64 time=0.083 ms
2 packets transmitted, 2 received, 0% packet loss, time 999ms
```

## 2. Basics

### Routes

* table de routage de `client1`
```
[vagrant@client1 ~]$ ip r s
# Route de l'interface NAT
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
# Route du premier host-only en /24
10.1.1.0/24 dev eth1 proto kernel scope link src 10.1.1.2 metric 101 
# Route du second host-only en /30
10.1.2.0/30 dev eth2 proto kernel scope link src 10.1.2.2 metric 102 
```

* opérations sur la table de routage
```
# Visualisation et utilisation de la route vers 10.1.1.0/24 (net1)
[vagrant@client1 ~]$ ip r s
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
10.1.1.0/24 dev eth1 proto kernel scope link src 10.1.1.2 metric 101 
10.1.2.0/30 dev eth2 proto kernel scope link src 10.1.2.2 metric 102 
[vagrant@client1 ~]$ ping -c 2 client2.tp1.b2
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=1 ttl=64 time=0.463 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=2 ttl=64 time=0.835 ms
2 packets transmitted, 2 received, 0% packet loss, time 1003ms

# Suppression de la route vers net1 et vérification 
[vagrant@client1 ~]$ sudo ip route del 10.1.1.0/24
[vagrant@client1 ~]$ ip r s
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 100 
10.1.2.0/30 dev eth2 proto kernel scope link src 10.1.2.2 metric 102 

# Test du non-fonctionnement
[vagrant@client1 ~]$ ping -c 2 client2.tp1.b2
connect: Network is unreachable

# Ré-insertion de la route (telle qu'elle était énoncée dans le ip r s plus haut)
[vagrant@client1 ~]$ sudo ip route add 10.1.1.0/24 dev eth1 proto kernel scope link src 10.1.1.2 metric 101

# Test du re-fonctionnement
[vagrant@client1 ~]$ ping -c 2 client2.tp1.b2
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=1 ttl=64 time=0.313 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=2 ttl=64 time=0.888 ms
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
```

---

### Table ARP

* visualisation de tous les voisins (table ARP)
```
[vagrant@client1 ~]$ ip n s
# Lien vers la passerelle de la carte NAT
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 DELAY
# Lien vers client1.tp1.b2 (net1)
10.1.1.3 dev eth1 lladdr 08:00:27:10:3e:cc STALE
# Lien vers l'hôte (net2)
10.1.2.1 dev eth2 lladdr 0a:00:27:00:00:02 STALE
# Lien vers l'hôte (net1)
10.1.1.1 dev eth1 lladdr 0a:00:27:00:00:01 STALE
```

* opérations sur la table ARP
```
[vagrant@client1 ~]$ sudo ip n flush all
[vagrant@client1 ~]$ ping -c 2 client2.tp1.b2
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=1 ttl=64 time=1.46 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=2 ttl=64 time=0.774 ms
2 packets transmitted, 2 received, 0% packet loss, time 1002ms

[vagrant@client1 ~]$ ip n s
# Une requête ARP a eu lieu avant le ping pour pouvoir joindre client2
# Une ligne correspondant à sa MAC a donc été ajoutée dans la table ARP
10.1.1.3 dev eth1 lladdr 08:00:27:10:3e:cc REACHABLE

# Etant donnée la connexion SSH utilisée pour se connecter à client1, l'adresse de l'hôte est elle aussi immédiatement revenue
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
```

---

### Capture réseau

* [capture de requête ARP + `ping` de `client1` vers `client2`](./captures/ping.pcap)
```
# Premier shell :
[vagrant@client1 ~]$ sudo ip n flush all 
[vagrant@client1 ~]$ sudo tcpdump -i eth1 -w ping.pcap
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
^C10 packets captured
10 packets received by filter
0 packets dropped by kernel

# Deuxième shell
[vagrant@client1 ~]$ ping -c 4 host.tp1.b2
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=1 ttl=64 time=2.41 ms
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=2 ttl=64 time=0.443 ms
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=3 ttl=64 time=0.426 ms
64 bytes from host.tp1.b2 (10.1.1.1): icmp_seq=4 ttl=64 time=0.418 ms

4 packets transmitted, 4 received, 0% packet loss, time 3008ms
```

# II. Communication simple entre deux machines

## 2. Basics

### `ping` et ARP

* [capture de requête ARP + `ping` de `client1` vers `client2`](./captures/ping-2.pcap)
```
# Premier shell :
[vagrant@client1 ~]$ sudo ip n flush all
[vagrant@client1 ~]$ sudo tcpdump -i eth1 -w ping.pcap
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
^C10 packets captured
10 packets received by filter
0 packets dropped by kernel

# Deuxième shell
[vagrant@client1 ~]$ ping -c 4 client2.tp1.b2
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=1 ttl=64 time=0.447 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=2 ttl=64 time=0.849 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=3 ttl=64 time=0.728 ms
64 bytes from client2.tp1.b2 (10.1.1.3): icmp_seq=4 ttl=64 time=0.927 ms
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
```

---

### `netcat`

* commandes préliminaires
```
[vagrant@client1 ~]$ sudo firewall-cmd --add-port=8888/tcp --permanent
success
[vagrant@client1 ~]$ sudo firewall-cmd --add-port=8888/udp --permanent
success
[vagrant@client1 ~]$ sudo firewall-cmd --reload
success
```

#### UDP

* capture [`nc-udp.pcap`](./captures/nc-udp.pcap)

* sur `client1`
```
# Premier shell
[vagrant@client1 ~]$ nc -l -u 8888
hello
hi
^C

# Deuxième shell
[vagrant@client1 ~]$ sudo tcpdump -i eth1 -w nc-udp.pcap
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
^C2 packets captured
2 packets received by filter
0 packets dropped by kernel
```

* sur `client2`
```
[vagrant@client2 ~]$ nc -u client1.tp1.b2 8888
hello
hi
^C
```

---

#### TCP

* capture [`nc-tcp.pcap`](./captures/nc-tcp.pcap)

* sur `client1`
```
# Premier shell
[vagrant@client1 ~]$ nc -l 8888
hi
hello
^C

# Deuxième shell
[vagrant@client1 ~]$ sudo tcpdump -i eth1 -w nc-udp.pcap
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
^C2 packets captured
2 packets received by filter
0 packets dropped by kernel
```

* sur `client2`
```
[vagrant@client2 ~]$ nc client1.tp1.b2 8888
hi
hello
^C
```

---

#### Firewall

* capture [`firewall.pcap`](./captures/firewall.pcap)

---

## 3. Bonus : ARP spoofing

* `client2` (victime)
```
[vagrant@client2 ~]$ sudo ip n flush all

[vagrant@client2 ~]$ ip n s
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE

[vagrant@client2 ~]$ ping 10.1.1.1
64 bytes from 10.1.1.1: icmp_seq=1 ttl=64 time=0.225 ms
64 bytes from 10.1.1.1: icmp_seq=2 ttl=64 time=0.432 ms
2 packets transmitted, 2 received, 0% packet loss, time 1001ms

[vagrant@client2 ~]$ ip n s
10.1.1.1 dev eth1 lladdr 0a:00:27:00:00:01 REACHABLE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE

# ARP spoof on client 1

[vagrant@client2 ~]$ ip n s
10.1.1.1 dev eth1 lladdr 08:00:27:49:df:6e STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE

[vagrant@client2 ~]$ ping 10.1.1.1
PING 10.1.1.1 (10.1.1.1) 56(84) bytes of data.
^C
5 packets transmitted, 0 received, 100% packet loss, time 4000ms

```

* `client1` (attacker)
```
# Premier shell
sudo sysctl net.ipv4.ip_nonlocal_bind=1
arping -c 4 -A -I eth1 10.1.1.1

# Deuxième shell
sudo tcpdump -i eth1 -w arp-spoof.pcap
tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
^C8 packets captured
8 packets received by filter
0 packets dropped by kernel
```

* [capture ARP spoof](./captures/arp-spoof.pcap)

---

# III. Routage statique simple

* sur `client1` :
```
sysctl -w net.ipv4.ip_forward=1`
```

* sur `client2`
```
[vagrant@client2 ~]$ ip r s
10.0.2.0/24 dev eth0 proto kernel scope link src 10.0.2.15 metric 101 
10.1.1.0/24 dev eth1 proto kernel scope link src 10.1.1.3 metric 100 

[vagrant@client2 ~]$ sudo ip route add 10.1.2.0/30 via 10.1.1.2 dev eth1

[vagrant@client2 ~]$ ping 10.1.2.1
64 bytes from 10.1.2.1: icmp_seq=1 ttl=64 time=1.18 ms
64 bytes from 10.1.2.1: icmp_seq=2 ttl=64 time=0.898 ms
64 bytes from 10.1.2.1: icmp_seq=3 ttl=64 time=1.02 ms
3 packets transmitted, 3 received, 0% packet loss, time 2003ms

[vagrant@client2 ~]$ sudo traceroute -I 10.1.2.1
traceroute to 10.1.2.1 (10.1.2.1), 30 hops max, 60 byte packets
 1  client1.tp1.b2 (10.1.1.2)  0.289 ms  0.143 ms  0.087 ms
 2  10.1.2.1 (10.1.2.1)  0.142 ms  0.165 ms  0.121 ms
```
* notre message passe bien par `client1` avant d'atteindre l'hôte dans `net2`
