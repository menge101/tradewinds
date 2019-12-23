#!/usr/bin/env bash

su postgres -c "psql postgres -c \"ALTER USER postgres PASSWORD 'postgres';\""