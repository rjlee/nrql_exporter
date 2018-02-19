# nrql_exporter

The nrql_exporter is a simple ruby daemon that acts as a telegraf exporter.  It is designed to work with New Relic and allows NRQL queries to be exported in a telegraf format for consumption by tools such as prometheus.

## Configuration

The exporter expects a configuratIon file `nrql_exporter.conf` to be present in the same directory as the exporter.  The file requires an insights API key and the New Relic Account ID.  For more details on how to obtain these see https://docs.newrelic.com/docs/insights/insights-api/get-data/query-insights-event-data-api.

### Query format

The queries are expected to return a single counter value using a label of 'count'.  An example following this format is shown below:

```
SELECT count(result) as 'count' FROM SyntheticCheck WHERE monitorName='API'
```

### Response Cache

The exporter cache value in the configuration file specifies how long the last response should be cached for (in seconds) before a new request to New Relic is made.  This allows control of the number of API requests being made to the New Relic origin.

## Installation

The `nrql_exporter` script has no dependancies other than a recent ruby version.  A configuration file `nrql_exporter.conf` should be added in the same directory as the exporter, with the appropriate configuration.

```
git clone https://github.com/rjlee/nrql_exporter.git
cd nrql_exporter
chmod u+x nrql_exporter
cp nrql_exporter.sample.conf nrql_exporter.conf
./nrql_exporter
```

If the Typheous Gem is installed, then the exporter will parallelize requests to New Relic, which is recommended for larger volumes of queries.

```
gem install bundler
bundle install
```

## Running

If a different location is required for the configuration file, this can be specified by using the `NRQL_EXPORTER_CONFIG` environment variable.

```
NRQL_EXPORTER_CONFIG=/etc/nrql_exporter.conf ./nrql_exporter
```

In production, the exporter should be run as a daemon using an init script.  This is left as an exercise for the reader.

## Docker

The included `Dockerfile` will build an example container but the config will be left as the default. To override this, it is recommended you extend the docker image and copy your own configuration file in:

```
FROM rjlee/nrql_exporter:latest

COPY my_nrql_exporter.conf /nrql_exporter/nrql_exporter.conf
```

**Important:** for production usage, I recommend you actually build your own local tag of the base image from this repository rather than pulling it from Docker Hub. The Docker Hub image is unlikely to be updated regularly and therefore may not include recent security fixes.
