FROM apache/airflow:2.4.1-python3.10
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pip install --upgrade pip