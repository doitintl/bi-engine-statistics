view: information_schema {

  parameter: project {
    type: unquoted
    allowed_value: {
      label: "default"
      value: "doitintl-cmp-online-reports"
    }
  }

  derived_table: {
    sql: SELECT
    creation_time
    , project_id
    , bi_engine_statistics.bi_engine_mode
    , bi_engine_reason.code
    , bi_engine_reason.message
    , cache_hit
    , query
    , job_id
    , total_bytes_billed
    , total_bytes_processed
    , end_time
    , start_time
    --, sum(count(job_id)) OVER() AS total_jobs
    --, SUM(total_bytes_billed)/pow(10,9) total_gb_billed
    --, SUM(total_bytes_processed)/pow(10,9) total_gb_processed
    --, SUM(TIMESTAMP_DIFF(end_time, start_time, MILLISECOND)/1000) duration
    --, SUM((SELECT SUM(end_ms - start_ms) FROM UNNEST(job_stages))/1000 ) stage_duration,
    FROM
    `doitintl-cmp-online-reports`.`region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
    LEFT JOIN  UNNEST(bi_engine_statistics.bi_engine_reasons) as bi_engine_reason
    WHERE 1=1
    AND job_type = "QUERY"
    AND creation_time BETWEEN TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 14 DAY) AND CURRENT_TIMESTAMP()
    AND destination_table.table_id LIKE "anon%" -- only queries with anoumous destination tables
    --GROUP BY 1,2,3,4,5,6,7,8
      ;;
  }
#
  dimension_group: query_run_time {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}.creation_time ;;
  }


  dimension: cache_hit {
    description: "BQ Cache used"
    label: "BQ Cache Hit"
    type: yesno
    sql: ${TABLE}.cache_hit ;;
  }

  dimension: project_id {
    label: "GCP Project ID"
    type: string
    sql: ${TABLE}.project_id ;;
  }
#

  dimension: job_id {
    primary_key: yes
    label: "BQ Job ID"
    type: number
    sql: ${TABLE}.job_id ;;
  }

  dimension: query {
    description: "BQ Query"
    type: string
    sql: ${TABLE}.query ;;
  }
#

  dimension: bi_engine_mode {
    label: "BI Engine Acceleration Mode"
    description: ""
    type: string
    sql: COALESCE(${TABLE}.bi_engine_mode,"other") ;;
    drill_fields: [query_details*]
  }


  dimension: code {
    label: "BI Engine Status Code"
    type: string
    sql: ${TABLE}.code ;;
    drill_fields: [query_details*]
  }

  dimension: message {
    label: "BI Engine Status Message"
    type: string
    sql: ${TABLE}.message ;;
    drill_fields: [query_details*]
  }


  dimension_group: job_duration {
    type: duration
    label: "BQ Job Duration"
    sql_start: ${TABLE}.start_time ;;
    sql_end:  ${TABLE}.end_time ;;
    intervals: [second, minute, hour]
    drill_fields: [query_details*]
  }

  measure: cnt_jobs {
    label: "BQ Job IDs"
    group_label: "Count"
    type: count
    drill_fields: [query_details*]
  }

  measure: total_gb_billed {
    type: sum
    sql: ${TABLE}.total_bytes_billed/pow(10,9) ;;
    label: "GB Billed"
    group_label: "Total"
    drill_fields: [query_details*]
    value_format: "0.#"
  }

  measure: total_gb_processed {
    type: sum
    sql: ${TABLE}.total_bytes_processed/pow(10,9) ;;
    group_label: "Total"
    label: "GB Processed"
    drill_fields: [query_details*]
    value_format: "0.#"
  }

  measure: total_potential_savings {
    type: sum
    sql:  ${TABLE}.total_bytes_processed/pow(10,9)/1024*5 ;;
    label: "Potential Savings in $"
    description: "Queries that are processed via BI Engine do not consume slots, or are billed via on-demand pricing"
    group_label: "Total"
    value_format_name: usd
  }

  measure: avg_job_duration {
    type: average
    sql: ${minutes_job_duration};;
    group_label: "Average"
    label: "Job Duration in sec"
    drill_fields: [query_details*]
    value_format: "SS"

  }

  set: query_details {
    fields: [query]
  }
}
