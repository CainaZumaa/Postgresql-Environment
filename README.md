
# PostgreSQL 17 + Backup com pgBackRest + Monitoramento (Prometheus + Grafana)

Este projeto levanta um ambiente completo com:

- PostgreSQL 17 com suporte a SSH
- Servidor de backup em Ubuntu com **pgBackRest**
- Exportador de métricas **postgres_exporter**
- Monitoramento via **Prometheus**
- Dashboard com **Grafana**

> O projeto utiliza **Docker Compose** para facilitar o provisionamento e gerenciamento dos serviços.

---

## 🚀 Serviços incluídos

| Serviço              | Descrição                                                    |
|----------------------|--------------------------------------------------------------|
| `maquina1`           | PostgreSQL 17 com SSH habilitado                             |
| `maquina2`           | Ubuntu com pgBackRest configurado para backups remotos       |
| `postgres_exporter`  | Exportador de métricas para o Prometheus                     |
| `prometheus`         | Coletor de métricas                                          |
| `grafana`            | Dashboard para visualização dos dados                        |

---

## 📜 Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## 🔧 Comandos disponíveis (`run.sh`)

### `./run.sh build`

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

* A exportação de métricas do PostgreSQL é feita via [`postgres_exporter`](https://github.com/prometheus-community/postgres_exporter).
* O Prometheus coleta e armazena as métricas.
* O Grafana exibe as métricas em dashboards interativos.

---

## 💾 Backup com pgBackRest

* O `pgBackRest` é instalado no container `maquina2` (Ubuntu).
* A comunicação entre os servidores é feita via SSH.
* O script `cpKeys` cuida da geração e troca de chaves públicas.

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
   ./run.sh restart
   ```

   para reiniciar os serviços.

4. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 check
   ```

   para testar a comunicação SSH entre as máquinas.

5. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --type=full backup
   ```

   para realizar o primeiro backup completo.

6. Execute:

   ```bash
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 info
   ```

   para verificar o status do backup.

7. Execute:

   ```bash
   docker exec -u postgres maquina1 systemctl stop postgresql
   docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --target-time="2025-07-05 15:01:33-03" --type=time   restore
   docker exec -u postgres maquina1 systemctl start postgresql
   ```

   para realizar o restore do backup.

## 🧑‍💻 Processo de monitoramento

1. Acesse o Grafana em: [http://localhost:3000](http://localhost:3000)

   * Usuário padrão: `admin`
   * Senha padrão: `senha`

2. Verifique os logs do PostgreSQL se houver falhas no `pgBackRest`:

   ```bash
   docker exec maquina1 tail -f /var/lib/postgresql/log/postgresql.log
   ```

   ou acesse direto pelo na pasta `maquina1/log`

## 🧑‍💻 Processo de carga de dados pelo pgloader

   ```bash
   cd pglaoder
   bash run.sh
   ```

