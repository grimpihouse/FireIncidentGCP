import logging
import pandas
import pyarrow
import requests
import json

from datetime import datetime,timedelta
from google.cloud import bigquery
from google.oauth2 import service_account

#This function load into a BigQuery table, the historical data from San Franciso Fire Incidents public dataset.
def load(request):
  try:
    client = bigquery.Client()
    table_name = "DataSF.Incidents"

    #Step 1. Read file from URL
    dataframe = pandas.read_csv("https://data.sfgov.org/api/views/wr8u-xric/rows.csv?accessType=DOWNLOAD", dtype = str)
    dataframe.columns = dataframe.columns.str.replace(' ', '').str.lower()

    #Step 2. Configure Bigquery Data job
    job_config = bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE")

    job = client.load_table_from_dataframe(
        dataframe, table_name, job_config=job_config
    )
    job.result()
    return f'OK'
    
  except Exception as e:
    logging.error("load - " + str(e))
    return f'Failed'

def load_daily(request):
  try:
    client = bigquery.Client()
    table_name = "DataSF.Incidents"

    #Request daily data from SF API (from yesterday)
    page = requests.get("https://data.sfgov.org/resource/wr8u-xric.json?incident_date=" + (datetime.today()- timedelta(days=1)).strftime('%Y-%m-%dT00:00:00'))
    rows = json.loads(page.text)

    #Transform Point record in a string column
    for index in range(0,len(rows)):
        rows[index]["point"] = "POINT (" + str(rows[index]["point"]['coordinates'][0]) + "," + str(rows[index]["point"]['coordinates'][1]) + ")"

    if (len(rows) > 0):
        google_table = client.get_table(table_name)
        errors = client.insert_rows(google_table, rows)
        if (len(errors) > 0):
            logging.error(errors[0])
    else:
      logging.info("Empty rows")

    return f'OK'

  except Exception as e:
    logging.error("load - " + str(e))
    return f'Failed'