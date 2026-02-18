# Client Deployment Checklist

## Infrastructure
[ ] New Hetzner project created

[ ] VPS labeled correctly

[ ] Snapshot baseline created

## Access Control
[ ] Unique SSH keypair generated

[ ] Root login disabled

[ ] Password auth disabled

[ ] UFW active (only 80/443 open)

## DNS
[ ] A record points to correct VPS IP

[ ] dig confirms correct resolution

## Application
[ ] compose.yml matches baseline template

[ ] .env created from .env.example

[ ] Unique N8N_ENCRYPTION_KEY generated

[ ] Unique Postgres password generated

[ ] Stack deployed successfully

## Validation
[ ] HTTPS certificate issued

[ ] docker restart test passed

[ ] No SQLite file present

[ ] Postgres tables verified

## Backups
[ ] Age key generated and secured

[ ] rclone remote configured

[ ] Manual backup test completed

[ ] Restore test successful

[ ] Healthcheck success ping confirmed

## Monitoring
[ ] HTTPS uptime monitor configured

[ ] Alert channel verified

## Documentation
[ ] Credentials stored in password manager
[ ] Client vault created
[ ] Backup key stored securely
