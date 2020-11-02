#
# Create MySQL databases, users and privileges
#

mysql_root_user:
  mysql_user.present:
    - host: "localhost"
    - name: root
    - password: "mate20mg"

{%- from 'settings/init.sls' import settings with context %}
{%- for environment, environment_details in settings.environments.items() %}
{%- for store in pillar.stores %}

# create database - zed
mysql_database_{{ store }}_{{ environment }}_zed:
  mysql_database.present:
    - name: {{ settings.environments[environment].stores[store].zed.database.database }}
    - connection_host: "localhost"
    - connection_user: root
    - connection_pass: "mate20mg"
    - require:
      - pkg: mysql_python_pkgs
{% if salt['pillar.get']('hosting:external_mysql', '') == '' %}
      - service: mysqld
{% endif %}

# create database - dump
mysql_database_{{ store }}_{{ environment }}_zed_dump:
  mysql_database.present:
    - name: {{ settings.environments[environment].stores[store].dump.database.database }}
    - connection_host: "localhost"
    - connection_user: root
    - connection_pass: "mate20mg"
    - require:
      - pkg: mysql_python_pkgs
{% if salt['pillar.get']('hosting:external_mysql', '') == '' %}
      - service: mysqld
{% endif %}

# create database user
mysql_users_{{ store }}_{{ environment }}:
  mysql_user.present:
    - name: {{ settings.environments[environment].stores[store].zed.database.username }}
    - host: "{{ salt['pillar.get']('hosting:mysql_network', '%') }}"
    - password: {{ settings.environments[environment].stores[store].zed.database.password }}
    - connection_host: "localhost"
    - connection_user: root
    - connection_pass: "mate20mg"
    - connection_charset: utf8
    - require:
      - pkg: mysql_python_pkgs
{% if salt['pillar.get']('hosting:external_mysql', '') == '' %}
      - service: mysqld
{% endif %}

# create database permissions (zed database)
mysql_grants_{{ store }}_{{ environment }}_zed:
  mysql_grants.present:
    - grant: all
    - database: {{ settings.environments[environment].stores[store].zed.database.database }}.*
    - user: {{ settings.environments[environment].stores[store].zed.database.username }}
    - host: "{{ salt['pillar.get']('hosting:mysql_network', '%') }}"
    - connection_host: "localhost"
    - connection_user: root
    - connection_pass: "mate20mg"

# create database permissions (dump database)
mysql_grants_{{ store }}_{{ environment }}_zed_dump:
  mysql_grants.present:
    - grant: all
    - database: {{ settings.environments[environment].stores[store].dump.database.database }}.*
    - user: {{ settings.environments[environment].stores[store].zed.database.username }}
    - host: "{{ salt['pillar.get']('hosting:mysql_network', '%') }}"
    - connection_host: "localhost"
    - connection_user: root
    - connection_pass: "mate20mg"
{% endfor %}
{% endfor %}