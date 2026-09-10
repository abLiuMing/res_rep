#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  echo "usage: $0 <manifest> <download-dir> <output-dir>" >&2
  exit 2
fi

manifest=$1
download_dir=$2
output_dir=$3
staging_dir="${output_dir}.new"
rm -rf "$staging_dir"
mkdir -p "$staging_dir"

cp "$(dirname "$manifest")/../configs/effect.json" "$staging_dir/effect.json"
while read -r name version artifact checksum; do
  case "$name" in ''|'#'*) continue ;; esac
  source_file="$download_dir/$artifact"
  [ -f "$source_file" ] || { echo "missing resource: $source_file" >&2; exit 1; }
  cp "$source_file" "$staging_dir/${name}-${version}.bin"
done < "$manifest"

rm -rf "$output_dir"
mv "$staging_dir" "$output_dir"
echo "resources built in $output_dir"
