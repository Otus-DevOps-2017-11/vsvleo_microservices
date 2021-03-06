## vsvleo_microservices
### Домашнее задание 14
#### Некоторые основные и полезные команды docker
```

docker start <u_container_id> # Запускает не запущенный контейнер
docker stop <u_container_id> # Останавливает запущенный контейнер
docker run [options] <u_image_id> # создает и запускает контейнер из указанного образа
    [options]
    - i - запускает контейнер в foreground режиме (docker attach)
    - d - запускает контейнер в background режиме
    - t - создает TTY
docker create <u_image_id> # создает но не запускает контейнер
docker commit <u_container_id> <new_name_image> # создает новый образ из существующего контейнера,
    включая все сделанные изменения внутри контейнера. Сохранияет текущий верхний уровень (слой RW)
    в слой Read.
docker exec -it <u_container_id> bash # запускает bash, как новый процесс, в выбраном контейнере. 
    Позволяет работать с системой внутри контейнера.
docker images # выводит список локальных образов 
docker inspect # выводит метаданные контейнера или образа
docker ps -q # выводит номера запущеных контейнеров
docker ps -a # выводит остановленные контейнеры
docker kill $(docker ps -q) # Безусловный останов всех запущенных контейнеров
docker system df # Отображает системные параметры по дисковому пространству
docker rmi <u_image_id> # удаляет образ по его номеру 
docker rmi $(docker images -q) # удалит все образы
docker rm $(docker ps -a -q) # удалит все незапущенные контейнеры
docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Names}}" # Вывод остановленных
    контейнеров в своем формате (форматирование вывода)
```
#### Файл docker-1.log
Содержит вывод команды docker images и задание со *

---

### Домашнее задание 15
#### Установка docker (https://docs.docker.com/install/linux/docker-ce/ubuntu/)
```
curl -fsSL https://download.docker.com/linux/ ubuntu /gpg | sudo apt-key add -
```
```
$ sudo apt-key fingerprint 0EBFCD88

pub   4096R/0EBFCD88 2017-02-22
      Key fingerprint = 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
uid                  Docker Release (CE deb) <docker@docker.com>
sub   4096R/F273FCD8 2017-02-22
```
```
$ sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
```
```
sudo apt update
```
```
$ sudo apt install docker-ce
```
#### Установка GoogleCloudPlatform (https://cloud.google.com/sdk/docs/quickstart-linux)
```
$ wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-XXX.0.0-linux-x86_64.tar.gz
```
XXX - актуальная, последняя версия
```
$ tar zfx google-cloud-sdk-XXX.0.0-linux-x86_64.tar.gz
```
```
$ ./google-cloud-sdk/install.sh
```
Инициализация проекта docker-XXXXXX в локальном GCP
```
$ gcloud init
```
Создаем инстанс в GCP проекте docker-XXXXXX с помощью docker-machine и с именем docker-host
```
$ docker-machine create --driver google    --google-project docker-XXXXXX  \
    --google-zone europe-west2-b    --google-machine-type g1-small \
    --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
    docker-host
```
Смотрим параметры созданной docker-machine
```
$ docker-machine ls
NAME          ACTIVE   DRIVER   STATE     URL                         SWARM   DOCKER        ERRORS
docker-host   -        google   Running   tcp://35.197.229.190:2376
```
Привязывем данную docker машину к текущей сессии, теперь вся работа с docker будет выполнятся на выбранном инстансе.
```
$ eval $(docker-machine env docker-host)
```
#### Создание инстанса с docker контейнером reddit
Создаем файлы, необходимые для docker на инстансе (Файлы в текущей папке)
Создаем Dockerfile с описанием инструкций по созданию образа (Файл в текущей папке)
Собираем образ reddit (образ собирается на инстансе)
```
$ docker build -t reddit:latest .
```
Запускаем собранный образ (контейнер запускается на инстансе)
```
docker run --name reddit -d --network=host reddit:latest
```
Открываем порт 9292 в firewall проекта
```
$ gcloud compute firewall-rules create reddit-app \
    --allow tcp:9292 --priority=65534 \
    --target-tags=docker-machine \
    --description="Allow TCP connections" \
    --direction=INGRESS
```

Сохраняем созданный образ в хранилище docker (https://hub.docker.com/), с предварительной авторизацией
```
$ docker login
$ docker tag reddit:latest <your-login>/otus-reddit:1.0
$ docker push <your-login>/otus-reddit:1.0
```

---

### Домашнее задание 16
Сборка ui начинается не с первых слоев,т.к
первые слои берутся из кеша, сформированных ранее при создании других образов.
#### Запуск контейнеров с переопределение переменных ENV в строке запуска
Запуск БД, назначаем алиас host_db, этот алиас используем в параметрах задаваемых переменных, при запуске других образов
```
docker run -d --network=reddit --network-alias=host_db mongo:latest 
```
Задаем новый алиас и указываем в переменной алиас БД
```
docker run -d --network=reddit --network-alias=test_post -e "POST_DATABASE_HOST=host_db" vsvleo/post:1.0
```
Задаем новый алиас и указываем в переменной алиас БД
```
docker run -d --network=reddit --network-alias=test_comment -e "COMMENT_DATABASE_HOST=host_db" vsvleo/comment:1.0
```
В Переменных указываем алиасы на приложения post и comment
```
docker run -d --network=reddit -p 9292:9292 -e "POST_SERVICE_HOST=test_post" -e "COMMENT_SERVICE_HOST=test_comment" vsvleo/ui:1.0
```
#### Что было сделано
На инстансе в GCP были развернуты docker контейнеры с БД, с самим приложением и двумя вспомагательными.<br/>
Для сохранения БД при перезапуске контейнера, был добавлен volumes
```
docker run -d --network=reddit --network-alias=host_db -v reddit_db:/data/db mongo:latest
```
Для уменьшения размера образа, был заменен начальный образ, на образ меньшего размера ubuntu:16.04

---

### Домашнее задание 17
#### вопросы
Вывод команд ssh и exec не отличается, т.к. использует тот же интерфейс что и хост. Через ssh мы смотрим сетевой интерфейс на хосте. Через
 exec - смотрим сетевой интерфейс внутри контейнера.<br/>

docker run --network host -d nginx - При запуске несколько раз, docker удаляет все вновь созданные контейнеры, возможно из-за уже используемых 
портов в самом первом контейнере.

При использовании host остается только default сеть, а при использовании none создается как бы персональная сеть для каждого контейнера

Связь между контейнерами можно организовать как через алиас, к примеру "--network-alias post", так и через имя контейнера "--name post"

Выводит список docker сетей
```
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
5082968d9f22        back_net            bridge              local
609679119e04        bridge              bridge              local
50594f276b4a        front_net           bridge              local
d07ad0cd0db3        host                host                local
2ff095298e80        none                null                local
```

back_net и front_net имеют теже итендификаторы, что и ID docker network, только с приставкой "br-"
```
$ docker-machine ssh docker-host 'ifconfig | grep br'
br-50594f276b4a Link encap:Ethernet  HWaddr 02:42:3e:78:03:0c
br-5082968d9f22 Link encap:Ethernet  HWaddr 02:42:ce:92:9b:dc
```

Пример вывода сетевого стека для front_net
```
$ docker-machine ssh docker-host 'brctl show br-50594f276b4a'
bridge name     bridge id               STP enabled     interfaces
br-50594f276b4a         8000.02423e78030c       no              veth41536f2
                                                        veth9a627a9
                                                        vethf29a6c3
```

Маршрутизация трафика
```
$ docker-machine ssh docker-host 'sudo iptables -v -nL -t nat'
. . .
Chain POSTROUTING (policy ACCEPT 458 packets, 27692 bytes)
 pkts bytes target     prot opt in     out     source               destination
   24  1528 MASQUERADE  all  --  *      !br-50594f276b4a  10.0.1.0/24          0.0.0.0/0
  266 18198 MASQUERADE  all  --  *      !br-5082968d9f22  10.0.2.0/24          0.0.0.0/0
  479 29203 MASQUERADE  all  --  *      !docker0  172.17.0.0/16        0.0.0.0/0
    0     0 MASQUERADE  tcp  --  *      *       10.0.1.2             10.0.1.2             tcp dpt:9292

Chain DOCKER (2 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 RETURN     all  --  br-50594f276b4a *       0.0.0.0/0            0.0.0.0/0
    0     0 RETURN     all  --  br-5082968d9f22 *       0.0.0.0/0            0.0.0.0/0
    0     0 RETURN     all  --  docker0 *       0.0.0.0/0            0.0.0.0/0
    5   280 DNAT       tcp  --  !br-50594f276b4a *       0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292
```

Посмотреть запущен процес docker-proxy и его PID 
```
$ docker-machine ssh docker-host 'ps ax | grep docker-proxy'
. . .
25948 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
```

Так же посмотреть какие контейнеры подключены к данной сети, например к front_net:
```
$ docker network inspect front_net
```

И аналогичным образом можно посмотреть какие сетевые службы использует указанный контейнер:
```
$ docker inspect post
```

#### docker-compose


Связь между контейнерами оссуществляется по имени сервиса в docker-compose.yml файле
```
docker ps
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                    NAMES
f92d03c4e759        vsvleo/ui:1.0        "puma"                   9 minutes ago       Up 9 minutes        0.0.0.0:9292->9292/tcp   redditmicroservices_ui_1
dd99f9fd9305        mongo:3.2            "docker-entrypoint.s…"   9 minutes ago       Up 9 minutes        27017/tcp                redditmicroservices_post_db_1
fd559b14d180        vsvleo/post:1.0      "python3 post_app.py"    9 minutes ago       Up 9 minutes                                 redditmicroservices_post_1
4ce42cd78937        vsvleo/comment:1.0   "puma"                   9 minutes ago       Up 9 minutes                                 redditmicroservices_comment_1
```

Префикс имени запущенных контейнеров указывается в файле .env в параметре COMPOSE_PROJECT_NAME

---

### Домашнее задание 19
Разворачиваем инстанс
```
docker-machine create --driver google    --google-project docker-196714 \
  --google-zone europe-west2-b  --google-disk-size 50  --google-machine-type n1-standard-1 \
  --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri)    gitlab-ci
```
Создаем docker-compose.yml

Настройки в web интерфейсе (группа, проект)

Создаем структуру каталогов на инстансе
mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs

Добавляем наш проект на инстанс gitlab
```
git checkout -b docker-6
git remote add gitlab http://35.189.66.166/homework/example.git
git push gitlab docker-6
```
Добавляем пайплайн, коммитим и отправляем на инстанс
```
git add .gitlab-ci.yml
git commit -m 'add pipeline definition'
git push gitlab docker-6
```
Запускаем runner на инстансе
```
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```
Регистрируем runner
```
docker exec -it gitlab-runner gitlab-runner register
```
Скачиваем и добавляем reddit на сервер
```
git clone https://github.com/express42/reddit.git && rm -rf ./reddit/.git
git add reddit/
git commit -m “Add reddit app”
git push gitlab docker-6
```
Настраиваем пайплайн для тестирования, вносим изменения в .gitlab-ci.yml

---

### Домашнее задание 20
При возобновлениее работы инстанса после остановки, произошла смена внешнего IP адреса, решилось переинициализацией.
инстанса через docker-machine, но инструмент gitlab-ci пришлось перезапускать (подправив адрес в docker-compose.yml файле),.
с принудительным остановом работающих контейнеров. Т.к. убивал все командой 'docker kill $(docker ps -q)', то убил
и runner, запустил заново.

Правка пайплайна:
- Изменен job: deploy_job на deploy_dev, с добавлением окружения dev
- Добавил два этапа: staging и production с ручным способом запуска
- В эти два этапа добавил директиву only с регулярным выражением, определяющим версию сборки. 
Версия задается спомощью тега:
```
$ git tag 2.4.10
$ git push gitlab2 docker-7 --tags
```
Если не указать версию, неверно указать версию, не попадающую под шаблон регулярного выражения, то эти два
этапа проигнорируются.<br/>
- Добавил job с определением динамического окружения, в зависимости от названия текущей git ветки, master ветка игнорируется.

---

### Домашнее задание 21
Настройка фаервола
```
gcloud compute firewall-rules create prometheus-default --allow tcp:9090
gcloud compute firewall-rules create puma-default --allow tcp:9292
```

Указываем рабочий проект
```
$ export GOOGLE_PROJECT=docker-196714
```

Запускаем инициализацию инстанса vm1
```
$ docker-machine create --driver google \
--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 vm1
```

Привязываем docker к инстансу vm1
```
eval $(docker-machine env vm1)
```

Устанавливает на инстансе prometeus
```
docker run --rm -p 9090:9090 -d --name prometheus prom/prometheus:v2.1.0
```
Или выполняем собственную сборку, необходимые файлы находятся в папке /monitoring/prometheus<br/>
В файле prometheus.yml описаны правила для слежения за сервисами, в нашем случае мы отслеживаем четыре сервиса: 
доступ на docker контенеры:
```
comment:9292/metrics
node-exporter:9100/metrics # собирает информацию о работе docker хоста
localhost:9090/metrics # сам prometheus
ui:9292/metrics
```
После изменения сервисов в файле prometheus.yml и сборки образа, у меня отрабатывала команда docker-compose up -d,
без остановки всех контейнеров.

Образы на DockerHub: https://hub.docker.com/u/vsvleo/

---

### Домашнее задание 23
Создаем инстанс vm1
```
$ docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 vm1
```

Открываем порт для cAdvisor
```
$ gcloud compute firewall-rules create cadvisor-default --allow tcp:8080
```

Открывает порт для grafana
```
$ gcloud compute firewall-rules create grafana-default --allow tcp:3000
```

Меняем метрику на первом графике, дополнительно убрал из графика вывод параметра path со значением "/metrics", 
т.к. они не меняются, а идут постоянно:
```
rate(ui_request_count{path!="/metrics"}[1m])
```

позже переделал на вывод графика, только корневого пути:
```
rate(ui_request_count{path="/"}[1m])
```

Добавление сервиса alertmanager, открываем порт:
```
$ gcloud compute firewall-rules create alertmanager-default --allow tcp:9093
```

Проверка вебхука с помощью curl:
```
curl -X POST \
--data-urlencode 'payload={"text": "This is posted to #general and comes from *monkey-bot*.", "channel": "#vsvleo-webhook", "link_names": 1, "username": "monkey-bot", "icon_emoji": ":monkey_face:"}' \
 https://hooks.slack.com/services/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
```
Если вебхук работает, то в ответ придет "ОК".

---

### Домашнее задание 25
В github ссылка на код приложения reddit скачивает что то другое, качал как zip архив.<br/>
Опробован сбор логов спомощью fluentd, опробованы некоторые настройки в конфигурационном файле. 
Результат смотрел через Kibana. Также проверил работу приложения zipkin.

```
$ docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d
```
Для исключения ошибки запуска контейнеров post и ui, добавил в docker-compose ожидать запуска сервиса fluentd
```
    depends_on:
     - fluentd
```

---

### Домашнее задание 27
Выполнил построение master-1, worker-1, worker-2 нод
```
docker-machine create --driver google \
   --google-project  docker-196714 \
   --google-zone europe-west1-b \
   --google-machine-type g1-small \
   --google-machine-image $(gcloud compute images list --filter ubuntu-1604-lts --uri) \
master-1 # или worker-1 или worker-2
```
Подключил сессию: eval $(docker-machine env master-1)<br/>
Войдя на мастер ноду (docker-machine ssh master-1), проинициализировал swarm, построив кластер (docker swarm init), 
на выходе получил команду для привязки рабочих нод к мастеру (содержит токен и IP адрес мастер ноды). Которую запустил на каждой рабочей ноде. <br/>
Спомощью следующей команды можно сгенерировать новый токен
```docker swarm join-token manager```
Проверка Состояния кластера
```
docker node ls
```
Запуск сервисов на кластере, объединяя их в стек
```
docker stack deploy --compose-file=<(docker-compose -f docker-compose.yml config 2>/dev/null) DEV
```
где DEV - это имя стека<br/>

Отобразить состояние стека. Выводится информация: имена сервисов, виды масштабирования, текущее состояние масштабирования, и по аналогии 
с командой (docker ps) выводится имя образа и разрешенные порты
```
docker stack services DEV
```
Создал метку для мастер ноды
```
docker node update --label-add reliability=high master-1
```
Команда для просмотра меток на нодах
```
docker node ls -q | xargs docker node inspect   -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'
```
Посмотреть распределение сервисов по нодам
```
docker stack ps DEV
```
Масштабирование сервисов, команды на выбор:
```
docker service scale DEV_ui=3
docker service update --replicas 3 DEV_ui
docker service update --replicas 0 DEV_ui
```
Состояние сервисов до организации 3-ей рабочей ноды
```
ID                  NAME                                          IMAGE                        NODE                DESIRED STATE       CURRENT STATE
emytf37tul29        DEV_node-exporter.jayjmjb1tbfdxsoclxkyczon2   prom/node-exporter:v0.15.0   worker-2            Running             Running 29 seconds ago
yr28i9u36voa        DEV_node-exporter.7ycjc9pdwlz5ppg1oo91z0og9   prom/node-exporter:v0.15.0   worker-1            Running             Running 28 seconds ago
mmsivpcv3cw1        DEV_node-exporter.bsznkvtsu66wfxz0k6bjuaju9   prom/node-exporter:v0.15.0   master-1            Running             Running 30 seconds ago
n7x8leqj9zm3        DEV_comment.1                                 vsvleo/comment:latest        worker-1            Running             Running 20 seconds ago
py1sjmx3o18b        DEV_ui.1                                      vsvleo/ui:latest             worker-1            Running             Running 11 minutes ago
o7dupjn5r097        DEV_post_db.1                                 mongo:3.2                    master-1            Running             Running 11 minutes ago
xqzbcrkkgmto        DEV_post.1                                    vsvleo/post:latest           worker-2            Running             Running 11 minutes ago
5r1vp83aminn        DEV_comment.2                                 vsvleo/comment:latest        worker-2            Running             Running 16 seconds ago
tj0yksc7ftqx        DEV_post.2                                    vsvleo/post:latest           worker-1            Running             Running 8 minutes ago
dfv815qgkvwm        DEV_ui.2                                      vsvleo/ui:latest             worker-2            Running             Running 8 minutes ago
```
После создания 3-ей рабочей ноды в нее добавился только сервис node-exporter, а после увеличения числа реплик микросервисов, произошло распределение 
сервисов на данную ноду
```
ID                  NAME                                          IMAGE                        NODE                DESIRED STATE       CURRENT STATE
yzdd1qashzlx        DEV_node-exporter.mkmgcul5hhnguon6l3n2utoox   prom/node-exporter:v0.15.0   worker-3            Running             Running 2 minutes ago
emytf37tul29        DEV_node-exporter.jayjmjb1tbfdxsoclxkyczon2   prom/node-exporter:v0.15.0   worker-2            Running             Running 10 minutes ago
yr28i9u36voa        DEV_node-exporter.7ycjc9pdwlz5ppg1oo91z0og9   prom/node-exporter:v0.15.0   worker-1            Running             Running 10 minutes ago
mmsivpcv3cw1        DEV_node-exporter.bsznkvtsu66wfxz0k6bjuaju9   prom/node-exporter:v0.15.0   master-1            Running             Running 10 minutes ago
n7x8leqj9zm3        DEV_comment.1                                 vsvleo/comment:latest        worker-1            Running             Running 9 minutes ago
py1sjmx3o18b        DEV_ui.1                                      vsvleo/ui:latest             worker-1            Running             Running 21 minutes ago
o7dupjn5r097        DEV_post_db.1                                 mongo:3.2                    master-1            Running             Running 21 minutes ago
xqzbcrkkgmto        DEV_post.1                                    vsvleo/post:latest           worker-2            Running             Running 20 minutes ago
5r1vp83aminn        DEV_comment.2                                 vsvleo/comment:latest        worker-2            Running             Running 9 minutes ago
tj0yksc7ftqx        DEV_post.2                                    vsvleo/post:latest           worker-1            Running             Running 17 minutes ago
dfv815qgkvwm        DEV_ui.2                                      vsvleo/ui:latest             worker-2            Running             Running 18 minutes ago
mgypfiy70bp2        DEV_post.3                                    vsvleo/post:latest           worker-3            Running             Assigned 6 seconds ago
c1kpaniezvcb        DEV_comment.3                                 vsvleo/comment:latest        worker-3            Running             Preparing 10 seconds ago
0gs0vy35llwp        DEV_ui.3                                      vsvleo/ui:latest             worker-3            Running             Preparing 13 seconds ago
kturm1kr1riw        DEV_post.4                                    vsvleo/post:latest           worker-2            Running             Running 5 seconds ago
rmgmwosjjcu9        DEV_comment.4                                 vsvleo/comment:latest        worker-3            Running             Preparing 10 seconds ago
zewvuv5erdvk        DEV_ui.4                                      vsvleo/ui:latest             worker-3            Running             Preparing 13 seconds ago
```

Запуск сервисов с нескольких docker-compose файлов
```
docker stack deploy --compose-file=<(docker-compose -f docker-compose.monitoring.yml -f docker-compose.yml config 2>/dev/null) DEV
```
Вывод состояния сервисов
```
ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
mbgpillnng55        DEV_alertmanager    replicated          1/1                 vsvleo/alertmanager:latest        *:9093->9093/tcp
zjieud4zk17g        DEV_cadvisor        replicated          1/1                 google/cadvisor:v0.29.0           *:8080->8080/tcp
p1wds8e0nn5o        DEV_comment         replicated          4/4                 vsvleo/comment:latest
mkz6to9ok5xz        DEV_grafana         replicated          1/1                 grafana/grafana:5.0.0             *:3000->3000/tcp
niy1kver3qdd        DEV_node-exporter   replicated          4/4                 prom/node-exporter:v0.15.0
z5e3br860sp1        DEV_post            global              3/3                 vsvleo/post:latest                *:5000->5000/tcp
ij1qgwli7y94        DEV_post_db         replicated          1/1                 mongo:3.2
o6vcc5onu4tc        DEV_prometheus      replicated          1/1                 vsvleo/prometheus:latest          *:9090->9090/tcp
s1tousy7r95e        DEV_ui              replicated          3/3                 vsvleo/ui:latest                  *:9292->9292/tcp
951sif3k657e        DEV_viz             replicated          1/1                 dockersamples/visualizer:latest   *:8081->8080/tcp
```
Для графического отображения состояния нод, добавил сервис visualizer.