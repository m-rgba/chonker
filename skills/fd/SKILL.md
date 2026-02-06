---
name: fd
description: This skill should be used when users ask to locate files or directories by name within the filesystem. It guides on using fd for filesystem navigation, filtering by extension, and executing commands on found files, offering a faster, more user-friendly alternative to find that respects .gitignore patterns by default.
allowed-tools: Bash(fd:*)
---

## How to use

First, to get an overview of all available command line options, you can either run [`fd -h`](#command-line-options) for a concise help message or `fd --help` for a more detailed version.

### Simple search

_fd_ is designed to find entries in your filesystem. The most basic search you can perform is to run _fd_ with a single argument: the search pattern. For example, assume that you want to find an old script of yours (the name included `netflix`):

```bash
> fd netfl
Software/python/imdb-ratings/netflix-details.py
```

If called with just a single argument like this, _fd_ searches the current directory recursively for any entries that _contain_ the pattern `netfl`.

### Regular expression search

The search pattern is treated as a regular expression. Here, we search for entries that start with `x` and end with `rc`:

```bash
> cd /etc
> fd '^x.*rc$'
X11/xinit/xinitrc
X11/xinit/xserverrc
```

The regular expression syntax used by `fd` is [documented here](https://docs.rs/regex/latest/regex/#syntax).

### Specifying the root directory

If we want to search a specific directory, it can be given as a second argument to _fd_:

```bash
> fd passwd /etc
/etc/default/passwd
/etc/pam.d/passwd
/etc/passwd
```

### List all files, recursively

_fd_ can be called with no arguments. This is very useful to get a quick overview of all entries in the current directory, recursively (similar to `ls -R`):

```bash
> cd fd/tests
> fd
testenv
testenv/mod.rs
tests.rs
```

If you want to use this functionality to list all files in a given directory, you have to use a catch-all pattern such as `.` or `^`:

```bash
> fd . fd/tests/
testenv
testenv/mod.rs
tests.rs
```

### Searching for a particular file extension

Often, we are interested in all files of a particular type. This can be done with the `-e` (or `--extension`) option.
Here, we search for all Markdown files in the fd repository:

```bash
> cd fd
> fd -e md
CONTRIBUTING.md
README.md
```

The `-e` option can be used in combination with a search pattern:

```bash
> fd -e rs mod
src/fshelper/mod.rs
src/lscolors/mod.rs
tests/testenv/mod.rs
```

### Searching for a particular file name

To find files with exactly the provided search pattern, use the `-g` (or `--glob`) option:

```bash
> fd -g libc.so /usr
/usr/lib32/libc.so
/usr/lib/libc.so
```

### Hidden and ignored files

By default, _fd_ does not search hidden directories and does not show hidden files in the search results. To disable this behavior, we can use the `-H` (or `--hidden`) option:

```bash
> fd pre-commit
> fd -H pre-commit
.git/hooks/pre-commit.sample
```

If we work in a directory that is a Git repository (or includes Git repositories), _fd_ does not search folders (and does not show files) that match one of the `.gitignore` patterns. To disable this behavior, we can use the `-I` (or `--no-ignore`) option:

```bash
> fd num_cpu
> fd -I num_cpu
target/debug/deps/libnum_cpus-f5ce7ef99006aa05.rlib
```

To really search _all_ files and directories, simply combine the hidden and ignore features to show everything (`-HI`) or use `-u`/`--unrestricted`.

### Matching the full path

By default, _fd_ only matches the filename of each file. However, using the `--full-path` or `-p` option, you can match against the full path.

```bash
> fd -p -g '**/.git/config'
> fd -p '.*/lesson-\d+/[a-z]+.(jpg|png)'
```

### Command execution

Instead of just showing the search results, you often want to _do something_ with them. `fd` provides two ways to execute external commands for each of your search results:

- The `-x`/`--exec` option runs an external command _for each of the search results_ (in parallel).
- The `-X`/`--exec-batch` option launches the external command once, with _all search results as arguments_.

#### Examples

Recursively find all zip archives and unpack them:

```bash
fd -e zip -x unzip
```

If there are two such files, `file1.zip` and `backup/file2.zip`, this would execute `unzip file1.zip` and `unzip backup/file2.zip`. The two `unzip` processes run in parallel (if the files are found fast enough).

Find all `*.h` and `*.cpp` files and auto-format them inplace with `clang-format -i`:

```bash
fd -e h -e cpp -x clang-format -i
```

Note how the `-i` option to `clang-format` can be passed as a separate argument. This is why we put the `-x` option last.

Find all `test_*.py` files and open them in your favorite editor:

```bash
fd -g 'test_*.py' -X vim
```

Note that we use capital `-X` here to open a single `vim` instance. If there are two such files, `test_basic.py` and `lib/test_advanced.py`, this will run `vim test_basic.py lib/test_advanced.py`.

To see details like file permissions, owners, file sizes etc., you can tell `fd` to show them by running `ls` for each result:

```bash
fd … -X ls -lhd --color=always
```

This pattern is so useful that `fd` provides a shortcut. You can use the `-l`/`--list-details` option to execute `ls` in this way: `fd … -l`.

The `-X` option is also useful when combining `fd` with [ripgrep](https://github.com/BurntSushi/ripgrep/) (`rg`) in order to search within a certain class of files, like all C++ source files:

```bash
fd -e cpp -e cxx -e h -e hpp -X rg 'std::cout'
```

Convert all `*.jpg` files to `*.png` files:

```bash
fd -e jpg -x convert {} {.}.png
```

Here, `{}` is a placeholder for the search result. `{.}` is the same, without the file extension.
See below for more details on the placeholder syntax.

The terminal output of commands run from parallel threads using `-x` will not be interlaced or garbled, so `fd -x` can be used to rudimentarily parallelize a task run over many files.
An example of this is calculating the checksum of each individual file within a directory.

```
fd -tf -x md5sum > file_checksums.txt
```

#### Placeholder syntax

The `-x` and `-X` options take a _command template_ as a series of arguments (instead of a single string).
If you want to add additional options to `fd` after the command template, you can terminate it with a `\;`.

The syntax for generating commands is similar to that of [GNU Parallel](https://www.gnu.org/software/parallel/):

- `{}`: A placeholder token that will be replaced with the path of the search result (`documents/images/party.jpg`).
- `{.}`: Like `{}`, but without the file extension (`documents/images/party`).
- `{/}`: A placeholder that will be replaced by the basename of the search result (`party.jpg`).
- `{//}`: The parent of the discovered path (`documents/images`).
- `{/.}`: The basename, with the extension removed (`party`).

If you do not include a placeholder, _fd_ automatically adds a `{}` at the end.

#### Parallel vs. serial execution

For `-x`/`--exec`, you can control the number of parallel jobs by using the `-j`/`--threads` option.
Use `--threads=1` for serial execution.

### Excluding specific files or directories

Sometimes we want to ignore search results from a specific subdirectory. For example, we might want to search all hidden files and directories (`-H`) but exclude all matches from `.git` directories. We can use the `-E` (or `--exclude`) option for this. It takes an arbitrary glob pattern as an argument:

```bash
> fd -H -E .git …
```

We can also use this to skip mounted directories:

```bash
> fd -E /mnt/external-drive …
```

.. or to skip certain file types:

```bash
> fd -E '*.bak' …
```

To make exclude-patterns like these permanent, you can create a `.fdignore` file. They work like `.gitignore` files, but are specific to `fd`. For example:

```bash
> cat ~/.fdignore
/mnt/external-drive
*.bak
```

> [!NOTE]
> `fd` also supports `.ignore` files that are used by other programs such as `rg` or `ag`.

If you want `fd` to ignore these patterns globally, you can put them in `fd`'s global ignore file.

You may wish to include `.git/` in your `fd/ignore` file so that `.git` directories, and their contents are not included in output if you use the `--hidden` option.

### Deleting files

You can use `fd` to remove all files and directories that are matched by your search pattern.
If you only want to remove files, you can use the `--exec-batch`/`-X` option to call `rm`.
For example, to recursively remove all `.DS_Store` files, run:

```bash
> fd -H '^\.DS_Store$' -tf -X rm
```

If you are unsure, always call `fd` without `-X rm` first. Alternatively, use `rm`s "interactive" option:

```bash
> fd -H '^\.DS_Store$' -tf -X rm -i
```

If you also want to remove a certain class of directories, you can use the same technique. You will have to use `rm`s `--recursive`/`-r` flag to remove directories.

> [!NOTE]
> There are scenarios where using `fd … -X rm -r` can cause race conditions: if you have a
> path like `…/foo/bar/foo/…` and want to remove all directories named `foo`, you can end up in a
> situation where the outer `foo` directory is removed first, leading to (harmless) _"'foo/bar/foo':
> No such file or directory"_ errors in the `rm` call.

### Command-line options

This is the output of `fd -h`. To see the full set of command-line options, use `fd --help` which also includes a much more detailed help text.

```
Usage: fd [OPTIONS] [pattern [path...]]

Arguments:
  [pattern]  the search pattern (a regular expression, unless '--glob' is used; optional)
  [path]...  the root directories for the filesystem search (optional)

Options:
  -H, --hidden                     Search hidden files and directories
  -I, --no-ignore                  Do not respect .(git|fd)ignore files
  -s, --case-sensitive             Case-sensitive search (default: smart case)
  -i, --ignore-case                Case-insensitive search (default: smart case)
  -g, --glob                       Glob-based search (default: regular expression)
  -a, --absolute-path              Show absolute instead of relative paths
  -l, --list-details               Use a long listing format with file metadata
  -L, --follow                     Follow symbolic links
  -p, --full-path                  Search full abs. path (default: filename only)
  -d, --max-depth <depth>          Set maximum search depth (default: none)
  -E, --exclude <pattern>          Exclude entries that match the given glob pattern
  -t, --type <filetype>            Filter by type: file (f), directory (d/dir), symlink (l),
                                   executable (x), empty (e), socket (s), pipe (p), char-device
                                   (c), block-device (b)
  -e, --extension <ext>            Filter by file extension
  -S, --size <size>                Limit results based on the size of files
      --changed-within <date|dur>  Filter by file modification time (newer than)
      --changed-before <date|dur>  Filter by file modification time (older than)
  -o, --owner <user:group>         Filter by owning user and/or group
      --format <fmt>               Print results according to template
  -x, --exec <cmd>...              Execute a command for each search result
  -X, --exec-batch <cmd>...        Execute a command with all search results at once
  -c, --color <when>               When to use colors [default: auto] [possible values: auto,
                                   always, never]
      --hyperlink[=<when>]         Add hyperlinks to output paths [default: never] [possible
                                   values: auto, always, never]
  -C, --base-directory <path>      Change the search path to <path>
  -h, --help                       Print help (see more with '--help')
  -V, --version                    Print version
```

Note that options can be given after the pattern and/or path as well.

## When to use this

- Use this tool when you need to locate files or directories by their name (e.g. `*.py`, `config.json`).
- It is faster and has better defaults than `find` (respects `.gitignore` by default).
- Useful for listing files in a directory recursively.

## When not to use this

- Do NOT use this tool to search for text **content** within files. Use `ripgrep` for that.
- If you need to perform complex actions on found files that `fd`'s `-x`/`-X` doesn't support, standard `find` might be more appropriate, but `fd` handles most cases.
- If you need to search for code based on structural patterns (AST), use `ast-grep`.

## Comparison

- **fd vs find**: `fd` is much faster and provides colored output and smart case sensitivity by default. It also ignores hidden files and `.gitignore` patterns by default, whereas `find` searches everything.
- **fd vs ripgrep**: `fd` searches for **filenames**. `ripgrep` searches for **file content**.
- **fd vs ast-grep**: `fd` searches by filename. `ast-grep` searches by code structure.

| Tool              | Primary Use Case                 | Awareness                             |
| ----------------- | -------------------------------- | ------------------------------------- |
| **fd**            | Finding files by name            | File-system based, respects gitignore |
| **ripgrep (rg)**  | Finding text/regex inside files  | Line-based, respects gitignore        |
| **ast-grep (sg)** | Structural code search & replace | AST-based (understands code syntax)   |
