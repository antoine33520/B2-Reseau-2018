# MENU

Au global :
* principaux axes auxquels penser :
  * sécu
  * HA
  * no SPOF
  * évolutivité
* technos intéressantes à mettre en place :
  * isolation réseau : VLAN
  * haute-dispo routeur : HSRP, VRRP
  * routage dynamique : OSPF
  * supprimer les boucles de réseau L2 : STP
  * redondance de liens réseau : LACP, Etherchannel

---

# Sujet 1 : Secu

* sécu
  * confidentialité
  * intégrité
  * confidentialité
* mettre en place petite infra
  * infra 
    * un petit truc suffira
    * backbone (= accès WAN/LAN)
    * switches d'accès clients
    * clients
  * firewall frontal
    * pfsense (ou opensense)
    * ou hardened CentOS
  * VLANs
  * authentification forte sur les équipements
    * SSH (routeurs, switches, VM)
  * DNS + DNSSEC
  * Serveur Web + WAF 
    * apache/modsecurity
    * nginx/naxsi
  * inspection de flux réseau
    * détection des flux réseau
    * visualisation
      * genre un dashboard qui affiche clairement l'état du traffic
      * il y a tel trafic qui circule dans tel lien
    * DPI (deep packet inspection)
  
---

# Sujet 2 : Infra campus
* Campus
  * 3 bâtiments
    * 2 étages, 5 salles/étages
    * chaque salle supporte au mini 30 clients
  * clients du réseau
    * ~200 étudiants
    * ~50 profs
    * ~20 serveurs
    * 15 caméras
    * 2 admins
  * besoin
    * les étudiants ont accès à 10 serveurs sur les 20
    * les profs ont accès à tous les serveurs
    * les admins ont accès à tous les serveurs et aux caméras
    * débit descendant WAN exigé : 
      * étudiant/profs/admins : 1Mo/sec
      * serveur : 5Mo/sec
  * rendu attendu :
    * plan d'adressage IP
    * plan des VLANs
    * schéma de la topologie
    * matériel nécessaire
      * pas dans les détails, mais au moins la quantité
      * les câbles, ça compte
    * maquette GNS3
  * conseils : archi 3-tier
    * core/distribution/access
    * on va faire une petite partie théorique là-dessus

---

# Sujet 3 : Infra 2 smal/medium office
* Small/Medium office
  * 1 bâtiment
    * 5 salles
  * clients du réseau
    * ~20 personnes pro
    * 3 RH
    * 1 admin
    * 5 serveurs
    * 5 imprimantes
  * besoin
    * pro et RH joignent les imprimantes et 2 serveurs
    * l'admin joint tout le monde
    * débit descendant WAN exigé
      * admin, pro, RH : 5Mo/sec 
      * serveur : 50Mo/sec
    * besoin d'un VPN pour se connecter à distance
      * Openvpn sur une machine CentOS
    * firewall frontal (centos ou pfsense/opensense ou autres)
    * serveur web redondé, sécurisé (nginx, haproxy, keepalived, etc.)
  * rendu attendu
    * plan d'adressage IP
    * plan des VLANs
    * schéma de la topologie
    * matériel nécessaire
      * pas dans les détails, mais au moins la quantité
      * les câbles, ça compte
    * maquette GNS3
      * conseils : router-on-a-stick
