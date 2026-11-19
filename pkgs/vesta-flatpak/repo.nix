# The OSTree repo built by flatpak-builder (see org.jp_minerals.VESTA.yml).
# Git doesn't track empty directories that OSTree needs, so recreate them.
# It only holds the wrapper; VESTA itself is fetched at install time.
{ runCommand }:
runCommand "vesta-flatpak-repo" { } ''
  cp -r ${./repo} $out
  chmod -R u+w $out
  mkdir -p $out/{extensions,state,tmp/cache,refs/remotes,refs/mirrors}
''
