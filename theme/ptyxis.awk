# Convert one Ptyxis palette section to Alacritty (stdout) and tmux (-v tmux=path).

function color(value) {
  sub(/^[[:space:]]+/, "", value)
  sub(/[[:space:]]+$/, "", value)
  if (value !~ /^#[[:xdigit:]]+$/ || (length(value) != 7 && length(value) != 9))
    invalid = 1
  return substr(value, 1, 7)
}

function channel(value, offset, digits) {
  digits = "0123456789ABCDEF"
  return (index(digits, toupper(substr(value, offset, 1))) - 1) * 16 + \
         (index(digits, toupper(substr(value, offset + 1, 1))) - 1)
}

function hex_byte(value, digits) {
  digits = "0123456789ABCDEF"
  return substr(digits, int(value / 16) + 1, 1) substr(digits, value % 16 + 1, 1)
}

function mix(from, to, amount, red, green, blue) {
  red = int(channel(from, 2) * (1 - amount) + channel(to, 2) * amount + 0.5)
  green = int(channel(from, 4) * (1 - amount) + channel(to, 4) * amount + 0.5)
  blue = int(channel(from, 6) * (1 - amount) + channel(to, 6) * amount + 0.5)
  return "#" hex_byte(red) hex_byte(green) hex_byte(blue)
}

function is_light(value) {
  return 299 * channel(value, 2) + 587 * channel(value, 4) + 114 * channel(value, 6) >= 128000
}

/^\[/ {
  section = substr($0, 2, length($0) - 2)
  next
}

section == wanted {
  separator = index($0, "=")
  if (!separator)
    next

  key = substr($0, 1, separator - 1)
  sub(/^[[:space:]]+/, "", key)
  sub(/[[:space:]]+$/, "", key)
  if (key == "Background" || key == "Foreground" || key == "Cursor" ||
      key ~ /^Color([0-9]|1[0-5])$/)
    value[key] = color(substr($0, separator + 1))
}

END {
  required[1] = "Background"
  required[2] = "Foreground"
  for (i = 0; i < 16; i++)
    required[i + 3] = "Color" i
  for (i = 1; i <= 18; i++)
    if (!value[required[i]])
      invalid = 1

  if (invalid) {
    print "theme: invalid Ptyxis palette" > "/dev/stderr"
    exit 1
  }

  name[0] = "black"
  name[1] = "red"
  name[2] = "green"
  name[3] = "yellow"
  name[4] = "blue"
  name[5] = "magenta"
  name[6] = "cyan"
  name[7] = "white"

  print "[colors.primary]"
  printf "background = \"%s\"\nforeground = \"%s\"\n", value["Background"], value["Foreground"]
  print "\n[colors.cursor]"
  printf "cursor = \"%s\"\ntext = \"CellBackground\"\n", value["Cursor"] ? value["Cursor"] : value["Foreground"]
  print "\n[colors.selection]"
  printf "background = \"%s\"\ntext = \"%s\"\n", value["Color3"], value["Background"]
  print "\n[colors.hints.start]"
  printf "foreground = \"%s\"\nbackground = \"%s\"\n", value["Background"], value["Color4"]
  print "\n[colors.hints.end]"
  printf "foreground = \"%s\"\nbackground = \"%s\"\n", value["Background"], value["Color4"]
  print "\n[colors.normal]"
  for (i = 0; i < 8; i++)
    printf "%-7s = \"%s\"\n", name[i], value["Color" i]
  print "\n[colors.bright]"
  for (i = 0; i < 8; i++)
    printf "%-7s = \"%s\"\n", name[i], value["Color" (i + 8)]

  primary[0] = value["Background"]
  # Light palettes do not assign stable surface roles to the ANSI black/white slots.
  if (is_light(value["Background"])) {
    primary[1] = mix(value["Background"], value["Foreground"], 0.10)
    primary[2] = mix(value["Background"], value["Foreground"], 0.16)
  } else {
    primary[1] = value["Color0"]
    primary[2] = value["Color8"]
  }
  primary[3] = value["Foreground"]
  primary[4] = value["Color4"]
  primary[5] = value["Color1"]
  primary[6] = value["Color3"]
  primary[7] = value["Color2"]
  primary[8] = value["Color6"]
  primary[9] = value["Color5"]
  for (i = 0; i < 10; i++)
    printf "set -g @primary%d \"%s\"\n", i, primary[i] > tmux
  close(tmux)
}
