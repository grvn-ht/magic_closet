FROM grafana/grafana:v10.2.2

USER root

COPY grafana.key /etc/grafana/grafana.key
COPY grafana.crt /etc/grafana/grafana.crt

RUN chmod 400 /etc/grafana/grafana.key /etc/grafana/grafana.crt

ENTRYPOINT [ "/run.sh" ]