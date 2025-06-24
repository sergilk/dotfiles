#!/bin/bash

i3-msg -t get_tree | jq -r '
  recurse(.nodes[]?) |
  select(.window_properties?.class?) |
  .window_properties.class
' | sort -u | while read -r class; do
  echo -n "$class • "
done

echo
