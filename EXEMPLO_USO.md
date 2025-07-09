# 🏈 Tutorial Completo - European Soccer Database

**Tutorial para o time acessar e usar o projeto de análise de dados de futebol.**

## 📋 Pré-requisitos para TODOS os membros do time

### 1. Instalar Docker Desktop

- **Windows**: Baixe em https://www.docker.com/products/docker-desktop
- **Mac**: Baixe em https://www.docker.com/products/docker-desktop
- **Linux**: Execute `sudo apt-get install docker.io docker-compose`

### 2. Verificar instalação

```bash
docker --version
docker-compose --version
```

### 3. Baixar o dataset

- Acesse: https://www.kaggle.com/datasets/hugomathien/soccer
- Clique em "Download" (precisa de conta Kaggle)
- Extraia o arquivo `database.sqlite` na pasta `data/`

## 🚀 Passo a Passo para TODOS

### Passo 1: Clonar o projeto

```bash
git clone <URL_DO_REPOSITORIO>
cd Postgresql-Environment
```

### Passo 2: Preparar dados

```bash
# Criar pasta data (se não existir)
mkdir data

# Colocar o arquivo database.sqlite na pasta data/
# O arquivo deve estar em: ./data/database.sqlite
```

### Passo 3: Subir o ambiente

```bash
# Build das imagens (primeira vez)
./run.sh build

# Subir todos os serviços
./run.sh up

# Aguardar 2-3 minutos para todos os containers iniciarem
```

### Passo 4: Verificar se tudo está funcionando

```bash
# Ver status dos containers
./run.sh showStatus

# Verificar se PostgreSQL está rodando
docker exec maquina1 pg_isready -U postgres
```

### Passo 5: Configurar backup (opcional)

```bash
# Configurar SSH entre servidores
./run.sh cpKeys

# Configurar backup automático
./run.sh setupBackup
```

### Passo 6: Importar dados

```bash
# Importar dados do SQLite para PostgreSQL
./run.sh importData
```

## 🌐 Acessar as Ferramentas

### pgAdmin (Interface do Banco)

- **URL**: http://localhost:5050
- **Email**: admin@soccer.com
- **Senha**: admin123
- **O que fazer**: Conectar ao servidor "Soccer Database" automaticamente

### Grafana (Dashboards)

- **URL**: http://localhost:3000
- **Usuário**: admin
- **Senha**: senha
- **O que fazer**: Criar dashboards para visualizar dados

### PostgreSQL (Conexão direta)

- **Host**: localhost
- **Porta**: 15432
- **Database**: soccer_db
- **Usuário**: postgres
- **Senha**: postgres

## 🔧 Comandos Úteis para o Time

### Verificar se está tudo funcionando

```bash
# Status dos containers
docker-compose ps

# Logs do PostgreSQL
docker logs maquina1

# Logs do pgAdmin
docker logs pgadmin
```

### Parar o ambiente

```bash
./run.sh stop
```

### Reiniciar o ambiente

```bash
./run.sh restart
```

### Acessar shell do banco

```bash
./run.sh bashMaquina1
```

### Ver dados importados

```bash
# Conectar ao PostgreSQL
docker exec -u postgres maquina1 psql -d soccer_db

# Verificar tabelas
\dt

# Contar registros
SELECT COUNT(*) FROM matches;
SELECT COUNT(*) FROM players;
SELECT COUNT(*) FROM teams;

# Sair
\q
```

## 📊 Exemplos de Consultas para o Time

### 1. Verificar se os dados foram importados

```sql
-- Conectar ao banco
docker exec -u postgres maquina1 psql -d soccer_db

-- Verificar tabelas
\dt

-- Contar registros principais
SELECT 'matches' as tabela, COUNT(*) as total FROM matches
UNION ALL
SELECT 'players' as tabela, COUNT(*) as total FROM players
UNION ALL
SELECT 'teams' as tabela, COUNT(*) as total FROM teams
UNION ALL
SELECT 'leagues' as tabela, COUNT(*) as total FROM leagues;
```

### 2. Top 10 jogadores

```sql
SELECT
    p.player_name,
    pa.overall_rating,
    pa.potential,
    pa.preferred_foot
FROM players p
JOIN player_attributes pa ON p.player_fifa_api_id = pa.player_fifa_api_id
WHERE pa.overall_rating IS NOT NULL
ORDER BY pa.overall_rating DESC
LIMIT 10;
```

### 3. Estatísticas por liga

```sql
SELECT
    c.name as pais,
    l.name as liga,
    COUNT(m.id) as total_partidas,
    AVG(m.home_team_goal + m.away_team_goal) as media_gols
FROM matches m
JOIN leagues l ON m.league_id = l.id
JOIN countries c ON l.country_id = c.id
GROUP BY c.id, c.name, l.id, l.name
ORDER BY media_gols DESC;
```

## 🚨 Problemas Comuns e Soluções

### Problema: "docker: command not found"

**Solução**: Instalar Docker Desktop

### Problema: "Permission denied"

**Solução**:

```bash
# Windows/Mac: Reiniciar Docker Desktop
# Linux:
sudo usermod -aG docker $USER
# Depois fazer logout e login
```

### Problema: "Port already in use"

**Solução**:

```bash
# Parar tudo
./run.sh stop

# Verificar se há outros containers rodando
docker ps

# Parar containers conflitantes
docker stop $(docker ps -q)
```

### Problema: "database.sqlite not found"

**Solução**:

```bash
# Verificar se o arquivo está na pasta correta
ls -la ./data/

# Se não estiver, baixar do Kaggle e colocar em ./data/database.sqlite
```

### Problema: "Import failed"

**Solução**:

```bash
# Verificar logs
docker logs pgloader

# Reimportar dados
./run.sh importData
```

### Problema: "Cannot connect to pgAdmin"

**Solução**:

```bash
# Aguardar mais tempo para containers iniciarem
sleep 60

# Verificar se pgAdmin está rodando
docker logs pgadmin

# Reiniciar apenas pgAdmin
docker-compose restart pgadmin
```

## 📱 Acesso Remoto (para trabalho em equipe)

### Se alguém quiser acessar de outra máquina:

1. Descobrir IP da máquina: `ipconfig` (Windows) ou `ifconfig` (Linux/Mac)
2. Acessar: `http://IP_DA_MAQUINA:5050` (pgAdmin)
3. Acessar: `http://IP_DA_MAQUINA:3000` (Grafana)

### Exemplo:

- Se o IP for 192.168.1.100:
- pgAdmin: http://192.168.1.100:5050
- Grafana: http://192.168.1.100:3000

## 🎯 Checklist para o Time

### ✅ Antes de começar:

- [ ] Docker Desktop instalado
- [ ] Dataset baixado e colocado em `./data/database.sqlite`
- [ ] Projeto clonado

### ✅ Para subir o ambiente:

- [ ] `./run.sh build` (primeira vez)
- [ ] `./run.sh up`
- [ ] Aguardar 2-3 minutos
- [ ] `./run.sh showStatus` (verificar se tudo está OK)

### ✅ Para usar:

- [ ] `./run.sh importData` (importar dados)
- [ ] Acessar pgAdmin: http://localhost:5050
- [ ] Acessar Grafana: http://localhost:3000

### ✅ Para parar:

- [ ] `./run.sh stop`

## 📞 Suporte

Se algo não funcionar:

1. Verificar se Docker está rodando
2. Verificar se arquivo `database.sqlite` está em `./data/`
3. Tentar `./run.sh restart`
4. Verificar logs: `docker logs maquina1`

**Boa sorte com o projeto! ⚽**
