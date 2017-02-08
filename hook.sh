#!/bin/bash
#
# Este script guarda un registro de las bases de datos creadas.
# Cuando se crea una nueva db se guarda el nombre en la base de datos: experiments_registry
# Otro formato de fecha: date +\"[%d %b %Y - %H:%M:%S]\" +\"[%d %b %Y - %H:%M:%S]\"

LOGFILE=/root/oml2-server-hook.log
TIMESTAMP=$(date)

function log ()
{
    echo "$@" >&2
    echo "$@" >> ${LOGFILE}
}

while read COMMAND ARGUMENTS; do
    if [ -z "$COMMAND" ]; then
        continue
    fi
    log -n "$TIMESTAMP: '${COMMAND} ${ARGUMENTS}': "
    case "${COMMAND}" in
        "DBCREATED") # se crea una db
            log "DB ${ARGUMENTS} created"
            case "${ARGUMENTS}" in
                postgresql://*)
                    # Se crea una DB tipo PostgreSQL
                    TMP="${ARGUMENTS/postgresql:\/\//}"
                    USER=${TMP/@*/}
                    TMP=${TMP/${USER}@/}
                    TMP=${TMP/${USER}@/}
                    HOST=${TMP/:*/}
                    TMP=${TMP/${HOST}:/}
                    PORT=${TMP/\/*/}
                    TMP=${TMP/${PORT}\//}
                    DBNAME=${TMP}
                    # Anadimos la base de datos DBNAME a la base de 
                    # datos 'experiments_registry', tabla 'experiments',
                    # columna 'experiment_name'
                    log "$TIMESTAMP: Insert '${DBNAME}' into experiments_registry db."
                    psql -U ${USER} -w -h ${HOST} -p ${PORT} experiments_registry -c "INSERT INTO experiments(experiment_name) VALUES ('${DBNAME}');"
                    ;;
                *)
                    log "DB ${ARGUMENTS} created, but don't know how to handle it"
                    ;;
            esac
            ;;
        "DBOPENED")
            log "DB ${ARGUMENTS} opened"
            ;;
        "DBCLOSED")
            log "DB ${ARGUMENTS} closed"
            log "$TIMESTAMP: Insert '${DBNAME}' into experiments_registry db."
            ;;
        "EXIT")
            log "Exiting"
            exit 0
            ;;
        *)
            log "Unknown command"
            ;;
    esac
done
