# What is QARoR?
It's another Questions & Answers platform for Ruby on Rails

# Why you must try QARoR?

Because it`s:

* develop in Rails fashion
* using common gems
* easy to develop thanks Ruby on Rails
* easy to deploy

# Deploy on Heroku (heroku.com)

Before installation:

* You need Ruby. Easest way to get RUBY is install RVM (Ruby Version Manager) https://rvm.io/rvm/install
* You also need GIT $ sudo apt-get install git
* To deploy QARoR on Heroku you need Heroku Toolbelt - https://toolbelt.heroku.com/ and confirmed Heroku Account.

Type in console:

        $ git clone https://github.com/magicmat/qaror.git
        $ cd ./qaror
        $ bundle install
        $ git init
        $ git add .
        $ git commit -m "init qaror app"
        $ heroku apps:create your-qaror-app-name
        $ git push heroku master
        $ heroku run rake db:migrate
        $ heroku run rake db:seed

Default QARoR installation is adapted to this Heroku Addons: 

        $ heroku addons:add mailgun:starter
        $ heroku addons:add memcachier:dev

If something goes wrong with addons read more on https://devcenter.heroku.com/

# Contribution

Feel free to contribute the project

# TODO

* upgrade to Rails 4
* more documentation and code refactoring
* tests
* rebuild UI with AngularJS and Bootstrap (not decide yet)
* AngularJS based WYSIWYG

# License

The MIT License - Copyright (c) 2014 Mateusz Dw
