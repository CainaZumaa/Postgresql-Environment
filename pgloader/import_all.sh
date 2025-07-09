#!/bin/bash

echo "=== Importação de Dados do Dataset de Futebol (SQLite) ==="
echo "Dataset: https://www.kaggle.com/datasets/hugomathien/soccer"
echo ""

# Verificar se o arquivo SQLite existe
echo "Verificando arquivo SQLite..."
if [ -f "/data/database.sqlite" ]; then
    echo "✓ database.sqlite encontrado"
else
    echo "✗ database.sqlite NÃO encontrado"
    echo ""
    echo "Por favor, baixe o dataset do Kaggle e coloque o arquivo database.sqlite na pasta /data/"
    echo "O arquivo deve estar em: /data/database.sqlite"
    exit 1
fi

echo ""
echo "Iniciando importação..."

# Importar dados usando pgloader
pgloader import_soccer.load

echo ""
echo "Importação concluída!"
echo ""
echo "Para verificar os dados importados, acesse:"
echo "- pgAdmin: http://localhost:5050 (admin@soccer.com / admin123)"
echo "- Grafana: http://localhost:3000 (admin / senha)"
echo "- Prometheus: http://localhost:9090" 