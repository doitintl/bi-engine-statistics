 /*
  * Daily BI Engine statitics
  * with a breakdown by bi_engine_mode, status_message
  */


SELECT
 TIMESTAMP_TRUNC(creation_time, DAY, "UTC") AS date
, project_id
, bi_engine_statistics.bi_engine_mode 
, bi_engine_reason.code
, bi_engine_reason.message
, cache_hit
, query
, job_id
, sum(count(job_id)) OVER() AS total_jobs
, SUM(total_bytes_billed)/pow(10,9) total_gb_billed
, SUM(total_bytes_processed)/pow(10,9) total_gb_processed
, SUM(TIMESTAMP_DIFF(end_time, start_time, MILLISECOND)/1000) duration
, SUM((SELECT SUM(end_ms - start_ms) FROM UNNEST(job_stages))/1000 ) stage_duration,
FROM
`region-eu`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
LEFT JOIN  UNNEST(bi_engine_statistics.bi_engine_reasons) as bi_engine_reason
WHERE job_type = "QUERY"
AND user_email NOT LIKE "doit-intl.com"
AND destination_table.table_id LIKE "anon%" -- only queries with anoumous destination tables
GROUP BY 1,2,3,4,5,6,7,8

