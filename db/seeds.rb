# this user could has access to one or more applications
user = User.find_or_create_by(email: 'username@example.com', password: 'password', password_confirmation: 'password')
# ApplicationEnvironment sample
application_environment=ApplicationEnvironment.find_or_create_by name: 'Development'
# Sample application add access to the user
user.oauth_applications.create!( name: 'Sample Application',
                                 redirect_uri: 'http://localhost:3000/users/auth/doorkeeper/callback',
                                 application_environment: application_environment,
                                 external_id: 'localhost')
# this an admin user to login in active-admin
AdminUser.find_or_create_by(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
