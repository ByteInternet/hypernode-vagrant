Install the build deps
======================

```
sudo gem install bundler rake rspec simplecov coveralls
```

Create the gemfile (package)
============================

```
$ make
rake build
vagrant-hypconfigmgmt 0.0.11 built to pkg/vagrant-hypconfigmgmt-0.0.11.gem.
```

Installing a locally developed hypconfigmgmt
============================================

1. Bump the version to one later than the latest version

Edit `Vagrantfile` and update `VAGRANT_HYPCONFIGMGMT_VERSION`

Edit `vagrant/plugins/vagrant-hypconfigmgmt/README.md` and update the version there.

Edit `vagrant/plugins/vagrant-hypconfigmgmt/lib/vagrant-hypconfigmgmt/version.rb` and update `VERSION`.

2. Navigate to `vagrant/plugins/vagrant-hypconfigmgmt` and run `make && make install`


Deploying a new vagrant-hypconfigmgmt
=====================================

1. Only for Byte staff members.

2. Do the above, except the `make install` is not necessary

3. Remove the previous latest gem from `vagrant/plugins/vagrant-hypconfigmgmt/pkg` so only your new version remains.

4. Commit into your branch, make a PR, merge after review.

5. Publish the new gem with `gem push vagrant-hypconfigmgmt-0.0.<YOURVERSION>.gem`, see http://guides.rubygems.org/publishing/ for details. Credentials are in the usual place.

