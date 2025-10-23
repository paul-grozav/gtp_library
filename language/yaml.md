## Yet Another Markup Language - YAML
The extension `.yaml` is preferred, not `.yml`.

## `yq` versions
### Python version
Just a wrapper on top of `jq`
```
$ pip install --user yq
$ yq --version
yq 3.4.3
```
### Mike Farah's version
More complex, written in Go
```sh
$ wget https://github.com/mikefarah/yq/releases/latest/download/yq_$(uname -s | tr '[:upper:]' '[:lower:]')_amd64 -O ./yq
$ chmod u+x ./yq

$ ./yq --version
yq (https://github.com/mikefarah/yq/) version v4.48.1
```

## Working with yaml `yq`
### Extract document object from file
Documents are separated by `---`:
```sh
$ cat x.yaml
a: document
with: |
  multiple
  lines
---
the: second
document:
- has
- more
- lines

$ cat x.yaml | yq -y '. | select(.the == "second")'
the: second
document:
  - has
  - more
  - lines
```
### Extract object with dot in name
```sh
$ cat x.yaml
the: second
document:
  tls.key: |
    --- Begin Public Key ---
    This is a FAKE key
    --- End Public Key ---
  tls:
    other: things
$ cat x.yaml | yq -r '.document."tls.key"'
--- Begin Public Key ---
This is a FAKE key
--- End Public Key ---

# Note that tls doesn't contain the key property !
$ cat x.yaml | yq -ry '.document.tls'
other: things
```

# Filtered patching
Only `.spec` needs to be pushed from environment A to B.
```sh
$ cat a.yaml
spec:
  version: 5.9
  except: |
    Hello
    World: sphere
metadata:
 x: box
$ cat b.yaml
spec:
  version: 5.8
  except: |
    Hello
    World: cube
metadata:
 x: boxy

# Show diff
$ diff -u <(yq -y .spec a.yaml) <(yq -y .spec b.yaml)
--- /dev/fd/63  2025-10-18 12:58:34.434456561 +0000
+++ /dev/fd/62  2025-10-18 12:58:34.434456561 +0000
@@ -1,6 +1,6 @@
-version: 5.9
+version: 5.8
 except: 'Hello

-  World: sphere
+  World: cube

   '
$ yq -y ".spec = $(yq -r '.spec | @json' a.yaml)" b.yaml
spec:
  version: 5.9
  except: 'Hello

    World: sphere

    '
metadata:
  x: boxy

# The problem here is that the literal style (the |) cannot be preserved
# So we'll use Mike's yq
$ ./yq eval-all 'select(fileIndex==0) as $a | select(fileIndex == 1) | .spec = $a.spec' a.yaml b.yaml
spec:
  version: 5.9
  except: |
    Hello
    World: sphere
metadata:
  x: boxy
```
