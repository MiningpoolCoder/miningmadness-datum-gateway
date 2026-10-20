#!/bin/sh
# MiningMadness DATUM Gateway launcher.
cd "$(dirname "$0")"
if [ ! -f config.json ]; then
	cp config.example.json config.json
	echo "Se ha creado config.json. Edítalo (RPC de tu nodo Knots y tu dirección) y vuelve a ejecutar ./start.sh"
	echo "config.json created. Edit it (your Knots node RPC and your address) and run ./start.sh again"
	exit 1
fi
if grep -q CAMBIA_ESTO config.json; then
	echo "config.json todavía contiene valores CAMBIA_ESTO. / config.json still contains CAMBIA_ESTO placeholders."
	exit 1
fi
exec ./datum_gateway --config config.json "$@"
