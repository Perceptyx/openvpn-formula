# This is the main state file for configuring openvpn.

{% from "openvpn/map.jinja" import map with context %}

include:
  - openvpn.service

# Install openvpn packages
openvpn_pkgs:
  pkg.installed:
    - pkgs:
      {% for pkg in map.pkgs %}
      - {{pkg }}
      {% endfor %}

# Generate diffie hellman files
{% for dh in map.dh_files %}
openvpn_create_dh_{{ dh }}:
  cmd.run:
    - name: openssl dhparam -out {{ map.conf_dir }}/dh{{ dh }}.pem {{ dh }}
    - creates: {{ map.conf_dir }}/dh{{ dh }}.pem
    - require:
      - pkg: openvpn_pkgs
    - watch_in:
{% if salt['grains.has_value']('systemd') %}
{% for type, names in salt['pillar.get']('openvpn', {}).items() %}
{% if type in ['client', 'server', 'peer'] %}
{% for name in names %}
      - service: openvpn_{{name}}_service
{% endfor %}
{% endif %}
{% endfor %}
{% else %}
      - service: openvpn_service
{% endif %}
{% endfor %}
