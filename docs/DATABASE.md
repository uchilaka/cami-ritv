# CAMI: Database guide

## Creating a `pg_dump` backup

To create a `pg_dump` backup of your local development database, run the following command in your console:

```shell
# -Fc = custom format (necessary for parallel restores)
# -Ox = no ownership
# -f = output file
pg_dump -U <your_db_username> -h localhost -p 16032 -Fc -Ox -f backup.dump <your_db_name>
```
