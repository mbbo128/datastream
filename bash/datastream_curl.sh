!/bin/bash

# Get all documents
curl --location --request GET 'http://localhost:9201/_search' --header 'Content-Type: application/json'

# Change rollover interval
curl --location --request PUT 'http://localhost:9201/_cluster/settings' \
--header 'Content-Type: application/json' \
--data-raw '{
  "transient": {
    "indices.lifecycle.poll_interval": "5s"
  }
}'

# Create ilm policy
curl --location --request PUT 'http://localhost:9201/_ilm/policy/meetup-policy' \
--header 'Content-Type: application/json' \
--data-raw '{
  "policy": {
    "_meta": {
      "description": "meetup ilm policy"
    },
    "phases": {
      "hot": {
        "min_age": "0ms",
        "actions": {
          "rollover": {
            "max_age": "1d",
            "max_docs": 3,
            "max_size": "20gb"
          }
        }
      },
      "delete": {
        "min_age": "60d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}'

# Get ilm policy
curl --location --request GET 'http://localhost:9201/_ilm/policy/meetup-policy'

# Create index template
curl --location --request PUT 'http://localhost:9201/_index_template/meetup-template' \
--header 'Content-Type: application/json' \
--data-raw '{
  "index_patterns": [ "broadcast-monitoring-docker*" ],
  "data_stream": { },
  "priority": 500,
  "template": {
    "settings": {
        "index.lifecycle.name": "meetup-policy",
        "index.lifecycle.rollover_alias": "broadcast-monitoring-docker"
    },
    "mappings": {
        "properties": {
            "action": {
                "type": "text"
            },
            "ad_id": {
                "type": "integer"
            },
            "service": {
                "type": "text"
            },
            "site_name": {
                "type": "keyword"
            },
            "status": {
                "type": "text"
            },
            "title": {
                "type": "text"
            },
            "vertical": {
                "type": "text"
            },
            "error_message": {
                "type": "text"
            },
            "@timestamp": {
                "type": "date"
            }
        }
    }
  }
}
'

# Create 3 documents in broadcast-monitoring-docker
curl --location --request PUT 'http://localhost:9201/broadcast-monitoring-docker/_bulk' \
--header 'Content-Type: application/json' \
--data-raw '{"create":{ }}
{ "ad_id": 1, "action": "new", "service": "ad-gate", "site_name": "leboncoin", "status": "error", "title": "Programme Résidence à Paris 75011", "vertical": "real_estate", "error_message": "{\"result\":{\"code\":400,\"message\":\"Request data contains bad values\"}}",  "@timestamp": "2021-04-06T11:04:01.102109668+02:00" }
{"create":{ }}
{ "ad_id": 2, "action": "new", "service": "ad-gate", "site_name": "leboncoin", "status": "error", "title": "Programme Résidence à Paris 75012", "vertical": "real_estate", "error_message": "{\"result\":{\"code\":400,\"message\":\"Request data contains bad values\"}}",  "@timestamp": "2021-04-07T11:04:01.102109668+02:00" }
{"create":{ }}
{ "ad_id": 3, "action": "new", "service": "ad-gate", "site_name": "leboncoin", "status": "error", "title": "Programme Résidence à Paris 75013", "vertical": "real_estate", "error_message": "{\"result\":{\"code\":400,\"message\":\"Request data contains bad values\"}}",  "@timestamp": "2021-04-07T11:04:01.102109668+02:00" }
'

# Create document in broadcast-monitoring-docker
curl --location --request POST 'http://localhost:9201/broadcast-monitoring-docker/_doc' \
--header 'Content-Type: application/json' \
--data-raw '{
    "ad_id": 4,
    "action": "new",
    "service": "ad-gate",
    "site_name": "leboncoin",
    "status": "error",
    "title": "Programme Résidence à Paris 75014",
    "vertical": "real_estate",
    "error_message": "{\"result\":{\"code\":400,\"message\":\"Request data contains bad values\"}}",
    "@timestamp": "2021-04-08T11:04:01.102109668+02:00"
}'

# Get datastream info
curl --location --request GET 'http://localhost:9201/broadcast-monitoring-docker' \
--header 'Content-Type: application/json'

# Get datastream rollover info
curl --location --request GET 'http://localhost:9201/.ds-broadcast-monitoring-*/_ilm/explain' \
--header 'Content-Type: application/json'

# Post rollover
curl --location --request POST 'http://localhost:9201/broadcast-monitoring-docker/_rollover/' \
--header 'Content-Type: application/json'

# Delete data stream broadcast-monitoring-docker
curl --location --request DELETE 'http://localhost:9201/_data_stream/broadcast-monitoring-docker' \
--header 'Content-Type: application/json'

# Delete ilm meetup-policy
curl --location --request DELETE 'http://localhost:9201/_ilm/policy/meetup-policy' \
--header 'Content-Type: application/json'

# Delete index template
curl --location --request DELETE 'http://localhost:9201/_index_template/meetup-template' \
--header 'Content-Type: application/json'
