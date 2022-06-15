# bi-engine-statistics
a opinionated bi engine statistics dashboard for datastudio

# Getting started
## Prerequisites 

In order to create the dashboard and query the INFORMATION_SCHEMA tables a user must have access to the following INFORMATION_SCHEMA table:
`INFORMATION_SCHEMA.JOBS_BY_PROJECT`

## Datasource
### 1.1 Copy the datasource
Log in to Data Studio and create a copy of the [data source](https://datastudio.google.com/datasources/d42dfc2c-71d4-46a3-ba38-bdd080e9472f) . More information on copying data sources can be found here[^1]. 
### 1.2 Set the correct GCP Billing project
Set it to the project, where you have made the BI Engine reservation.
### 1.3 Modify the data source: 
We used region-eu in our example, however you can modify this to a region of your choice (where your BI Engine capacity is reserved).  Use the following format to specify regionality for the project-id, region, and views in the INFORMATION_SCHEMA view[^2]:
```
`PROJECT_ID`.`region-REGION_NAME`.INFORMATION_SCHEMA.VIEW 
```

## Dashboard
### 2.1 Copy the dashboard
Create a copy of the [public dashboard](https://datastudio.google.com/u/0/reporting/079ae1d2-0392-4c13-94a0-d05919dad3ac/page/gtyuC). You will be asked to select a new Datasource, you have to select the one you copied in step 1. Click on create report and rename it as desired.
### 2.2 Modify the date pickers
Once the report is copied and all of the data is rendered, modify any date pickers in the report pages to use the time period you desire (ex: last week, last 14 days, last 28 days, etc).

[^1] https://support.google.com/datastudio/answer/7421646?hl=en&ref_topic=6370331
[^2] https://cloud.google.com/bigquery/docs/bi-engine-sql-interface-overview#acceleration_statistics_in_information_schema 



