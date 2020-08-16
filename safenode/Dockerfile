FROM safecoin/safecoin

COPY setup-safenode.sh /usr/bin/setup-safenode.sh
COPY docker-entrypoint.sh /usr/bin/docker-entrypoint-safenode.sh

ENTRYPOINT ["docker-entrypoint-safenode.sh"]