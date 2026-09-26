{
  size = $1
  $1 = ""
  path = $0
  sub(/^ +/, "", path)
  gsub(/\/+$/, "", path)
  if (path == "." || path == "") {
    next
  }
  sub(/^\.\//, "", path)

  split(path, parts, "/")
  top = parts[1]
  if (!(top in seen)) {
    seen[top] = 1
    order[++count] = top
  }

  totals[top] += size
}
END {
  grand_total = 0
  for (i = 1; i <= count; i++) {
    name = order[i]
    value = totals[name]
    grand_total += value
    printf "%s\t%d KB\n", name, value
  }
  printf "TOTAL\t%d KB\n", grand_total
}
