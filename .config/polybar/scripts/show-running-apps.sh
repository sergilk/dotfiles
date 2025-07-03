#!/usr/bin/env bash

# Define the path to the color configuration file
COLORS_INI_FILE="$HOME/.config/polybar/scripts/show-running-apps.ini"

# Getting icon and color from the config file
get_icon_and_color() {
  app_name="$1"
  icon=$(awk -F '=' '/^\['$app_name'\]/{flag=1;next} /icon/{if(flag) {print $2; exit}}' $COLORS_INI_FILE)
  color=$(awk -F '=' '/^\['$app_name'\]/{flag=1;next} /color/{if(flag) {print $2; exit}}' $COLORS_INI_FILE)

  # If no icon or color is found, use defaults
  if [ -z "$icon" ]; then
    icon=""
  fi
  if [ -z "$color" ]; then
    color="#FFFFFF"
  fi

  echo "$icon:$color"
}

active_ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused).name')

sub=( "" "₁" "₂" "₃" "₄" "₅" "₆" "₇" "₈" "₉" "₁₀" )

  # Manage gap & padding values
  separator="%{O3}"              
  workspace_separator="%{O3}"   
  icon_padding="%{O10}"   
        
i3-msg -t get_tree | jq -c '
  def nodes: .nodes + .floating_nodes;
  recurse(nodes[]) |
  if .type == "workspace" then
    {
      ws: .name,
      classes: [recurse(.nodes[]?) | select(.window_properties?.class?) | .window_properties.class]
    }
  else empty end
' | while read -r ws_entry; do
  ws=$(echo "$ws_entry" | jq -r '.ws')
  mapfile -t classes < <(echo "$ws_entry" | jq -r '.classes[]')

  declare -A class_count=()
  for class in "${classes[@]}"; do
    key="${class,,}"
    class_count["$key"]=$(( ${class_count["$key"]} + 1 ))
  done

  elements=()
  for class in "${!class_count[@]}"; do
    count=${class_count[$class]}
    suffix=""
    (( count > 1 && count < ${#sub[@]} )) && suffix="${sub[$count]}"
    icon_color=$(get_icon_and_color "$class")
    icon="${icon_color%%:*}"
    color="${icon_color##*:}"

    # Icons padding
    icon_with_padding="$icon_padding$icon$icon_padding"

    element="%{F$color}%{A1:i3-msg workspace \"$ws\":}$icon_with_padding$suffix%{A}%{F-}"
    elements+=("$element")
  done

  # Underline the open app icons on the active workspace
  if [[ "$ws" == "$active_ws" ]]; then
    echo -n "%{u#bc99ed}%{+u}"
  fi

  # Display elems with defined gaps between icons
  for (( i=0; i<${#elements[@]}; i++ )); do
    echo -n "${elements[$i]}"
    (( i < ${#elements[@]} - 1 )) && echo -n "$separator"
  done

  if [[ "$ws" == "$active_ws" ]]; then
    echo -n "%{-u}"
  fi

  # Workspaces gap
  echo -n "$workspace_separator"

  unset class_count elements
done

echo
