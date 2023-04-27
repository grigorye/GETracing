FROM grigorye/ge-workflows AS mint-builder

COPY Mintfile ./
RUN mint bootstrap

FROM grigorye/ge-workflows AS runner

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY Pipfile Pipfile.lock ./
RUN pipenv install

COPY --from=mint-builder /root/.mint /root/.mint
