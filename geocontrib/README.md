# About

Temporary code which builds a customized version on geocontrib ; the only
modification compared to upstream is that the default timeout (30s) has
been increased to 300s.

See [GSEST-576](https://camptocamp.atlassian.net/browse/GSEST-576) for the
context.

The LDAP tree in the DataGrandEst project contains too many users to leave
geocontrib a chance to finish when the synchronization is launched from
the web ui (then running synchronously).

