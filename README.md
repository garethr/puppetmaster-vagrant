Vagrant makes playing with Puppet easy, but sometimes just using puppet
apply isn't enough. You might want to experiment with a puppet master, stored
configurations or puppetdb.

This project contains a Puppetfile, Vagrantfile and somewhat messy
manifests that will create a puppetmaster/puppetdb and a client which talks to them.

## Instructions

First, install the dependencies (I'm assuming you have Ruby, Vagrant and
Bundler installed already):

    bundle install

Then use librarian to download the puppet modules

    librarian-puppet install

And finally use vagrant to create the two instances:

    vagrant up

The Puppetdb web interface should be available at localhost:8080, with
the repl available at localhost:8082.

## Then what

You could use this to experiment with puppetdb, test out some stored
configs or just see how Puppet and Vagrant can work together. You'll
probably want to just copy the project and then hack on your own copy.

## Maybe later

I'll tidy up the manifest when I get a chance, it contains a few _just
make it work_ scars like execs, file concats and no internal classes.
