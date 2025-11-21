# Helm

## Introduction

Dans l'ecosystème Kubernetes, déployer des applications peut amener à plusieurs challenges:
* **Gestion des ressources complexes**: Gérer de multiples fichiers d'entités Kubernetes, qu'il s'agisse de ConfigMaps, de Pods, et Deployments, etc. peut vite devenir une charge de travail importante et l'on peut s'y perdre.
* **Editions manuelles pouvant amener à des erreurs**: L'édition manuelle de fichiers YAML peut amener à des soucis de syntaxe, des problèmes de nommage des entités ou des soucis de configuration. La gestion de la configuration de chaque entité du cluster peut être une tâche assez délicate et amène souvent à des erreurs humaines.
* **Configuration de l'environnement fastidieuse**: La duplication du code et des fichiers est rapidement une tâche ennuyante de part la similitude importante entre les différents fichiers. En utilisant **Kustomize**, on a un manque de flexibilité dans le cadre de la création d'environnement de déploiement différents.
* **Gestion des version et rollbacks délicats**: Gérer la version de chaque fichier YAML peut être un grand challenge et amènera souvent à des écarts de configuration entre les entités. Dans le cas d'un échec, il n'y a pas de manière aisée de passer à une ancienne version.

Dans l'ecosystème Kubernetes, l'ajout d'une application va passer potentiellement par de multiples fichiers de ressources, tous de différents types et avec leurs ensembles clés-valeurs particuliers. En cas de changement de la configuration, on va devoir modifier dans pleins de fichiers à la fois plusieurs valeurs de clés. Cela peut être un travail de longue haleine, en particulier si l'on a plusieurs miliers de lignes à changer d'un coup. Pour éviter ce cauchemar, on peut utiliser **Helm**. Via son utilisation, on passe d'un paradigme des entités kubernetes à un paradigme centré sur l'application. Il est parfois comparé à un gestionnaire de paquets pour Kubernetes.

* Helm est en quelque sorte un **gestionnaire de paquets pour Kubernetes**, de la même façon que yum pour RedHat, apt pour Débian ou npm pour Nodejs.
  * Il sert à définir, installer et mettre à jour des applications contenant de multiples ressources Kubernetes via une seule commande.
* Via son utilisation, on peut créer ce que l'on appelle des chartes de sorte à gérer plusieurs manifestes d'un coup. Compatible avec les fonctionnalités de templating du langage Go, on peut également créer de multples variantes de notre déploiement via l'utilisation de variables. 
* Il est possible de stocker ou de récupérer des chartes externes via l'utilisation d'un registre des chartes Helm privé ou public. Dans ce registre, on peut stocker plusieurs version d'une même charte de sorte à sauvegarder ou utiliser plusieurs versions d'un déploiement applicatif.
* Via l'utilisation de hooks et de la CLI, on peut réaliser du testing facilité sur l'ensemble de notre déploiement.

### Avantages et Limites

Parmi les avantages, nous avons:
* **Processus de déploiement simplifié**: Permet de s’assurer plus facilement que tous les composants Kubernetes nécessaires sont installés, et de gérer les mises à jour et correctifs dans des déploiements comportant plusieurs composants.
* **Cohérence entre les environnements**: Garantit que les déploiements restent cohérents d’un environnement à l’autre, tout en autorisant des configurations spécifiques à chaque environnement grâce aux value overrides (surcharges de valeurs).
* **Gestion efficace des versions (releases)**: Permet d’effectuer des mises à jour ou des retours en arrière (rollbacks) d’applications entières à l’aide de simples commandes.
* **Collaboration renforcée**: Des milliers de charts très utiles sont disponibles dans des dépôts publics. Les équipes et les entreprises peuvent aussi utiliser des dépôts privés pour partager et examiner des charts, favorisant la cohérence, la standardisation et les bonnes pratiques.
Hel**m encourage également une documentation complète des charts, rendant ainsi les composants réutilisables plus faciles à utiliser.
* **Déploiements versionnés**: Le versionnage des charts contribue grandement à garantir la stabilité des versions empaquetées de ton application.
* **Souplesse du système de templates**: Permet de dépasser les limitations de Kubernetes et de Kustomize afin de créer des applications réellement flexibles et configurables.

Et pour les inconvénients:
* **Courbe d’apprentissage**: Helm introduit de nouveaux concepts tels que le templating et la structure spécifique des charts, ce qui peut demander un certain temps d’adaptation. Le langage de templating de Go est également très riche, mais parfois difficile à maîtriser.
* **Sur-templating et charts difficiles à maintenir**: Pour des applications simples, Helm peut ajouter une complexité inutile. On risque aussi de tomber dans le piège du sur-engineering des modèles (templates), les rendant plus complexes et plus difficiles à maintenir que nécessaire.
* **Implications en matière de sécurité**: L’utilisation de charts issus de la communauté nécessite une vérification attentive afin d’éviter les vulnérabilités potentielles.
* **État des releases stocké dans le cluster**: L’état d’une release est enregistré directement dans le cluster, ce qui signifie que la suppression de cet état peut provoquer des incohérences dans Helm. De plus, toute modification manuelle des objets déployés entraîne une divergence de configuration (configuration drift) entre ce que Helm pense être déployé et la réalité du cluster.
* **Mises à jour parfois complexes**: Les mises à niveau peuvent être difficiles à exécuter, et de petites erreurs de version (par exemple incrémenter seulement la version mineure alors qu’il faudrait une version majeure pour un changement incompatible) peuvent causer d’importants problèmes lors des mises à jour.

### Différences entre Helm et Kustomize 

| **Dimension**                           | **Helm**                                                                                                                                                                                     | **Kustomize**                                                                                                                                                                 |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Objectif global**                     | Gestionnaire de paquets pour Kubernetes, prenant en charge le *templating*, la gestion des dépendances et le versionnage des applications.                                                   | Permet de personnaliser des manifestes YAML Kubernetes existants en appliquant des modifications (*overlays*) également définies en YAML.                                     |
| **Complexité**                          | Plus complexe à utiliser, car il faut apprendre le langage de *templating* Go et la structure globale des *charts*.                                                                          | Plus simple à utiliser, car il repose uniquement sur les constructions natives du YAML et n’introduit pas de langage de *templating*.                                         |
| **Fonctionnalités de personnalisation** | Système complet de *templating* incluant des conditionnels, des boucles, des fonctions et la substitution de variables.                                                                      | Prise en charge des *strategic merge patches*, *JSON patches*, préfixes/suffixes de noms, labels et annotations communs.                                                      |
| **Cas d’utilisation**                   | • Gestion et empaquetage d’applications ainsi que de leurs dépendances.  <br>• Versionnage des applications.  <br>• Personnalisations avancées via des *templates* et des fichiers *values*. | • Gestion de personnalisations propres à chaque environnement (ex. : dev, staging, prod).  <br>• Application de correctifs et modifications sans dupliquer les fichiers YAML. |

### Architecture

![Helm Architecture](assets/helm-architecture.png)

### Installation

Pour installer Helm, il faut:
* Installer KinD de sorte à pouvoir créer notre propre cluster Kubernetes: [lien](https://kind.sigs.k8s.io/docs/user/quick-start/#installing-from-release-binaries)
* Installer la dernière version de kubectl afin de pouvoir gérer le cluster: [lien](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
* Installer Helm via les instructions disponible à ce [lien](https://helm.sh/docs/intro/install/).

```bash
# kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"


# helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```

## Helm Charts

### Installer une chart

Lorsque l'on veut utiliser des chartes Helm disponible en ligne, il est nécessaire d'ajouter dans un premier temps manuellement les dépots de sorte à pouvoir ensuite aller y chercher les fichiers Helm servant au déploiement de tel ou tel applicatif. De nombreuses chartes sont d'ailleurs déjà disponible en ligne, par exemple sur [artifacthub.io](https://artifacthub.io/). Il est possible de les parcourir et les manipuler via des commandes helm:
* `helm repo add <repository-name> https://repository-link/`: Va servir à ajouter progressivement les dépot à la liste des dépots dans lesquels Helm peut aller effectuer des actions
* `helm repo list`: Permet le listing des différents dépots ajoutés précédemments
* `helm repo update`: Permet la mise à jour des informations présentes sur les différents dépots ajoutés
* `helm search repo <search-input>`: Permet de chercher la présence d'un artéfact sur l'un des dépots en tracking
* `helm show chart <repository>/<chart-name>`: Permet de visualiser les informations d'une chart Helm
* `helm show readme <repository>/<chart-name>`: Permet de visualiser les informations d'un README de documentation affilié à une chart Helm
* `helm show values <repository>/<chart-name>`: Permet de visualiser les valeurs par défaut des variables utilisées dans une chart Helm

```bash
# Pour chercher une chart en ligne
helm search <repository> <search-input>

# Pour télécharger une chart distante
helm pull --untar <chart-name>

# Pour installer une chart sur notre cluster depuis un repository distant (la 'release-name' sera le nom commun à l'ensemble des éléments dans le cluster)
helm install <release-name> <chart-name>

# Exemple: Installation depuis un registre distant
helm install <release-name> bitnami/wordpress

# Exemple: Installation depuis un fichier local
helm install <release-name> ./workdpress

# Pour lister l'ensemble des paquets installés
helm list

# Pour retirer une chart de notre cluster
helm uninstall <release-name>
```

```bash
# Ajouter le repository
helm repo add bitnami https://charts.bitnami.com/bitnami
# Installer la chart
helm install my-wordpress bitnami/wordpress --version 27.1.8
# Desinstaller la release de la chart 'bitnami/wordpress'
```

Une fois une application manipulée et testée, il est possible de la retirer via la suite de commandes suivantes. Attention cependant, dans la majorité des cas, Helm ne va pas supprimer les données de l'application, ce qui est un avantage lorsque l'on veut conserver ces dernières. Dans le cas de redéploiement, cela peut cependant poser problème. Dans l'exemple d'une application Wordpress provenant du dépot de Bitnami, alors il est nécessaire d'opérer à une suppression des secrets de sorte à ce que la nouvelle série de manifeste puisse repartir avec un mot de passe de connexion entre la BdD et le frontend généré au lancement. De même, le mot de passe admin de Wordpress sera également généré et stocké dans des secrets.

```bash
helm uninstall my-wordpress
# Vérifier ensuite la présence de données (celles-ci ne sont pas supprimées par Helm lors de la désinstallation)
kubectl get pv,pvc
kubectl delete pvc/<pvc-name>
```

### Choisir nous même nos variables

Lors du lancement d'une charte Helm via l'invité de commande, il est possible de modifier les valeurs via des arguments supplémentaires: 

```bash
helm install my-wordpress bitnami/wordpress --version 27.1.8 \
  --set mariadb.auth.rootPassword=rootpassword \
  --set mariadb.auth.password=password
```

Pour ensuite retrouver nos valeurs, il y a deux moyens. Sachant qu'il s'agit de secrets au niveau de Kubernetes, il nous faudra utiliser le décoding de base64: 

```bash
# Méthode classique Kubernetes
kubectl get secret my-wordpress-mariadb -o jsonpath='{.data.mariadb-password}' | base64 -d
kubectl get secret my-wordpress-mariadb -o jsonpath='{.data.mariadb-rootPassword}' | base64 -d

# Méthode via Helm
helm get values my-wordpress
# Pour atteindre une révision en particulier
helm get values my-wordpress --revision 13
```

Pour ajouter des données sécurisées, il est aussi possible de passer par l'utilisation de fichiers de type YAML dans le but de fournir un ensemble de valeurs à la place d'utliser une succession de `--set`: 

```bash
helm install my-wordpress bitnami/wordpress --version 27.1.8 \
  -f custom-values.yaml
```

### Gérer les versions

Dans le cas où l'on aurait besoin de mettre à jour les valeurs actuellement dans notre release Helm, il est possible de le faire via la commande: 

```bash
helm upgrade \
  --reuse-values \
  --values custom-values.yaml \
  my-wordpress bitnami/wordpress \
  --version 27.1.8
```

Si l'on veut désormais mettre à jour notre déploiement via une nouvelle version de la charte Helm, on peut le faire via:
```bash
helm upgrade \
  --reuse-values \
  --values custom-values.yaml \
  my-wordpress bitnami/wordpress \
  --version 27.1.10
```

Il est possible de consulter l'historique des versions d'une release avec la commande suivante. Chaque ligne affiche la révision, la date, le statut et la description:
```bash
# Afficher l'historique d'une release
helm history <release-name>

# Exemple
helm history my-wordpress

# Limiter le nombre d'entrées affichées
helm history my-wordpress --max 10
```


Si la mise à jour pose problème ou qu'il y a un soucis quelconque dans la nouvelle version, il est possible de revenir en arrière via un rollback.
```bash
# Revenir à une révision donnée
helm rollback <release-name> <revision>

# Exemple : revenir à la révision 2
helm rollback my-wordpress 2
```

Dans le cas où l'on souhaiterai faire une mise à niveau d'une révision, il est possible d'améliorer notre commande afin de prendre en compte divers types d'échecs dans le but de faire un rollback automatique. Pour cela, on peut utiliser par exemple les options suivantes:
```bash
helm upgrade \
  --reuse-values \
  --values custom-values.yaml \
  --set "image.tag=nonexistant" \
  my-wordpress bitnami/wordpress \
  --version 27.1.10 \
  --atomic \
  --cleanup-on-fail \
  --debug \
  --timeout 2m
```

* `--atomic`: Si l'upgrade échoue, Helm tente automatiquement de revenir à l'état précédent (rollback). Implique généralement un comportement d'attente (--wait) pour vérifier la réussite avant de valider l'upgrade.
* `--cleanup-on-fail`: En cas d'échec, supprime les ressources ou la release partiellement créée afin de ne pas laisser un état intermédiaire cassé. (Complémentaire à --atomic pour laisser l'environnement propre.)
* `--debug`: Affiche des logs et sorties détaillées (utile pour diagnostiquer les erreurs, montrer les manifests renderés, etc.).
* `--timeout 2m`: Durée maximale d'attente pour les opérations (par ex. création des pods / readiness) : ici 2 minutes. Format supporté (ex) s, m. Si l'opération dépasse ce délai, Helm considère l'opération comme échouée.

## Créer nos propres charts

### A quoi ça sert ? 

* Il se peut qu'une application maintenue par une équipe compétente et packagée dans une chart Helm n'existe pas pour notre besoin spécifique
* La réalisation d'une chart manuellement permet la configuration des dépendances et des entitées directement en lien avec notre applicatif
* Via la réalisation d'une chart personnalisée, on a le contrôle de l'ensemble des ressources et de leur configuration. Il est alors possible d'implémenter la logique adaptée à notre templating.
* L'utilisation d'un versioning rend plus aisé le passage d'une version à l'autre de notre aplication, permettant le contrôle de multiples objets d'un seul coup.
* En créant nous même notre chart, on peut renforcer le besoin d'adhésion à une cohérence de politique interne et des bonnes pratiques de l'entreprise. 
* La réutilisation de charts externe peut encore être possible, permettant d'avoir également le contrôle sur un assemblage de plusieurs ressources créées par autrui dans lesquelles ont viendrait piocher.

### Structure

Pour réaliser une charte Helm, il est nécessaire d'avoir une certaine quantité de fichiers, tel que: 

```text
├── Chart.yaml
├── LICENCE
├── README.md
├── charts/
├── templates/
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── svc.yaml
│   ├── deploy.yaml
│   ├── ingress.yaml
│   └── <others>.yaml
└── values.yaml
```

On y trouve donc les fichiers suivants: 
* `Chart.yaml` : fichier de métadonnées de la chart. Contient des champs obligatoires et optionnels :
  - `apiVersion`: version du format (ex. "v2").
  - `name`: nom de la chart (ex. "my-app").
  - `version`: version de la chart elle‑même (semver, ex. "0.1.0").
  - `appVersion`: version de l'application empaquetée (ex. "1.2.3").
  - `description`: courte description.
  - `type`: type de package (ex. "application" ou "library").
  - `keywords`: liste de mots‑clés.
  - `dependencies`: tableau de dépendances (nom, version, repository).
  
  Exemple minimal :
  ```yaml
  apiVersion: v2
  name: my-app
  version: 0.1.0
  appVersion: "1.0.0"
  description: "Chart pour déployer my-app"
  type: application
  keywords:
    - web
    - backend
  dependencies:
    - name: redis
      version: "14.4.0"
      repository: "https://charts.bitnami.com/bitnami"
  ```

* `values.yaml` : valeurs par défaut utilisées par les templates. Centralise les paramètres configurables (image, réplicas, ressources, ports, secrets simulés, etc.). Exemple :
  ```yaml
  replicaCount: 2

  image:
    repository: myorg/my-app
    tag: "1.0.0"
    pullPolicy: IfNotPresent

  service:
    type: ClusterIP
    port: 80

  resources:
    limits:
      cpu: 200m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi

  persistence:
    enabled: true
    size: 10Gi
  ```

* `README.md` : documentation utilisateur de la chart. Décrit l'objectif de la chart, variables importantes (extraits de values.yaml), exemples d'installation et notes d'utilisation (NOTES.txt peut compléter). Inclure instructions pour overrides et exemples `helm install` / `helm upgrade`.

* `LICENCE` : fichier indiquant la licence sous laquelle la chart est publiée (MIT, Apache‑2.0, etc.). Fournir le texte complet de la licence choisie ou un lien clair.

* `.helmignore` : liste de motifs à ignorer lors du packaging (`helm package`). Exemples courants : fichiers CI, .git, node_modules, fichiers temporaires :
  ```
  .git/
  .DS_Store
  .gitignore
  README.md
  tests/
  ```

* `charts/` : répertoire optionnel contenant des charts dépendantes (sous‑charts) ou des archives `.tgz` de dépendances. Utilisé pour empaqueter localement plusieurs composants.

* `templates/` : répertoire contenant les manifests Kubernetes templatisés. Contient :
  - `_helpers.tpl` : fonctions et templates réutilisables.
  - `deployment.yaml`, `service.yaml`, `ingress.yaml`, `secret.yaml`, `pvc.yaml`, etc.
  - `NOTES.txt` : message affiché après l'installation.
  - `tests/` : (optionnel) tests helm (hooks ou manifests pour `helm test`).

  Bonnes pratiques :
  - Utiliser `.Values` pour toutes les valeurs modifiables.
  - Protéger les secrets (encourager External Secrets / sealed-secrets plutôt que d’ajouter des secrets en clair).
  - Documenter les paramètres importants dans README.md et values.yaml.
  - Garder les templates simples et réutiliser `_helpers.tpl` pour les noms et labels.

Ces fichiers ensemble forment la structure minimale d'une Helm Chart et facilitent le packaging, la configuration et la réutilisation.

### Les fichiers de templating

Parmi l'entièreté de nos fichiers de manifeste Kubernetes, de nombreuses informations pourraient être gérer par des variables, telles que la version de l'image de conteneur, les ressources requises par les pods, les secrets ou les ports des services. Pour centraliser tout cela, Helm va utiliser des fichiers contenant des valeurs ainsi que des fichiers de templating. Nos fichiers de templates seront au final nos anciens fichiers de manifestes.

```yaml
# deployment.yaml 

apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.27.0
          ports:
            - containerPort: 80
```

```yaml
# service.yaml

apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
  labels: 
    app: nginx
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

Une fois nos fichiers créés au bon endroit, il est possible de manipuler notre chart via l'ensemble des commandes suivantes:

```bash
# Pour obtenir un résumé des YAML concernés par notre charte
helm template /path/to/helm/folder/

# Pour vérifier la qualité d'écriture de nos fichiers et être informé d'améliorations possible
helm lint /path/to/helm/folder/

# Pour installer une charte locale et la déployer ainsi au sein de notre cluster
helm install <chart-name> /path/to/helm/folder/
```

### Templating Go

Il est d'ailleurs possible d'utiliser un systeme descendant du templating du langage Go de sorte à utiliser des valeurs variables pour remplacer les valeurs fixes de nos fichiers, permettant ainsi la création de variantes:

```yaml
# secret-helm-template.yaml

apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-admin-password
data:
  key: {{ .Values.passwordEncoded }}
```

```yaml
# pv-helm-template.yaml

apiVersion: v1
kind: PersistantVolume
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}-pv
spec:
  capacity:
    storage: {{ .Values.storage }}
  accessModes:
    - ReadWriteOnce
  gcePersistentDisk:
    pdName: wordpress-2
    fsType: ext4
```

On peut ainsi, au sein de nos template, utiliser des valeurs provenant de notre fichier values.yaml via la syntaxe `.Values.nomVariable`. A côté de ça, on peut aussi utiliser d'autre valeurs disponibles de par l'utilisation de Helm telle que `.Release.Name` ou `.Chart.Name` dans le but d'avoir des identifiants uniques dans les déploiement Kubernetes (Helm impose des noms de release différents). Un fichier de valeurs ressemble de son côté à ceci:
```yaml
# values.yaml
storage: 20Gi
passwordEncoded: dqzdQZdqdqDQd3qd45dqd6==
```

Il est possible, au sein d'un template de manifeste Kubernetes, de faire appel aux conditions de sorte à ajouter, modifier ou retirer des informations des fichiers de configurations résultant de la génération par Helm en amont de leur envoi au cluster. Pour cela, on peut utiliser une syntaxe telle que: 

```yaml
# Ce type de commentaire restera dans la template finale
{{/* Ce type là ne restera pas dans la template finale, mais causera une ligne vide */}}
{{- /* Ce type là ne restera pas dans la template finale et ne causera pas de ligne vide */}}
labels:
  {{- /* Comment A */}}
  app: {{ .Release.Name }}
  {{- /* Comment B */}}
  chart: {{ .Chart.Name }}

{{- /* Il est également possible d'utiliser des fonctions avec la syntaxe ci-dessous. Le piping est également possible. */}}
{{- /* <function name> <arg1> <arg2> */}}
testLower: {{ lower .Values.test }}
testReplace: {{ replace " " "-" .Values.test  }}
testBoth: {{ lower (replace " " "-" .Values.test)  }}
testBothBis: {{ replace " " "-" .Values.test | lower  }}

{{- /* On peut créer des blocs de condition pour notre templating */}}
{{- if eq .Values.environment "Production" }}
environment: Production
build: stable
public-ingress: true
{{- else }}
environment: Development
build: alpha
public-ingress: false
{{- end }}
```

### Utiliser des helpers 

Dans le cas où l'on aimerait centraliser nos données de template, il peut être intéressant de faire usage des helpers. Il s'agit en quelque sorte de fonction retournant une ou plusieurs valeurs, que l'on peut ensuite appeler au sein de nos fichiers de templating. 

```yaml
{{- define "templating-deep-dive.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "templating-deep-dive.selectorLabels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end -}}
```

```yaml
# deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "templating-deep-dive.fullname" . }}
  labels: {{ include "templating-deep-dive.selectorLabels" . | nindent 4 }}
...
```

### Variables et structure de contrôle

On peut créer des variables pour les utiliser au sein de nos helpers. Le scope d'une variable, dans un bloc de helper, correspond uniquement à ce bloc. Elle ne pourra ainsi pas être retrouvée et utilisée en dehors de ce dernier. Il est d'ailleurs possible, au sein d'un bloc de helper, d'utiliser des structures conditionelles. Dans le cas d'utilisation de telles structures, alors le scope d'une variable déclaré en leur sein correspond à la structure conditionnelle, comme dans un langage de programmation type Javascript: 

```yaml
{{- define "templating-deep-dive.fullname" -}}
{{- $fullName := printf "%s-%s" .Release.Name .Chart.Name }}
{{- if .Values.customName }}
{{- $fullName = .Values.customName }}
{{- end }}
{{- $fullName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

Une autre façon d'avoir une valeur par défaut est de faire usage de la fonction dédiée tel que:

```yaml
{{- define "templating-deep-dive.fullname" -}}
{{- $defaultName := printf "%s-%s" .Release.Name .Chart.Name }}
{{- .Values.customName | default $defaultName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

#### Listes

Si l'on veut créer une structure de type boucle au sein d'un template Helm, il est possible d'utiliser la fonction `range` (un peu comme en Python) de sorte à itérer entre les valeurs d'une liste. On obtiendra alors deux variables, l'index en court de parcourt ainsi que la valeur associée au sein de la liste: 

```yaml
list:
  - prop1: value
    prop2: value
  - prop1: value
    prop2: value
```

```yaml
{{- range $idx, $svc := (.Values.services | default list) }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "templating-deep-dive.fullname" $ }}-{{ $idx }}
  labels: {{ include "templating-deep-dive.selectorLabels" $ | nindent 4 }}
spec:
  type: {{ $svc.type }}
  selector: {{ include "templating-deep-dive.selectorLabels" $ | nindent 4 }}
  ports:
    - protocol: TCP
      port: {{ $svc.port }} 
      targetPort: {{ $.Values.containerPorts.http }}
{{- end }}
```

#### Dictionnaires

L'utilisation de range peut également se faire dans le cas d'un dictionnaire (`map`). Dans ce cas de figure, il faut que notre variable à itérer soit sous cette forme: 

```yaml
dictionnary:
  key1: 
    prop1: value
    prop2: value
  key2: 
    prop1: value
    prop2: value
```

```yaml
{{- range $key, $svc := (.Values.services | default list) }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "templating-deep-dive.fullname" $ }}-{{ $key }}
  labels: {{ include "templating-deep-dive.selectorLabels" $ | nindent 4 }}
spec:
  type: {{ $svc.type }}
  selector: {{ include "templating-deep-dive.selectorLabels" $ | nindent 4 }}
  ports:
    - protocol: TCP
      port: {{ $svc.port }} 
      targetPort: {{ $.Values.containerPorts.http }}
{{- end }}
```

## Aller plus loin

### Helm create

Dans le cas où l'on souhaiterai créer un dossier contenant une charte Helm, il est possible de nous simplifier la vie en faisant usage de la commande `helm create <repertory-name>`. De la sorte, Helm va chercher à créer un dossier et le peupler via les fichiers communs d'une charte. Les valeurs seront également prépeuplées et commentées de sorte à offrir des informations de base sur les composants Kubernetes potentiellement utilisés par notre charte.

### La variable "."

De base, la variable `.` va contenir le super-objet servant de base au système de templating de Helm. Dans ce super objet, il est possible d'aller piocher des clés généralistes telles que `Values`, `Release`, `Chart`, etc. Cette variable va cependant prendre des valeurs différentes en fonction du contexte. Bien souvent, lorsque l'on réalise une itération (via la fonction `range` par exemple), la valeur de cette variable est amenée à changer. Il est alors important de savoir à quoi elle correspond et comment y palier. Pour atteindre de nouveau le super-objet racine de notre templating, on peut dans ce genre de cas passer plutôt par `$`. Dans le cas où l'on utiliserait une itération, la variable `.` va prendre pour valeur l'**élément en court d'itération**. Pour un listing, on aura donc l'élément et pour un dictionnaire la valeur cachée à telle ou telle clé.

### Le bloc "with"

Si l'on souhaite modifier la valeur de la variable `.`, il est possible de le faire via un bloc de type `with`. En utilisant ce bloc, on peut définir une nouvelle valeur pour la variable `.` au sein d'un scope. Pour que cela fonctionne, il ne faut cependant pas oublier de fermer le bloc with de sorte à ne pas avoir d'erreur de syntaxe. 

```yaml
{{- with .Values.securityContext | default dict }}
{{- if and (hasKey . "enabled") .enabled }}
securityContext:
  runAsUser: {{ .runAsUser }}
  fsGroup: {{ .fsGroup }}
{{- end }}
{{- end }}
```

### Validation

Pour tester et valider les valeurs de nos variables en amont de la création de nos templates, il est possible de faire appel à des fonction spécifiques telles que la fonction `required` qui a pour but de tester la présence de variables sous certaines condition (et d'offrir un message personnalisé en cas de non respect de cette vérification) ou d'utiliser la fonction `fail` au sein d'un bloc de structure conditionnelle (la fonction `fail` a pour but de causer à tous les coups l'échec de la génération de templating et de donner un message personnalisé en complément à but informatif). Ces blocs de code vont en général se retrouver dans un fichier YAML spécifique qui se nommera `validations.yaml`. Comme lorsque Helm créé une charte, il parcourt l'ensemble des fichiers présents en son sein, ces lignes d'instruction seront également parcourues en amont de la publication des fichiers de manifeste. 

```yaml
{{- if and .Values.securityContext .Values.securityContext.enabled -}}
{{- $_ := required "securityContext.runAsUser is required when setting securityContext and enabled is true" .Values.securityContext.runAsUser -}}
{{- $_ := required "securityContext.fsGroup is required when setting securityContext and enabled is true" .Values.securityContext.fsGroup -}}
{{- if int .Values.securityContext.runAsUser | eq 0 -}}
{{- fail "Containers cannot be run as root users. Please provide an UID greater than 0" -}}
{{- end -}}
{{- end -}}
```

Une autre solution serait d'utiliser le principe des helpers et de leur envoyer des valeurs issues de nos variables afin d'opérer un contrôle plus ou moins précis de ces dernières. On aurait donc un helper de ce type: 

```yaml

{{- define "templating-deep-dive.validators.service" -}}
{{- $sanitizedPort := int .port -}}
{{/*Port validation*/}}
{{- if or (lt $sanitizedPort 1) (gt $sanitizedPort 65535) -}}
{{- fail "Error: Posts must always be between 1 and 65535" -}}
{{- end -}}

{{/*Service type validation*/}}
{{- $allowedSvcTypes := list "ClusterIP" "NodePort" -}}
{{- if not (has .type $allowedSvcTypes) -}}
{{- fail (printf "Error: Invalid service type \"%s\". Supported values are [%s]" .type (join ", " $allowedSvcTypes)) -}}
{{- end -}}
{{- end -}}
```

Et son utilisation au sein du fichier de manifeste comme ceci: 

```yaml
{{- range $key, $svc := (.Values.services | default list) }}
{{ include "templating-deep-dive.validators.service" $svc }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ include "templating-deep-dive.fullname" $ }}-{{ $key }}
  labels: {{ include "templating-deep-dive.selectorLabels" $ | nindent 4 }}
spec:
  type: {{ .type }}
  selector: {{ include "templating-deep-dive.selectorLabels" $ | nindent 4 }}
  ports:
    - protocol: TCP
      port: {{ .port }} 
      targetPort: {{ $.Values.containerPorts.http }}
{{- end }}
```

### Utiliser des sous-chartes

* Un subchart (ou chart dependency) est un autre chart qui est soit :
  * **requis** pour que ton chart principal fonctionne correctement,
  * **nécessaire** pour activer une fonctionnalité optionnelle dans l’application installée.
* Les subcharts te permettent d’inclure et de gérer le déploiement d’autres charts en même temps que le tien.
* Quelques cas d’usage typiques des subcharts :
  * **Databases** : Inclure un chart de base de données (ex. : MySQL, PostgreSQL) dont ton application dépend.
  * **Shared Services** : Inclure des services communs utilisés par plusieurs applications.
  * **Common Utilities** : Inclure une librairie de fonctions ou utilitaires destinés à faciliter le développement de charts.
* Les subcharts sont placés dans le dossier charts/ de ton Helm chart. Ils peuvent être :
  * un **dossier** contenant tous les fichiers nécessaires d’un Chart,
  * ou un **fichier** `.tgz` correspondant à un chart existant.
  * Les subcharts listés sans repository doivent contenir tous les fichiers requis et être un Helm chart valide.
* Les subcharts peuvent être activés de manière conditionnelle via :
  * des **valeurs booléennes**,
  * ou des **tags**.

Ajouter une sous-charte est assez simple. Il faut aller manipuler le fichier `Chart.yaml` et y ajouter un ensemble de clés-valeurs telles que:

```yaml
dependencies:
  - name: postgresql
    version: "16.2.2"
    repository: "https://charts.bitnami.com/bitnami"
```

Une fois cela fait, on peut mettre à jour les dépendances de notre charte principale via la commande `helm dependency update`. Plusieurs commandes peuvent d'ailleurs nous aider à gérer les dépendances au niveau de nos charts Helm: 
* `helm dependency list <chart dir>`: Affiche la liste des dépendances définies dans Chart.yaml (nom, version, repository, condition, enabled, status). Utile pour vérifier l'état avant de télécharger ou construire les sous‑charts.
* `helm dependency update <chart dir>`: Met à jour le fichier Chart.lock puis télécharge les archives des dépendances dans le dossier `charts/` en résolvant les versions selon Chart.yaml et les dépôts configurés. Utiliser quand on veut récupérer les versions compatibles les plus récentes ou régénérer le lock.  
* `helm dependency build <chart dir>`: Construit le répertoire `charts/` à partir de `Chart.lock` (télécharge les versions exactes verrouillées). Utiliser quand on veut restaurer les dépendances à partir du lock sans modifier celui‑ci. 

Dans le cas où l'on souhaiterai faire un contrôle de nos dépendances en fonction de variables contenues dans le fichier `values.yaml` du parent, il est possible de le faire de plusieurs façon:
* Via la clé `condition` qui doit retourner un booléen: 
```yaml
dependencies:
  - name: postgresql
    version: "16.2.2"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled
```

* Via le listing de `tags` qui doivent être présent dans les valeurs de la dépendance: 
```yaml
dependencies:
  - name: postgresql
    version: "16.2.2"
    repository: "https://charts.bitnami.com/bitnami"
    tags: 
      - database
```

### Partager des données entre chartes enfants / parents

Attention cependant, dans le cas où l'on aurait besoin de partager des valeurs entre nos différentes chartes, il va falloir, au sein du fichiers contenant les variables (`values.yaml`) de notre charte principale, ajouter une clé représentant le nom de notre sous-charte pour ensuite pouvoir y définir ses valeurs dans le but de les remplacer par celles provenant du parent.

```yaml
subchart-name:
  key1: value
  key2: value
```

Dans le cas où l'on aurait besoin de définir un ensemble de valeurs qui se retrouveraient dans toutes nos sous-chartes, on peut le faire avec un objet `global` tel que:

```yaml
global:
  defaultStorageClass: 'my-custom-storage-class'
```

Une fois déclarée dans le fichier Chart.yaml de notre charte parent, l'utilisation se fera par la variable `.Values.global.defaultStorageClass` tel que:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "demo-subchart.fullname" . }}
data:
  test-value-global: {{ .Values.global.defaultStorageClass }}
```

Dans pas mal de chartes Helm, les variables sont définies en faisant usage de la fonction `coalesce` qui permet d'overrider au besoin les variables définiées globalement par celles définies spécifiquement pour tel ou tel charte. Il est bien entendu possible, lorsque l'on fait nos propres chartes, de contrôler ce processus et de l'inverser au besoin. Il est d'ailleurs possible, au sein d'une charte parent, d'exploiter les valeurs rendues disponibles dans les helpers de nos sous-charte. Ce procédé peut être intéressant lorsque l'on a envie de construire une sorte d'output de valeurs dans nos chartes, utilisables au besoin dans les parents pour remonter l'information. Il faut cependant garder la tête froide et ne pas en abuser sous peine de créer des couplages trop important. Il est plus intéressant de passer par exemple par l'objet global si l'objectif est le partage d'informations entre parent et enfants.

### Packager nos charts

Dans le cas où l'on aurait envie, par la suite, d'empaqueter nos charts dans le but de les envoyer ou de les publier, il est possible de le faire via la commande: 
```bash
helm package /folder/for/chart/
```

Suite à son utilisation, on va avoir un fichier au format `.tgz` contenant le nom de notre applicatif suivi de sa version. Il sera ensuite possible, par exemple via un dépot Git, un pipeline CI / CD ainsi que GitHub Pages, de faire la promotion de notre chart.