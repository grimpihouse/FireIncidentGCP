CREATE VIEW DataSF.VW_Incidents
AS
SELECT battalion, incident_date , neighborhood_district as district,
COUNT(*) AS IncidentsCount,
SUM(CAST(fire_fatalities AS NUMERIC)) AS fire_fatalities,
SUM(CAST(fire_injuries AS NUMERIC)) AS fire_injuries,
SUM(CAST(civilian_fatalities AS NUMERIC)) AS civilian_fatalities,
SUM(CAST(civilian_injuries AS NUMERIC)) AS civilian_injuries,
SUM(CAST(number_of_alarms AS NUMERIC)) AS number_of_alarms
from DataSF.Incidents
GROUP BY battalion, incident_date , neighborhood_district