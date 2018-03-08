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
