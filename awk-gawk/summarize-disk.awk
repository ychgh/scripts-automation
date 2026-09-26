{
  size = $1
  $1 = ""
  sub(/^ +/, "", $0)
  if ($0 == "." || $0 == "./") {
    next
  }
  total += size
  printf "%s\t%s KB\n", $0, size
}
END {
  printf "TOTAL\t%d KB\n", total
}
