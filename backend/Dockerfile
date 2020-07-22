FROM bitwalker/alpine-elixir-phoenix:latest

# Set exposed ports
EXPOSE 5000
ENV PORT=5000 MIX_ENV=prod

RUN useradd -ms /bin/bash admin
RUN chown -R admin:admin .
RUN chmod 755 .


# Cache elixir deps
ADD mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

ADD . .

USER admin

CMD ["mix", "phx.server"]
