from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from datetime import datetime
import psycopg2

default_args = {
    'owner': 'airflow',
    'start_date': datetime(2025, 7, 1),
    'retries': 1,
}

@dag(
    dag_id='etl_dag_with_staging',
    default_args=default_args,
    schedule=None,
    catchup=False,
    description='ETL: copiar dados de maquina1 para dw',
)
def etl_pipeline():


    dbt_run = BashOperator(
        task_id='dbt_run',
        bash_command='cd /opt/airflow/dbt && dbt run --target destination --profiles-dir /opt/airflow/dbt',
    )

    dbt_run

etl_dag_with_staging = etl_pipeline()
