#!/bin/bash
seq 8000 8003 | xargs -P0 -IX bash -c "SHADE_PORT=X ./example.native"
