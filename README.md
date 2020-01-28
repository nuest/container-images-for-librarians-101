# Container images for librarians 101

Conference: https://vickysteeves.gitlab.io/librarians-reproducibility/

Slides: https://doi.org/10.17605/OSF.IO/XTA6D

_This repository contains a toy example of a "scientific workflow" to create a simple container, that can be exported and then investigated as a "historic artefact"._

## 1. Build an image from a Dockerfile

```bash
docker build --tag cifl101 .
```

## 2. Run the container

```bash
docker run --rm -it cifl101
```

Output:

```
Done:  10Error in file(file, "rt") : cannot open the connection
Calls: read.csv2 -> read.table -> file
In addition: Warning message:
In file(file, "rt") :
  cannot open file '/data/stuff.csv': No such file or directory
Execution halted
```

_Only works with correct mount_ - a challenge for reproducibility!

```bash
docker run --rm -it --volume $(pwd)/data:/data cifl101
```

Output:

```
Done:  10 
More:  0 
```

## 3. Export the image to a file

```bash
docker save cifl101 --output image.tar
```

The file `image.tar` is not added to this repository.

```
$ du -sh image.tar 
591M    image.tar
```

## 4. Look at the file and it's contents!

Extract and show directory sizes:

```bash
mkdir image-content
tar -xvf image.tar -C image-content
```

```
$ tree -L 2 image-content/
image-content/
├── 26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891
│   ├── json
│   ├── layer-content
│   ├── layer.tar
│   └── VERSION
├── 29f44b8199e63b0ffd64d4dfdd912a9cac53e42cd9c01fa0b48d164bb6ebcadf
│   ├── json
│   ├── layer-content
│   ├── layer.tar
│   └── VERSION
├── 3b699800373f874fa828e4e8001fae7c63cf1b8df90f40435ec4a785e0d3a11c.json
├── 425b37231d02dadeaf076f01185c6a8a747a3700f2b1a810c472f734e3d64302
│   ├── json
│   ├── layer-content
│   ├── layer.tar
│   └── VERSION
├── 87a7bb06b556c7780e7acb54f72c4580b08cfbd0c2c2cd429cfed1c7be092b1d
│   ├── json
│   ├── layer-content
│   ├── layer.tar
│   └── VERSION
├── b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88
│   ├── json
│   ├── layer-content
│   ├── layer.tar
│   └── VERSION
├── manifest.json
└── repositories

10 directories, 18 files
```

Of the extracted files, the JSON files were pretty-printed and the contents of the `image.tar` files were extracted locally to `image-content/` directories in each layer.
The `image-content/` directories content are only committed for small layers:

```
$ du -sh image-content/*
212M    image-content/26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891
28K     image-content/29f44b8199e63b0ffd64d4dfdd912a9cac53e42cd9c01fa0b48d164bb6ebcadf
12K     image-content/3b699800373f874fa828e4e8001fae7c63cf1b8df90f40435ec4a785e0d3a11c.json
980K    image-content/425b37231d02dadeaf076f01185c6a8a747a3700f2b1a810c472f734e3d64302
24K     image-content/87a7bb06b556c7780e7acb54f72c4580b08cfbd0c2c2cd429cfed1c7be092b1d
996M    image-content/b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88
4,0K    image-content/manifest.json
4,0K    image-content/repositories
```

Extract each `layer` tar into `layer-content` directories:

```bash
mkdir layer-content
tar -xvf layer.tar -C layer-content/
```

The contents of the largest layers (`26e..` and `b6f0..`) were saved into files `layer.tar.txt`.
They are from the base image, see Dockerfile at https://github.com/rocker-org/rocker-versioned/blob/master/r-ver/3.6.0.Dockerfile, from the instructions `FROM debian:stretch` and the large `RUN ...` instruction.

```bash
cd image-content/b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88/
tree . > layer.tar.txt
cd ..
cd 26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891/
tree . > layer.tar.txt
```

The files `layer.tar` in these directories were removed and then replaced with empty files for illustration in the file tree.

```
$ rm 26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891/layer.tar b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88/layer.tar
$ touch 26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891/layer.tar b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88/layer.tar
$ ls -l 26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891/layer.tar b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88/layer.tar
-rw-r--r-- 1 daniel daniel 0 Jan 29 00:29 26e155e18a6f75d70941b74e25a461e9202672a5cb5ccd0374535eb0b7151891/layer.tar
-rw-r--r-- 1 daniel daniel 0 Jan 29 00:29 b6f0f247fc1c315142888ef23d9dbfcd7da2f0ef1f4ebe4e039bec068ea64c88/layer.tar
```

**Look at individual layers created by the Dockerfile**

- `425b37231d02dadeaf076f01185c6a8a747a3700f2b1a810c472f734e3d64302` contains the result of `install2.r here`
- `...`

## Next steps

- Try out image squashing/flattening to get all layers into the local filesystem tree
- Play around with `docker inspect` and how the layers are stored on the local storage (somewhere in `/var/lib/docker/..`)

## License

Creative Commons Zero v1.0 Universal, see file `LICENSE`.

