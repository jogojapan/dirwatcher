# dirwatcher
A system that monitors a directory for new files and moves them to a
different directory when they are at least 1 min old.

I use this for the Samba-mounted directory that my scanner puts the
PDF file into that result from scanning. When it scans multiple pages,
it puts a first version into that directory, but later keeps adding to
it. I want to make sure I move the file into the `consume` directory
of my paperless-ngx only when it no longer changes. That's what I use
this docker image for.

## Building the image
You can build the image in the usual way:

``` bash
docker build -t dirwatcher:latest .
```

## Running the container
You can use docker directly:

``` bash
docker run -v /path/to/source:/data/source -v /path/to/destination:/data/destination dirwatcher
```

Or you modify the `volumes` in the `docker-compose.yml` and then use that:

``` bash
docker-compose up -d
```
