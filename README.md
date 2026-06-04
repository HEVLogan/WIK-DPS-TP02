# WIK-DPS-TP02

Dockerisation de l'API TypeScript développée en TP01.  
L'API expose un endpoint `GET /ping` qui retourne les headers HTTP de la requête en JSON.

---

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Trivy](https://trivy.dev/) (pour le scan de vulnérabilités)

---

## Structure du projet

```
wik-dps-tp02/
├── src/
│   └── index.ts              ← code source de l'API
├── package.json
├── package-lock.json
├── tsconfig.json
├── .dockerignore
├── Dockerfile                ← image single-stage
├── Dockerfile.multistage     ← image multi-stage
└── trivy-scan.txt            ← résultat du scan de vulnérabilités
```

---

## Image single-stage

Une seule image qui installe les dépendances, compile le TypeScript et exécute l'API.

### Optimisations

- `package*.json` copié **avant** le code source → le layer `npm ci` est mis en cache tant que les dépendances ne changent pas
- `npm prune --production` supprime les devDependencies après le build
- Exécution sous l'utilisateur `node` (non-root) pour limiter les risques de sécurité

### Build

```bash
docker build -t wik-dps-tp02:single .
```

### Lancement

```bash
docker run --rm -p 8080:8080 -e PING_LISTEN_PORT=8080 wik-dps-tp02:single
```

### Test

```bash
curl http://localhost:8080/ping
```

---

## Image multi-stage

Deux stages séparés : un pour compiler, un pour exécuter.  
L'image finale ne contient **ni le code source TypeScript, ni les devDependencies**.

### Stage 1 — build

Installe toutes les dépendances et compile `src/index.ts` → `dist/index.js`.

### Stage 2 — run

Repart d'une image Node.js vierge et copie uniquement le dossier `dist/` depuis le stage précédent.

### Build

```bash
docker build -f Dockerfile.multistage -t wik-dps-tp02:multi .
```

### Lancement

```bash
docker run --rm -p 8080:8080 -e PING_LISTEN_PORT=8080 wik-dps-tp02:multi
```

---

## Comparaison des tailles

| Image | Taille |
|---|---|
| `wik-dps-tp02:single` | ~69 MB |
| `wik-dps-tp02:multi` | ~58 MB |

La multi-stage est plus légère car les outils de build (TypeScript, @types/node) ne sont pas inclus dans l'image finale.

---

## Scan de vulnérabilités

Scan réalisé avec [Trivy](https://trivy.dev/) :

```bash
trivy image wik-dps-tp02:single
```

Résultat complet disponible dans [`trivy-scan.txt`](./trivy-scan.txt).

### Résumé

| Sévérité | Nombre |
|---|---|
| CRITICAL | 0 |
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 0 |

Les vulnérabilités détectées proviennent des dépendances internes de `npm` embarqué dans l'image Node.js officielle, et non du code de l'application.
