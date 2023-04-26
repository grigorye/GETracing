FROM grigorye/ge-workflows

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY Mintfile ./
RUN mint bootstrap

COPY Pipfile Pipfile.lock ./
RUN pipenv install
