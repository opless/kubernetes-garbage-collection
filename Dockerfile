FROM bitnami/kubectl
COPY --chmod=755 gc.sh /usr/local/bin
ENTRYPOINT ["/bin/bash","gc.sh"]
