# FireIncidentGCP

El ejercicio usa GCP y Google Data Studio como herramienta de reporting.

Hay 2 cloud functions para importar la informacion desde el data source.
* load_history: Importa un CSV desde una URL y hace el dump dentro de la tabla Incidents en BigQuery. Se ejecuta ondemand.
* load_daily: Lee la API de DataSF para el dia de ayer e importa la informacion. Se ejecuta todos los dias. Hay un job creado para tal fin.

Ambas funciones se ejecutan mediante http.
El codigo fuente de ambas funciones esta el file main.py. Tambien se incluye el requirements.txt para cargar todas las dependencias necesarias.

La base de datos esta en Bigquery y hay una tabla Incidents que se actualiza todos los dias.

Hay una vista VW_Incidents que es usada por Google Data Studio. Se incluye el archivo views.sql con el script de la vista.

Hay un script Terraform de deploy, que crea el storage, cloud function, job y el dataset de Bigquery.
La tabla no es necesaria crearla previamente, ya que la funcion load_history la crea en caso de no existir.

