FROM grafana/grafana:master

COPY grafana.key /etc/grafana/grafana.key
COPY grafana.crt /etc/grafana/grafana.crt

RUN sudo chown grafana:grafana grafana.crt
RUN sudo chown grafana:grafana grafana.key
RUN sudo chmod 400 grafana.key grafana.crt

ENTRYPOINT [ "/run.sh" ]