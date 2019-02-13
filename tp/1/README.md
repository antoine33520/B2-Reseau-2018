# B2 Réseau 2018 - TP1

# Notions vues avant le TP

* Manipulations IP et masque (avec le [binaire](../../cours/lexique.md#binaire))
* Notions :
  * IP, Ports, MAC
* Utilisation de CentOS
  * installation simple
  * utilisation CLI simple (cf [les commandes du Lexique](../../cours/lexique.md#commandes))
    * `man`, `cd`, `ls`, `nano`, `cat`
    * `ip a`, `ping`, `nc`, `traceroute`, `ss`
  * configuration réseau (voir la fiche de [procédures](../../cours/procedures.md))
    * configuration d'[interfaces](../../cours/lexique.md#carte-réseau-ou-interface-réseau)
    * gestion simplifié de nom de domaine
      * hostname, FQDN, fichier `/etc/hosts`
    * configuration [firewall](../../cours/lexique.md#pare-feu-ou-firewall)

# TP 1 - Remise dans le bain 

Premier TP un peu tranquille pour se remettre dans le bain. Au programme : 
* des VMs (avec du SSH)
* du routage
* revue de IP, MAC, ports, ARP

# Déroulement et rendu du TP 
* vous utiliserez un l'hyperviseur de votre choix parmi : 
  * [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
  * VMWare Workstation
  * j'utiliserai VirtualBox pour ma part, c'est avec lui que les exemples seront donnés

* les machines virtuelles : 
  * l'OS **devra être** [CentOS 7 (en version minimale)](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso)
  * pas d'interface graphique (que de la ligne de commande)
  
* il y a beaucoup de ligne de commande dans ce TP, préférez les copier/coller aux screens

* [la forme pour le rendu est décrite sur le README du dossier TP](../README.md)

# Hints généraux

* **pour vos recherches Google** (ou autres) : 
  * **en anglais**
  * **précisez l'OS et la version** dans vos recherches ("centos 7" ici)
* dans le TP, **lisez en entier une partie avant de commencer à la réaliser.** Ca donne du sens et aide à la compréhension
* **allez à votre rythme.** Le but n'est pas de finir le TP, mais plutôt de bien saisir et correctement appréhender les différentes notions
* **n'hésitez pas à me demander de l'aide régulièrement** mais essayez toujours de chercher un peu par vous-mêmes avant :)
* pour moult raisons, il sera préférable pendant les cours de réseau de **désactiver votre firewall**. Vous comprendrez ces raisons au fur et à mesure du déroulement du cours très justement. N'oubliez pas de le réactiver après coup.
* **utilisez SSH dès que possible**

---

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
Nous utiliserons CentOS 7 comme support tout au long du cours. La plupart des choses vue sur CentOS sont valables sur d'autres OS GNU/Linux mais aussi sous MacOS, Windows ou autres équipements. Je parle ici de concepts comme table de routage, table ARP, etc. que nous allons explorer dans cette première partie.  

Vous n'aurez besoin que d'**une seule VM pour cette première partie** (clonez le patron qu'on a créé en cours ensemble).    

## 1. Mise en place

Dans cete partie, on va mettre en place une unique VM, qui sera dans deux réseaux : 

Machine | `net1` | `net2`
--- | --- | ---
PC | `10.1.1.1` | `10.1.2.1`
VM (`client1.tp1.b2`) | `10.1.1.2` | `10.1.2.2`

Je ferai en sorte que les IPs choisies pour les TPs soient consistantes. Par exemple, ici, pour `10.1.2.1` :
* `10` : plage d'adresses privées, ce sera toujours `10` au début
* `1` : TP1
* `2` : `net2`
* `1` : premier hôte *(souvent votre PC dans un host-only)*  

Idem pour les noms de domaines.

---

*Pour rappel, quand vous créez un host-only, Virtualbox :*
  * *crée une interface réseau sur le PC hôte*
  * *crée un switch qui s'appelle "vboxnetX"*
  * *branche la carte réseau de l'hôte sur le switch*   

### Configuration de VirtualBox
* créer deux host-only
  * `net1` : `10.1.1.0/24`
    * combien y a-t-il d'adresses disponibles dans un `/24` ?
  * `net2` : `10.1.2.0/30`
    * combien y a-t-il d'adresses disponibles dans un `/30` ?
    * quelle est l'utilité d'un `/30` ?

### Création de la VM
* clone du patron créé ensemble
* réseau :
  * 1 carte NAT
  * 2 cartes host-only (une dans `net1`, l'autre dans `net2`)

### Allumage et configuration de la VM
* [X] Désactiver SELinux
  * déja fait dans le patron
* [X] Installation de certains paquets réseau
  * déja fait dans le patron
* [ ] [définition d'IP statique sur les deux cartes host-only](../../cours/procedures.md#définir-une-ip-statique)
* [ ] connexion en SSH
* [ ] [définition d'un nom de domaine](../../cours/procedures.md#changer-son-nom-de-domaine)
* [ ] [compléter le fichier hosts de la VM](../../cours/procedures.md#editer-le-fichier-hosts)
  * avec toutes ses IPs
  * et les IPs de l'hôte

[ ] s'assurer que les 3 cartes réseaux fonctionnent :
  * NAT : le `ping` est bloqué en sortie à YNOV. Donc : 
    * `curl google.com` si vous êtes à YNOV
    * expliquer le retour que vous obtenez (code retour HTTP `301`)
    * essayez avec `curl -L google.com`
  * `net1` : `ping <IP_HOST_PC>`
    * donc `ping 10.1.1.1`
  * `net2` : `ping <IP_HOST_PC>`
      * donc `ping 10.1.2.1`

## 2. Basics

Les opérations sont à réaliser sur la VM sauf si le contraire est explicitement demandé.  

**On va explorer TOUT ce qu'il se passe lors d'un simple `ping` entre deux machines.**

### Routes

* afficher [les routes](../../cours/1.md#table-de-routage) que connaît votre machine
  * `ip route show`
  * expliquer chacune des lignes

* supprimer une [route](../../cours/1.md#table-de-routage)
  * `sudo ip route del <NETWORK_ADDRESS>`
  * tester qu'elle ne fonctionne plus = tester qu'on ne peut plus utiliser le réseau concerné

* remettre la [route](cours/1.md#table-de-routage)
  * [il y a une procédure dans le cours pour faire ça](../../cours/procedures.md#ajouter-une-route-statique)
  * tester qu'elle fonctionne de nouveau

---

### Table ARP

* afficher [les voisins](../../cours/1.md#table-de-voisinnage-ou-table-arp) que connaît votre machine = la table ARP
  * `ip neigh show` 
    * *"neigh" comme "neighbour" = "voisin"*
  * expliquer chacune des lignes

* [vider la table ARP](../../cours/procedures.md#gérer-sa-table-arp)
  * `sudo ip neigh flush all`
  * vérifier avec `ip neigh show`

* effectuer une requête simple vers l'hôte
  * `ping 10.1.2.1` par exemple
  * afficher de nouveau la table ARP
  * expliquer la nouvelle ligne

---

### Capture réseau

Ce serait encore mieux de voir passer ces petites trames réseau.
* dans le patron on a installé [`tcpdump`](../../cours/lexique.md#tcpdump)
* ça permet de faire de simples captures réseau, afin de les ouvrir dans Wireshark plus tard (= voir toutes les trames réseau qui passent)
* juste un détail :
  * vous êtes actuellement connectés à votre VM en SSH
  * sur une des deux interfaces host-only
  * donc il y a du trafic en permanence sur cette interface, à cause de votre session SSH
  * **donc vous lancerez les captures réseau sur l'autre interface**

Let's go :
* choisir une interface host-only que vous allez utilisez pour `ping` l'hôte (votre PC)
  * celle qui n'est pas utilisée pour votre SSH
  * par exemple `enp0s8`
* [vider la table ARP](../../cours/procedures.md#gérer-sa-table-arp)
* [vérifier qu'elle est vide](../../cours/procedures.md#gérer-sa-table-arp)
* ouvrir deux sessions SSH dans la VM
  * **1** : lancer une capture
    * `sudo tcpdump -i enp0s8 -w ping.pcap`
  * **2** : 
    * s'assurer que la table ARP est toujours vide
    * envoyer 4 `ping`
      * `ping -c 4 <HOST_IP>`
  * **1** : CTRL + C
    * vous devrez avoir capturé 10 paquets
      * 2 pour l'échange ARP
      * 4 ping
      * 4 pong
* récupérer le fichier `ping.pcap` sur l'hôte
  * si vous savez pas comment, faites signe
* explorer la capture dans Wireshark
  * **ce sont des messages très simples, il n'y a que 10 trames, essayez de vraiment tout comprendre**

* l'échange ARP n'est nécessaire que si la table ARP ne contient pas déjà l'IP
  * vous pouvez refaire la capture sans vider la table pour vérifier

---

Si on résume : 
* vous tapez `ping IP`
* la machine regarde si elle a une route pour ce réseau
  * -> si elle n'en a pas : erreur `network unreachable`
* si une route existe et que la machine est directement connectée au réseau
  * -> la machine regarde dans sa table ARP à la recherche de l'`IP` demandée
    * si l'`IP` n'y est pas, il y aura un échange ARP pour ajouter l'`IP` et la MAC associée à la table
    * si l'`IP` y est déjà, aucun échange ARP nécessaire
* à ce stade, la machine :
  * sait que l'`IP` demandée est sur un réseau auquel elle est directement connectée
  * connaît [l'adresse MAC](../../cours/lexique.md#mac--media-access-control) de la machine de destination grâce à [ARP](../../cours/lexique.md#arp--adresse-resolution-protocol)
* le message `ping` est alors envoyé
  * il est dans un paquet à destination de `IP`
  * ce paquet est dans un trame à destination de la bonne [adresse MAC](../../cours/lexique.md#mac--media-access-control)

---

# II. Communication simple entre deux machines

## 1. Mise en place

Machine | `net1` | `net2`
--- | --- | ---
PC | `10.1.1.1` | `10.1.2.1`
`client1.tp1.b2` | `10.1.1.2` | `10.1.2.2`
`client2.tp1.b2` | `10.1.1.3` | X

Clonez une deuxième fois le patron pour avoir un deuxième VM. 
* réseau
  * 1 carte NAT
  * 1 carte host-only dans `net1`  

[Répéter les opérations de configurations](#allumage-et-configuration-de-la-vm) pour cette deuxième VM. 
* n'oubliez pas de mettre à jour le fichier `hosts` de la première VM

## 2. Basics

### `ping` et ARP

* vider les tables ARP des deux machines
* depuis `client1` :
  * `ping -c 4 client2`
* observer le changement dans les tables ARP 
* refaire l'opération en faisant une capture réseau `ping-2.pcap`
  * attention encore à choisir une interface où il n'y a pas de trafic SSH

* récupérer `ping-2.pcap` sur l'hôte et l'analyser dans Wireshark

### `netcat`
[`netcat` ou `nc`](../../cours/lexique.md#nc-ou-netcat) est un outil très simple de fonctionnement et d'utilisation qui permet d'écouter sur un [port](../../cours/lexique.md#ports), ou de se connecter sur un [port](../../cours/lexique.md#ports) distant. On va l'utiliser pour voir un peu comment fonctionnent des connexions TCP et UDP simples.

Afin de permettre à `netcat` d'écouter sur un port, il faudra l'ouvrir dans le firewall. Le firewall de CentOS n'accepte presque rien par défaut.  

#### UDP

Sur `client1`
* [ouvrir le port UDP 8888](../../cours/procedures.md#interagir-avec-le-firewall)
* lancer `netcat` pour qu'il écoute sur le port UDP 8888
  * `nc -u -l 8888`
    * `-u` pour UDP
    * `-l` pour "listen" 
    * `8888` pour le port choisi
Sur `client2`
* se connecter au port 8888 UDP du `client1`
  * `nc -u <IP_CLIENT1> 8888`

Vous devriez avoir un chat simpliste entre les deux machines. Pendant que la connexion est établie : 
* ouvrez un deuxième shell sur chacune des machines
* utilisez [la commande `ss`](../../cours/lexique.md#netstat-ou-ss) sur les deux machines pour voir la connexion établie
  * `ss -unp` fera l'affaire
    * `-u` pour voir les connexions UDP uniquement
    * `-n` pour avoir le numéro des ports plutôt que leurs noms 
    * `-p` pour voir le processus qui tourne derrière
* utilisez [`tcpdump`](../../cours/lexique.md#tcpdump) pour capturer quelques messages
  * capture `nc-udp.pcap`
  * récupérez sur l'hôte et analysez dans Wireshark
    * hint : raisonnez par comparaison avec les captures précédentes de `ping`

#### TCP

Sur `client1`
* [ouvrir le port TCP 8888](../../cours/procedures.md#interagir-avec-le-firewall)
* lancer `netcat` pour qu'il écoute sur le port UDP 8888
  * `nc -l 8888` (TCP c'est par défaut avec `netcat`)
    * `-l` pour "listen" 
    * `8888` pour le port choisi
Sur `client2`
* se connecter au port 8888 UDP du `client1`
  * `nc <IP_CLIENT1> 8888`

Vous devriez avoir un chat simpliste entre les deux machines. Pendant que la connexion est établie : 
* ouvrez un deuxième shell sur chacune des machines
* utilisez [la commande `ss`](../../cours/lexique.md#netstat-ou-ss) sur les deux machines pour voir la connexion établie
  * `ss -tnp` fera l'affaire
    * `-t` pour voir les connexions TCP uniquement
    * `-n` pour avoir le numéro des ports plutôt que leurs noms 
    * `-p` pour voir le processus qui tourne derrière
* utilisez [`tcpdump`](../../cours/lexique.md#tcpdump) pour capturer quelques messages
  * lancer la capture AVANT l'établissement du `netcat`
  * couper la capture APRES avoir couper le `netcat`
  * capture `nc-tcp.pcap`
  * récupérez sur l'hôte et analysez dans Wireshark
    * hint : raisonnez par comparaison avec la capture précédente de `nc-udp.pcap`
    * hint2 : vous devriez voir le "3-way handshake TCP"

---

## 3. Bonus : ARP spoofing

> **Jetez au moins un oeil pour la curiosité.** 

C'est assez facile de faire de l'ARP spoofing (ou ARP cache poisoning) avec une ligne de commande sous la main. C'est un man-in-the-middle qu'on peut réaliser en une commande. Vous pouvez utiliser `arping` pour ça.  

Le but ? Usurpation d'identité sur un réseau local. Essayer de faire croire à `client2` que votre hôte c'est `client1`. [Tout est là](https://sandilands.info/sgordon/arp-spoofing-on-wired-lan). 

---

# III. Routage statique simple

Dans cette partie on va transformer notre `client1` en routeur. Le but sera de permettre à `client2` d'accéder à `net2`.

Sur `client1` :
* "transformer la machine en routeur" = activer l'IPv4 forwarding
  * `sysctl -w net.ipv4.ip_forward=1`

Sur `client2` :
* [ajouter une route statique vers `net2`](./cours/procedures.md#ajouter-une-route-statique)
* `ping 10.1.2.1` pour tester (ip de l'hôte dans `net2`)
* `traceroute 10.1.2.1` pour voir le chemin parcouru par vos paquets

