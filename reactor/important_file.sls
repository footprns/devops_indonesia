put_important_file:
  local.state.single:
    - tgt: 'kernel:Linux'
    - tgt_type: grain
    - args:
      - fun: file.managed
      - name: /etc/important_file
      - contents: |
          This is important file