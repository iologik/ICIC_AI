[ ![Codeship Status for keating/Invest](https://www.codeship.io/projects/00776c80-4578-0132-d73f-361a09117bba/status)](https://www.codeship.io/projects/45010)

#Test database#

to run the migrations for test database

    rake db:migrate RAILS_ENV=test

    rspec spec/

-----------------------------

#Guide for database backup and restore(local)#

https://devcenter.heroku.com/articles/heroku-postgres-import-export

1 enter your local app directory

    cd your_app_directory

2 backup heroku database

    heroku pg:backups capture -a icic-investment
    New Command:
    heroku pg:backups capture --app icic-investment

3 download database as latest.dump

    curl -o latest.dump `heroku pg:backups public-url -a icic-investment`

4 enter your pg console,

    psql -U itamardavid postgres

5 drop your database(for example invest_development)

    drop database invest_development;

6 create a new database with a pg user(for example invest_development and invest_user)

    create database "invest_development" with owner="itamardavid";

7 restore the backup file to your database(for example invest_development and invest_user)

**Exit psql**

    pg_restore --verbose --clean --no-acl --no-owner -h localhost -U itamardavid -d invest_development latest.dump

#Guide for copy icic database to test server#

https://devcenter.heroku.com/articles/heroku-postgres-import-export

1 backup heroku database(same as above instruction)

    heroku pg:backups capture -a icic-investment

2 display backup file url

    heroku pg:backups public-url -a icic-investment

3 use backup file above to restore on lit(for example https://s3.amazonaws.com/.../b046.dump...)

    heroku pg:backups restore 'https://s3.amazonaws.com/.../b046.dump...' DATABASE_URL -a icic-staging

    (You will be asked to enter icic-staging)

#Guide for restore icic database from a backup file#

https://devcenter.heroku.com/articles/pgbackups

1 This is a destructive operation, so lets backup the current database first (same as above instruction)

    heroku pgbackups:capture --app icic-investment --expire

2 Display all the backup files

    heroku pgbackups --app icic-investment

    (You will see something like the following screenshot)

![Screen Shot 2014-10-05 at 5.58.48 PM.png](https://bitbucket.org/repo/ARG7Mb/images/1503796021-Screen%20Shot%202014-10-05%20at%205.58.48%20PM.png)

3 Say we want to restore from the backup file on 2014/10/01, its id is a083

    heroku pgbackups:restore DATABASE_URL a083 --app icic-investment

    (You will be asked to enter icic-investment)

#Environment#

    ENV['aws_access_key_id'] = 'provide_key'

    ENV['aws_secret_access_key'] = 'provide_key'

    ENV['bucket'] = 'icic-investment-local'

    ENV['admin_emails'] = 'provide_admin_email,additional_email'

#Restart the app#

First, we need to find the reason for the app is down, it is 

    heroku logs -t --app icic-investment

Then, we could restart the app

    heroku restart --app icic-investment

#Transfer wrong amount#

https://bitbucket.org/Davidit/invest/issue/282/transfer-wrong-amount

#Change current amount for a sub-investment#

    SubInvestment.find(127).affect_investment(-50000) # plus 5000 from current amount
