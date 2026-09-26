{
  total += $1
  printf "%s\t%s KB\n", $2, $1
}
END {
  printf "TOTAL\t%d KB\n", total
}
