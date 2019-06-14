# Pipeline Production Docker Deployment

This is a deployment configuration for running the core services (e.g., databases), coordinator (api, scheduler,
and client), along with a specific configuration using four workers.  It assumes a topology of all services other than
each worker backend/api (which must run on it its actual machine) running on a single host.

The system is built from:
* The default Compose file to launch core services
* A Compose file to add coordinator services
* A Compose file to add worker frontend clients (worker backend/api services must be local to the appropriate machine)

There are a number of required environmental variables in each of the Compose files.  For a new installation, copy and
paste `.env-template` as `.env` and change the values as appropriate.

The defaults in the template are configured to use four workers (worker1..worker4).  Add or remove entries in `.env` and
`docker-compose.workers.yml` as desired.

In general it is preferable to run one of following system modes for a given deployment directory and Compose project name.
It is possible to change back and forth between the different deployment modes, however you must maintain values such as
project name for each mode.

### Full System Mode

To manage the full system that includes all required services plus the worker frontend services for the four workers
 se the up/stop/down/logs scripts.  These scripts include all required Compose files for the full system.

By default the Compose project will be named "pipeline".  If you plan to run multiple systems systems, or would like to
override the project name, copy and paste `options-template.sh` as `options.sh` and change the `PIPELINE_COMPOSE_PROJECT`
variable name.

### Core Services Only (Development Mode)
The default Compose file will only load the core services, which are off-the-shelf containers and do not include any
pipeline specific containers.  This configuration is primarily useful for development where the pipeline-specific
services will be operated manually outside of containers.

Because it is the default Compose file, it can be started without specific Compose flags, e.g., `docker-compose up`.  To 
allow for also running in the other modes, use `dev.sh` or the -p flag to specify a project name that matches the default
or your override in `options.sh`.

## Misc Notes

Temporary container to view output logs:

`./pipeline-logs.sh`

Connect to the container database instance from the command line for direct interaction use (change network name
as appropriate):

`docker run -it --rm --link pipeline_db:postgres --network pipeline_back_tier postgres:9 psql -h postgres -U postgres`


Connect to an API instance just for migration:

`docker run -it --rm --network pipeline_back_tier mouselightpipeline/pipeline-api /bin/bash`

If the migration was not automatically run

`./migrate.sh`

If seed is needed (only on a full system refresh) from within the container (change path to task repository location
as appropriate)

`export PIPELINE_TASK_ROOT=/groups/mousebrainmicro/mousebrainmicro/pipeline-systems/pipeline`

and

`./seed.sh`
