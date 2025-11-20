# Kubernetes

## Introduction à Kubernetes

Kubernetes existe dans le but de pallier à certain problèmes que l'on pourrait rencontrer dans le cadre de l'utilisation de Docker. Par exemple, il est souvent délicat de devoir déployer manuellement des conteneurs, en particulier si ces derniers finissent par avoir un soucis et se stopper suite à une erreur. A l'heure actuelle, le deploiement Docker demandera la majorité du temps une personne présente en temps réelle pour gérer les conteneurs un par un, ce qui risque d'augmenter rapidement les coups de déploiement d'une application, en particulier si ce déploiement a lieu dans le cloud comme sur des services tels qu'**Azure**, **GCP** ou **AWS**.

Dans un contexte de déploiement professionnel, l'autre cas de figure qui pourrait se présenter est la nécessité de devoir démultiplier ou réduire le nombre de conteneurs de notre application en cas de forte demande ou en cas de pause temporaire de la demande. Pour ce faire, Kubernetes est un service optimal nous assurant un scaling de notre application en temps réel, en plus de permettre de redistribuer les demande des clients vers les différents conteneurs de sorte à éviter une trop forte demande de performance d'un conteneur en particulier. Le tout mis dans le cadre d'une multitudes de conteneurs pouvant tourner non par sur une seule machine hôte mais bien sur plusieurs machines rend les capacités de Kubernetes nécessaire dans le monde actuel, en particulier si l'on veut se mesurer aux géants de ce monde. La plupart des fournisseurs de services Cloud offrent d'ailleurs la possibilité de déploier une application en se servant des services tels que l'**Auto-Scaling** ou le **Load Balancing**.


### Le Jargon Kubernetes

Dans l'univers de Kubernetes, il existe plusieurs mot-clés essentiels qu'il est bon de connaitre afin de pouvoir éviter les soucis de compréhension future. 

Un déploiement Kubernetes donne lieu à la création d'un `cluster`, qui consiste en une multitude de `nodes` pouvant être de deux types:

* Les `master nodes` dont l'objectif est la manipulation des autres nodes. Celles-ci disposent dans leur fonctionnement de plusieurs composants essentiels tels qu'une API, des outils de plannification, etc... L'élément important à retenir est la capacité des master nodes à se servir d'un `control plane`.
* Les `worker nodes` qui sont de leur côté les réels éléments de travail dans un cluster Kubernetes. Ces worker nodes sont en général plus nombreuses et peuvent être de plusieurs types. La plupart du temps, chaque nodes de travail se voit être une machine virtuelle différente, permettant ainsi la spécialisation des conteneurs travaillant dans leur infrastructure interne. Pour fonctionner, ces nodes utilisent des `configurations`, des `proxys` ainsi que des `pods`. Un groupement de pods se verra la plupart du temps rassembler derrière un `service`, qui a pour rôle d'assurer la communication entre les éléments et de d'exposer une IP unique pour chaque pod.

### Composants Kubernetes

Pour fonctionner, Kubernetes utilise plusieurs composants. Chaque composant a un rôle propre participant à l'ensemble:

* **API Server**: Point d'entrée du cluster exposant l'API REST. Valide et transforme les requêtes, applique l'authentification/autorisation et écrit/lit l'état dans etcd. Tous les composants communiquent principalement avec l'API Server.
* **etcd**: Magasin clé-valeur distribué et tolérant aux pannes qui contient l'état persistant du cluster (source de vérité). L'API Server y stocke et récupère les objets Kubernetes.
* **Kubelet**: Agent présent sur chaque node qui reçoit les spécifications de pods depuis l'API Server et veille à ce que les conteneurs décrits soient démarrés, surveillés et reportés (état, probes, volumes, etc.).
* **Container runtime**: Composant local responsable du téléchargement des images et de l'exécution des conteneurs (ex. containerd, CRI-O). Il gère le cycle de vie des conteneurs demandé par le kubelet.
* **Controller**: Boucle de contrôle (ou ensemble de contrôleurs) qui observe l'état réel via l'API Server et effectue les actions nécessaires pour atteindre l'état désiré (ex. réplication, déploiement, services, gestion des endpoints).
* **Scheduler**: Composant qui assigne les pods non planifiés aux nodes en évaluant contraintes et ressources (CPU, mémoire, affinités, taints/tolerations, policy) pour choisir le node le plus approprié.

### Les Master Nodes

Les nodes maîtresses ont une architecture plus spécialisée dans la gestion que les nodes de travail. En effet, chaque node maîtresse possède dans son infrastructure le `Serveur API` dont les kubelets présents sur les nodes ouvrières se servent pour discuter avec la node maîtresse. L'autre élément important d'une node maîtresse est la présence d'un `Scheduler`, dont l'objectif est ici la sélection de la node de travail la plus optimale pour le stockage et le lancement d'un ou de plusieurs conteneurs lors de la création d'un nouveau déploiement. Les déploiements sont ensuite gérés par un ou plusieurs `contrôleurs`, l'application de gestion se trouvant aussi dans l'infrastructure de notre node maîtresse responsable de la logique métier. Enfin, il est possible de trouver également un `gestionnaire cloud spécifique` en fonction du service en ligne dans lequel nous sonmmes en train de réaliser notre cluster, comme c'est bien souvent le cas des grands du Cloud comme **AWS**. Il est ainsi possible, via une node maîtresse, d'assurer le fonctionnement de nodes de travail à la fois dans le même serveur / ordinateur mais également dans des emplacements Web complètements différents, ce grâce à la présence de l'API et des autres sous-services possédés par la node.

### Les Worker Nodes

Une node ouvrière est capable de gérer un ou plusieurs conteneurs. Ces conteneurs seront la plupart du temps situés dans des `Pods`, qui sont des sous-ensemble regroupant le ou les conteneurs, ainsi qu'au besoin des volumes. Il est facile de se représenter une node de travail comme étant notre ordinateur, mais il ne faut pas oublier que ces dernières peuvent être à la fois des machines physiques mais aussi des virtualisation d'ordinateurs. 

Chaque node de travail dispose pour sont fonctionnement d'un agent `kubelet`, qui a pour rôle d'assurer la communication entre les nodes, en particulier avec la node maîtresse, d'un `Container Runtime` dans le but de faire tourner les conteneurs (qui peut être Docker mais également autre chose comme rkt ou CRI-O) et d'un proxy qui est utilisé dans le cadre d'une communication inter-nodes. 

Une node de travail ne peut exister en solitaire, et il lui faut pour assurer son fonctionnement la supervision d'une node maîtresse dont l'objectif est le management des multitudes de nodes de travail, un peu comme un développeur assurerait le lancement ou le déploiement de X conteneurs sur X machines, mais de façon automatisée et configurable.

### Kubectl

**Kubectl** est l'outil servant à l'administration d'un cluster K8s, Il s'agit d'une application en ligne de commande permettant d'opérer des changement au sein du cluster. Par exemple: 

```bash
# Pour lancer un nouveau déploiementkubectl run hello-minikube

# Pour obtenir des informations sur l'état du cluster
kubectl cluster-info

# Pour obtenir un listing des différents nodes disponibles dans le cluster
kubectl get nodes
```

### Docker vs Containerd

A l'origine, Docker était en quelque sorte la seule solution viable dans le but de conteneuriser les applications. Lors de l'arrivée sur le marché de Kubernetes, le chois a rapidement été fait de proposer d'orchestrer des conteneurs dépployés via Docker. Il est cependant possible de fonctionner autrement qu'avec Docker de par l'ajout dans Kubernetes de la **CRI** (Container Runtime Interface). Par l'ajout de cette interface, il est possible pour d'autres solutions de conteneurisation de s'ajouter dans le monde de Kubernetes à condition de respecter les **OCI** (Open Container Initiative, des specifications techniques sur le comment une image doit être réalisée). Cependant, Docker lui-même ne respectait pas les CRI, ce qui a forcé Kubernetes à introduire `dockershim`, un fix temporaire permettant de continuer de supporter Docker malgré tout. 

Docker, de son côté, est composé de plusieurs outils, tel que le CLI, l'API, les outils de build, etc... dont le runtime nommé `runc`. Ce runtime fonctionne via le daemon qui se trouve être `containerd`. Ce daemon, lui, est compatible avec les CRI de Kubernetes et peut donc être utilisé en solitaire. Arrivé à la version 1.24 de Kubernetes, le maintient du développement de dockershim fut stoppé et le support pour Docker arreté. Les images Docker continuaient cependant de fonctionner de par leur respect des specificités relatives au images (**imagespec**).

De par son autonomie, il est donc possible d'utiliser containerd en solo pour déployer des conteneurs. Le CLI est nommé `ctr` mais n'est pas très user-friendly. Une meilleure alternative se trouve être d'utiliser `nerdctl` proposant une interface similaire avec Docker et propose la majorité de ses options. Il propose d'ailleurs l'accès à des features plus récentes de containerd telle que l'**encryption des images de conteneurs**, la **distribution des images en peer-to-peer**, la **vérification et signature des images** ainsi que le **lazy pulling**, la **vérification des namespaces dans K8s** entre autres choses.

```bash
# docker
nerdctl

# docker run --name redis redis:alpine
nerdctl run --name redis redis:alpine

# docker run --name webserver -p 80:80 nginx
nerdctl run --name webserver -p 80:80 nginx
```

A côté de ça, il est possible d'utiliser également le CLI `crictl` offrant une interface compatible avec le CRI et utilisée pour inspecter ou déboguer les lancements de conteneurs. Il ne sert pas à créer des conteneurs mais fonctionne dans plusieurs runtimes. Il sert de branchement entre les différents outils de gestion de conteneurs et K8s. Encore une fois, les commandes sont similaires à celles de docker mais offrent un peu plus d'options comme la gestion directe des pods: 

```bash
# docker
crictl

# docker pull busybox
crictl pull busybox

# docker images
crictl images

# docker ps -a
crictl ps -a

# docker exec -it 33sddqsd5sd6 ls
crictl exec -it 33sddqsd5sd6 ls

# docker logs 33sddqsd5sd6
crictl logs 33sddqsd5sd6

# Pas d'equivalent
crictl pods
```

Malgré tout, la popularité de Docker en fait encore aujourd'hui un outil de choix et il n'est pas forcément nécessaire de passer à un système de gestion de conteneur autre (c'est juste rendu possible de par l'ajout de la CRI depuis **K8s 1.24**).

### Minikube

Pour travailler facilement avec Kubernetes et pour notre apprentissage, deux options s'offrent à nous si l'on a pas envie de se ruiner en création de cluster chez les cloud providers. LA solution la plus aisée est l'utilisation de **Minikube**, qui est un service permettant le lancement d'une machine virtuelle (qui peut d'ailleurs être dans un Docker), dont l'objectif sera la création d'un ensemble master-worker node unique nous permettant de gérer des pods de façon aisée. Pour installer minkube, le plus simple est de passer par l'utilisation d'un gestionnaire de packages tels que **Chocolatey** et d'entrer la ligne de commande ci-dessous dans un terminal ouvert avec les privilèges administrateur: 

```bash
choco install minikube kubernetes-cli
```

Gra^ce à cette ligne de commande, l'installation de minikube ainsi que de `kubectl`, l'outil d'administration de Kubernetes, se réalisera généralement sans encombre. Une fois l'installation effectuée, il ne restera plus qu'à créer notre cluster dans lequel on va pouvoir déploier nos applicatifs via la ligne de commande ci-dessous: 

```bash
# Pour démarrer notre cluster
minikube start 

# Pour connaitre l'état de fonctionnement du service minikube
minikube status

# Pour arrêter notre cluster
minikube stop
```

### Kind

L'autre possibilité est l'utilisation de **Kind**, qui, contrairement à minikube, permet la création de cluster plus complexes. Via l'utilisation de Kind, il est ainsi possible sur un même ordinateur de virtualiser plusieurs fausses machines virtuelles via des configurations sur la forme d'un ou de plusieurs fichiers `.yml`. L'utilisation de Kind est cependant plus complexe, et il vaut mieux avoir déjà un peu de pratique dans l'environnement Kubernetes pour comprendre réellement comment s'en servir. 

Son installation n'est cependant pas plus compliquée que celle de minikube, en particulier si l'on a, encore une fois, recourt à un gestionnaire de paquets tels que **Chocolatey**:

```bash
choco install kind kubernetes-cli
```

Pour démarrer un environnement dans lequel on peut déploier nos applicatifs avec Kind, les lignes de commandes suivantes sont nécessaires: 

```bash
# Pour démarrer un cluster ne possédant d'une node maîtresse
kind create cluster

# Pour stopper le cluster
kind delete cluster
```

Pour aller plus loin, en particulier pour créer des structures plus complexes avec X nodes maîtresses et / ou X nodes de travail, il va falloir utiliser l'option `--config chemin/vers/fichier.yml`. De plus, pour changer le nom de notre cluster, on peut utiliser l'option `--name nom-cluster`.

## Bases de Kubernetes

### Les objets Kubernetes

Dans l'univers de Kubernetes, les éléments auprès desquels nous allons travailler et que nous manipulerons auront pour dénomination des objets. Ces objets peuvent être de plusieurs type:

* **Pods**: Un pod est une unité de fonctionnement. Il contient en général un (ou plusieurs) conteneur ainsi que ses volumes dans le cas où ce dernier demandent l'utilisation de volumes. Chaque conteneur au sein du même pod peuvent communiquer entre eux de par leur partage de `localhost`. Les pods sont des petites unités éphémères, et Kubernetes va se chercher de stopper / créer / relancer des pods en cas de besoin. La gestion des pods passe en général par l'utilisatio d'un déploiement. 
* **Deployment**: Un déploiement concerne la création de conteneurs sur un ou plusieurs pods, et permet le lancement des conteneurs dans une ou plusieurs nodes, qui seront assignées par le scheduler d'une node maîtresse. L'objet de déploiement cherche simplement à faire atteindre à notre cluster un état en particulier, et opérera les modifications nécessaire au passage de l'état actuel vers celui désiré. Les déploiements peuvent être mit en pause, supprimé, etc... et permettent la scalabilité de notre cluster. Via nos déploiement, nous gérons les pods. Il n'est donc pas nécessaire de gérer manuellement les pods des worker nodes.
* **Service**: Un service sert à regrouper et à gérer l'IP privée d'un ou de plusieurs pods dans le but d'idéalement y accéder en dehors du cluster. Par défaut, les pods auront une adresse IP qu'il est difficile de connaître, mais il est possible, via un service, de regrouper un ou plusieurs pods derrière une adresse IP, ce dans le but de les exposer à d'autres pods ou de les rendre accessible à l'extérieur du cluster. Sans service, la communication vers et depuis les pods est difficile à mettre en place. 
* **Volume**: Un volume est un espace dédié au stockage des données de nos applications
* ...

Dans l'utilisation de Kubernetes, il existe deux méthodes principale de lancement et de manipulation des objets. La première, dite **impérative**, correspond au lancement des différents objets et leur manipulation par des lignes de commande. De la sorte, nous avons à peu près le même fonctionnement que lorsque l'on utilisait les commandes Docker classique. L'autre méthode est dite la méthode **déclarative**, et concerne l'utilisation de fichiers de configuration contenant les différents objets, cette méthode s'apparente à l'utilisation de Docker Compose et permet d'appliquer, d'éditer ou de supprimer des éléments Kubernetes en une ligne de commande. 


### L'approche impérative

Lorsque l'on utilise l'approche impérative, il va nous falloir utiliser beaucoup de lignes de commandes. Ces lignes de commandes permettent de mettre en place nos objets, de les éditer et si l'on le veut de les détruire. Pour pouvoir entrer des commandes, il nous faut nous assurer que l'interface en lignes de commande de Kubernetes est installée sur notre machine (`kubectl version --client --output=yaml`).

Prennons l'exemple d'un déploiement d'une application simple. Notre application a, dans un premier temps, besoin d'être dockerizée pour être disponible dans Kubernetes (rappelons le, Kubernetes n'a pas pour objectif de remplacer Docker mais d'étendre ses capacités). Une fois notre application dockerizée, son placement et fonctionnement au sein d'un cluster passera par la création d'un pod qui se chargera de lancer le ou les conteneurs de notre application. Ce pod devra être situé dans une node de travail, et l'ensemble de ce processus sera rendu possible via la création d'un déploiement. 

Il est possible de créer un pod possédant une image de conteneur de notre choix via la commande:

```bash
kubectl run nginx --image=nginx

# ou pour obtenir uniquement le manifeste
kubectl run nginx --image=nginx --dry-run=client -o yaml 

```

Pour créer un déploiement, il n'y a rien de plus simple, il suffit d'utiliser la commande `kubectl create deployment nom-deploiement` en usant de l'option `--image` de sorte à indiquer quelle est l'image docker dont notre cluster a besoin:

```bash
kubectl create deployment dep-001 --image=mon-repo/mon-image

# Et pour choisir directement le nombre de replicas
kubectl create deployment dep-001 --image=mon-repo/mon-image --replicas=5
```

On observe ici également qu'il nous faut avoir recourt à l'utilisation d'un lien d'image sous la forme d'un repository distant. En effet, le cluster n'a pas pour objectif d'être sur notre machine, et il est naturel que ce dernier ne s'amuse donc pas à tranférer nos images automatiquement depuis notre stockage local vers le cluster. Pour ce faire, il va `docker pull`, et il lui faut donc le nom d'une image disponible, par exemple sur Dockerhub. La syntaxe est donc celle observée plus haut.

Dans le cas où l'on travaille avec `minikube`, il est possible de bénéficier d'une interface graphique (application web) dans le but d'observe l'état de notre cluster. Pour en bénéficier, il suffit d'entrer la ligne de commande ci-dessous dans notre terminal:

```bash
minikube dashboard
```

> Il est également possible d'avoir cette interface lorsque l'on utilise `kind`, mais pour ce faire, il nous faut dans un premier temps la configurer.

Une fois notre déploiement réaliser, il peut être intéressant de le rendre accessible à l'extérieur du cluster. Pour cela, il va nous falloir réaliser un service. Les services ont pour objectif d'aider à fixer et à atteindre les adresses IP de nos pods dans le but de permettre la communication intra-cluster mais également vers ou depuis l'extérieur.

Il existe plusieurs types principaux de services, chacun ayant ses avantages et ses inconvénients: 

* **ClusterIP**: Le déploiement va se voir affecté une (ou plusieurs si plusieurs pods) adresse IP qui ne sera accessible qu'au sein du Cluster. Via ce service, il est plus aisé de créer de la communication intra-cluster entre nos pods.
* **NodePort**: Le déploiement va s'adapter pour exposer à l'extérieur du cluster l'IP de la node de travail sur laquelle tourne le pod. Via ce service il est possible de communiquer en dehors du cluster, par exemple pour créer des sites webs.
* **LoadBalancer**: Le déploiement va s'adapter pour créer une IP extérieure au cluster qui sera ciblable par de potentiels clients, cette IP va de son côté automatiquement cibler un node / pod disponible, et va attaquer un autre node / pod concerné par le même déploiement en cas de surcharge. De la sorte, on peut créer des applications gérant de multiples requêtes sans surcharger une machine en particulier.

```bash
# Laisser Kubernetes choisir le nodePort
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=NodePort --name=nginx-service

# Récupérer le port assigné :
kubectl get svc nginx-service

# Ou fixer explicitement le nodePort (ex. 30080)
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=NodePort --name=nginx-service --node-port=30080

# Via ClusterIP (service interne au cluster) :
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=ClusterIP --name=nginx-service

# Via LoadBalancer (demande une IP externe fournie par le cloud provider ; en local l'EXTERNAL-IP peut rester <pending>) :
kubectl expose deployment nginx-deployment --port=80 --target-port=80 --type=LoadBalancer --name=nginx-service
```

Notes rapides :
- En local avec Minikube : utilisez `minikube service nginx-service` ou `minikube tunnel` pour obtenir un accès externe.
- Avec Kind, un LoadBalancer nécessite une configuration additionnelle (voir la doc Kind LoadBalancer).
- Préférez préciser `--target-port` si le conteneur n'écoute pas exactement sur le port exposé.
- Utilisez `kubectl get svc -o wide` pour voir toutes les informations du service.
```

Dans le cas de l'utilisation de `LoadBalancer`, l'IP externe ne sera disponible de base que si l'on lance ce service dans un environnement cloud capable de gérer ce type de services. Dans le cas contraire, par exemple pour notre cluster local, il va nous falloir quelques étapes en plus pour donner une IP à notre service, qui restera `<pending>` en attendant. 

Pour atteindre notre service depuis l'extérieur du cluster, il est possible d'avoir recourt au port-forwarding: 

```bash
kubectl port-forward svc/<service-name> <port-hote>:<port-service>
```

Pour minikube, ce n'est pas très compliqué, il va nous falloir utiliser `minikube service nom-service` pour exposer à l'extérieur du cluster notre **LoadBalancer**. Dans le cas de kind, il est possible de suivre un tutoriel (disponible [ici](https://kind.sigs.k8s.io/docs/user/loadbalancer/)) mais il est important de savoir que l'IP ne sera attaquable en dehors du cluster qu'en cas d'utilisation d'un environnement **Linux** et d'utilisation de **Docker Engine**.

Une fois notre service créé, il peut être intéressant, dans le cas d'un LoadBalancer, d'augmenter le nombre de conteneurs pour notre application, vu que l'IP rendue disponible par le load balancer sera dynamiquement transformée en l'IP d'un pod disponible. 

Pour augmenter le nombre de pods, on peut utiliser l'édition de notre déploiement, via la commande `kubectl scale nom-deploiement`. Dans le but d'augmenter le nombre de pods, il va falloir changer le nombre de `replicas`. Pour cela, l'option `--replicas number` va rendre cela assez aisé.

```bash
kubectl scale nom-dep --replicas 5
```

Si l'on souhaite modifier l'image Docker d'un déploiement, il est possible de modifier nos objets kubernetes via la commande `kubectl set`. Dans notre cas, on va avoir une syntaxe de la sorte:

```bash
kubectl set image deployment/deployment-name old-image-name=new-image-name:different-tag
```

Le pull d'une image Docker ne se fera cependant pas sans avoir un tag différent, il est donc important de faire attention à changer le tag de notre image dans le but de pouvoir changer notre déploiement.

Pour observer le status d'un déploiement, on peut utiliser la commande:

```bash
kubectl rollout status deployment/dep-name
```

En cas d'erreur ou si l'on souhaite revenir à l'ancienne version de notre déploiement, il est possible d'effectuer un rollback via la commande:

```bash
kubectl rollout undo deployment/dep-name

# Pour spécifier une version en particulier, on peut utiliser:
kubectl rollout undo deployment/dep-name --to-revision revision-number
```

On peut également consulter l'historique de nos changements via la commande:

```bash
kubectl rollout history deployment/dep-name
```

### L'approche déclarative

Jusqu'à maintenant, nous avions eu recourt à l'approche impérative pour travailler dans Kubernetes. Cette approche permet de réaliser l'essentiel des fonctionnalités de Kubernetes, mais elle possède un désavantage de taille: Il nous faut, tout comme c'est le cas de docker sans l'utilisation de Docker Compose, connaître par coeur toutes les commandes et toutes les options dont nous avons besoin, en plus de les utiliser dans le bon ordre. Si l'on le veut, il est possible, encore une fois, de créer un fichier texte contenant toutes nos commandes et de copier coller une à une chacune d'entre elle dans le but de les exécuter. 

Ce processus est cependant lent et fastidieux, et quitte à créer un fichier, il serait de bon ton de créer un fichier plus adapté à notre objectif. C'est pour cela que l'approche déclarative existe. Grâce à elle, il va être possible de stocker un ou plusieurs fichiers décrivant les objectifs (les objets et leurs propriétés que l'on veut voir présent) et via une commande, il sera possible d'appliquer ou de retirer telle ou telle configuration.

Pour exécuter un fichier de configuration, tout ce que nous avons à faire est d'utiliser des commandes:

```bash
# Pour ajouter une ressource via un fichier de ressource (possible de s'en servir pour l'update également)
kubectl apply -f chemin/vers/fichier.yml

# Pour supprimer une ressource via un fichier de ressource
kubectl delete -f chemin/vers/fichier.yml

# Pour modifier une ressource via un fichier de ressource (va recréer les pods)
kubectl replace -f chemin/vers/fichier.yml
```

Les fichiers de configuration d'entité K8s ressemblent à cela: 

```yaml
apiVersion:
kind:
metadata:
  name:
  labels:
    app: myapp
    type: mytype

spec:
  ...
```

- **apiVersion**: Indique le groupe et la version de l'API (ex. `v1`, `apps/v1`) utilisés pour valider et interpréter la ressource. Détermine le schéma attendu et la compatibilité lors de l'application du YAML.
- **kind**: Le type de ressource Kubernetes décrite (ex. `Pod`, `Deployment`, `Service`). Guide le contrôleur et l'API Server sur le comportement et les champs attendus.
- **metadata**: Métadonnées de la ressource (ex. `name`, `namespace`, `labels`, `annotations`). Sert à l'identification, au regroupement (labels) et au stockage d'informations non fonctionnelles (annotations).
- **spec**: La spécification de l'état souhaité pour la ressource — champs propres au `kind` (ex. `replicas`, `template`, `selector`, `containers`, `ports`). C'est la partie déclarative que Kubernetes tente de réaliser.

Pour voir les ressources d'un certain type au sein de notre cluster, on peut effectuer les commandes suivantes:

```bash
# Pour voir la ressource et son état
kubectl get <resource-type>/<resource-name>

# Pour extraire le fichier de configuration de la ressource
kubectl get <resource-type>/<resource-name> -o yaml
```

Dans le cas où l'on aurait besoin d'un peu de documentation, directement depuis le terminal, il est possible de l'avoir via la commande `kubectl explain` tel que:

```bash
kubectl explain pods

# Pour en voir un résumé de l'ensemble:
kubectl explain pods --recursive

# Ou pour aller plus en détail:
kubectl explain pod.spec.containers
```

Dans le cas où l'on aimerai savoir quelle version de l'API utiliser lors de l'écriture des fichiers de ressources K8s, on peut également utiliser la commande `kubectl api-resources`.

#### Pods

Un pod est une abstraction de conteneur et est la plus petit ressource possible de créer dans un environnement K8s. Un pod à une durée de vie ephémère et a pour objectif de permettre le lancement d'une application conteneurisée au sein du cluster. Il est possible de faire fonctionner plusieurs conteneurs au sein d'un pod, par exemple dans le cadre de conteneurs helpers qui vont être nécessaire au bon fonctionnement de l'applicatif. Il est cependant important de retenir que la destruction d'un pod entrainera la destruction de l'ensemble de ses conteneurs. De même, le scaling horizontal d'un pod va entrainer la modification du nombre de l'ensemble des conteneurs qui lui sont assignés.

Un fichier de configuration de pod peut ressembler à ceci: 

```yaml
# pod-example.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: mytype

spec:
  containers:
      - name: myapp-container
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
```


Dans le cas d'un besoin de modification, il nous suffira de changer les informations dans le fichier de ressources et de l'appliquer à nouveau. Du moment que le nom de notre objet est le même, il s'agira d'une édition. De plus, il faut savoir qu'il est possible de fusionner plusieurs ressources en un seul fichier. Dans le YAML, il est possible de séparer des sections via `---`:

```yaml
# Fichier A

---

# Fichier B
```

#### Variables d'environnement

Si l'on le veux, on peut également utiliser des variables d'environnement dans notre environnement K8s. Il est possible de le faire via l'ajout en texte brute ou via des références à une **ConfigMap**. Dans le cas de données sensibles, il est également possible d'avoir recourt à des ressources K8s particulières pour cela telle qu'un **Secret**.

```yaml
# pod-example-env.yaml

apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
  labels:
    app: ubuntu-sleeper
spec:
  containers:
      - name: ubuntu-sleeper
        image: ubuntu
        env:
          - name: <key>
            value: <value>
```

```yaml
# pod-example-configmap.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
      - name: myapp-container
        image: ubuntu
        envFrom:
          - configMapRef: 
              name: myapp-configmap

```

```yaml
# pod-example-secret.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
      - name: myapp-container
        image: ubuntu
        envFrom:
          - secretRef: 
              name: myapp-secret

```

#### ConfigMAps

Por stocker des ensembles de clés-valeurs en dehors de la définition d'un pod et pouvoir ainsi s'en servir comme référence pour une ou plusieurs autres ressources K8s, on a recourt à l'utilisation de **ConfigMaps**. Cette ressource est assez simple à configurer de par la structure assez simpliste de son fichier. Une fois la ressource créée, il suffira de nous en servir comme référence dans un pod afin de pouvoir en extraire des valeurs.

Dans le cas où l'on souhaiterai créer une ConfigMap via l'utilisation de l'approche impérative, on peut passer par cet ensemble de commande:

```bash
kubectl create configmap <configmap-name> \
    --from-literal=<key>=<value> \
    --from-literal=<key>=<value>

# Exemple
kubectl create configmap app-config \
    --from-literal=APP_COLOR=blue \
    --from-literal=APP_MODE=prod

# On peut aussi passer par un fichier
kubectl create configmap app-config --from-file=app_config.properties
```

Le fichier devra alors ressembler à ceci:

```text
# app_config.properties

APP_COLOR=blue
APP_MODE=prod
```

Une autre option est de passer par l'approche déclarative et d'utiliser, comme d'habitude, un fichier de ressources. Un fichier de ConfigMap pourrait ressembler à ceci:

```yaml
# configmap-example.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-configmap
data:
  APP_COLOR: blue
  APP_MODE: prod
```

#### Secrets

Si les données que l'on veut stocker ont besoin d'une sécurité particulière, il vaut mieux utiliser la ressource de type **Secret**. De part l'usage de cette ressource, les données se voient encryptées via hashing. Le fonctionnement est similaire aux ConfigMaps, et il est possible de le faire aussi de façon impérative:

```bash
kubectl create secret <secret-type> <secret-name> \
    --from-literal=<key>=<value> \
    --from-literal=<key>=<value> 

# Exemple
kubectl create secret generic app-config \
    --from-literal=DB_HOST=mysql \
    --from-literal=DB_USER=root \
    --from-literal=DB_PASSWORD=passwprd 

# On peut aussi passer par un fichier
kubectl create secret generic app-config --from-file=app_config.properties
```

Si l'on privilégie l'approche déclarative, on peut créer un fichier de secrets. Il faudra cependant y entrer les données déjà hashée, tel que:

```yaml
# secret-example.yaml

apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret
data:
  DB_HOST: bXlzcWw=
  DB_USER: cm9vdA==
  DB_PASSWORD: cGFzd3Jk
```

#### Replicasets

A l'origine, la ressource K8s permettant la création d'ensemble de pods se nommait un **Replication Controller**. Cette entité est toujours disponible et il est tout à fait possible d'en créer un fichier de ressource dans le but de l'appliquer au cluster. Cependant, une version plus moderne et robuste existe: les ReplicaSets. Cette entité dispose des mêmes fonctionnalités que la précédente mais permet en plus de définir des sélecteurs de sorte à pouvoir, au besoin, se brancher sur un ensemble de pod créés en amont. La demande d'un replicaset passera par un ensemble de pods. Dans le cadre de la suppression d'un pod directement, celui-ci se verra recréé de par la demande d'un certain nombre de pods de ce type de par le replicaset.

Un fichier de configuration de replicaset ressemble à cela: 

```yaml
# replicaset-example.yaml

apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-replicaset
  labels:
    app: myapp
    type: mytype
spec:
  replicas: 4
  selector: 
    matchLabels:
      app: myapp
      type: mytype
  template:
    metadata:
      name: myapp-pod
      labels:
        app: myapp
        type: mytype
    spec:
      containers:
          - name: myapp-container
            image: nginx
            resources:
              limits:
                memory: "128Mi"
                cpu: "500m"
            ports:
            - containerPort: 80
```

On remarque que le `template` d'un replicaset correspond en réalité au contenu d'un fichier de configuration de pod.

La plupart du temps, il est également nécessaire d'ajouter des labels et des sélecteurs dans nos fichiers. Dans le cadre d'un replicaset, il va falloir que Kubernetes puisse connaître quels pods sont concernés par notre ressource. Le plus simple est d'utiliser des labels qui ne sont au final que des ensemble de clés et de valeurs qui doivent correspondre entre le sélecteur et les labels possédés par les objets Kubernetes.

#### Deployment

Lorsque l'on veut déployer une application sur K8s, on passe rarement par les pods directement. On privilégie à la place l'utilisation de fichiers de déploiement. Ces fichiers vont amener à la création d'un ou de plusieurs pods. Il sera d'ailleurs possible, via des déploiements, de gérer le fonctionnement de la mise à jour d'un ensemble de pods. En effet, lors de la publication dans le cloud d'une nouvelle version de notre applicatif, il devient intéressant de pouvoir réaliser la modification rapidement et sans impacter les utilisateurs de part l'arret de l'ensemble des pods le temps de la mise à jour. De plus, dans le cas où la nouvelle version pose problème, il sera possible de faire un rollback facilement.

Un fichier de ressource de type `Deployment` pourrait posséder les attributs suivants:

```yaml
# deployment-example.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 5
  selector:
    matchLabels:
      app: myapp
      type: mytype
  template:
    metadata:
      labels:
        app: myapp
        type: mytype
    spec:
      containers:
      - name: myapp-container
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
```

Dans le cas où l'on souhaiterai voir l'ensemble de nos ressources K8s (Pods, Replicasets et Deployments) d'un seul coup, on peut utiliser la commande:

```bash
kubectl get all
```

#### Namespace

Dans un cluster K8s, il est possible de regrouper les ressources via l'utilisation de **namespaces**. Cette entité sert à compartimenter le cluster de sorte à permettre le partage de ressources entre un groupement et la nécessité d'utiliser un adressage particulier en dehors de ce groupement. Par défaut, l'ensemble des ressoueces créées au sein d'un cluster se trouvent être créées dans le namepacle `default`, créé automatiquement lors de l'initialisation du cluster. Les ressoueces de base de cluster sont créées elles dans un namespace `kube-system` de sorte à éviter la modification de ces dernières par un utilisateur néophyte. Un autre namespace, `kube-public` est également créé pour stocker les ressources qui devraient être en commun avec l'ensemble des utilisateurs.

Il peut être intéressant de créer des namespace pour plusieurs environnements tels le developpement ou la production. Chaque namespace pourra ensuite avoir ses propres règles et une quantité de ressoueces hardware / virtualisées qui lui seront disponibles. Au sein d'un même namespace, les ressources peuvent intéragir entre elles via un DNS permettant l'appel via leur nom, tout simplement. Dans le cas où l'on voudrait atteindre une ressource en dehors du namespace actuel, alors il faudra ajouter plusieurs suffixes tels que `db-service.dev.svc.cluster.local`:

* `db-service`: Le nom de la ressource que l'on cherche à atteindre
* `dev`: Le nom du namespace que l'on chercher à atteindre
* `svc`: Le type de ressouece que l'on cherche à atteindre, ici un service
* `cluster.local`: Le nom de domaine du cluster que l'on veut atteindre, ici le cluster local

Les commandes K8s vont également un peu changer dans le cadre de la manipulation des ressoueces au sein d'un namespace: 

```bash
# Liste les pods dans le namespace actuel
kubectl get pods 

# Liste les pods dans le namespace 'toto'
kubectl get pods --namespace=toto

# Création de ressource dans le namespace 'toto'
kubectl apply -f resource-file.yaml --namespace=toto
```

Pour éviter l'ajout de l'options de namespace à chaque commande, il est possible d'ajouter simplement la clé `namespace` au sein d'un fichier de configuration, dans la section des méta-données.

Pour créer un namespace, on peut se servir encore une fois d'un fichier de ressource tel que:

```yaml
# namespace-example.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: myapp-namespace
```

Dans le but de limiter les ressources au sein d'un namespace, on peut utiliser un quota de ressources. Un fichier de configuration pourrait ressembler à ceci:

```yaml
# resource-quota-example.yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: myapp-resource-quota
  namespace: myapp-namespace
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    request.memory: 5Gi
    limits.cpu: "10"
    limits.memory: 10Gi
```

Il est aussi tout à fait possible de le faire via la commande:

```bash
kubectl create namespace myapp-namespace
```

Pour naviguer entre les différents namespaces, on peut utiliser la commande:

```bash
# On passe par la susbtitution de commande de sorte à ne pas avoir à connaitre par coeur le nom du contexte actuel
kubectl config set-context $(kubectl config current-context) --namespace=namespace-name
```

#### Service

Au sein d'un cluster, l'accès aux ressources ne se fera pas par leur adresse IP, celle-ci étant changeante. Il faut un **service**, qui va offrir un nom de domaine unique relié automatiquement par les mécanismes internes de K8s aux pods qu'il a sous sa gouverne. Il existe plusieurs types de services en fonction de nos besoins (communication interne, externe, besoin de scaling ou non):

* **NodePort**: Expose le service sur un port fixe (en général dans la plage 30000–32767) de chaque node du cluster. Permet d'accéder au service depuis l'extérieur via l'IP d'une node + le port NodePort. Simple à utiliser pour du dev, mais limité en production (gestion manuelle des ports, pas d'IP publique dédiée).

```yaml
# service-nodeport-example.yaml

apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    type: mytype
  ports:
    - port: 80        # port exposé dans le cluster
      targetPort: 80  # port dans le conteneur
      nodePort: 30080 # port externe sur les nodes (30000-32767)
  type: NodePort
```

Le champ nodePort doit être dans la plage 30000–32767 ; si omis, Kubernetes choisira un port automatiquement.

* **ClusterIP**: Crée une adresse IP interne stable accessible uniquement depuis l'intérieur du cluster. Idéal pour la communication intra-cluster entre microservices ou pour des backends qui ne doivent pas être exposés publiquement.

```yaml
# service-clusterip-example.yaml

apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    type: mytype
  ports:
    - port: 80        # port exposé dans le cluster
      targetPort: 80  # port dans le conteneur
  type: ClusterIP
```

* **LoadBalancer**: Demande au cloud provider de provisionner un équilibreur de charge externe et lui associe une IP publique. Fournit un point d'entrée externe avec répartition automatique du trafic vers les pods. En environnements locaux (minikube/kind) l'IP peut rester `<pending>` sauf configuration ou solutions additionnelles.

```yaml
# service-loadbalancer-example.yaml

apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
    type: mytype
  ports:
    - port: 80        # port exposé dans le cluster
      targetPort: 80  # port dans le conteneur
  type: LoadBalancer
```

## Gestion des ressources

### Resource Requirements

Le cluster fonctionne via un ensemble de nodes qui ont chacune des ressources disponibles. Il est intéressant de gérer ces ressources lors du déploiement d'applicatifs de sorte à ne pas surcharger le cluster inutilement. Il s'agit de `kube-scheduler` qui se charge de l'allocation des pods aux différentes nodes. 

Par défaut, il va faire au mieux, en essayant de placer les nouveaux pods sur les nodes ayant le moins de charge (au niveau de la RAM ou au niveau des CPUs). En l'absence d'information sur l'allocation des ressources, les pods peuvent aller piocher librement dans les ressources disponibles pour la node et peuvent donc perturber assez rapidement le fonctionnement de l'ensemble des pods présent sur cette node. Pour optimiser cela, il est possible d'ajouter dans le manifeste d'un pod quels sont les quantités de CPU et de RAM qu'il va nécessiter au lancement. Il faut donc définir, lors de l'écriture d'un fichier de configuration de Pod, les ressources nécessaire: 

```yaml
# example-pod-resources.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: mytype
spec:
  containers:
      - name: myapp-container
        image: myapp
        resources:
          requests:
            memory: "4Gi"
            cpu: 2
```

Les unités utilisées ici sont:
* **Pour le CPU**: exprimé en "cores". 1 = un cœur logique complet (dans le cloud, cela peut correspondre par exemple à 1 vCPU sur AWS). On peut préciser des fractions avec des décimales (ex. 0.5) ou en milli-CPU (ex. 500m = 0,5 core), mais on ne peut pas descendre en dessous de 1m.
* **Pour la RAM**: exprimée en octets avec suffixes. Préférer les suffixes binaires Ki, Mi, Gi (ex. 128Mi, 1Gi). Les suffixes décimaux (K, M, G) sont aussi acceptés mais moins courants pour la mémoire. 

La définition de cette requête lors de la création ne va pas forcément empêcher les conteneurs de consommer plus que celle-ci. Il ne s'agit pas d'une limite, mais il est possible d'en imposer une également: 

```yaml
# example-pod-resources-limits.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: mytype
spec:
  containers:
      - name: myapp-container
        image: myapp
        resources:
          requests:
            memory: "1Gi"
            cpu: 1
          limits:
            memory: "2Gi"
            cpu: 2
```

Au niveau du CPU, les requests servent au scheduler pour réserver des ressources lors du placement des pods, tandis que les limits sont appliqués au niveau du système (cgroups) et peuvent provoquer du throttling si le conteneur dépasse sa limite. Le CPU est "compressible" (le noyau peut réduire la part CPU via throttling) ; la mémoire est non‑compressible (dépassement → OOM kill). Le scheduler prend en compte les requests, pas les limits, et les classes QoS (Guaranteed / Burstable / BestEffort) déterminent l'ordre d'éviction en cas de pression.

* **Aucune informations** : QoS = BestEffort. Requests implicites = 0. Le pod a la plus faible priorité est susceptible d'être évincé en premier et n'a aucune réservation CPU garantie.
* **Requête ET Limites** : QoS = Guaranteed. Le scheduler réserve la quantité demandée ; le pod a la plus haute priorité à l'éviction. Si la limite CPU est atteinte, le conteneur sera throttlé (pas tué).
* **Requêtes uniquement** : QoS = Burstable. Le scheduler réserve la ressource demandée ; le conteneur peut consommer plus de CPU si le nœud est libre (pas de throttling imposé), mais subira des évictions après les Guaranteed si pression mémoire/CPU.
* **Limites uniquement** : QoS = traité comme Burstable (requests effectif = 0 pour le scheduler). Risque : le scheduler peut placer le pod sans réserver de CPU, puis le runtime appliquera la limit et le conteneur sera fortement throttlé en cas de concurrence. 

Il est donc recommandé de toujours définir `requests` en cohérence avec les `limits`.

#### LimitRanges

Pour avoir une limitation par défaut au niveau des pods, il est possible de faire appel à une ressource de type **LimitRange**.

```yaml
# example-limitrange-cpu.yaml

apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-resource-constraint
spec:
  limits:
  - default:            # Limit
      cpu: 500m
    defaultRequest:     # Request
      cpu: 500m
    max:                # Limit
      cpu: "1"
    min:                # Request
      cpu: 100m
    type: Container
```

```yaml
# example-limitrange-memory.yaml

apiVersion: v1
kind: LimitRange
metadata:
  name: memory-resource-constraint
spec:
  limits:
  - default:            # Limit
      memory: 1Gi
    defaultRequest:     # Request
      memory: 1Gi
    max:                # Limit
      memory: 1Gi
    min:                # Request
      memory: 500Mi
    type: Container
```

#### ResourceQuotas

Si l'on souhaite désormais imposer la limite au niveau de l'ensemble des nodes, alors on peut le faire via des quotas du niveau du namespace. Le type de ressource à utiliser cette fois-ci est un **ResourceQuota**:

```yaml
# example-resource-quota.yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: my-resource-quota
spec:
  hard:
    requests.cpu: 4
    requests.memory: 4Gi
    limits.cpu: 10
    limits.memory: 10Gi
```

### Taints / Tolerations

Lorsque l'on veut gérer les pods et leur emplacement futur, il est possible de le faire de plusieurs façon et à plusieurs niveau. Le premier moyen de le faire est d'utiliser le principe des **Taints** et des **Tolerances**. Une analogie que l'on pourrait faire afin d'aider à leur compréhension serait celle des alergies:

* **Taints**: Il est possible de placer une taint sur une node de sorte à lui afilier une "substance allergène". Par défaut, l'ensemble des pods sont alergique à toutes les substances placées sur une node.
* **Tolerance**: Certains pods peuvent de leur côté posséder une tolérance à cette "substance allergène" ce qui leur permet de se placer tout de même sur cette node dans le cas du placement par le scheduler.

Pour appliquer une taint sur une node, on peut le faire via la commande:

```bash
kubectl taint nodes <node-name> key=value:taint-effect
```

Parmi les effets, trois sont disponibles:

* **NoSchedule**: Va empêcher le placement d'un pod sur cette node
* **PreferNoSchedule**: Va chercher à empêcher le placement d'un pod sur cette node, mais cela peut quand même arriver en cas de surcharge des nodes par d'autres paramètres comme les ressources.
* **NoExecute**: Va retirer un pod actuellement placé sur cette node malgré son placement antérieur

Du côté des pods, on peut leur définir une tolérance via les ensembles de clé-valeurs suivants dans leur manifeste:

```yaml
# pod-example-toleration.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  spec: 
    containers:
      - name: myapp-container
        image: myapp
    tolerations:
      - key: "key-name" # Attention, les guillemets ont leur importance ici
        operator: "Equal"
        value: "value"
        effect: "NoSchedule"
```

### Node Selectors et Node Affinity

UNe autre façon de s'assurer que tel pod arrivera bien sur tel node est d'utiliser le principe des sélecteurs de node ou de l'affinité des pods. Ces principes se basent sur l'ajout de labels au préalable sur les différentes nodes du cluster. Il est possible de labéliser les nodes via: 

```bash
kubectl label nodes <node-name> <label-key>=<label-value>
```

Ensuite, on peut utiliser les sélecteurs de node via le manifeste du pod, comme pour la tolérance:

```yaml
# pod-example-node-selector.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  spec: 
    containers:
      - name: myapp-container
        image: myapp
    nodeSelector:
      size: Large
```

Ou passer par les affinités: 

```yaml
# pod-example-node-affinity.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  spec: 
    containers:
      - name: myapp-container
        image: myapp
    affinity:
      requiredDuringSchedulingIgnoredDuringExecution:    # Plusieurs options ici dont d'autres en cours développement
        nodeSelectorTerms:
          - matchExpressions:
            - key: size
              operator: In | NotIn | Exists               # Pour 'Exists', pas besoin de mettre de valeurs ensuite
              values:                                     # Nécessaire pour 'In' ou 'NotIn'
                - Large
                - Medium
```

Les différents types d'affinités de nodes actuellement disponibles / planifiées sont: 
* **requiredDuringSchedulingIgnoredDuringExecution**: Va être utilisé de façon absolue durant le scheduling mais ne va pas arrêter les pods en cas de mise à jour des nodes
* **preferredDuringSchedulingIgnoredDuringExecution**: Va être utilisé de façon privilégiée durant le scheduling mais ne va pas arrêter les pods en cas de mise à jour des nodes
* **requiredDuringSchedulingRequiredDuringExecution** (en cours): Va être utilisé de façon absolue durant le scheduling et va stopper les pods en cas de mise à jour des nodes

### Affinity vs Taints ?

Dans le cas de l'utilisation de K8s, on peut donc en venir à se demander de quelle est la meilleure façon de pouvoir cibler une node ou l'autre avec nos pods. La réponse à cette question se trouve être dans les deux qui doivent se combiner de sorte à s'assurer:

* Via **Taints / Tolerance**: De ne pas avoir de pods autres que ceux que l'on veut parmis les nodes ciblées
* Via **Node Affinity**: D'avoir parmi une portion de nodes, à demander aux pods capable de s'y placer d'y aller en priorité

## Observabilité

### Readiness Probes

Les pods possèdent des informations, comme par exemple leur statut et leur état. 

Par rapport aux status, on peut différencier: 
* **Pending**: Lors de leur création, les pods sont "en cours de création". C'est le moment où le Scheduler cherche où placer le pod. Si le scheduler ne peut pas trouver où placer ce dernier, il restera dans cet état
* **ContainerCreating**: Dans cet état, les pods sont placés par le scheduler sur une node mais les conteneur en leur sein ne sont pas encore fonctionnels. Ils sont en cours de création.
* **Running**: L'état dans lequel un pod se trouvera du temps que les conteneurs en son sein fonctionnent et travaillent sur leur tâche. 

Pour compléter ces informations, les conditions (dont la valeur est booléenne) de l'état du pod sont:
* **PodScheduled**: Le Scheduler a trouvé et assigné un node pour le pod. Si false → le pod est en état Pending (aucun node n'a été choisi).
* **Initialized**: Tous les initContainers du pod se sont terminés avec succès. Si false → les initContainers sont encore en cours ou ont échoué.
* **ContainersReady**: Les containers réguliers du pod ont passé leurs readiness probes et sont prêts à recevoir du trafic. Si false → certains containers ne sont pas encore prêts (probes en échec ou en cours).
* **Ready**: État final indiquant que le pod est prêt pour le trafic : le pod est programmé (PodScheduled), les initContainers sont terminés (Initialized) et les containers sont prêts (ContainersReady). Quand true, le pod est inscrit comme endpoint des Services.

Attention cependant, la condtion "prêt" est par défaut uniquement basée sur des informations standards au niveau du conteneur et non par rapport à l'application qu'il héberge. Elle n'est pas en lien avec l'objectif interne du pod et peut donc indiquer des informations erronées si jamais, par exemple, notre serveur est encore en cours d'initialisation. Pour améliorer ce critère, il peut alors être intéressant de créer des sondes personnalisées. Cette sonde peut consister en plusieurs choses telle qu'un appel HTTP, un test de transfert via TCP, le code de sortie d'un script d'initialisation, etc. Pour ajouter une sonde, il suffit de modifier encore une fois le manifeste au niveau du pod: 

```yaml
# pod-example-readiness-http.yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-api-pod
  spec: 
    containers:
      - name: my-api-container
        image: my-api
        readinessProbe:
          httpGet:
            path: /api/v1/ready
            port: 8080
          # En cas de besoin d'un temps d'attente au démarrage...
          initialDelaySeconds: 10
          # Si l'on a besoin de définir tout les combien de temps tester...
          periodSeconds: 10
          # Si l'on veut tester plus de fois que '3', qui est la valeur par défaut...
          failureThreshold: 8
```

```yaml
# pod-example-readiness-tcp.yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-db-pod
  spec: 
    containers:
      - name: my-db-container
        image: my-db
        readinessProbe:
          tcpSocket:
            port: 3306
```

```yaml
# pod-example-readiness-script.yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
  spec: 
    containers:
      - name: my-app-container
        image: my-app
        readinessProbe:
          exec:
            command: 
              - cat 
              - /app/is_ready
```

### Liveness Probes

Dans l'ecosystème Docker, les conteneurs ayant rencontré un soucis menant à un crash resteront éteint le temps de leur relance. Dans Kubernetes, l'orchestration va tenter de relancer les pods dans le cas où ces derniers font partie d'un ensemble tel qu'un ReplicaSet ou un Deployment. L'information de "Est-ce que le conteneur fonctionne correctement ?" est cependant gérée par défaut sur le fait que le conteneur soit en crash ou non, non en fonctionne de l'application interne au conteneur. Pour modifier cela, il faut définir une sonde de santé. Cela passe par l'ajout de configuration dans le manifeste du pod: 

```yaml
# pod-example-liveness-http.yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-api-pod
  spec: 
    containers:
      - name: my-api-container
        image: my-api
        livenessProbe:
          httpGet:
            path: /api/v1/healthy
            port: 8080
          # En cas de besoin d'un temps d'attente au démarrage...
          initialDelaySeconds: 10
          # Si l'on a besoin de définir tout les combien de temps tester...
          periodSeconds: 10
          # Si l'on veut tester plus de fois que '3', qui est la valeur par défaut...
          failureThreshold: 8
```

```yaml
# pod-example-liveness-tcp.yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-db-pod
  spec: 
    containers:
      - name: my-db-container
        image: my-db
        livenessProbe:
          tcpSocket:
            port: 3306
```

```yaml
# pod-example-liveness-script.yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-app-pod
  spec: 
    containers:
      - name: my-app-container
        image: my-app
        livenessProbe:
          exec:
            command: 
              - cat 
              - /app/is_ready
```

### Logging

Dans l'ecosystème Docker, le logging est possible une fois un conteneur lancé via l'utilisation de la commande:

```bash
docker logs -f <container-name | container-id>
```

Si l'on veut faire un logging de la même façon dans Kubernetes, alors la commande est cette fois-ci:

```bash
# Si le pod ne possède qu'un conteneur: 
kubectl logs -f <pod-name>

# Si le pod possède plus d'un conteneur: 
kubectl logs -f <pod-name> <container-name>
```

### Monitoring

Si l'on souhaite désormais voir les différentes ressources utilisées au sein d'un cluster Kubernetes, il va falloir faire usage de surveillance. La surveillance peut être au niveau des nodes, comme par exemple connaitre le nombre de nodes, leurs consomation et leur disponibilités en terme de CPU / RAM ou Disques; ou cette surveillance peut être au niveau des pods, comme leur nombre et leurs utilsations de ressources sur leurs nodes hôtes. Cette surveillance se fera via un outil tier la majorité du temps vu que Kubernetes ne fourni pas de solution interne. Cet outil peut être par exemple **Prometheus**.

Kubernetes fourni cependant un serveur de métrique (remplaçant **Heapster**, désormais déprécié) permettant, en RAM, d'aggréger les différentes informations du cluster. Le fait que cela soit en mémoire cause le soucis de l'historique bien évidemment, mais cela est mieux que rien. Pour fonctionner, cet outil va utiliser les différents `cAdvisors` (responsables de la récupération et trairement des métriques) et les différents `kubelet` présents sur les nodes. Le serveur de métrique est disponible en fonction de notre type de cluster via les commandes suivantes:

```bash
# Dans minikube 
minikube addons enable metrics-server

# Les autres
git clone https://github.com/kubernetes-sigs/metrics-server.git
kubectl create -f deploy/1.8+/
```

Une fois le serveur lancé et des informations récupérées, il est possible de le consulter via:

```bash
# Pour voir les métriques des nodes
kubectl top node

# Pour voir les métriques des pods
kubectl top pod
```

### Labels / Annotations

Dans le monde moderne, il est important de pouvoir classifier des ensembles d'éléments, qu'il s'agisse d'animaux, de produits dans un magasin ou d'entités dans Kubernetes. Pour rappel, il est possible de créer des labels sur l'ensemble de nos ressources lors de l'écriture des fichiers de manifeste. Cela permettra par exemple de classer les entités par type, objectif, couche de l'applicatif, etc. Lorsque l'on créé un manifeste de ReplicaSet, on doit par exemple utiliser des sélecteurs basés sur les labels de sorte à relier des templates de pods avec l'entité du ReplicaSet.

L'utilisation de labels permet une altération de certaines commandes tel:

```bash
kubectl get all --selector app=myapp
```

A côté des ces labels existent également les annotations. Cet dernières n'ont pas pour but directement d'affecter le fonctionnement du cluster ou des commandes que l'on va utiliser, mais plutôt de servir à titre informatif sur certaines choses telle que la version de l'application. Pour créer des annotations, on peut encore une fois le faire dans les fichiers de manifeste: 

```yaml
# replicaset-annotations-example.yaml

apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp-replicaset
  labels:
    app: myapp
    type: mytype
annotations:
  buildVersion: 1.34
spec:
  replicas: 4
  selector: 
    matchLabels:
      app: myapp
  template:
    metadata:
      name: myapp-pod
      labels:
        app: myapp
    spec:
      containers:
          - name: myapp-container
            image: nginx
```

## Pour aller plus loin

### La sélection par expression

Suite à l'évolution de Kubernetes, il est arrivé la possibilité de sélectionner via des expressions, qui se retrouvent définies par des accolades dans lesquelles ont peut définir plus de détails, par exemple sélectionner plusieurs valeurs possibles pour une clé, voire même d'utiliser des opérateurs logiques: 

```yaml
selector:
  matchExpressions:
    - {key: key-name, operator: In, values: [value-1, value-2, value-3, ...]}
    - {key: key-name, operator: NotIn, values: [value-4, value-5, ...]}
```

Via l'utilisations des labels, il est aussi possible de sélectionner dans le cadre des commandes vues en premier partie de cette introduction (l'approche impérative). Pour ce faire, il est pas exemple possible de supprimer les éléments possédant un label particulier: 

```bash
kubectl delete object-type-1,object-type-2,... -l key=value
```

### Choisir la politique de récupération de l'image Docker

Il est possible via l'utilisation de fichiers de manifeste de définir de quelle façon Kubernetes va gérer le pull de nos images Docker. Par défaut, l'attribut a pour valeur `IfNotPresent` en cas d'asence de spécification du tag `latest` dans notre image, mais il est possible de le changer à `Always` pour forcer le pull d'une image en cas de changement sans avoir modifié le tag, ou sur `Never` pour que Kubernetes ne cherche pas de son côté à pull c'image Docker, quand bien même le tag serait différent ou l'image absente.

```yaml
# pod-imagepull-policy-example.yaml

apiVersion: v1
kind: Pod
metadata: 
  name: myapp-pod-example
spec:
  containers:
    - name: web-server
      image: nginx
      imagePullPolicy: IfNotPresent
```

### Pods avancés

Il est possible de choisir les commandes d'entrée dans un conteneur via les clés `command` et `args` tel que: 

```yaml
# pod-example-args.yaml

apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper-pod
  labels:
    app: ubuntu-sleeper
spec:
  containers:
      - name: ubuntu-sleeper
        image: ubuntu
        command: ["sleep"] # Sert à remplacer au besoin ENTRYPOINT
        args: ["10"] # Permet l'ajout d'arguments d'entrée placés après la commande
```

#### Multi-containers Pods

Dans certains cas, il peut être nécessaire d'avoir des pods comportant plusieurs conteneurs en même temps. Par exemple, dans le cadre du déploiement d'une application ayant besoin d'un serveur web pour être atteinte, ou d'une application fonctionnant via un cache (Redis). Il faut dans ce cas avoir idéalement deux conteneurs, l'un pour l'application, l'autre servant de conteneur utilitaire. Bien entendu, ce shéma n'est pas limité à seulement deux conteneurs. Dans un environnement Kubernetes, la création de ces ensembles de conteneurs se fera via des pods multi-conteneurs. Ce genre de déploiement offre ainsi le même cycle de vie, le même réseau ainsi que les mêmes accès aux stockages pour plusieurs conteneurs.

Plusieurs patterns existent dans ce genre de déploiement:

* **Co-located**: Le plus ancien et le plus classique des patterns. Deux conteneurs tournent ainsi dans un pod et sont dépendants l'un de l'autre, sans différenciation entre le démarrage de l'un ou de l'autre en premier.

```yaml
# pod-multi-containers-co-located-example.yaml

apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-pod
  labels:
    app: simple-webapp
spec:
  containers:
      - name: simple-webapp-container
        image: web-app
        ports:
        - containerPort: 8080
      - name: main-app-container
        image: main-app
```

* **Regular Init**: Un autre pattern serait celui dans lequel un conteneur sert de point de démarrage à l'autre conteneur - celui de l'application, avant de se terminer. Par exemple, on pourrait avoir un conteneur vérifiant les accès à une base de données avant lancement de celui de l'application.

```yaml
# pod-multi-containers-regular-init-example.yaml

apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-pod
  labels:
    app: simple-webapp
spec:
  containers:
      - name: simple-webapp-container
        image: web-app
        ports:
        - containerPort: 8080
  # Il est possible de définir des conteneurs d'initialisation en nombre voulu
  initContainers:
      - name: db-checker-container
        image: busybox
        command: ["wait-for-db-to-start.sh"]
      - name: api-checker-container
        image: busybox
        command: ["wait-for-another-api.sh"]
```

* **Sidecar**: Dans ce pattern, le conteneur annexe débute son cycle de vie en premier mais reste actif une fois l'application lancée. On peut imaginer par exemple l'initialisation d'un système de logging et ensuite le tracking de l'application via ce système durant le cycle de vie partagé.

```yaml
# pod-multi-containers-sidecar-example.yaml

apiVersion: v1
kind: Pod
metadata:
  name: simple-webapp-pod
  labels:
    app: simple-webapp
spec:
  containers:
      - name: simple-webapp-container
        image: web-app
        ports:
        - containerPort: 8080
  initContainers:
      - name: log-shipper-container
        image: busybox
        command: ["setup-log-shipper.sh"]
        # Assure la présence de ce conteneur durant le cycle de vie de l'application de base
        restartPolicy: Always
```

### Stratégies de déploiement 

#### Rollout / Rollback

Lors de la création d'une ressource de type Deployment, un nouveau **Rollout** est également créé. Cet élément va entrainer de son côté l'ajout d'une version X de l'applicatif sur les pods / conteneurs: une nouvelle **Revision**. En cas de changement de la version de notre application, un nouveau Rollout aura lieu et une nouvelle Revision sera enregistrée. Il est possible de manipuler ces rollouts via des commandes telles que:

```bash
# Connaitre l'état actuel du rollout
kubectl rollout status deployment/<deployment-name>

# Connaitre l'historique des revisions
kubectl rollout history deployment/<deployment-name>

# Annuler la mise à jour de la nouvelle révision
kubectl rollout undo deployment/<deployment-name>
```

Dans le cas du passage d'une version A à une version B d'un applicatif, deux stratégies sont possible dans le cadre de la réalisation d'un rollout: 

* **Rolling**: Dans cette stratégie, les pods sont stoppés et créés un par un, de sorte à ce qu'il y ait potentiellement une ancienne version de l'applicatif le temps de la transition vers la nouvelle. Cette stratégie est celle par défaut.
* **Recreate**: Dans cette stratégie, l'ensemble des pods sont stoppés et l'ensemble des pods sont créés d'un seul bloc. Cette stratégie va entrainer la présence entre les deux d'un temps mort durant lequel l'applicatif ne sera plus disponible dans le cluster.

La réalisation d'une stratégie de rollout se fait dans plusieurs cas tels que la mise à jour de la version de l'image, le changement des labels de notre déploiement, la modification des variables d'environnement, des labels, etc. En interne, le fonctionnement d'un rollout se passe via la création d'un nouveau ReplicaSet qui va être de la même taille que l'initial. Ce replicaset sera basé sur la nouvelle configuration et servira à héberger le résultat du rollout. La vitesse de remplissage du nouveau replicaset sera fonction du type de stratégie utilisée (un à la fois pour Rolling, tout d'un coup pour Recreate).

```yaml
# deployment-strategy-example.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 5
  # On doit ajouter cette clé si l'on veut changer la stratégie
  strategy:
    # Rolling est par défaut donc pas besoin de spécifier quoi que ce soit
    type: Recreate
  selector:
    matchLabels:
      app: myapp
      type: mytype
  template:
    metadata:
      labels:
        app: myapp
        type: mytype
    spec:
      containers:
      - name: myapp-container
        image: nginx
        resources:
          limits:
            memory: "128Mi"
            cpu: "500m"
        ports:
        - containerPort: 80
```

#### Autres statégies

D'autres stratégies peuvent être mises en place lors de la création d'un déploiement. Parmi celles-ci: 
* **Blue / Green**: Cette stratégie consiste à avoir deux environnements parallèles — la "Blue" (production active) et la "Green" (nouvelle version prête). Le processus typique:
  - Déployer la nouvelle version dans un nouveau ReplicaSet / namespace / cluster (Green) sans impacter la production.
  - Exécuter des tests automatisés et des validations (smoke, intégration, performance) sur Green.
  - Basculement instantané du trafic vers Green en changeant la cible du Service (selector), la configuration d'un Ingress/LoadBalancer ou via un Service Mesh (ex. modification d'un VirtualService Istio).
  - En cas de problème : rollback simple en redirigeant le trafic vers Blue.
  Avantages : bascule rapide, rollback immédiat, tests en production isolés. Inconvénients : double infrastructure (coût), synchronisation des données d'état peut être complexe.

* **Canary**: Cette stratégie déploie progressivement la nouvelle version et augmente le pourcentage de trafic dirigé vers elle pour détecter les régressions avant une promotion complète. Étapes courantes:
  - Déployer la nouvelle version comme un ReplicaSet/Deployment parallèle (canary).
  - Acheminer une petite portion du trafic vers le canary (ex. 1–5%) via Service Mesh (Istio/Linkerd), Ingress avec poids ou un controller de rollouts (Argo Rollouts, Flagger).
  - Surveiller métriques et erreurs (SLOs, logs, traces). Si OK → augmenter progressivement le pourcentage ; si KO → rollback en réduisant à 0% et supprimant le canary.
  Avantages : faible risque, détection précoce des régressions, consommation d'infra limitée. Inconvénients : nécessite instrumentation et outils de routage fine (ou scripts de gestion du traffic).

### Les Jobs / CronJobs

Dans le cas où l'on aurait besoin d'exécuter des tâches plus ou moins courtes dans le but de par exemple traiter un ensemble de données ou de faire des manipulations avant de mettre fin au conteneur, on fait ce que l'on appelle communément un "job". Par exemple, dans le cadre d'un workflow classique Docker, on pourrait avoir: 

```bash
# On lance le conteneur via une commande...
docker run ubuntu expr 2 + 4

# ...et on voit que ce dernier s'est terminé avec un code de sortie 0
docker ps -a
```

Dans Kubernetes, ce genre de workflow pourrait ressembler à un fichier de manifeste tel que: 

```yaml
# pod-math-example.yaml

apiVersion: v1
kind: Pod
metadata: 
  name: math-pod
spec:
  containers:
    - name: math-add
      image: ubuntu
      command: ["expr", "1", "+", "3"]
```

On pourrait ensuite réaliser les commandes suivantes:

```bash
# On lance le pod via une commande...
kubectl create -f pod-job-example.yaml

# ...et on voit que ce dernier s'est terminé avec un statut 'Completed' (relancé ensuite X fois avant le threshold)
kubectl get pods
```

Contrairement à Docker, Kubernetes va donc tenter de relancer le pod afin de le maintenir présent dans le cluster. Cela est dû à la configuration par défaut des pods (`restartPolicy`), qui est par défaut à **Always**. Les différentes valeurs possibles sont: 

* **Always**: Par défaut, le pod va chercher à se relancer de sorte à être actif dans le cluster un certain nombre de fois avant le threshold.
* **Never**: Le pod ne sera jamais relancé, quelle que soit la cause de l'arrêt (succès ou échec). Utilisé pour les tâches qui ne doivent s'exécuter qu'une seule fois.
* **OnFailure**: Le pod sera relancé uniquement si le conteneur se termine avec un code d'erreur (différent de 0). Si le conteneur termine avec succès (code 0), il ne sera pas relancé.

Dans l'ecosystème Kubernetes, il est possible de créer un ensemble de pods d'un coup via l'utilisation d'un ReplicaSet. Cependant, l'objectif est ici ce permettre non pas la présence en tout temps d'un ensemble de pods, mais plutôt de créer un ensemble de pods avec un objectif avant leur terminaison. Pour automatiser l'exécution de tâches ponctuelles ou récurrentes, Kubernetes propose deux objets dédiés :

- **Job** : garantit qu'un ou plusieurs pods s'exécutent jusqu'à leur complétion. Il relance les pods en cas d'échec selon la stratégie définie.
- **CronJob** : permet de planifier l'exécution de jobs à des intervalles réguliers (similaire à cron sous Linux).

Exemple de Job :

```yaml
# job-example.yaml

apiVersion: batch/v1
kind: Job
metadata:
  name: example-job
spec:
  template:
    spec:
      containers:
      - name: math-add
        image: ubuntu
        command: ["expr", "1", "+", "3"]
      restartPolicy: OnFailure
```

```yaml
# job-multi-pods-example.yaml

apiVersion: batch/v1
kind: Job
metadata:
  name: random-error-job
spec:
  # Un certain nombre de pods vont être créés de sorte à avoir X complétions avant de stopper la création
  completions: 3
  # Par défaut les pods se créeront sequentiellement. On peut définir le nombre de pods à créer en même temps via la clé suivante:
  parallelism: 3
  template:
    spec:
      containers:
      - name: random-error
        image: kodecloud/random-error
      restartPolicy: Never
```

```yaml
# cronjob-example.yaml

apiVersion: batch/v1
kind: CronJob
metadata:
  name: example-cronjob
spec:
  # L'intervale doit être défini sour la forme 'minute heure jourDuMois mois jourDeSemaine'
  schedule: "0 * * * *" # Ici cela aura lieu toutes les heures
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: reporting-tool
            image: reporting-tool
          restartPolicy: OnFailure
```

## Networking dans Kubernetes

Pour permettre dans un premier temps la communication entre le cluster et le monde extérieur, il est important de réaliser un fichier de ressource de service. Via l'utilisation de services, il est possible de créer des adresses IP pouvany être la cible de requêtes, que cela soit d'un pod à un autre, d'une node à l'autre, ou du monde extérieur à un pod. Pour communiquer entre notre machine et le cluster, le plus simple est la création d'un service de type `LoadBalancer`.

```yml
apiVersion: v1
kind: Service
metadata:
  name: service-name
spec:
  selector:
    key: value
  type: LoadBalancer
  ports:
  - port: 80 
    # Port extérieur
    targetPort: 5000 
    # Port dans le conteneur
```

Via un service de ce type, et dans le cas où l'on déploie sur un cloud-provider gérant le load balancing, il est possible de bénéficier directement d'une adresse IP externe via la commande `kubectl get svc` pour lister les services.

Si l'on est en développement local, alors via minikube il est aussi possible de réaliser l'exposition de notre IP via l'utilisation de `minikube service service-name`. Via cette commande, notre navigateur va s'ouvrir automatiquement à l'adresse et au port générés. Il ne nous rester plus qu'à récupérer ses informations si notre application n'est pas une application web, et de les exploiter, par exemple via un client REST dans le cadre d'une API.


### Communication intra-pod

Dans le cadre de la communication entre deux conteneurs se trouvant dans le même pod, il est possible de réaliser celle-ci via l'utilisation de `localhost` ainsi que les ports demandés par les différents services. Il suffit alors d'ajouter soit via l'attribut `env`, soit via un service de type `ConfigMap` pour plus de sécurité.


### Communication inter-pod

Pour permettre à différents pods de communiquer entre eux, il nous faut déjà avoir créé un service pour chacun d'entre eux. Dans le cadre de pods devant communiquer entre eux mais ne pas être exposés à l'extérieur du cluster, il est possible de le faire via un service de type `ClusterIP`. Il nous sera ensuite possible de récupérer l'adresse IP via un `kubectl get svc`. 

Il est également possible de se servir de variables d'environnement créées automatiques par Kubernetes, qui peuvent servir à rediriger automatiquement vers l'adresse IP d'un service. Pour les utiliser, il suffit de respecter la syntaxe, qui est de la sorte:

```bash
SERVICE_NAME_SERVICE_HOST

# Par exemple, pour un service nommé 'blabla':
BLABLA_SERVICE_HOST

# Et pour un service nommé 'truc-bidule':
TRUC_BIDULE_SERVICE_HOST
```

Depuis l'avancement des technologies Kubernetes, il est aussi possible d'utiliser une feature qui se nomme **CoreDNS** dans le but de manipuler la communication inter-pods. A la façon de Docker compose, il est possible de simplement utiliser comme nom de domaine le nom de notre service suivi de son **namespace** (les namespaces ont pour rôle de séparer les ressources dans le but de les assigner à différentes équipes par exemple) et Kubernetes se chargera de rediriger les requêtes entrantes vers ce dernier.

```yml
environment: 
  - name: VAR_A
    value: "service-name.namespace-name"
```

Dans le cadre de l'utilisation de minikube, on peut se contenter du namespace `default` qui est assigné par défaut à toutes nos ressources.

### NetworkPolicies

Imaginons un déploiement comportant une application web (écoutant au port 80), une API (écoutant au port 5000) ainsi qu'une base de donnée MySQL (écoutant au port 3306)

Dans Kubernetes, le traffic génère des flux. Il peut être défini selon les termes suivants:
* **Ingress**: Le traffic entrant dans l'entité que l'on est en train de visualiser (80 pour WebApp, 5000 pour API, 3306 pour MySQL)
* **Egress**: Le traffic sortant dans l'entité que l'on est en train de visualiser (5000 pour WebApp, 3306 pour API)

Ces deux flux peuvent avoir une série de règles de sorte à permettre ou non l'entrée / sortie à un ensemble de ports définis.

Du point de vue de la sécurité, l'ensemble des pods et des services au sein d'un cluster ont la capacité de communiquer par défaut via leur adresse IP privée. Par défaut, Kubernetes est configuré avec une règle de type "All Allow" pour le traffic intra-cluster. Dans notre exemple, l'ensemble des entités peuvent donc communiquer entre-elles librement. Si l'on voulait empêcher le traffic par exemple depuis l'application Web vers la base de donnée, on devrait créer une politique réseau particulière. Ce genre d'entité est liée à un élément du cluster et permet la configuration des traffic Ingress / Egress manuellement. Pour ce faire, on va utiliser des labels et un fichier de manifeste:

```yaml
# network-policy-ingress-example.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
  ingress:
      # On va définir des règles entrantes via le listing dans la clé 'from' qui fonctionneront comme un 'OR' logique. Au sein de chaque règle, les critères fonctionneront via un 'AND' logique
    - from:
        # On peut définir un critère basé sur les labels des pods au sein du cluster
      - podSelector:
          matchLabels:
            name: api-pod
        # On peut définir un critère basé sur le namespace des ressources au sein du cluster
        namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: prod 
            
        # On peut définir un critère basé sur l'adresse IP pour les ressources en dehors du cluster
      - ipBlock: 
          cidr: 192.168.5.10/32
      ports:
        - protocol: TCP
          port: 3306
```

Attention cependant, les politiques de réseau sont imposées par la solution réseau utilisée sur le cluster. Ces fichiers de manifeste seront compatible en cas d'utilisation de **Kube-Router**, **Calico**, **Romana** mais pas **Flannel**. Dans le cas où celle-ci n'est pas supportée, il n'y aura pas de message d'erreur, juste une absence de conséquence suite à l'ajout d'un manifeste de ce type.

```yaml
# network-policy-both-example.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-policy
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            name: api-pod
      ports:
        - protocol: TCP
          port: 3306
  egress:
    - to:
      - ipBlock: 
          cidr: 192.168.5.10/32
      ports:
        - protocol: TCP
          port: 80
```

### Ingress

Dans le cas où l'on aurait besoin de configurer les accès à plusieurs replicasets de plusieurs applications au sein d'un cluster, mais en conservant un système d'URL unique et en bénéficiant de certificats TLS en lien avec notre environnement, le plus simple est de faire appel à une ressource kubernetes dédiée, un **Ingress**. On pourra, via cette ressourcer, gérer:

- La redirection par URL
- L'envoi des certificats TLS
- Le Load Balancing des différents services

Attention cependant, il faudra toujours exposer cette ressource à l'extérieur du cluster, par exemple avec un Load Balancer Cloud, mais cette configuration sera unique. La majorité de la configuration viendra ensuite de l'Ingress. Pour fonctionner, il faudra:

* **Ingress Controller**: Un reverse proxy tel que **NGINX**, **Traefik** ou **HAProxy**
* **Ingress Resources**: Des configurations (certificats TLS et ensemble de règles) au moyen par exemple d'un fichier de manifeste

Pour commencer, il faudra déployer un contrôleur Ingress donc. Pour utiliser par exemple NGINX, on va créer un fichier de déploiement pour obtenir pod et donc un conteneur spécifique de NGINX servant à la réalisation d'un Ingress. Ce **Deployment** aura besoin de configuration que l'on lui fournira sous la forme d'un **ConfigMap**, d'accès sous la forme d'un **Service** ainsi que de droits fournis sous la forme d'un **ServiceAccount**

```yaml
# configmap-nginx-controller.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-configuration
data:
  ...
```

```yaml
# deployment-nginx-controller.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels: 
      name: nginx-ingress
  template:
    metadata:
      labels: 
        name: nginx-ingress
    spec:
      containers:
        - name: nginx-ingress-controller
          image: quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.21.0
          args:
            - /nginx-ingress-controller
            - --configmap=$(POD_NAMESPACE)/nginx-configuration
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
            - name: POD_NAMESPACE
              valueFrom: 
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - name: http
              containerPort: 80
            - name: https
              containerPort: 443
```

```yaml
# service-nginx-controller.yaml

apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
      name: http
    - port: 443
      targetPort: 443
      protocol: TCP
      name: https
  selector:
    name: nginx-ingress
```

```yaml
# serviceaccount-nginx-controller.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-ingress-serviceaccount
```

Une fois le contrôleur mis en place, il nous faut passer à la création des ressources Ingress. Ces ressources vont se faire via un fichier de manifeste expliquant les règles de notre Ingress:

```yaml
# ingress-basic-example.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear
spec:
  # Défini où le traffic va aller
  defaultBackend:
    service:
      name: wear-service
      port: 80
```

```yaml
# ingress-rules-example.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear
spec:
  rules:
    - http:
        paths:
          - path: /wear
            backend: 
              service:
                name: wear-service
                port: 80
          - path: /watch
            backend: 
              service:
                name: watch-service
                port: 80
```

```yaml
# ingress-domains-example.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wear-watch
spec:
  rules:
    - host: wear.my-online-shop.com
      http:
        paths:
          - path: /
            backend: 
              service:
                name: wear-service
                port: 80
    - host: watch.my-online-shop.com
      http:
        paths:
          - path: /
            backend: 
              service:
                name: watch-service
                port: 80
```

## Les données dans Kubernetes

### Rappels Docker

Dans l'ecosystème de Docker, les données de notre image sont stockées sous la forme de couches. Ces couches sont utilisées principalement lors de la génération d'une image similaire à celle que l'on vient de réaliser dans le but d'en accélerer le build via le cache. Il est important également de savoir que lors du lancement d'un conteneur à partir d'une image, une nouvelle couche va se créer. Celle-ci ne sera cependant pas persistée une fois le conteneur détruit à moins de faire usage d'une commande telle que `docker commit`. 

Les couches ont des paramètres de Lecture/Ecriture différents: Celles provenant du lancement du conteneur sont **ReadWrite** alors que celles réalisées lors du build de l'image sont de leur côté **ReadOnly**, ce cause leur copie au sein de la couche du conteneur avant leur modification le cas échéant (et donc non persistées par défaut). 

Pour persister les données créées par un conteneur, la solution basique est d'utiliser un volume. On peut ensuite brancher un emplacement (monter un volume) au sein du conteneur vers un dossier de volume nommé afin de les retrouver par la suite. Une autre solution à la pérénité des données est de faire usage d'un Bind Mount: On va monter un emplacement sur l'ordinateur hôte à une emplacement dans le conteneur. Pour le conteneur, l'emplacement lié est le même, mais pour l'hôte, l'emplacement sera soit un dossier de volume sauvegardé par exemple dans `/var/lib/docker/volumes`, soit un emplacement tel que `/home/user/folder`.

```bash
# Volume nommé
docker run -v data_volume:/var/lib/mysql mysql

# Bind mount
docker run -v /data/mysql:/var/lib/mysql mysql

# Syntaxe moderne et plus verbeuse
docker run --mount type=bind,source=/data/mysql,target=/var/lib/mysql mysql
```

Tous ces mécanismes sont rendu possibles par les pilotes de gestion du stockage dans Docker. Les plus communs sont: **AUFS**, **ZFS**, **BTRFS**, **Device Mapper**, **Overlay** et **Overlay2**. Docker va sélectionner automatiquement le meilleur pilote en fonction de ceux présents sur l'ordinateur hôte. A côté de ça, d'autres pilotes de gestion de volumes existent: **Local**, **Azure File Storage**, **Convoy**, **DigitalOcean Block Storage**, **Flocker**, etc. Il est possible de choisir le driver de volume à utiliser lors de l'exécution d'une commande tel que:

```bash
docker run \
  --name mysql \
  --volume-driver rexray/ebs \
  --mount source=ebs-vol,target=/var/lib/mysql \
  mysql
```

### Et dans Kubernetes ?

Pour manipuler des données dans Kubernetes, il est important de comprendre ce que l'on entend lorsque l'on parle de l'**état** de notre cluster. Par rapport à nos données, il peut être intéressant de rapeller qu'il existe deux grands types de données: 
- Les données générées par l'utilisateur et dont l'objectif est souvent de se voir être stockées dans une base de données pour un usage futur.
- Les données générées par l'application et qui sont en général conservées en mémoire vive le temps de vie de l'application.

Dans le cadre de Kubernetes, ces deux types de données devraient idéalement persister à un certain degré. Les données de l'application devrait survivre à un reboot du conteneur par exemple afin de ne pas perturber l'utilisation de notre application, alors que les données d'utilisateur doivent être stockées évidemment dans le but de les rendre disponible en tout temps. Kubernetes ne va cependant pas ré-ecrire l'Histoire, et le stockage des données dans des volumes par Docker ne sera pas changé pour autant. La variante se fera dans le cadre de la méthodologie de remplissage des volumes, qui devront alors être gérés par Kubernetes pour potentiellement les rendre disponibles sur plusieurs pods voire même sur plusieurs nodes / machines.

Au vu de l'emplacement des volumes dans Kubernetes, qui sont rappellons le dans des pods, il est important de se rendre compte que le temps de vie d'un volume va dépendre du temps de vie d'un pod dans lequel il se trouve. Quand bien même Kubernetes est capable de gérer et de peupler les volumes au niveau des nodes ou au niveau des cloud-providers, le fonctionnement interne de la liaison pod-volume ne peut être changée et les volumes seront spécifiques à leur pod.

La différence fondamentale entre des volumes Docker et des volumes dans le cadre d'un fonctionnement via Kubernetes vient donc de la façon dont ces volumes vont être typés et de quels drivers vont être fixés dans leur configuration. De plus, dans le cadre de Kubernetes, les volumes ne vont par forcément résister à un reboot.

### emptyDir

Pour notre premier cas de volume Kubernetes, nous allons commencer par nous intéresser au driver `emptyDir`, qui a pour objectif, comme son nom l'indique, la création d'un dossier vide dans lequel Kubernetes va stocker les éléments en cas de crash du conteneur. Par analogie, on pourrait dire qu'il s'agit d'un volume ayant le même objectif qu'un volume anonyme. Le seul détail qui change est qu'il sera réellement vide, car quand bien même l'image est censé apporter un fichier à cet emplacement dans l'application, Kubernetes va placer à cet emplacement un dossier vide, et donc tous les fichiers que l'image y aurait mit seront effacés. 

Dans le cadre d'une application ayant pour but le stockage de valeurs temporaires n'étant pas accessible en amont, ce n'est cependant pas un soucis, et cela protègera notre application de pertes éventuelles dues à un crash.

```yaml
# pod-volumes-emptyDir-example.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec: 
  containers:
    - name: myapp-container
      image: myapp
      # Au niveau de la définition du conteneur, il nous faudra ajouter l'emplacement qui sera reliée à ce volume, via l'attribut `volumeMounts`:
      volumeMounts:
        - mountPath: /path/to/bind
          name: volume-name
  volumes:
    - name: volume-name
      emptyDir: {}
```


### hostPath

L'utilisation d'un volume de type emptyDir pose cependant un soucis en cas d'utilisation de multiples replicas de notre conteneur, car chaque clone de notre conteneur va posséder son propre dossier lié. Pour pallier à ce soucis, nous allons désormais explorer le driver `hostPath`.

Via l'utilisation de ce driver, le chemin lié ne le sera plus vers un dossier vide pour chaque pod mais tous les pods du déploiement partagerons le même chemin lié dans la node de travail. Via de système, il sera possible de gérer les multiples clones d'un conteneur se trouvant sur la même node. Pour nous en servir, il suffit de changer les attributs de notre fichier de ressource:


```yaml
# pod-volumes-hostPath-example.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
spec: 
  containers:
    - name: myapp-container
      image: myapp
      volumeMounts:
        - mountPath: /path/to/bind
          name: volume-name
  volumes:
    - name: volume-name
      hostPath:
        path: /path/to/data/on/node
        type: DirectoryOrCreate # Permet la création en cas d'absence du dossier contrairement à 'Directory' où le conteneur va crash en cas d'absence du chemin
```

Le soucis que l'on peut encore avoir avec ce genre de driver est le fait que dans la majorité des cas, un cluster va travailler avec plusieurs nodes. Malgré tout, ce style de driver offre des avantages non néglibeables sur la méthode de **emptyDir**.


### csi

Contrairement aux autres drivers, le CSI (Container Storage Interface) est un driver plus flexible car il permet de gérer plusieurs systèmes de volumes. En réalité, en tant qu'interface, il fixe des règles de fonctionnement d'un système de liaison de données dans Kubernetes, et cette interface est utilisée comme base commune dans plusieurs autres drivers, en particulier chez les cloud-providers. 

De part ce mode de développement de l'environnement Kubernetes, on peut voir l'apparition de système de gestion de volumes dans plusieurs systèmes du cloud et ne pas perdre nos connaissances, mais simplement les appliquer à ce cloud-provider de part son respect de l'interface **CSI**.


### PersistentVolume

Il est désormais temps de voir un tout autre type de volume, les **volumes persistants**. En effet, jusqu'à maintenant, nos volumes ne sont soit disponibles que durant la vie d'un pod, soit durant la vie d'une node. Il est cependant fréquent que l'on veuille gérer des données non dépendantes d'un pod ou d'une node, mais qui soit communes. Bien entendu, des scénarios oû ce mode de fonctionnement existent également, et il est alors utile de pouvoir manier à la fois les volumes classiques et les volumes persistants.

Pour créer des volumes persistants, il nous est déjà possible de le faire via le driver CSI et l'utilisation d'un cloud-provider, mais il peut être intéressant de voir les solutions "maisons" de Kubernetes. Dans le cadre des volumes persistants, la premier grosse différence est l'indépendance entre un pod et un volume. En tant que gérant d'un cluster, il sera même possible de brancher / débrancher des volumes aux pods de notre choix. Pour gérer ces liaisons, il est nécessaire d'utiliser des **claims** qui permettront à certains pods d'accéder à X volumes, qui seront désormais des ressources de cluster au même titre qu'une node. Pour définir un volume persistant, il est nécessaire d'utiliser des fichiers de ressources supplémentaires. Il nous en faudra un pour le volume persistant, et un autre pour les claims nécessaire au branchement du volume persistant sur le ou les nodes. L'objectif de notre fichier de manifeste pour le volume persistant est la création d'une ressource Kubernetes permettant le stockage d'une quantité finie de données. Généralement fixée par l'administrateur du cluster, cette ressource sera par la suite soit occupée entièrement, soit partagée entre plusieurs nodes / pods.

```yaml
# persistantvolume-example.yaml

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-name
spec:
  # On défini comment le volume doit être monté sur l'hôte ici
  accessModes:
    - ReadWriteOnce 
  # On choisi la quantité d'espace disponible pour le futur volume
  capacity:
    storage: '1Gi'
  # On choisi l'emplacement sur l'hôte du volume persistant 
  hostPath:
    path: /path/to/data
    type: DirectoryOrCreate
```

Les modes d'accès (`accessModes`) servent à définir de quelle façon les pods vont pouvoir accéder à la ressource. Dans le cadre d'un accès de type `ReadWriteOnce`, alors la lecture et l'écriture seront possible pour un seul pod. Si l'on veut rendre la chose possible pour X pods, alors il nous faut utiliser soit de la lecture seule pour de multiples pods via `ReadOnlyMany`, soit de l'écriture et lecture pour X pods via `ReadWriteMany`.

Lors de la suppression d'un volume persistant, plusieurs politiques sont dispinibles. La gestion de cette suppression se fait au niveau de la clé `persistantVolumeReclaimPolicy` qui peut alors être:
* **Retain**: On conserve les données
* **Delete**: On supprime tout
* **Recycle**: Les données sont mises disponibles pour un futur volume persistant, actuellement déprécié

### PersistentVolumeClaim

Pour gérer l'association entre cette quantité de données et les pods, il est désormais nécassaire de réaliser des claims: 

```yaml
# persistantvolumeclaim-example.yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-name
spec:
  # Les modes d'accès pour les volumes Docker par la suite
  accessModes:
    - ReadWriteOnce
  # On demande une portion de son espace disponible
  resources:
    requests:
      storage: '100Mi'
```

Si la demande est d'une taille requise est disponible dans l'un des PersistantVolume ET que les droits d'accès sont compatible, alors l'association va se faire automatiquement. Il est cependant possible de cibler un volume persistant directement via l'ajout de la clé **volumeName**. 

Via l'utilisation de claims, il est possible de séparer au besoin la ressource préalablement configurée en fonction des besoin de tels ou tels pods. De la sorte, un espace de données de taille finie peut être 'partitionné' et alloué en fonction des besoin en espace des pods. 

### Storage Classes

Dans le cadre d'utilisation de volumes persistants et de claims, il est possible de spécifier l'utilisation d'une **StorageClass**. Leur objectif est de permettre l'automatisation de la création des disques servant par la suite de PersistantVolume. En effet, sans utilisation de ces classes de stockage, il faudra manuellement créer les disques (en local ou dans le cloud) avant de pouvoir en faire des volumes persistants (on parle alors de Stack Provisioning). Dans le cadre du **Dynamic Provisioning**, on va donc définir des entités de StorageClass sous la forme de manifeste et nous en servir par la suite dans les manifestes des PV et PVC.  

```yaml
# storageclass-example.yaml

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: google-storage
provisioner: kubernetes.io/gce-pd
# Les paramètres sont spécifiques au type de cloud provider que l'on utilise
parameters:
  type: pd-standard
  replication-type: none
```

```yaml
# persistantvolumeclaim-storageclass-xample.yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-name
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: '100Mi'
  # On spécifie ensuite la classe de stockage que l'on veut ici
  storageClassName: google-storage
```

### Stateful Sets

Dans le cadre d'un déploiement d'une solution de base de données, il se peut qu'on ait besoin de replicats de notre SGBD afin d'augmenter la disponibilité et la résilience de notre installation. On peut imaginer une stratégie de déploiement tel que:
1. On peut ainsi définir une instance comme étant l'instance **maître**, qui doit être mise en place en premier. Les autres seront les **esclaves**
2. Les données vont être clonées de l'instance maître vers la première instance esclave lors de son initialisation
3. Par la suite, on va mettre en place une replication continue des données entre les deux types de façon synchrone ou non. L'instance maître sera disponible en **ReadWrite** alors que les autres uniquement en **ReadOnly**. Ce mode de fonctionnement peut ralentir les ajout sur l'instance maître en cas de synchronisation en temps réel ou causer un laps de temps où les données ne seront pas les mêmes si la replication est asynchrone.
4. On attent que l'instance esclave soit disponible avant de passer à la mise en place des autres esclaves
5. On va cloner les données de l'esclave précédent vers le suivant lors de leur initialisation
6. Et activer la replication continue des données entre l'instance maître et chaque instance esclave une à une
7. Enfin, on va configurer l'adresse de l'instance maître sur les instances esclaves

Ce mode de déploiement est compliqué à réaliser dans Kubernetes via un déploiement classique car il n'y a aucune garantie que l'instance maître se fera en premier. De plus, l'attente de l'état disponible pour l'instance esclave est dur à définir, les adresses IPs des différents pods étant automatiquement définis par le cluster et leur nom changerait en cas de recréation, ce qui rend compliqué le suivi de qui est qui. 

Pour nous aider, on a la possibilité de faire appel aux **StatefulSets**. Ils sont similaires aux **Deployments** classiques en cela qu'ils servent à déployer X pods et permettent également les stratégies de rollout, mais possèdent des différences intéressantes face à notre problématique. Tout d'abord, lors de l'utilisation des StatefulSets, les pods vont être créés de façon séquentielle. Avant la création des suivants, les pods précédents doivent être dans un état de disponibilité spécifique pour permettre la suite des opérations. Les noms des pods vont se faire via un compteur débutant à 0, ce qui permet par exemple de cibler l'instance maîtresse via le nom `mysql-0`. Ce nom est conservé même en cas de recréation du pod.

```yaml
# statefulset-example.yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
  labels:
    app: mysql
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql-container
          image: mysql
          ports:
            - containerPort: 3306
```

Lors du déploiement de ce type de ressource, on va avoir un déploiement séquentiel et avec un scaling également séquentiel. Les noms des pods seront uniques et leur enregistrement DNS stable. Ces détails aideront dans le cas où l'on a besoin de ces deux conditions pour notre projet comme c'est le cas ici pour la mise en place d'une série de bases de Données.

### Headless Service

Le seul détail qu'il reste à régler est la façon dont nous allons accéder aux différents pods. On sait qu'un service classique sert pour l'ensemble du cluster à accéder via l'équivalent d'un LoadBalancer à une ressource tel qu'un pod ou un ensemble de pods (**ReplicaSet**, **Deployment**, etc.). 

```text
servicename.namespace.svc.cluster-domain.example
```

Il nous faut cependant pouvoir faire la différence entre la lecture et l'ecriture pour notre cas. Il nous faudrait un service permettant de lire indépendamment entre tous les pods mais également un service pour écrire uniquement sur le pod de l'instance maîtresse. Pour réaliser cela, on va utiliser le mécanisme des **Headless Services** qui ne servira pas de LoadBalancer entre les X pods, il va simplement créer un enregistrement DNS et un accès pour chaque pod en se basant sur le nom du pod et non son adresse IP. L'enregistrement DNS ressemblera à:

```text
podname.headless-servicename.namespace.svc.cluster-domain.example
```

La création d'un enregistrement DNS de ce type passera par la configuration d'un service spécifiquement ainsi que la configuration d'un pod tel que:

```yaml
# service-headless-example.com

apiVersion: v1
kind: Service
metadata:
  name: mysql-h
spec:
  ports:
    - port: 3306
  selector:
    app: mysql

  # La différence est ici
  clusterIP: None
```

```yaml
# pod-headless-service-example.com

apiVersion: v1
kind: Pod
metadata:
  name: mysql-pod
spec:
  containers:
    - name: mysql
      image: mysql

  # Pour que le pod ait son propre enregistrement DNS, il lui faut ces deux clés optionnelles
  subdomain: mysql-h
  hostname: mysql-pod
```

Par la suite, une différence notable peut être observée lors de la configuration de pods aus sein d'un fichier manifeste de type **Deployment** ou de type **StatefulSet**.

```yaml
# deployment-headless-service-example.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
      subdomain: mysql-h
      hostname: mysql-pod
```

Dans le cadre de la réalisation d'un Deployment, l'ajout de telles clés en plus sur les template de pod amènerait à la création de X enregistrement DNS pointant vers X pods différents à partir du même nom de domaine. Cela est du au fait que les pods vont porter le même nom. 

```text
mysql-pod.mysql-h.dev.svc.cluster.local => Pod A
mysql-pod.mysql-h.dev.svc.cluster.local => Pod B
mysql-pod.mysql-h.dev.svc.cluster.local => Pod C
```

```yaml
# statefulset-headless-service-example.yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
spec:
  serviceName: mysql-h
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
```

Dans le cadre de l'utilisation d'un StatefulSet, il n'est pas nécessaire d'ajouter du côté du template de pod les clés `subdomain` et `hostname`, ces valeurs vont être ajoutées indépendamment pour chaque pod par le cluster, ce qui permettra d'avoir un enregistrement DNS différent avec son propre nom de domaine pour chaque pod. Le choix du service à utiliser se passera par l'ajout d'une clé unique `serviceName` à la place.

```text
mysql-pod-0.mysql-h.dev.svc.cluster.local => Pod A
mysql-pod-1.mysql-h.dev.svc.cluster.local => Pod B
mysql-pod-2.mysql-h.dev.svc.cluster.local => Pod C
```

### Template de PVC

Dans le cas où l'on voudrait la création de PersistantVolumeClaim indépendante pour chaque pod suite à un déploiement par StatefulSet, il faudrait un mécanisme servant à la création automatique d'une PVC se branchant sur un PV indépendant lors de l'initialisation. Pour cela, on peut utiliser le contenu d'un fichier de manifeste de **PersistantVolumeClaim** à l'intérieur de notre fichier de manifeste de **StatefulSet** via la clé `volumeClaimTemplate`: 

```yaml
# statefulset-persistantvolumeclaim-templating-example.yaml

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql-statefulset
spec:
  serviceName: mysql-h
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql
          volumeMounts:
            - mountPath: /var/lib/mysql
              name: data-volume

  volumeClaimTemplates:
    - metadata:
        name: data-volume
      spec:
        accessModes:
          - ReadWriteOnce
        storageClassName: google-storage
        resources:
          requests:
            storage: '100Mi'
```

Dans ce mode de fonctionnement, à chaque création de **Pod**, on va avoir la création d'une **PersistantVolumeClaim**. Cette PVC va entrainer la création d'un **PersistantVolume** se basant sur une **StorageClass** automatiquement. Si l'un de ces pods se trouve à être détruit puis recrée, alors le Pod recréé va être automatiquement attaché à la bonne PVC et donc aux bons fichiers.

## Sécurité

### Activer l'encryption des données *at rest*

Lorsque l'on utilise des secrets, l'ensemble des clés-valeurs est disponible de façon lisible à condition d'utiliser les bonnes commandes. Si l'on cherche à lire un fichier de configuration d'un secret, on obtient alors une version base64 de cette donnée sensible, qu'il suffit de manipuler de sorte à avoir la vrai version:

```bash
# Pour obtenir le fichier de configuration du secret
kubectl get secret <secret-name> -o yaml

# Pour décoder la valeur que l'on cherche à obtenir
echo "<encoded-value>" | base64 --decode
```

L'intérêt de l'encrpytion des données "en repos" est de vérifier qu'il n'est pas possible, via un accès au cluster, d'aller piocher dans les fichiers servant au gestionnaire de clés-valeurs du cluster. `etcd`, l'outil dédié à cette fonction, stockera les données d'une façon particulière. Il est possible d'aller vérifier ce qu'il stocke via l'installation de `etcdctl` et l'utilisation de commandes.

```bash
# Pour installer l'outil de gestion 'etcdctl'
sudo apt update -y && sudo apt install -y etcd-client
```

Pour obtenir un secret, on peut utiliser la commande suivante une fois l'outil installé:

```bash
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/old-secret | hexdump -C
```

Pour ajouter une configuration, il faut créer un fichier de configuration et relancer le serveur API de K8s avec la bonne option. Dans un premier temps, on peut aller voir quelles options ont été utilisées lors du lancement via la commande suivante (afin de vérifier que l'option `--encryption-provider-config` n'est pas déjà présente):

```bash
# Pour voir les options ayant servi au lancement du serveur API de K8s
cat /etc/kubernetes/manifests/kube-apiserver.yaml
```

Un fichier de configuration est ni plus ni moins qu'un autre fichier de ressource K8s: 

```yaml
# example-encrpytion-at-rest.yaml

apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: <BASE64_ENCODED_SECRET_KEY>
      - identity: {} 
```

* `resources`: Les différentes ressources que l'on veut encrpyter, sous forme de liste
* `providers`: Un listing des différents providers servant à l'encrpytage de nos données. L'ordre de cette liste importe car il définir l'ordre de passage des différents providers. Si **identity** est le premier de la liste, alors il n'y aura aucune sécurité car il se contentera de re-écrire les données en texte brut.

Une fois le fichier de configuration réalisé, il suffit dont d'aller modifier le fichier du manifeste de l'API server de K8s et de relancer le serveur. Voici un exemple de fichier:

```yaml
# example-kube-apiserver.yaml

---

apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 10.20.30.40:443
  creationTimestamp: null
  labels:
    app.kubernetes.io/component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    ...
    - --encryption-provider-config=/etc/kubernetes/enc/enc.yaml  # Modifier pour y mettre l'emplacement de notre fichier de configuration

    # Pour lier le fichier au cluster, on va avoir besoin d'un volume. Il faut donc une section de montage du volume dans le cluster...
    volumeMounts:
    ...
    - name: enc                           # Le nom du volume que l'on veut monter
      mountPath: /etc/kubernetes/enc      # Le dossier contenant notre fichier de configuration
      readOnly: true                      # Ajout de la lecture seule pour éviter de modifier le fichier de configuration de notre machine
    ...

  # ...et une section de création du volume de sorte à lier un fichier présent sur le 'controlplane' (via un hostPath) au cluster
  volumes:
  ...
  - name: enc                             # Un nom de volume
    hostPath:                             # Type de volume
      path: /etc/kubernetes/enc           # Chemin sur le controlplane
      type: DirectoryOrCreate             # Le type de chemin
  ...
```

Une fois le cluster relancé, on peut aller regarder si la manoeuvre a réussi via la suite de commandes suivante:

```bash
# Création du secret
kubectl create secret generic encrpytion-at-rest-test \
  --from-literal=key1=valueA

# Vérification du stockage dans 'etcd' (il n'est plus possible de lire les données directement)
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/encrpytion-at-rest-test | hexdump -C

# Les anciennes données, elles, seront toujours stockées de façon lisible car non mise à jour
ETCDCTL_API=3 etcdctl \
   --cacert=/etc/kubernetes/pki/etcd/ca.crt   \
   --cert=/etc/kubernetes/pki/etcd/server.crt \
   --key=/etc/kubernetes/pki/etcd/server.key  \
   get /registry/secrets/default/old-secret | hexdump -C

# Pour mettre à jour l'ensemble des anciens secrets
kubectl get secrets --all-namespaces -o json | kubectl replace -f -
```

### Gérer les droits dans nos conteneurs

Par défaut, les conteneurs issus d'image Docker exécutent les commandes en tant qu'utilisateur root. Cet utilisateur est le même utilisateur root que celui du système mais limité par Docker de sorte à ce qu'il n'ait pas non plus l'ensemble des capacités qu'aurait l'utilisateur hôte. Cela est rendu possible via les instructions spécifiées dans le fichier `/usr/include/linux/capability.h`. Il est possible d'avoir plus de permissions si l'on ajoute des options:

```bash
# Pour ajouter des permissions manuellement
docker run --cap-add CAP-NAME image-name

# Pour retirer des permissions manuellement
docker run --cap-drop CAP-NAME image-name

# Pour obtenir les mêmes priviléges que l'hôte
docker run --privileged CAP-NAME image-name
```

Dans le cas où l'on souhaite ne pas avoir à gérer les droits de l'utilisateur root utilisé par le conteneur, il est également possible de modifier l'utilisateur qui va être utilisé. On peut le faire lors du lancement d'une image via:

```bash
docker run --user=1001 ubuntu-sleeper
```

Ou en manipulant le fichier de création de l'image (Dockerfile) de sorte à spécifier directement l'utilisateur qui va être utilisé:

```dockerfile
# ubuntu-sleeper.Dockerfile

FROM ubuntu

USER 1001

ENTRYPOINT ["sleep"]

CMD ["10"]
```

### Security Contexts

Au niveau d'un cluster K8s, il est également possible de choisir l'utilisateur qui va être utilisé pour le conteneur via l'ajout d'un contexte de sécurité: 

```yaml
# example-pod-security-context-global.yaml

apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-pod
  labels:
    app: ubuntu
    type: mytype
spec:
  securityContext:
    runAsUser: 1000
  containers:
      - name: ubuntu-container
        image: ubuntu
        command: ["sleep", "5000"]
```

Cet ajout va concerner l'entièreté des conteneurs du pod. Il est possible de le faire plus dans le détail en déplaçant la définition du contexte de sécurité au niveau du conteneur. On peut également gérer les capacités individuellement via `capabilities`:

```yaml
# example-pod-security-context-container.yaml

apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-pod
  labels:
    app: ubuntu
    type: mytype
spec:
  containers:
      - name: ubuntu-container
        image: ubuntu
        command: ["sleep", "5000"]
        securityContext:
          runAsUser: 1000
          capabilites:
            add: ["MAC_ADMIN"]
```

### Service Accounts

Dans le cas où l'on veut déployer des applications qui doivent avoir des droits particuliers vis à vis du cluster, il n'est pas possible de le faire via des comptes utilisateurs classiques comme lorsqu'un humain va se connecter et manipuler le cluster. Il faut pour cela utiliser des comptes de service liés à des pods. Par exemple, Jenkins aurait besoin d'un ensemble de permissions afin de pouvoir déployer des applications sur le cluster, ou Prometheus doit pouvoir observer les métriques via l'équivalement des commandes que nous exécuterions.

Pour créer un compte de service de façon impérative, on peut utiliser la commande: 

```bash
# Création
kubectl create serviceaccount <sa-name>

# Listing
kubectl get serviceaccount

# Détails
kubectl describe serviceaccount <sa-name>
```

Les crédentials du nouveau compte de service passeront par l'utilisation de tokens qui sont stockés via des **Secret**. Lors de la création d'un compte de service, on a donc automatiquement la création d'au moins un jeton qui sera stocké via un secret dans le cluster et référencé dans le visionnage du compte. Dans le cas où l'on souhaiterai déployer une application dans notre cluster, on peut alors simplement lier le jeton via un volume à notre pod et demander à notre applicatif d'aller lire la valeur du jeton dans son code afin d'alimenter l'ensemble des requêtes futures. Lors de la création d'un pod, on va avoir au moins un jeton de base qui sera fourni afin de permettre la communication de base avec l'API du cluster. Ce jeton offre cependant des droits limités mais nécessaire pour que le pod puisse resté informé de l'évolution du cluster. Il est préférable de le configurer si l'on a besoin de plus de permissions.

On peut aller voir les fichiers de base liés au compte de service par défaut via:

```bash
# Pour voir le montage par défaut d'un objet Secret dans le pod
kubectl describe pod <pod-name>

# Pour lister les trois fichiers montés par défaut ('ca.crt', 'namespace' et 'token')
kubectl exec <pod-name> ls /var/run/secrets/kubernetes.io/serviceaccount

# Pour visualiser le contenu du jeton de base
kubectl exec <pod-name> cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

Pour ajouter un compte de service à notre pod, il suffit d'ajouter la clé dans son manifeste: 

```yaml
# example-pod-service-account.yaml

apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
    type: mytype
spec:
  containers:
      - name: myapp-container
        image: myapp
  serviceAccountName: <sa-name>
```

Le jeton utilisé par le compte de service était au préalable uniquement lié qu'à le durée de vie du compte de service. Il ne possèdait ni date d'expiration, ni audience. 

* Lors de la version **1.22** de K8s, ce détail a soulevé une issue, qui a amené à la création de la **TokenRequestAPI**, dont le but était d'améliorer la sécurité de l'ensemble du cluster par l'ajout d'une API générant des jetons possédant une audience, une date d'expiration et toujours liés à un objet - le compte de service. 
* Puis, lors du passage à la version **1.24**, la création automatique de token fut supprimée et il fallait passer par la commande suivante afin d'obtenir un token affiché en sortie standard:

```bash
kubectl create token <sa-name>
```

La capacité de créer des token à l'ancienne ne possédant ni date d'expiration ni audience est toujours possible, mais n'est pas recommandée. L'équipe en charge du développement de K8s privilégie désormais le passage par l'API de demande de jeton si l'on veut manipuler le cluster au sein de notre applicatif, de sorte à avoir des jetons plus sécurisés disposant d'une date d'expiration et d'une audience en plus de l'objet auquel ils sont liés.


### Authentication

La première ligne de défense de notre cluster est la capacité ou non à pouvoir y entrer dans le but d'exécuter des commandes via le serveur API. Pour sécuriser tout ça, il est important de mettre en place un mode d'authentification. On peut définir plusieurs types d'entités qui vont accéder au cluster: 
* **App Users**: Utilisateurs classiques passant par les applications déployées au sein du cluster (n'entre donc pas en compte ici car gérés dans les applicatifs directement)
* **Bots**: Les différentes ressources du cluster pouvant intéragir avec le cluster (tel Prometheus ou Jenkins). Pour les applications, on se sert de leur côté d'un **Service Account** afin d'en gérer les permissions et l'accès. 
* **Developers**: Personnes ayant les capacités à déployer et / ou modifier des ressources dans le cluster, utilisant par exemple des commandes via `kubectl`
* **Admins**: Personnes ayant des droits d'aministration et de modification de l'intégrité du cluster, utilisant par exemple des commandes via `kubeadm`

Pour gérer les utilisateurs "humains", Kubernetes repose sous un outil externe. Il est alors possible d'accéder au cluster via:
* **Jetons d'authentification**: Il est possible de faire passer un fichier contenant des informations de jetons, des noms d'utilisateurs ainsi que des informations sur ces derniers tel que leur groupe en tant que paramètre dans le lancement du serveur API. Pour cela, on peut utiliser l'option `--token-auth-file` et y mettre en valeur un fichier au format CSV. Cela n'est cependant pas le meilleur moyen de connexion
* **Certificats** : Kubernetes supporte l’authentification par certificats X.509. Chaque utilisateur ou service peut se voir attribuer un certificat signé par l’autorité du cluster. Lors de la connexion à l’API server, le client présente son certificat, qui est vérifié pour l’authentification. Cette méthode est courante pour les accès administrateurs ou pour sécuriser les communications entre composants internes (ex. kubelet, API server). Les certificats sont généralement gérés via des outils comme `openssl`, `cfssl` ou automatisés par kubeadm lors de l’installation du cluster.
* **Services d’identification** : Pour une gestion centralisée et évolutive des utilisateurs, Kubernetes peut s’intégrer à des services d’identité externes via l’authentification OpenID Connect (OIDC), LDAP ou SAML. Cela permet de déléguer l’authentification à des fournisseurs comme Google, Azure AD, Okta, Keycloak, etc. L’API server est alors configuré pour accepter les jetons OIDC ou les assertions SAML, facilitant la gestion des accès, la révocation et l’audit des utilisateurs. Cette approche est recommandée pour les environnements d’entreprise ou multi-utilisateurs.

### KubeConfig

Dans le cas où l'on souhaiterai passer par l'utilisation de fichiers de certificats pour s'authentifier, on peut utiliser une requête de type curl différente telle que: 

```bash
curl https://my-kubernetes-cluster:6443/api/v1/pods \
  --key admin.key \
  --cert admin.crt \
  --cacert ca.crt

{
  "kind": "PodList",
  "apiVersion": "v1",
  "metadata": {
    "selfLink": "/api/v1/pods"
  },
  "items": []
}
```

Une autre solution est bien sur de passer par l'utilisation classique de `kubectl`:

```bash
kubectl get pods \
  --server my-kubernetes-cluster:6443 \
  --client-key admin.key \
  --client-certificate admin.crt \
  --certificate-authority ca.crt
```

Mais ajouter à chaque fois les options et leur paramètre dans toutes nos commandes va rapidement être fastidieux. Pour éviter cela, on va plutôt passer par l'utilisation d'un fichier de configuration qui contiendra l'ensemble de notre configuration (modifiable au besoin). 

```bash
kubectl get pods \
  --kubeconfig config
```

Par défaut, l'outil va chercher un fichier tel que `$HOME/.kube/config`, il n'est alors pas forcément besoin de le configurer s'il s'y trouve. Le format du fichier est séparé en trois sections:
* **Clusters** : Cette section définit les différents clusters Kubernetes auxquels vous pouvez vous connecter. Chaque cluster est identifié par un nom et contient l’URL du serveur API (`server`), le certificat d’autorité (`certificate-authority`) et éventuellement d’autres paramètres de connexion.
* **Contexts** : Un contexte associe un utilisateur à un cluster et éventuellement à un namespace. Il permet de basculer facilement entre plusieurs environnements (ex. dev, prod) sans modifier les paramètres de connexion à chaque commande. Le contexte actif détermine le cluster et l’utilisateur utilisés par défaut.
* **Users** : Cette section décrit les identifiants d’accès pour chaque utilisateur (certificats, jetons, etc.). Chaque utilisateur peut avoir ses propres méthodes d’authentification (clé privée, certificat client, token d’accès).

```yaml
# kubeconfig-config-example.yaml

apiVersion: v1
kind: Config

clusters:
- name: demo-cluster
  cluster:
    server: https://demo-kubernetes-cluster:6443
    certificate-authority: /path/to/ca.crt

users:
- name: admin
  user:
    client-certificate: /path/to/admin.crt
    client-key: /path/to/admin.key

contexts:
- name: admin@demo-cluster
  context:
    cluster: demo-cluster
    user: admin
    namespace: default

current-context: admin@demo-cluster
```

Plusieurs commandes existent dans Kubernetes pour manipuler la configuration: 

```bash
# Visionner le contenu actuel du fichier de configuration
kubectl config view

# Visionner le contenu d'un autre fichier de configuration
kubectl config view -kubeconfig=my-custom-config

# Pour changer le contexte actuel (current-context)
kubectl config use-context user@cluster
```

### API Groups

Pour manipuler les différentes ressources de Kubernetes, il est possible de le faire via deux familles principales d'endpoints. La premier débute par `/api/v1`. Via cet endpoint, on peut par la suite manipuler les ressources via le type de ressource que l'on veut manipuler tel que `/api/v1/pods`. Une autre solution qui sera utile de connaître pour comprendre les droits est l'endpoint des groupes débutant par `/apis`. Dans cet endpoint se trouve plusieurs sous-sections telles que `/api/apps` ou `/api/sotage.k8s.io`, ce dans le but de regrouper ensuite les sous ensemble par catégories par une syntaxe de type `/apis/category/v1/resource/verb`. Ainsi, on aura par exemple `/api/apps/v1/deployments/list`, `/api/apps/v1/deployments/create`, `/api/apps/v1/replicasets/list` ou `/api/apps/v1/statefulsets/delete`.

Dans le cas où l'on aimerait revoir l'ensemble des groupes disponibles dans le serveur API, on peut le faire via une requête curl telle que: 

```bash
# Démarre un proxy dans le but de pré-peupler la requête avec les certificats
kubectl proxy

# Réalise une requête au proxy
curl http://localhost:8081 -k
```

### Authorization

Une fois passé la porte d'entrée dans le cluster, on aimerait pouvoir gérer plus spécifiquement les droit de tel ou tel utilisateur. De la sorte, on pourrait par exemple créer des rôles au sein de l'équipe de développement ou restreindre les droits à tel ou tel section du cluster pour un groupement de personne ou pour un applicatif particulier (en cas d'utilisation d'un **ServiceAccount** par cette dernière). Pour gérer les droits, plusieurs modes sont disponibles. Pour modifier le mode, cela passe par l'option `--authorization-mode` lors du lancement du serveur API. Il est possible d'en mettre plusieurs, dans ce cas l'autorisation se fera via l'ensemble des modes demandés, dans l'ordre mentionné. Tous devront valider l'autorisation sous peine de ne pas avoir les droits.

* Le mode de base est le mode **Node**. Parmi les autorisations déjà présentes au sein du cluster se trouve le **Node Authorizer**, qui se charge des droits pour les `kubelet` présent sur les différentes nodes. Ces nodes peuvent ainsi lire les informations du cluster et partager les informations sur leur intégrité en temps réel avec le serveur API du cluster, présent sur une node maîtresse.
* Il est aussi possible de créer un mécanisme **ABAC** pour les utilisateurs, en gérant leur liste de droits tels que la lecture des pods ainsi que leur manipulation basique. Pour cela, on va créer un fichier de politiques au format JSON que l'on va envoyer au serveur. A chaque modification des politiques ABAC, il faudra relancer le serveur API.
* Une façon plus simple de gérer l'entièreté des politiques est de passer par l'utilisation de rôles (**RBAC**) de sorte à regrouper via un rôle l'ensemble des politiques et appliquer ce rôle à un ensemble d'utilisateurs directement.
* Il est également possible d'exériorisé le mécanisme d'authentification et d'autorisation. Pour cela, on peut passer par l'utilisation d'un agent externe, **Open Policy Agent**.
* Enfin, deux autres modes existent, celui de **AlwaysAllow** (le mode par défaut) et **AlwaysDeny**, dont le nom laisse peut à supposer quant à leur fonction.

```json
// policy-file-abac-example.json

[
  {
    "kind": "Policy",
    "spec": {
      "user": "dev-user",
      "namespace": "*", 
      "resource": "pods", 
      "apiGroup": "*"
    },
  },
  {
    "kind": "Policy",
    "spec": {
      "user": "dev-user2",
      "namespace": "*", 
      "resource": "pods", 
      "apiGroup": "*"
    },
  }
]
```

### RBAC

Pour gérer les rôles au sein du cluster, il va tout d'abord falloir définir un nouveau rôle. Pour cela, on passe par la création d'un objet de **Role**: 

```yaml
# role-example.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
rules:
  - apiGroups: [""]
    resources: ["ConfigMap"]
    verbs: ["create"]
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["list", "get", "create", "update", "delete"]
    # On peut optionnellement ajouter cette clé dans le but de spécifier les resources auquelles ce rôle s'applique en détail
    resources: ["blue", "green"]
```

Ensuite, pour lier un utilisateur à un rôle, il faut créer un objet de type **RoleBinding**

```yaml
# role-binding-example.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: devuser-developer-binding
subjects:
  - kind: User
    name: dev-user
    apiGroup: rbac.authorization.k8s.io
roleDef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

Des commandes relatives à ces entités existent dans Kubernetes:

```bash
# Pour lister les rôles du cluster
kubectl get roles

# Pour lister les rôlebindings du cluster
kubectl get rolebinding

# Pour vérifier nos propres droits au sein du cluster
kubectl auth can-i <verb> <resource>

# Pour vérifier les droits d'un utilisateur au sein du cluster (si on est administrateur)
kubectl auth can-i <verb> <resource> --as <username>
kubectl auth can-i <verb> <resource> --as <username> --namespace <namespace>
```

### ClusterRoles

Les rôles et les liaisons de rôle classique ne sont d'aucune utilité dans le cadre de l'administration de ressources communes à l'ensemble des namespace comme c'est le cas par exemple d'une node ou de volumes persistants. Pour gérer les droits de ces entités, il va falloir avoir recourt à des ressources différentes, les **ClusterRoles** et **ClusterRoleBindings**.

```yaml
# clusterrole-example.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cluster-administrator
rules:
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["list", "get", "create", "update", "delete"]
```

```yaml
# clusterrole-binding-example.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-admin-role-binding
subjects:
  - kind: User
    name: cluster-admin
    apiGroup: rbac.authorization.k8s.io
roleDef:
  kind: ClusterRole
  name: cluster-administrator
  apiGroup: rbac.authorization.k8s.io
```

Il est également possible de spécifier des ressources présentent dans un Namespace via un rôle de cluster. Contrairement à une Role classique qui n'autorisait les manipulations des ressources qu'au sein d'un namespace, cette fois ci, il sera possible de le faire même depuis un autre namespace.

### Admission Controllers

Pour résumer, le mécanisme d'envoi d'une requête via kubelet vers le serveur API se fait via: 
* Récupération d'un fichier de configuration contenant le branchement vers les différentes clés et certificats afin de passer le processus d'**Authentification**
* Parcourt de l'ensemble des droits gérés par les rôles et les liaisons de rôle afin de vérifier que l'on a le droit ou non d'effectuer la manipulation voulue, c'est le processus d'**Authorization**.

Si les deux conditions sont réunies, alors la requête passera et traitée par le cluster.

Imaginons désormais que l'on veuille vérifier des choses telles que l'image utilisée au sein d'un déploiement, les droits ajoutés à un conteneur, les labels du pods ou l'utilisateur de lancement d'un conteneur. Pour cela, on a la possibilité de mettre une troisième étape lors de la vérification d'une requête. Il s'agit des **Admission Controllers**. Si l'on veut connaître les contrôleurs actifs par défaut ou en modifier le listing, cela se passe via l'option `--enable-admission-plugins` ou `--disable-admission-plugins`. 

Il en existe plusieurs de base dans Kubernetes, tel:
* **AlwaysPullImages** : Ce contrôleur d’admission force Kubernetes à effectuer systématiquement un `docker pull` de l’image spécifiée pour chaque pod, même si l’image est déjà présente localement sur le nœud. Cela garantit que la version la plus récente de l’image est utilisée et limite les risques liés à l’utilisation d’images obsolètes ou modifiées localement. Il est particulièrement utile dans les environnements multi-utilisateurs ou partagés pour renforcer la sécurité et la cohérence des déploiements.
* **DefaultStorageClass** : Ce contrôleur attribue automatiquement une classe de stockage par défaut (`StorageClass`) aux PersistentVolumeClaims (PVC) qui n’en spécifient pas explicitement. Cela simplifie la gestion du stockage dynamique, car les utilisateurs n’ont pas besoin de connaître ou de définir la classe de stockage à utiliser. Si plusieurs StorageClass sont présentes, une seule peut être marquée comme par défaut.
* **EventRateLimit** : Ce contrôleur permet de limiter le nombre d’événements générés par le cluster Kubernetes (par exemple, les événements liés aux pods, nodes, etc.) afin d’éviter la surcharge du serveur API ou des systèmes de monitoring. Il est configurable pour fixer des quotas par type d’événement, namespace ou source, et ainsi protéger la stabilité du cluster contre des boucles d’erreurs ou des applications trop bavardes.
* **NamespaceExists** : Ce contrôleur vérifie que le namespace ciblé par une ressource existe bien avant d’autoriser sa création ou sa modification. Il empêche la création accidentelle de ressources dans des namespaces inexistants, ce qui pourrait entraîner des incohérences ou des erreurs lors du déploiement.
* **NamespaceAutoProvision** : Ce contrôleur d’admission permet la création automatique d’un namespace lorsqu’une ressource est soumise dans un namespace inexistant. Plutôt que de rejeter la requête, Kubernetes crée le namespace à la volée avant de traiter la ressource. Cela simplifie les workflows automatisés ou les scripts qui déploient des ressources dans des namespaces qui n’ont pas encore été explicitement créés, mais peut aussi entraîner la prolifération involontaire de namespaces si la gestion des noms n’est pas rigoureuse. (Non actif par défaut)
* etc.

Ces Admission Controller sont catégorisés en deux grandes familles qui ont un ordre d'exécution prévu pour rendre la requête logique: 
- **Mutating Admission Controllers** : Ils peuvent modifier les objets envoyés à l’API avant leur validation et stockage. Par exemple, ils peuvent ajouter des labels, injecter des sidecars, ou compléter des champs manquants. Exemples : `MutatingAdmissionWebhook`, `DefaultStorageClass`, `NamespaceAutoProvision`.
- **Validating Admission Controllers** : Ils vérifient que les objets respectent certaines contraintes ou politiques, mais ne les modifient pas. Si la validation échoue, la requête est rejetée. Exemples : `ValidatingAdmissionWebhook`, `NamespaceExists`, `ResourceQuota`.