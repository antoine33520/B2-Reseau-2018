# B2 Réseau 2018 - TP3

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
  * utilisation de [`tcpdump`](../../cours.lexique.md#tcpdump)

# TP 3 - Utilisation de matériel Cisco 

Dans ce TP on va mettre en place des topologies un peu plus intéressantes. Pour ce faire on va avoir besoin de :
* **GNS3** : 
  * pour virtualiser des routeurs
* **routeurs**
  * gestion du routage entre les différents réseaux
  * permettre un accès à internet
  * dans tout le TP, les "routeurs" seront des Cisco 3640
* **switches**
  * gestion des VLANs
  * permet aux clients d'accéder au réseau
  * dans tout le TP, les "switches" seront des iOU Cisco

On va mettre en place plusieurs labs pour y aller petit à petit.  

Le dernier lab est une topo que l'on voit souvent : c'est le principe du *router-on-a-stick.* C'est simple à mettre en place, et ça permet répodnre aux besoin de beaucoup de petites boîtes.

# Déroulement et rendu du TP 
* vous aurez besoin de : 
  * [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
  * [GNS3](https://www.gns3.com/)

* les machines virtuelles Linux : 
  * l'OS **devra être** [CentOS 7 (en version minimale)](http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso)
  * pas d'interface graphique (que de la ligne de commande)
  
* les routeurs Cisco :
  * l'iOS devra être celui d'un [Cisco 3640](https://drive.google.com/drive/folders/1DFe2u5tZldL_y_UYm32ZbmT0cIfgQM2p)

* les switches :
  * afin d'utiliser GNS3 comme plateforme pour tous les labs, on utilisera les [iOU dispos sur le même drive]()
  * on va faire l'install ensemble

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

*

---

# I. Manipulation de switches et de VLAN

Dans cette partie on va mettre en place de simples Switches Cisco afin de permettre la connectivité entre plusieurs clients.  

On va aussi mettre en place des VLANs afin d'isoler certaines parties du trafic.  

# 1. Mise en place

#### Topologie
```
client1           SW1                  SW 2
+----+         +-------+            +-------+
|    +---------+       +------------+       |
+----+         +---+---+            +---+---+
                   |                    |
                   |                    |
                   |                    |
                   |                    |
                +--+-+               +--+-+
                |    |               |    |
                +----+               +----+
               client2               client3
```

#### Réseau(x)
* `lab1-net1` : `10.1.1.0/24`

#### Tableau d'adressage

Hosts | `lab1-net1`
--- | ---
`client1.lab1.tp1` | `10.1.1.1/24`
`client2.lab1.tp1` | `10.1.1.2/24`
`client3.lab1.tp1` | `10.1.1.3/24`

#### Vérification de mise en place
* [ ] [Nom de domaines](../../cours/procedures.md#changer-son-nom-de-domaine) sur toutes les machines
* [ ] Toutes les machines doivent pouvoir se `ping`

# 2. Mise en place des VLANs
