# TP 4 : Le MENU

* [Menu 1 : Sécu](#menu-1--secu)
* [Menu 2 : Campus](#menu-2--infra-campus)
* [Menu 3 : Small/medium Office](#menu-3--infra-smallmedium-office)

#### > Principaux axes auxquels penser :

* **sécu**
  * confidentialité
  * intégrité
  * confidentialité
* **HA**
  * haute-disponibilité
  * redondance
  * no SPOF
* **évolutivité**
  * penser à l'augmentation du nombre de clients du réseau
  * penser à un bon nommage des machines

#### > Technos réseau intéressantes à mettre en place :

* firewall
  * sur les machines serveurs
  * en frontal, dans le backbone
* isolation réseau : [VLAN](../../cours/3.md#vlan)
* haute-dispo routeur : HSRP, VRRP
* routage dynamique : [OSPF](../../cours/3.md#ospf)
* supprimer les boucles de réseau L2 : STP
* redondance de liens réseau : LACP, Etherchannel

#### > Service réseau intéressants pour une infra

* DHCP
* DNS
* NTP
* Serv Web
  * pour simuler un intranet ou autres site interne/externe

#### > Bonnes pratiques de configuration de l'infra

* toutes les machines ont un **hostname**
  * il est explicite
* les machines peuvent communiquer à l'aide de hostnames
  * `/etc/hosts` ou DNS
* on peut **accéder à distance aux équipements**
  * SSH ou RDP
  * accès sécurisé
* il existe **un référentiel des machines existantes**
  * on peut facilement connaître leur nom, leur IP, leur rôle dans l'infra

---

# Menu 1 : Secu

**Renforcer la sécurité d'une topologie simple qui comporte quelques services réseaux.**

#### > Infra

* un petit truc suffira
  * backbone (= accès WAN/LAN)
  * switches d'accès clients
  * clients

#### > Sécurité des flux

* firewall frontal
  * pfsense (ou opensense)
  * ou hardened CentOS
* DMZ
* VLANs
* authentification forte sur les équipements
  * SSH (routeurs, switches, VM)

#### > Services réseau

* DNS + DNSSEC
* Serveur Web + WAF 
  * apache + modsecurity
  * NGINX + naxsi
  * ou autres

#### > Monitoring/Métrologie

* inspection de flux réseau
  * détection des flux réseau
  * visualisation
    * genre un dashboard qui affiche clairement l'état du traffic
    * il y a tel trafic qui circule dans tel lien
* DPI (deep packet inspection)

#### > Rendu attendu
* choix + explication des choix effectués
  * en quoi ça c'est secure ? ou + secure qu'autre chose ?
* maquette

---

# Menu 2 : Infra campus

**Fournir un réseau stable à un grand nombre de clients sur un même site.**

#### > Locaux
* 3 bâtiments
  * 2 étages, 5 salles/étages
  * chaque salle supporte au mini 30 clients

#### > Clients du réseau

* ~200 étudiants
  * en moyenne, ils ont 1,5 équipements
    * tous ont un PC
    * certains utilisent smartphone/tablette avec la wifi
* ~50 profs
  * en moyenne, ils ont 1,5 équipements
    * tous ont un PC
    * certains utilisent smartphone/tablette avec la wifi
* ~20 serveurs
* 15 caméras
* 2 admins

#### > Besoin

* les étudiants ont accès à 10 serveurs sur les 20
* les profs ont accès à tous les serveurs
* les admins ont accès à tous les serveurs et aux caméras
* débit descendant WAN exigé : 
  * étudiant/profs/admins : 1Mo/sec
  * serveur : 5Mo/sec

#### > Rendu attendu

* plan d'adressage IP
* plan des VLANs
* schéma de la topologie
* matériel nécessaire
  * pas dans les détails, mais au moins la quantité
  * les câbles, ça compte
* maquette GNS3

> **HINT**  mettez en place une **archi 3-tier** (core/distribution/access) (on aura une partie théorique là-dessus)

---

# Menu 3 : Infra small/medium office

**Fournir un accès Internet robuste et des services réseau utiles et récurrents.**

#### > Locaux

* 1 bâtiment
  * 5 salles
  * 1 à 5 personnes/salle

#### > Clients du réseau

* ~20 personnes pro
* 3 RH
* 1 admin
* 5 serveurs
* 5 imprimantes

> Les gens (RH, pro, admin) n'ont QUE leur PC (pas de tablette/smartphone)

#### > Besoin

* pro et RH joignent les imprimantes et 2 serveurs
* l'admin joint tout le monde
* débit descendant WAN exigé
  * admin, pro, RH : 5Mo/sec 
  * serveur : 50Mo/sec
* besoin d'un VPN pour se connecter à distance
  * Openvpn sur une machine CentOS
* firewall frontal (centos ou pfsense/opensense ou autres)
* serveur web redondé, sécurisé (nginx, haproxy, keepalived, etc.)

#### > Rendu attendu

* plan d'adressage IP
* plan des VLANs
* schéma de la topologie
* matériel nécessaire
  * pas dans les détails, mais au moins la quantité
  * les câbles, ça compte
* maquette GNS3

> **HINT** : Mettez en place un router-on-a-stick
