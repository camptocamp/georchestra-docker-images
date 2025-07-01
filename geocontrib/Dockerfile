FROM neogeo/geocontrib:5.4.7

ENTRYPOINT [ "src/docker/geocontrib/docker-entrypoint.sh" ]
CMD        [ "gunicorn","-w 3","-b 0.0.0.0:5000", "--timeout 300", "config.wsgi:application" ]
