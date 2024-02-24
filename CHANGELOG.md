# CHANGELOG

## Key notes - PLEASE READ

1. Detailed changes available at the [GitHub repository's commit history](https://github.com/patschi/parsedmarc-dockerized/commits/master).
2. These are rolling changes. There won't be a specific version number.
3. Please closely read any migration/update notes before updating. Certain manual intervention might be needed.

## Log

- 2024-02-24
  - General project hygiene:
    - Updated README: added troubleshooting section, using new docker compose method, new wording, etc
    - Added this CHANGELOG file
    - Added renovate
    - Updated dependencies
  - Updated sample configuration with more notes and settings of parsedmarc, also moved settings in ini-file to prevent deprecation messages
  - Make port binding configurable via environment variable (#3)
  - Updated elasticsearch and kibana to 7.17.18, also fixes security vulnerabilites in older versions (#18)
  - Adding further OS dependencies `python3-gi python3-gi-cairo gir1.2-secret-1` to hopefully fix msgraph implementation (#8)

- 2022-06-11
  - Switch from GeoLite2-City to GeoLite2-Country, as only country-based geolocation is used. Efficiency. (#5)

- 2020-08-09
  - Initial release.
