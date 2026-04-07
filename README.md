# Fast Guide for Entering Project
## pre-requirements
### in system: 
`redis`, `postgres@14`, `asdf` </br>
you can download them with `brew`.
```sh
brew update && brew install redis postgres@14 asdf
brew services start postgresql
brew services start redis
```
### for `asdf` setup: 
we need these is system: </br>
```sh
xcode-select --install
brew install openssl@3 readline libyaml gmp autoconf
brew install rbenv/tap/openssl@1.1
brew install python
```
just run this commands:
```sh
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf plugin add yarn
echo "legacy_version_file = yes" > $HOME/.asdfrc
echo "legacy_version_file = yes" > ~/.asdfrc
```

### if you have mac arm64
just proceed to our guides about that or search `asdf-ruby` and `asdf-nodejs`github pages for troubleshootings about it. </br>


# FRONTEND
## Client
### bootstrap:
Download or clone the `node_modules` and `bower_components` from github links and copy their content to the clients root folder. </br>
Links of [client-node-modules](https://github.com/parasutcom/client-node-modules) and [client-bower-components](https://github.com/parasutcom/client-bower-components).
```sh
asdf install nodejs 0.11.16 && asdf set nodejs 0.11.16
npm install -g bower
bower install
```
### start:
```sh
./node_modules/ember-cli/bin/ember serve
```

## Trinity
### bootstrap:
```sh
asdf install nodejs 8.16.0 && asdf set nodejs 8.16.0
asdf install yarn 1.21.1 && asdf set yarn 1.21.1
npm install -g bower
bower install
yarn install
echo "API_HOST=http://api.parasut.localhost:3000
LOGIN_HOST=http://uygulama.parasut.localhost:3000
EMBER_HOST=http://localhost:4200
EXPORT_TEMPLATE_HOST=http://uygulama.parasut.localhost:3000
PRINTAP_HOST=http://printap.parasut.localhost:3000
INTEGRATIONS_HOST=http://uygulama.parasut.localhost:3000
FULL_APP_HOST=http://uygulama.parasut.localhost:3000" > .env.development
```
Eğer Shared-Logic üzerinde çalışılacak ise:
### (Optional) Shared-logic bootstrap:
Trinity klasöründe:
```sh
# sed sadece tek satırda iş yapar, ileride bu kural bozulursa yeni yöntem arayın
sed -i '' 's#"shared-logic": ".*"#"shared-logic": "link:../shared-logic"#' package.json
```
Shared Logic klasöründe:
```sh
yarn install
bower install
```

### start (Trinity):
```sh
yarn run ember serve --watcher=polling --polling-interval=1000
```

## Phoenix
### bootstrap:
```sh
asdf plugin add nodejs || true
arch -x86_64 /bin/zsh -lc '
asdf install nodejs 10.15.3
asdf set nodejs 10.15.3
'
asdf plugin add yarn || true
asdf install yarn 1.21.1
asdf set yarn 1.21.1
npm install -g bower
bower install
yarn install
```
### start (Bizmu):
```sh
PROJECT_TARGET=phoenix ./node_modules/ember-cli/bin/ember serve
```
### start (Assist):
```sh
PROJECT_TARGET=companion ./node_modules/ember-cli/bin/ember serve
```
Note: `phoenix-bizmu` and `phoenix-assist` use the same port, so run only one at a time.

# BACKEND
## Server
### bootstrap:
current version of ruby is in .ruby-version or .tool-versions, if you have setted legacy support for asdf, setting asdf is not needed.
```sh
asdf install ruby 2.6.9 && asdf set ruby 2.6.9
bundle install
SEED_E_MIKRO_EINVOICE=true SEED_E_MIKRO_ESMM=true SEED_FORIBA_EINVOICE=true SEED_E_MIKRO_EARCHIVE_ONLY=true SEED_IRGAT_EARCHIVE_ONLY=true bin/bootstrap
```
### start:
```sh
bundle exec puma -C config/puma.rb
```
### sidekiq start:
```sh
bundle exec sidekiq -C config/sidekiq.yml
```

## Billing
## bootstrap:
```sh
asdf install ruby 2.6.7 && asdf set ruby 2.6.7
bundle install
SEED_E_MIKRO_EINVOICE=true SEED_E_MIKRO_ESMM=true SEED_FORIBA_EINVOICE=true SEED_E_MIKRO_EARCHIVE_ONLY=true SEED_IRGAT_EARCHIVE_ONLY=true bin/bootstrap
```
### start:
```sh
rails server -p 4002
```
### sidekiq start:
```sh
bundle exec sidekiq -C config/sidekiq.yml
```

## E-Doc-Broker
### bootstrap:
```sh
asdf install ruby 2.6.6 && asdf set ruby 2.6.6
bundle install
EED_E_MIKRO_EINVOICE=true SEED_E_MIKRO_ESMM=true SEED_FORIBA_EINVOICE=true SEED_E_MIKRO_EARCHIVE_ONLY=true SEED_IRGAT_EARCHIVE_ONLY=true bin/bootstrap
```
### start:
```sh
rails s -p 5002
```

### sidekiq start (foreman):
```sh
foreman start --formation ",sidekiq_inbound=1,sidekiq_outbound=1,sidekiq_storage=1,sidekiq_other=1,sidekiq_send=1"
```

# All start commands:
## Frontend
### Client:
```sh
./node_modules/ember-cli/bin/ember serve
```
### Trinity:
```sh
yarn run ember serve --watcher=polling --polling-interval=1000
```
### Phoenix (Bizmu):
```sh
PROJECT_TARGET=phoenix ./node_modules/ember-cli/bin/ember serve
```
### Phoenix (Assist):
```sh
PROJECT_TARGET=companion ./node_modules/ember-cli/bin/ember serve
```

## Backend
### Server:
start:
```sh
bundle exec puma -C config/puma.rb
```
sidekiq:
```sh
bundle exec sidekiq -C config/sidekiq.yml
```

### Billing:
start:
```sh
rails server -p 4002
```
sidekiq:
```sh
bundle exec sidekiq -C config/sidekiq.yml
```

### E-doc-broker:
start:
```sh
rails s -p 5002
```
sidekiq (foreman):
```sh
foreman start --formation ",sidekiq_inbound=1,sidekiq_outbound=1,sidekiq_storage=1,sidekiq_other=1,sidekiq_send=1"
```

# Included Scripts

This project includes four scripts:
1. __Setup script (`setup.sh`)__</br>Prepares and installs project dependencies in the current working directory.
2. __Start script (`start.sh`)__</br>Starts selected projects in tmux session `parasutcom`.
3. __Stop script (`stop.sh`)__</br>Stops tmux session `parasutcom` and cleans residual project processes.
4. __Legacy start script (`start-all-tmux-legacy.sh`)__</br>Older tmux startup flow kept for backward compatibility.

### Notes
- `start.sh` is the current main entry point.
- `start.sh` can start all default projects or only selected projects by name.
- `phoenix-bizmu` and `phoenix-assist` cannot run together (same port).
- `stop.sh` sends `Ctrl+C` to panes, waits, kills the tmux session, then runs targeted `pkill` cleanup.
- `start-all-tmux-legacy.sh` uses a fixed startup sequence and Phoenix target selection is done by commenting/uncommenting lines in the script.

## Setup Script (`setup.sh`)

how to:
1. go to your project folder
2. call this script
3. you are done

requirement: `brew install asdf` ve bu guide içinde olan diğer kurulum gereksinimleri </br></br>

this script installs and sets all projects in your current folder.

### examples:

```sh
bash ./bootstraping-projects/setup.sh
```
or
```sh
bash ~/parasutcom/bootstraping-projects/setup.sh
```

## Start Script (`start.sh`)

how to:
1. go to your project folder (parent folder that contains repos like `client`, `trinity`, `phoenix`, `server`, ...)
2. call this script
3. tmux session is created/attached

requirement: `brew install tmux` </br></br>

### examples:

```sh
# start default projects:
bash ./bootstraping-projects/start.sh
```

```sh
# start selected projects:
bash ./bootstraping-projects/start.sh client trinity phoenix-bizmu server
```

Available project names:
`client`, `trinity`, `phoenix-bizmu`, `phoenix-assist`, `server`, `billing`, `e-doc-broker`

## Stop Script (`stop.sh`)

Use this when you want to stop all processes started by `start.sh` in tmux session `parasutcom`.

```sh
bash ./bootstraping-projects/stop.sh
```

## Legacy Start Script (`start-all-tmux-legacy.sh`)

This is the old startup script. It is kept for compatibility and manual flow cases.

```sh
bash ./bootstraping-projects/start-all-tmux-legacy.sh
```

Legacy Phoenix note:
- In this legacy script, Bizmu vs Companion target is selected manually by commenting/uncommenting the related `tmux send-keys` line.
