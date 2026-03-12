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

This project includes two ready-to-use scripts:
1. __Setup script__</br>Prepares the system in the current working directory and makes the environment ready for development.

2. __Start script__</br>Starts the projects located in the current working directory.

### Notes
- The start script currently does not include a use case for handling situations where some projects are missing.
- In `start_all_tmux.sh`, tmux commands can be commented out if only specific projects should be started.
- Because I currently only have access to the limited projects listed in this guide as an intern, this project includes only those specified repositories.
- Additional setup steps and configurations can be added by following the same structure already used in this project.

## Setup Script

how to: 
1. go to your project folder
2. call this script
3. you are done

requirement: `brew install asdf` ve bu guide içinde olan diğer kurulum gereksinimleri </br></br>


this script installs and set all projects to your current folder.

### examples:

```sh
bash ./bootstraping-projects/setup.sh
```
or
```sh
bash ~/parasutcom/bootstraping-projects/setup.sh
```
### another example:
```sh
omeryavas@Omers-MacBook-Pro ~/parasutcom % bash ./bootstraping-projects/setup.sh
#                                           |
#                                           |--> this commands clones and sets all repos in "~/parasutcom" folder
```
## Start Script

how to: 
1. go to your project folder
2. call this script
3. you are done

requirement: `brew install tmux` </br></br>

this script starts the repos in current folder and set tmux settings.

### examples:

```sh
bash ./bootstraping-projects/start_all_tmux.sh
```
or
```sh
bash ~/parasutcom/bootstraping-projects/start_all_tmux.sh
```
### another example:
```sh
omeryavas@Omers-MacBook-Pro ~/parasutcom % bash ./bootstraping-projects/start_all_tmux.sh
#                                           |
#                                           |--> this commands starts all repos in "~/parasutcom" folder
```