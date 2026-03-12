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

