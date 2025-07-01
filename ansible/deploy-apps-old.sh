---
# deploy-apps.yml - Déploiement simple sur 3 instances

- name: Configuration de la base de données
    hosts: database
    become: yes
    
    tasks:
        - name: Installer MySQL
        apt:
            name: mysql-server
            state: present
            update_cache: yes
            
        - name: Configurer MySQL pour écouter sur toutes les interfaces
        lineinfile:
            path: /etc/mysql/mysql.conf.d/mysqld.cnf
            regexp: '^bind-address'
            line: 'bind-address = 0.0.0.0'
            
        - name: Redémarrer MySQL
        systemd:
            name: mysql
            state: restarted
            
        - name: Créer la base de données
        mysql_db:
            name: appdb
            state: present
            login_unix_socket: /var/run/mysqld/mysqld.sock

- name: Configuration du backend
    hosts: backend
    become: yes
    
    vars:
        backend_port: 3000
        mysql_host: "{{ hostvars['database']['ansible_default_ipv4']['address'] }}"
        
    tasks:
        - name: Installer Node.js et NPM
        apt:
            name: nodejs, npm
            state: present
            update_cache: yes
            
        - name: Installer PM2
        npm:
            name: pm2
            global: yes
            
        - name: Créer le dossier de l'application
        file:
            path: /var/www/backend
            state: directory
            owner: ubuntu
            group: ubuntu
            
        - name: Créer un fichier de test backend
        copy:
            content: |
            const express = require('express');
            const app = express();
            
            app.use(express.json());
            
            app.get('/api', (req, res) => {
                res.json({ message: 'Hello from Backend!', timestamp: new Date() });
            });
            
            app.get('/api/health', (req, res) => {
                res.json({ status: 'healthy', mysql: '{{ mysql_host }}' });
            });
            
            app.listen({{ backend_port }}, () => {
                console.log('Backend running on port {{ backend_port }}');
            });
            dest: /var/www/backend/app.js
            owner: ubuntu
            
        - name: Installer Express
        npm:
            name: express
            path: /var/www/backend
            
        - name: Démarrer l'application avec PM2
        become_user: ubuntu
        shell: |
            cd /var/www/backend
            pm2 start app.js --name backend
            pm2 save
            pm2 startup systemd -u ubuntu --hp /home/ubuntu

- name: Configuration du frontend
    hosts: frontend
    become: yes
    
    vars:
        backend_url: "http://{{ hostvars['backend']['ansible_default_ipv4']['address'] }}:3000"
        
    tasks:
        - name: Installer Nginx
        apt:
            name: nginx
            state: present
            update_cache: yes
            
        - name: Créer une page d'accueil
        copy:
            content: |
            <!DOCTYPE html>
            <html>
            <head>
                <title>DevOps Project</title>
                <style>
                    body { font-family: Arial; padding: 50px; text-align: center; }
                    .box { background: #f0f0f0; padding: 20px; margin: 20px auto; max-width: 600px; }
                    .status { color: green; }
                </style>
            </head>
            <body>
                <h1>🚀 Application DevOps</h1>
                <div class="box">
                    <h2>Frontend ✅</h2>
                    <p>Nginx serving React app</p>
                </div>
                <div class="box">
                    <h2>Backend API</h2>
                    <p id="api-status">Checking...</p>
                </div>
                <script>
                    fetch('/api/health')
                        .then(r => r.json())
                        .then(data => {
                            document.getElementById('api-status').innerHTML = 
                                '<span class="status">✅ Connected</span><br>' +
                                'MySQL: ' + data.mysql;
                        })
                        .catch(e => {
                            document.getElementById('api-status').innerHTML = '❌ Error: ' + e;
                        });
                </script>
            </body>
            </html>
            dest: /var/www/html/index.html
            
        - name: Configurer Nginx pour proxy vers le backend
        copy:
            content: |
            server {
                listen 80 default_server;
                listen [::]:80 default_server;
                
                root /var/www/html;
                index index.html;
                
                server_name _;
                
                location / {
                    try_files $uri $uri/ =404;
                }
                
                location /api {
                    proxy_pass {{ backend_url }};
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection 'upgrade';
                    proxy_set_header Host $host;
                    proxy_cache_bypass $http_upgrade;
                }
            }
            dest: /etc/nginx/sites-available/default
            
        - name: Redémarrer Nginx
        systemd:
            name: nginx
            state: restarted
            
        - name: Afficher les URLs
        debug:
            msg:
            - "✅ Déploiement terminé !"
            - "🌐 Frontend : http://{{ ansible_host }}"
            - "🔌 API : http://{{ ansible_host }}/api"