#!/bin/bash

export AIRFLOW_UID=$(id -u)

build(){
    docker-compose build --no-cache --memory 4g --progress=plain;
}

up(){
    docker-compose up -d;
}

stop(){
    docker-compose down;
}

drop(){
    docker-compose down;
}

restart(){
    docker-compose down && docker-compose up -d
}

drop_hard(){
    docker-compose down --volumes --remove-orphans --rmi all;
    # docker stop $(docker ps -aq);
    docker builder prune --all --force;
    sudo rm -rf ./maquina1/data ./maquina1/log;
    # docker rm $(docker ps -aq);
    # docker rmi -f $(docker images -aq);
    # docker volume rm $(docker volume ls -q);
    sudo rm -rf ./maquina2/data ./maquina2/log;
    # docker network rm $(docker network ls -q | grep -vE '^(bridge|host|none)$');
}

cpKeys(){
    echo "Configurando chaves SSH..."
    
    # Verificar se containers estão rodando
    if ! docker ps | grep -q maquina1; then
        echo "ERRO: maquina1 não está rodando"
        return 1
    fi
    
    if ! docker ps | grep -q maquina2; then
        echo "ERRO: maquina2 não está rodando"
        return 1
    fi
    
    # Limpar chaves existentes
    docker exec -u postgres maquina1 bash -c 'rm -f /var/lib/postgresql/.ssh/id_*' || true
    docker exec -u postgres maquina2 bash -c 'rm -f /var/lib/postgresql/.ssh/id_*' || true
    
    # Gerar novas chaves
    docker exec -u postgres maquina1 ssh-keygen -t ed25519 -f /var/lib/postgresql/.ssh/id_ed25519 -N '' -q
    docker exec -u postgres maquina2 ssh-keygen -t ed25519 -f /var/lib/postgresql/.ssh/id_ed25519 -N '' -q
    
    # Trocar chaves públicas
    MAQUINA1_PUB="$(docker exec -u postgres maquina1 cat /var/lib/postgresql/.ssh/id_ed25519.pub)"
    MAQUINA2_PUB="$(docker exec -u postgres maquina2 cat /var/lib/postgresql/.ssh/id_ed25519.pub)"
    
    docker exec -u postgres maquina1 bash -c "echo '$MAQUINA2_PUB' > /var/lib/postgresql/.ssh/authorized_keys"
    docker exec -u postgres maquina2 bash -c "echo '$MAQUINA1_PUB' > /var/lib/postgresql/.ssh/authorized_keys"
    
    # Configurar permissões
    docker exec -u root maquina1 bash -c 'chown -R postgres:postgres /var/lib/postgresql/.ssh && chmod 700 /var/lib/postgresql/.ssh && chmod 600 /var/lib/postgresql/.ssh/*'
    docker exec -u root maquina2 bash -c 'chown -R postgres:postgres /var/lib/postgresql/.ssh && chmod 700 /var/lib/postgresql/.ssh && chmod 600 /var/lib/postgresql/.ssh/*'
    
    # Testar conexões
    echo "Testando conexões SSH..."
    docker exec -u postgres maquina1 ssh -o StrictHostKeyChecking=no maquina2 true && echo "✓ Conexão maquina1 → maquina2 OK" || echo "✗ Falha maquina1 → maquina2"
    docker exec -u postgres maquina2 ssh -o StrictHostKeyChecking=no maquina1 true && echo "✓ Conexão maquina2 → maquina1 OK" || echo "✗ Falha maquina2 → maquina1"
    
    echo "Configuração SSH concluída!"
}

bashMaquina2(){
    docker-compose exec -u postgres maquina2 bash
}

bashMaquina1(){
    docker-compose exec -u postgres maquina1 bash
}

# Novos comandos para o projeto de futebol
importData(){
    echo "=== Importação de Dados do Dataset de Futebol (SQLite) ==="
    echo "Verificando se o arquivo SQLite está na pasta data/..."
    
    # Verificar se o arquivo SQLite existe
    if [ -f "./data/database.sqlite" ]; then
        echo "✓ database.sqlite encontrado"
    else
        echo "✗ database.sqlite NÃO encontrado"
        echo ""
        echo "Por favor, baixe o dataset do Kaggle:"
        echo "https://www.kaggle.com/datasets/hugomathien/soccer"
        echo ""
        echo "E coloque o arquivo database.sqlite na pasta ./data/"
        echo "O arquivo deve estar em: ./data/database.sqlite"
        return 1
    fi
    
    echo ""
    echo "Iniciando importação..."
    docker exec pgloader bash -c "cd /pgloader && chmod +x import_all.sh && ./import_all.sh"
}

setupBackup(){
    echo "=== Configuração de Backup ==="
    
    # Configurar SSH
    ./run.sh cpKeys
    
    # Criar stanza
    docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 stanza-create || echo "Stanza já existe"
    
    # Testar conexão
    docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 check
    
    # Fazer primeiro backup
    docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --type=full backup
    
    echo "Backup configurado com sucesso!"
}

showStatus(){
    echo "=== Status dos Serviços ==="
    docker-compose ps
    
    echo ""
    echo "=== URLs de Acesso ==="
    echo "pgAdmin: http://localhost:5050 (admin@soccer.com / admin123)"
    echo "Grafana: http://localhost:3000 (admin / senha)"
    echo "Prometheus: http://localhost:9090"
    echo "PostgreSQL: localhost:15432 (postgres / postgres)"
    
    echo ""
    echo "=== Comandos Úteis ==="
    echo "./run.sh importData    - Importar dados do dataset"
    echo "./run.sh setupBackup   - Configurar backup"
    echo "./run.sh bashMaquina1  - Acessar shell do PostgreSQL"
    echo "./run.sh bashMaquina2  - Acessar shell do servidor de backup"
}

$1