# 🏈 European Soccer Database - Ambiente PostgreSQL Completo

Este projeto implementa um ambiente completo para análise de dados de futebol europeu, baseado no dataset do Kaggle: [European Soccer Database](https://www.kaggle.com/datasets/hugomathien/soccer).

## 🚀 Serviços Incluídos

| Serviço               | Descrição                                | Porta |
| --------------------- | ---------------------------------------- | ----- |
| `maquina1`            | PostgreSQL 17 com dados de futebol       | 15432 |
| `maquina2`            | Servidor de backup Ubuntu com pgBackRest | 2222  |
| `pgadmin`             | Interface web para gerenciar PostgreSQL  | 5050  |
| `pgloader`            | Ferramenta para importação de dados CSV  | -     |
| `postgresql-exporter` | Exportador de métricas para Prometheus   | 9187  |
| `prometheus`          | Coletor e armazenamento de métricas      | 9090  |
| `grafana`             | Dashboard para visualização de dados     | 3000  |

## 📊 Dataset de Futebol

O projeto utiliza o **European Soccer Database** que contém:

- **25,000+ partidas** de 11 países europeus
- **10,000+ jogadores** com atributos detalhados
- **8 temporadas** (2008-2016)
- **Dados de apostas** e estatísticas de jogo
- **Informações de times** e ligas

### Estrutura do Banco de Dados

```sql
-- Tabelas principais
countries          -- Países das ligas
leagues            -- Ligas de futebol
teams              -- Times participantes
players            -- Jogadores
player_attributes  -- Atributos dos jogadores (FIFA-style)
seasons            -- Temporadas
matches            -- Partidas com estatísticas completas
```

## 🛠️ Pré-requisitos

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- Dataset do Kaggle baixado e extraído na pasta `data/`

## 📥 Preparação dos Dados

1. **Baixe o dataset do Kaggle:**

   ```
   https://www.kaggle.com/datasets/hugomathien/soccer
   ```

2. **Extraia os arquivos CSV na pasta `data/`:**
   ```
   Postgresql-Environment/data/
   ├── Country.csv
   ├── League.csv
   ├── Team.csv
   ├── Player.csv
   ├── Player_Attributes.csv
   ├── Season.csv
   └── Match.csv
   ```

## 🔧 Comandos Disponíveis (`run.sh`)

### Comandos Básicos

```bash
./run.sh build      # Build das imagens Docker
./run.sh up         # Subir todos os serviços
./run.sh stop       # Parar todos os serviços
./run.sh restart    # Reiniciar todos os serviços
./run.sh drop_hard  # Remover tudo (cuidado!)
```

### Comandos Específicos do Projeto

```bash
./run.sh importData    # Importar dados do dataset
./run.sh setupBackup   # Configurar backup automático
./run.sh cpKeys        # Configurar SSH entre servidores
./run.sh showStatus    # Mostrar status e URLs
./run.sh bashMaquina1  # Acessar shell do PostgreSQL
./run.sh bashMaquina2  # Acessar shell do servidor de backup
```

## 🚀 Início Rápido

### 1. Preparar os Dados

```bash
# Baixe o dataset do Kaggle e extraia na pasta data/
# Os arquivos CSV devem estar em: ./data/
```

### 2. Subir o Ambiente

```bash
./run.sh build
./run.sh up
```

### 3. Configurar Backup

```bash
./run.sh setupBackup
```

### 4. Importar Dados

```bash
./run.sh importData
```

### 5. Acessar as Ferramentas

| Ferramenta     | URL                   | Credenciais                 |
| -------------- | --------------------- | --------------------------- |
| **pgAdmin**    | http://localhost:5050 | admin@soccer.com / admin123 |
| **Grafana**    | http://localhost:3000 | admin / senha               |
| **Prometheus** | http://localhost:9090 | -                           |
| **PostgreSQL** | localhost:15432       | postgres / postgres         |

## 📈 Monitoramento

### Grafana Dashboards

- **Métricas do PostgreSQL**: Conexões, queries, performance
- **Dados de Futebol**: Estatísticas de partidas, jogadores, times
- **Sistema**: CPU, memória, disco

### Prometheus

- Coleta métricas a cada 15 segundos
- Armazena dados por 30 dias
- Exportador PostgreSQL configurado

## 💾 Backup com pgBackRest

- **Backup automático** configurado
- **Compressão** para economizar espaço
- **Retenção** de 5 backups completos
- **Comunicação SSH** segura entre servidores

### Comandos de Backup

```bash
# Verificar status do backup
docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 info

# Fazer backup manual
docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --type=full backup

# Restaurar backup
docker exec -u postgres maquina1 pgbackrest --stanza=maquina1 --type=full restore
```

## 🔍 Exemplos de Consultas SQL

### Top 10 Jogadores por Overall Rating

```sql
SELECT player_name, overall_rating, potential
FROM players p
JOIN player_attributes pa ON p.player_fifa_api_id = pa.player_fifa_api_id
WHERE pa.overall_rating IS NOT NULL
ORDER BY pa.overall_rating DESC
LIMIT 10;
```

### Estatísticas por Liga

```sql
SELECT
    l.name as league,
    COUNT(m.id) as total_matches,
    AVG(m.home_team_goal + m.away_team_goal) as avg_goals_per_match
FROM matches m
JOIN leagues l ON m.league_id = l.id
GROUP BY l.id, l.name
ORDER BY avg_goals_per_match DESC;
```

### Performance de Times em Casa

```sql
SELECT
    t.team_long_name,
    COUNT(m.id) as home_matches,
    AVG(m.home_team_goal) as avg_goals_scored,
    AVG(m.away_team_goal) as avg_goals_conceded
FROM matches m
JOIN teams t ON m.home_team_id = t.id
GROUP BY t.id, t.team_long_name
HAVING COUNT(m.id) > 10
ORDER BY avg_goals_scored DESC;
```

## 🐛 Troubleshooting

### Problemas Comuns

1. **Erro de conexão SSH:**

   ```bash
   ./run.sh cpKeys
   ```

2. **Dados não importados:**

   ```bash
   # Verificar se arquivos CSV estão na pasta data/
   ls -la ./data/

   # Reimportar dados
   ./run.sh importData
   ```

3. **Container não inicia:**

   ```bash
   # Ver logs
   docker-compose logs maquina1

   # Rebuild
   ./run.sh drop_hard
   ./run.sh build
   ./run.sh up
   ```

### Logs Importantes

```bash
# Logs do PostgreSQL
docker exec maquina1 tail -f /var/lib/postgresql/log/postgresql-maquina1.log

# Logs do pgBackRest
docker exec maquina2 tail -f /var/log/pgbackrest/pgbackrest.log

# Logs do pgloader
docker logs pgloader
```

## 📚 Recursos Adicionais

- **Documentação pgBackRest**: https://pgbackrest.org/
- **Documentação pgloader**: https://pgloader.readthedocs.io/
- **Dataset Original**: https://www.kaggle.com/datasets/hugomathien/soccer
- **Documentação PostgreSQL**: https://www.postgresql.org/docs/

## 🤝 Contribuição

Para contribuir com melhorias:

1. Fork o projeto
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para detalhes.
