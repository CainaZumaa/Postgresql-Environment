#!/bin/bash

export AIRFLOW_UID=$(id -u)

build(){
    docker compose build --no-cache --memory 4g --progress=plain;
}

up(){
    docker compose up -d;
}

stop(){
    docker compose down;
}

drop(){
    docker compose down;
}

restart(){
    docker compose down && docker compose up -d
}

drop_hard(){
    docker compose down --volumes --remove-orphans --rmi all;
    docker stop $(docker ps -aq);
    docker builder prune --all --force;
    sudo rm -rf ./maquina1/data ./maquina1/log;
    docker rm $(docker ps -aq);
    docker rmi -f $(docker images -aq);
    docker volume rm $(docker volume ls -q);
    sudo rm -rf ./maquina2/data ./maquina2/log ./dw/data ./dw/log ./dbt/data ./dbt/dbt_internal_packages ./dbt/.dbt ./airflow/logs ./airflow/config ./airflow/plugins;
    docker network rm $(docker network ls -q | grep -vE '^(bridge|host|none)$');
}

cpKeys(){
    docker exec -u postgres maquina1 bash -c 'rm /var/lib/postgresql/.ssh/id_*'
    docker exec -u postgres maquina2 bash -c 'rm /var/lib/postgresql/.ssh/id_*'
    docker exec -u postgres maquina1 ssh-keygen -t ed25519 -f /var/lib/postgresql/.ssh/id_ed25519 -N '' -q
    docker exec -u postgres maquina2 ssh-keygen -t ed25519 -f /var/lib/postgresql/.ssh/id_ed25519 -N '' -q
    MAQUINA1_PUB="$(docker exec -u postgres maquina1 cat /var/lib/postgresql/.ssh/id_ed25519.pub)"
    MAQUINA2_PUB="$(docker exec -u postgres maquina2 cat /var/lib/postgresql/.ssh/id_ed25519.pub)"
    docker exec -u postgres maquina1 bash -c "echo '$MAQUINA2_PUB' > /var/lib/postgresql/.ssh/authorized_keys"
    docker exec -u postgres maquina2 bash -c "echo '$MAQUINA1_PUB' > /var/lib/postgresql/.ssh/authorized_keys"
    docker exec -u postgres maquina1 bash -c "echo '$MAQUINA1_PUB' >> /var/lib/postgresql/.ssh/authorized_keys"
    docker exec -u postgres maquina2 bash -c "echo '$MAQUINA2_PUB' >> /var/lib/postgresql/.ssh/authorized_keys"
    docker exec -u root maquina1 bash -c 'chown -R postgres:postgres /var/lib/postgresql/.ssh'
    docker exec -u root maquina2 bash -c 'chown -R postgres:postgres /var/lib/postgresql/.ssh'
    docker exec -u root maquina1 bash -c 'chmod 700 /var/lib/postgresql/.ssh'
    docker exec -u root maquina2 bash -c 'chmod 700 /var/lib/postgresql/.ssh'
    docker exec -u root maquina1 bash -c 'chmod 600 /var/lib/postgresql/.ssh/*'
    docker exec -u root maquina2 bash -c 'chmod 600 /var/lib/postgresql/.ssh/*'
    # Testar conexão
    docker exec -u postgres maquina1 ssh -o StrictHostKeyChecking=no maquina2 true || echo "Conexão falhou da maquina1 para a maquina2"
    docker exec -u postgres maquina2 ssh -o StrictHostKeyChecking=no maquina1 true || echo "Conexão falhou da maquina2 para a maquina1"
}

bashMaquina2(){
    docker compose exec -u postgres maquina2 bash
}

bashMaquina1(){
    docker compose exec -u postgres maquina1 bash
}

$1