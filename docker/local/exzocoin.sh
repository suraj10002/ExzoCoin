#!/bin/sh

set -e

EXZO_NETWORK_BIN=./exzocoin
GENESIS_PATH=/genesis/genesis.json

case "$1" in

   "init")
      if [ -f "$GENESIS_PATH" ]; then
          echo "Secrets have already been generated."
      else
          echo "Generating secrets..."
          secrets=$("$EXZO_NETWORK_BIN" secrets init --num 4 --data-dir data- --json)
          echo "Secrets have been successfully generated"

          echo "Generating genesis file..."
          "$EXZO_NETWORK_BIN" genesis \
            --dir "$GENESIS_PATH" \
            --consensus ibft \
            --ibft-validators-prefix-path data- \
            --bootnode /dns4/node-1/tcp/1478/p2p/$(echo $secrets | jq -r '.[0] | .node_id') \
            --bootnode /dns4/node-2/tcp/1478/p2p/$(echo $secrets | jq -r '.[1] | .node_id')
          echo "Genesis file has been successfully generated"
      fi
      ;;

   *)
      until [ -f "$GENESIS_PATH" ]
      do
          echo "Waiting 1s for genesis file $GENESIS_PATH to be created by init container..."
          sleep 1
      done
      echo "Executing exzocoin..."
      exec "$EXZO_NETWORK_BIN" "$@"
      ;;

esac