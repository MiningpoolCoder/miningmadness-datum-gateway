# MiningMadness DATUM Gateway (Bitcoin Knots BLAKE2b)

DATUM Gateway preconfigured for the **MiningMadness** DATUM pool
(`miningmadness.com:4483`). You build your own block templates with your own
Bitcoin Knots BLAKE2b node; the pool only coordinates shares and pays every
miner **directly in the coinbase**, proportionally to the work since the last
pool block (recalculated every 10 seconds).

Based on [CONVOYMining/datum_gateway](https://github.com/CONVOYMining/datum_gateway)
(MIT) plus the MiningMadness direct-payout extension. Upstream documentation:
[doc/UPSTREAM_README.md](doc/UPSTREAM_README.md).

> ⚠️ Beta software. Test with a small amount of hashrate first.

---

## Español — inicio rápido

### Requisitos

1. **Nodo Bitcoin Knots BLAKE2b sincronizado** (con RPC activado). DATUM
   construye las plantillas en tu nodo: sin nodo propio no funciona.
   En su `bitcoin.conf`:
   ```
   server=1
   rpcuser=TU_USUARIO
   rpcpassword=TU_PASSWORD
   blockmaxweight=785000
   blocknotify=wget -q -O /dev/null http://127.0.0.1:7152/NOTIFY
   ```
   `blockmaxweight` reserva espacio para la coinbase con los pagos a los mineros.
2. Linux x86_64 o ARM64 (los binarios son estáticos: funcionan en cualquier distro).

### Instalación (binario)

Descarga la última versión desde **Releases**:

```bash
# x86_64 (para ARM usa linux-aarch64)
VER=$(curl -s https://api.github.com/repos/MiningpoolCoder/miningmadness-datum-gateway/releases/latest | grep -m1 tag_name | cut -d'"' -f4)
curl -LO https://github.com/MiningpoolCoder/miningmadness-datum-gateway/releases/download/$VER/miningmadness-datum-gateway-$VER-linux-x86_64.tar.gz
tar xzf miningmadness-datum-gateway-$VER-linux-x86_64.tar.gz
cd miningmadness-datum-gateway-$VER-linux-x86_64

./start.sh          # crea config.json la primera vez
nano config.json    # pon el RPC de tu nodo y tu dirección
./start.sh          # arranca el gateway
```

En `config.json` solo tienes que cambiar los valores `CAMBIA_ESTO`:

| Campo | Qué poner |
|---|---|
| `bitcoind.rpcuser` / `rpcpassword` / `rpcurl` | RPC de tu nodo Knots BLAKE2b |
| `mining.pool_address` | Tu dirección. Solo se usa si el pool no está disponible |

El servidor del pool, puerto y clave pública ya vienen configurados.

### Conectar los mineros

Apunta tus ASIC al gateway (no al pool):

```
URL:      stratum+tcp://IP_DE_TU_GATEWAY:23334
Usuario:  TU_DIRECCION_BLAKE2B.nombreworker
Password: x
```

Cada minero cobra en **la dirección que pone como usuario**; puedes tener
varias direcciones detrás de un mismo gateway.

Panel web del gateway: `http://IP_DE_TU_GATEWAY:7152`.

### Docker

```bash
mkdir -p datum && curl -L -o datum/config.json \
  https://raw.githubusercontent.com/MiningpoolCoder/miningmadness-datum-gateway/main/config.example.json
nano datum/config.json
docker run -d --name datum --restart unless-stopped --network host \
  -v "$PWD/datum:/app/config" ghcr.io/miningpoolcoder/miningmadness-datum-gateway:latest
```

(`--network host` para que el contenedor llegue al RPC del nodo en `127.0.0.1`.)

### Compilar desde el código fuente

```bash
sudo apt install build-essential cmake pkgconf git libcurl4-openssl-dev libjansson-dev libsodium-dev libmicrohttpd-dev
git clone https://github.com/MiningpoolCoder/miningmadness-datum-gateway.git
cd miningmadness-datum-gateway
cmake -S . -B build && cmake --build build -j
./build/datum_gateway --config config.json
```

Binario estático igual que el de Releases:
`docker run --rm -v "$PWD:/src" -w /src alpine:3.20 sh packaging/build-static.sh`

---

## English — quick start

1. Run a synced **Bitcoin Knots BLAKE2b** node with RPC enabled (and the
   `blockmaxweight`/`blocknotify` lines above).
2. Download the release for your architecture, extract it and run `./start.sh`.
   It creates `config.json`; set your node RPC credentials and fallback
   `mining.pool_address`, then run `./start.sh` again.
3. Point miners at `stratum+tcp://GATEWAY_IP:23334`, username
   `YOUR_BLAKE2B_ADDRESS.worker`. Each miner is paid directly in the coinbase to
   the address in its username.

Pool host, port and public key are built in (`miningmadness.com:4483`).
Override them in the `datum` section of the config only if instructed.

## License

MIT — see [LICENSE](LICENSE). Original work © Bitcoin Ocean, LLC, Jason Hughes,
CONVOY and contributors.
