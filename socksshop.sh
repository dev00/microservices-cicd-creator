#!/bin/sh
oc new-app --name=carts-db --template=mongodb-ephemeral \
--param=DATABASE_SERVICE_NAME=carts-db \
--param=MONGODB_USER=user \
--param=MONGODB_PASSWORD=pass \
--param=MONGODB_DATABASE=data \
--param=MONGODB_VERSION=3.2 \
-l stage=dev

oc new-app --name=carts redhat-openjdk18-openshift:1.1~https://github.com/microservices-cicd/carts#master \
-e PORT=8080 \
-e DB="user:pass@carts-db" \
-l stage=dev

oc new-app --name=catalogue-db registry.access.redhat.com/rhscl/mysql-57-rhel7~https://github.com/microservices-cicd/catalogue#master \
--context-dir=docker/catalogue-db/data \
--strategy=source \
-e MYSQL_DATABASE=socksdb \
-e MYSQL_USER=user \
-e MYSQL_PASSWORD=pass \
-e MYSQL_ROOT_PASSWORD=fake_password \
-l stage=dev

oc new-app --name=catalogue https://github.com/microservices-cicd/catalogue#master -l stage=dev

oc new-app --name=front-end nodejs:latest~https://github.com/microservices-cicd/front-end#master \
-e PORT=8080 \
-l stage=dev

oc new-app --name=orders-db --template=mongodb-ephemeral \
--param=DATABASE_SERVICE_NAME=orders-db \
--param=MONGODB_USER=user \
--param=MONGODB_PASSWORD=pass \
--param=MONGODB_DATABASE=data \
--param=MONGODB_VERSION=3.2 \
-l stage=dev

oc new-app --name=orders redhat-openjdk18-openshift:1.1~https://github.com/microservices-cicd/orders#master \
-e PORT=8080 \
-e DB="user:pass@orders-db" \
-l stage=dev

oc new-app --name=payment https://github.com/microservices-cicd/payment#master -l stage=dev

oc new-app --name=rabbitmq --docker-image=rabbitmq:3.6.8 -l stage=dev

oc new-app --name=queue-master redhat-openjdk18-openshift:1.1~https://github.com/microservices-cicd/queue-master#master \
-e PORT=8080 \
-l stage=dev

oc new-app --name=shipping redhat-openjdk18-openshift:1.1~https://github.com/microservices-cicd/shipping#master \
-e PORT=8080 \
-l stage=dev

oc new-app --name=user-db registry.access.redhat.com/rhscl/mongodb-32-rhel7:latest~https://github.com/microservices-cicd/user#master \
--context-dir=docker/user-db \
--strategy=source \
-e DATABASE_SERVICE_NAME=user-db \
-e MONGODB_USER=user \
-e MONGODB_PASSWORD=pass \
-e MONGODB_DATABASE=users \
-e MONGODB_ADMIN_PASSWORD=admin \
-l stage=dev

oc new-app --name=user golang:1.7~https://github.com/microservices-cicd/user#master \
--strategy=docker \
-e MONGO_USER="user" \
-e MONGO_PASS="pass" \
-l stage=dev

oc expose dc/user --port=8080

oc patch svc/user -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/shipping -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/queue-master -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/payment -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/orders -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/catalogue -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json
oc patch svc/carts -p '[{"op": "replace", "path": "/spec/ports/0", "value":{"name":"8080-tcp","port":80,"protocol":"TCP", "targetPort":8080}}]' --type=json

oc expose service/front-end
