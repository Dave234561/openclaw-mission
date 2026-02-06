# PLAN D'ACTION SÉCURITÉ OPENCLAW - PRIORITÉ IMMÉDIATE

## 🚨 PHASE 1 - URGENT (0-24 heures)

### 1. Mise à jour CRITIQUE (30 min)
```bash
# Sauvegarder config actuelle
cp -r ~/.openclaw/config ~/.openclaw/config.backup

# Mettre à jour OpenClaw
openclaw gateway stop
npm update -g openclaw
openclaw gateway start

# Vérifier version
openclaw gateway status
```

### 2. Firewall immédiat (15 min)
```bash
# Bloquer port 18789 à l'extérieur
sudo ufw deny 18789
sudo ufw enable
sudo ufw status

# Vérifier avec
netstat -tulpn | grep 18789
```

### 3. Audit des tokens (45 min)
```bash
# Lister tous les tokens actifs
find ~/.openclaw -name "*.json" -exec grep -l "token" {} \;

# Sauvegarder puis supprimer tokens suspects
mkdir ~/.openclaw/tokens_backup
cp ~/.openclaw/config/*.json ~/.openclaw/tokens_backup/

# Générer nouveau token sécurisé
openclaw gateway generate-token --scope limited
```

### 4. Désactiver mDNS (5 min)
```bash
# Éditer config
echo "mdns: enabled: false" >> ~/.openclaw/config/gateway.yaml
openclaw gateway restart
```

---

## ⚡ PHASE 2 - COURT TERME (1-7 jours)

### 5. Container Docker sécurisé (2h)
```dockerfile
# Dockerfile sécurisé
FROM node:18-alpine
RUN adduser -D -s /bin/sh -u 65534 openclaw
USER openclaw
WORKDIR /app
COPY --chown=openclaw:openclaw . .
RUN npm install --production
EXPOSE 18789
CMD ["node", "gateway.js"]
```

```bash
# Lancer avec restrictions
docker run -d \
  --name openclaw-secure \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --network host \
  --memory 1g \
  --cpus 1 \
  --user 65534:65534 \
  -v $HOME/.openclaw/workspace:/workspace:rw \
  -v $HOME/.openclaw/config:/config:rw \
  openclaw:secure
```

### 6. Monitoring de sécurité (1h)
```bash
# Installer fail2ban
sudo apt install fail2ban

# Configurer pour OpenClaw
echo "[openclaw]" | sudo tee -a /etc/fail2ban/jail.local
echo "enabled = true" | sudo tee -a /etc/fail2ban/jail.local
echo "port = 18789" | sudo tee -a /etc/fail2ban/jail.local
echo "filter = openclaw" | sudo tee -a /etc/fail2ban/jail.local

# Créer filtre
echo "[Definition]" | sudo tee /etc/fail2ban/filter.d/openclaw.conf
echo "failregex = ^.*Unauthorized.*from <HOST>" | sudo tee -a /etc/fail2ban/filter.d/openclaw.conf

sudo systemctl restart fail2ban
```

---

## 🛡️ PHASE 3 - HARDENING (1-4 semaines)

### 7. AppArmor Profile (3h)
```bash
# Créer profile AppArmor
sudo tee /etc/apparmor.d/docker-openclaw << 'EOF'
#include <tunables/global>

profile docker-openclaw flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  capability setuid,
  capability setgid,
  capability dac_override,
  
  deny network raw,
  deny capability sys_admin,
  
  /usr/bin/node ix,
  /app/** r,
  /workspace/** rw,
  /config/** rw,
  /tmp/** rw,
  
  deny /proc/sys/** w,
  deny /sys/** w,
}
EOF

sudo apparmor_parser -r /etc/apparmor.d/docker-openclaw
```

### 8. Audit logging (2h)
```bash
# Configurer auditd pour OpenClaw
sudo apt install auditd

# Monitorer accès OpenClaw
sudo auditctl -w /home/cherubin/.openclaw/ -p rwxa -k openclaw_access
sudo auditctl -w /usr/bin/openclaw -p x -k openclaw_exec

# Voir logs
sudo ausearch -k openclaw_access
```

---

## 📊 CHECKLIST DE SUIVI

### Semaine 1
- [ ] Mise à jour vers v2026.1.29+ ✓
- [ ] Firewall configuré ✓
- [ ] Tokens révoqués ✓
- [ ] mDNS désactivé ✓
- [ ] Docker sécurisé
- [ ] Monitoring actif

### Semaine 2
- [ ] AppArmor profile
- [ ] Audit logging
- [ ] Backup automatisé
- [ ] Test de restauration
- [ ] Documentation procédures

### Semaine 3
- [ ] Test de pénétration
- [ ] Revue de code
- [ ] Formation équipe
- [ ] Procédures incident
- [ ] Plan de continuité

---

## 🚨 CONTACTS D'URGENCE

**En cas de compromission:**
1. Déconnecter immédiatement le service
2. Contacter l'équipe de sécurité
3. Préserver les logs pour analyse
4. Suivre le plan d'incident

**Scripts d'urgence préparés:**
- `emergency_shutdown.sh` - Arrêt immédiat
- `log_preservation.sh` - Sauvegarde preuves
- `network_isolation.sh` - Isolement réseau

---

**Prochaine revue:** Dans 7 jours
**Statut actuel:** 🔴 CRITIQUE - Phase 1 en cours