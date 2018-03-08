vsvleo_microservices
### домашнее задание 14
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