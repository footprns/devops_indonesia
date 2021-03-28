apply on minion1:
  salt.state:
    - tgt: salt-minion-001
    - sls:
        # - state.orchtime
        - apache

apply on minion2:
  salt.state:
    - tgt: salt-minion-002
    - sls:
        # - state.orchtime
        - tomcat