1. update system > `apt update && apt -y upgrade`
2. Install base packages > `apt -y install ca-certificates curl gnupg ufw nano`
3. add user, ssh keys and sudo > `bootstrap_admin.sh`
4. restart ssh> `systemctl restart ssh`
5. Install Docker Engine & Compose > `dockerinstall.sh`
6. Verify Docker installed > `docker --version` `docker compose version`
7. Allow admin to run Docker without sudo > `usermode -aG docker admin`
8. SSH hardening > `nano /etc/ssh/sshd_config` add > `PermitRootLogin no` `PasswordAuthentication no` `PubkeyAuthentication yes`
9. Restart ssh > `systemctl restart ssh`
10. Test login in a second terminal
11. FW UFW > `ufwconfig.sh`
12. Log out root, login admin
13. Verify Docker works > `docker ps`
14. create stack directory structure > `directorylayout_create.sh`
15. Create compose.yml > in github
16. Create Caddyfile > in github
17. Create .env.example > in github
18. Create .env > not in github, never commit, contains secrets > `cp .env.example .env` > `nano .env` > Replace `N8N_DOMAIN` with real domain, `LETSENCRYPT_EMAIL` with real email, and generate strong secrets (three): 
`openssl rand -base64 24` `openssl rand -base64 24` `openssl rand -base64 32` use as: `POSTGRES_PASSWORD` , `N8N_BASIC_AUTH_PASSWORD` , `N8N_ENCRYPTION_KEY` (this is the 32 bit one)

19. Start the stack > `docker compose up -d` and check status `docker compose ps`
20. Validate TLS and reachability > `docker compose logs -f caddy` (certificate issuance succeeed is what we want to see) then test `https://mydomain
21. Confirm it is NOT using DQLite > `docker compose logs n8n | tail -n 200` we want to see postgres
22. Verify postgres has n8n tables > `docker exec -it $(docker ps -q --filter "ancestor=postgres:16-alpine") \ psql -U n8n -d n8n -c '\dt'` you want to see multiple tables

What is commited to github vs what is not:
Commit:
compose.yml
caddy/Caddyfile
.env.example

Do NOT Commit:
.env
postgres/data/
n8n/data/
caddy/data/ 
caddy/config/

Add .gitignore like:
.env
postgres/data/
n8n/data/
caddy/data/
caddy/config/




