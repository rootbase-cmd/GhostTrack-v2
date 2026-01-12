# SECURITY - Linee guida minime per GhostTrack

**Accesso**
- Usa account GitHub con 2FA.
- Limitare permessi push ai maintainer.

**Ambiente**
- Separare ambiente di test da produzione.
- Backup giornalieri dei dati critici in .backups.

**Dati sensibili**
- Non committare chiavi o password.
- Usare file .env esclusi da git e un vault esterno.

**Aggiornamenti**
- Aggiornare dipendenze ogni 30 giorni.
- Eseguire scansione vulnerabilità prima del deploy.

**Ruoli**
- Definire almeno 1 owner, 1 dev, 1 community manager.
