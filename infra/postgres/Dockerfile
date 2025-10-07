FROM postgres:15

# Copy initialization scripts (SQL or SH) into the folder Postgres expects
COPY init /docker-entrypoint-initdb.d/

# Make sure .sh files are executable, so entrypoint runs them
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
