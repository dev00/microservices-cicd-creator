#!/bin/sh

oc new-app --name=carts-db --docker-image=centos/mongodb-32-centos7 -e DATABASE_SERVICE_NAME=carts-db -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=data -e MONGODB_ADMIN_PASSWORD=pass -e MONGODB_VERSION=3.2 -l stage=dev

oc new-app --name=carts registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.2~https://github.com/microservices-cicd/carts#master -e PORT=8080 -e DB="user:pass@carts-db" -l stage=dev

oc new-app --name=catalogue-db mysql:5.7~https://github.com/microservices-cicd/catalogue#master \
--context-dir=docker/catalogue-db/data \
-e MYSQL_DATABASE=socksdb \
-e MYSQL_USER=user \
-e MYSQL_PASSWORD=pass \
-e MYSQL_ROOT_PASSWORD=fake_password \
-l stage=dev

oc new-app --name=catalogue https://github.com/microservices-cicd/catalogue#master -l stage=dev

oc new-app --name=front-end nodejs:6~https://github.com/microservices-cicd/front-end#master \
-e PORT=8080 \
-l stage=dev

oc new-app --name=orders-db  --docker-image=centos/mongodb-32-centos7:latest -e DATABASE_SERVICE_NAME=orders-db -e MONGODB_USER=user -e MONGODB_PASSWORD=pass -e MONGODB_DATABASE=data -e MONGODB_ADMIN_PASSWORD=pass -e MONGODB_VERSION=3.2 -l stage=dev

oc new-app --name=orders registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.2~https://github.com/microservices-cicd/orders#master \
-e PORT=8080 \
-e DB="user:pass@orders-db" \
-l stage=dev

oc new-app --name=payment https://github.com/microservices-cicd/payment#master -l stage=dev

oc new-app --name=rabbitmq --docker-image=rabbitmq:3.6.8 -l stage=dev

oc new-app --name=queue-master registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.2~https://github.com/microservices-cicd/queue-master#master \
-e PORT=8080 \
-l stage=dev

oc new-app --name=shipping registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift:1.2~https://github.com/microservices-cicd/shipping#master \
-e PORT=8080 \
-l stage=dev

oc new-app --name=user-db mongodb:3.2~https://github.com/microservices-cicd/user#master \
--context-dir=docker/user-db \
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

oc create route edge --service=front-end --insecure-policy="Redirect"
