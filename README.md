**NOTE**

*Documentation is being transitioned to and enhanced at https://mouselightpipeline.github.io.  Please use the information there in conjuction with this repository in the interim.*

*This the just top-level repository for deployment of the pipeline services in a self-contained system.  There are a number of associated repositories for the individual service code.*

# MouseLight Acquisition Pipeline

The Mouse Light Pipeline is a collection of services that facilitate the multi-step data processing of the several-thousand tiles per acquisition sample.  The processing may occur in real-time as the data becomes available, offline after acquisition is complete, or a combination of both.  Although originally designed to utilize metadata specific to the Mouse Light acquisition process, it has since been generalized to allow processing of additional input sources.

Although similar to other computation pipelines, the Mouse Light Pipeline is designed around the concept of a 2-D or 3-D lattice of work units and manages the bookkeeping of spatially related elements. This simplifies tasks that require patterns of elements such as using adjacent tiles in one or more planes. The second significant feature is the integrated real-time monitoring of the pipeline with the ability to pause and resume stages of the pipeline and the porject itself independently. This includes multiple ways to view the status of each stage (waiting, in process, complete) each plane (which work units are in what state for which stage), and for each work unit (history or past and, if applicable, current processing attempts).

## Overview

A Pipeline project consists of a root pipeline “stage” that is based on an input source, such as the output tiles during acquisition, and one or more downstream stages that perform data processing.  The root stage itself does not perform any processing, but simply monitors the acquisition or other input source for existing or new data and then stores the required metadata for downstream stages.  

Any stage, including the root stage, can have one or more downstream stages.  These can be added or removed at any time, including while processing is active.  Each stage defines its functionality, typically through a shell script that calls a processing function written in Python, MATLAB, or any other language or tool.  That stage function is called for each tile or unit of work in the project once the parent stage has successfully completed its processing.  Success or failure of the processing of each tile for each stage is tracked, logged, and reported.   

The two primary elements of the system are the coordinator and the workers.  The coordinator monitors workers, defines each project including creating and removing downstream stages, and is used to control which pipelines and stages are actively processing.  Workers are distributed across multiple machines and execute the stage functions for individual each tile.  They may do so either by perform the processing locally or by managing the submission and monitoring to some form of remote compute cluster.  Workers may be added or removed from the system at any time as well as configured to take on more or less processing load as appropriate. 

## Quick Start

The Mouse Light Acquistion Pipeline virtual machine is a self-contained instance of the complete pipeline system.  It contains two example projects that demonstrate pipeline processing and additional ones may be added.
A VMWare version (https://janelia.figshare.com/projects/MouseLight_Acquisition_Pipeline_VM/63212) is available for download.
* Download and install VirtualBox, VMWare Player, or a similar product
* Select and download the appropriate format for your virtual machine host application and unzip the archive
* Open the virtual machine in your host app and follow the instructions in the ReadMe included with the virtual machine

## General Installation
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

Connect to the container database instance from the command line for direct interaction use (change network name
as appropriate):

`docker run -it --rm --link pipeline_db:postgres --network pipeline_back_tier postgres:9 psql -h postgres -U postgres`

The database is automatically migrated to the the latest when the system is started, however if you would like to tinker
and manually migrate:

`./migrate.sh`

If seed is needed (only on a full system refresh and if you want the default Mouse Light project examples)

`./seed.sh`

The various `PIPELINE_SEED_...` variables in the `.env` file likely need to to be changed unless running on
Mouse Light project systems.
