# `LLVM-9`

## Add fresh submodule

```sh
# Add new
git submodule add -b release/9.x --name llvm-9-src-for-polymer-pluto https://github.com/llvm/llvm-project.git llvm-9-src-for-polymer-pluto

# .gitmodules looks like
[submodule "llvm-9-src-for-polymer-pluto"]
	path = llvm-9-src-for-polymer-pluto
	url = https://github.com/llvm/llvm-project.git
	branch = release/9.x
```

##  Deinit

```sh
git submodule deinit -f -- llvm-9-src-for-polymer-pluto

# reloading again
git submodule update --init -- llvm-9-src-for-polymer-pluto
```

##  Remove completely

```sh
# Remove Completely
git rm -f llvm-9-src-for-polymer-pluto/

rm -Rf .git/modules/llvm-9-src-for-polymer-pluto
```