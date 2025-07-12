# Ambiente PostgreSQL automatizado!

Este projeto levanta um ambiente completo com:

- PostgreSQL 17 com suporte a SSH
- Servidor de backup em Ubuntu com **pgBackRest**
- Exportador de métricas **postgres_exporter**
- Monitoramento via **Prometheus**
- Dashboard com **Grafana**
- ETL com **Airflow + dbt**
- EL com **PGLoader**
- PostgreSQL 17 servindo como DW

> O projeto utiliza **Docker Compose** para facilitar o provisionamento e gerenciamento dos serviços.

---

## 🚀 Serviços incluídos

| Serviço             | Descrição                                              |
| ------------------- | ------------------------------------------------------ |
| `maquina1`          | PostgreSQL 17 com SSH habilitado                       |
| `maquina2`          | Ubuntu com pgBackRest configurado para backups remotos |
| `postgres_exporter` | Exportador de métricas para o Prometheus               |
| `prometheus`        | Coletor de métricas                                    |
| `grafana`           | Dashboard para visualização dos dados                  |

---

## 📜 Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## 🔧 Comandos disponíveis (`run.sh`)

### `./run.sh build`

O serviço deve ser buildado dessa forma, caso contrário o airflow, não irá funcionar. O bash exporta uma variável que é utilizada por ele.
Faz o build das imagens com cache desabilitado e limite de memória:

```bash
docker-compose build --no-cache --memory 4g --progress=plain
```

---

### `./run.sh up`

Sobe todos os containers em segundo plano (`-d`):

```bash
docker-compose up -d
```

---

### `./run.sh stop` ou `./run.sh drop`

Derruba todos os containers:

```bash
docker-compose down
```

---

### `./run.sh restart`

Reinicia todos os serviços:

```bash
docker-compose down && docker-compose up -d
```

---

### `./run.sh drop_hard`

Derruba os containers, remove imagens, volumes e dados persistidos localmente:

```bash
docker-compose down --volumes --remove-orphans --rmi all
docker builder prune --all --force
sudo rm -rf ./maquina1/data ./maquina1/log
sudo rm -rf ./maquina2/data ./maquina2/log
```

⚠️ **Atenção:** este comando apaga os dados da base e do backup.

---

### `./run.sh cpKeys`

Gera e configura chaves SSH entre `maquina1` e `maquina2` para permitir backups via `pgBackRest`.

---

### `./run.sh bashMaquina1`

Abre um shell interativo no container `maquina1` como usuário `postgres`.

---

### `./run.sh bashMaquina2`

Abre um shell interativo no container `maquina2` como usuário `postgres`.

---

## 📈 Monitoramento

- A exportação de métricas do PostgreSQL é feita via [`postgres_exporter`](https://github.com/prometheus-community/postgres_exporter).
- O Prometheus coleta e armazena as métricas.
- O Grafana exibe as métricas em dashboards interativos.

---

## 💾 Backup com pgBackRest

- O `pgBackRest` é instalado no container `maquina2` (Ubuntu).
- A comunicação entre os servidores é feita via SSH.
- O script `cpKeys` cuida da geração e troca de chaves públicas.

---

## 📂 Processo de backup

1. Execute:

   ```bash
   ./run.sh cpKeys
   ```

   para configurar a comunicação SSH entre as máquinas.

2. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 stanza-create
   ```

   para criar pasta dedicada para o backup no servidor de backup `maquina2`.

3. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 check
   ```

   para testar a comunicação SSH entre as máquinas.

4. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --type=full backup
   ```

   para realizar o primeiro backup completo.

5. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 info
   ```

   para verificar o status do backup.

6. Execute:

   ```bash
   docker exec -u postgres maquina1 pg_ctl stop -D /var/lib/postgresql/data/pgdata
   docker exec -u root maquina1 rm -rf /var/lib/postgresql/data/pgdata
   docker exec -u root maquina1 ls /var/lib/postgresql/data/pgdata   --> o caminho não pode existir, deletamos todos o banco
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --type=time --target="2025-07-07 18:50:47-03" restore
   docker exec -u root maquina1 chown -R postgres:postgres /var/lib/postgresql/data/pgdata
   docker exec -u root maquina1 chmod 750 /var/lib/postgresql/data/pgdata
   bash run.sh restart
   ```

   para realizar o restore do backup.

   ⚠️ **Atenção:** Para ver os arquivos é necessários executar o comando para ter permissão. sudo chmod 777 ./ -R

7. Verifique os logs do PostgreSQL se houver falhas no `pgBackRest`:

   ```bash
   docker exec maquina1 tail -f /var/lib/postgresql/log/postgresql.log
   ```

   ou acesse direto pelo na pasta `maquina1/log`

## 🧑‍💻 Processo de monitoramento

1. Acesse o Grafana em: [http://localhost:3000](http://localhost:4000)

   - Usuário padrão: `admin`
   - Senha padrão: `senha`

   exemplo de dash: https://grafana.com/grafana/dashboards/9628-postgresql-database/

## 📂➡️📤 Processo de carga de dados pelo pgloader

1. Lembre-se de colocar o arquivo .sqlite que será importado dentro da pasta pgloader

   ```bash
   cd pglaoder
   bash run.sh
   ```

## 📥 ➡️ 🔄 ➡️ 📤 Processo de ETL com Airflow + dbt

O Airflow já está configurado e os volumes dentro dele e do dbt já foram criados, portanto, não precisa reiniciar o container para modificar arquivos de DAGs e model do DBT.

1. Suas DAGs são o processos do Airflow que irão executar seu ETL.

2. Os diretórios das DAGs já foram configurados e a interface do Airflow pode ser acessada em http://localhost:8080/ utilizar a senha "airflow" e usuário "airflow". Uma DAG que roda o batch do dbt já irá estar disponível. Utilizem a interface para rodar seus DAGs.

3. O DBT irá executar os arquivos de SQL que estiverem dentro da pasta models. Criei 2 schemas iniciais: staging, intermediate e mart. Usem eles para executarem diferentes transformações com o dbt para tranformar as tabelas até chegar a formação do dw.

4. Uma model de exemplo já foi criada e já está levando as informações do container da maquina1 para o dw.

5. Criem os arquivo de sql necessários para execução de processo de etl.

6. Comando para rodar o dbt manualmente. Este já está dentro da dag do airflow:

   ```bash
   cd /opt/airflow/dbt && dbt run --target destination --profiles-dir /opt/airflow/dbt
   ```
