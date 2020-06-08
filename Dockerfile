FROM ruby:2.7.1-alpine

# set up app root
WORKDIR /root/application

# add packages
# - build-base installs build tools for native gems (req: nokogiri gem)
# - postgresql-dev installs files for building pg frontends (req: pg gem)
# - tzdata is required to avoid tzinfo-data gem installation
RUN apk update && apk add -u build-base yarn postgresql-dev postgresql-client tzdata

# set bundler path
# - if not set, use default (calls `bundle config path` below instead of setting)
# - if set, override default (enable usage of named volumes for gem storage)
ARG bundler_path=

# install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config path ${bundler_path} && bundle install --jobs 20 --retry 5

# install yarn packages
COPY package.json yarn.lock ./
RUN yarn install --check-files

# copy the other app files
COPY . .

# precompile assets
RUN bundle exec rails assets:precompile
