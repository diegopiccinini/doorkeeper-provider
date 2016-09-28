# this user could has access to one or more applications
user = User.create!(email: 'username@example.com', password: 'password', password_confirmation: 'password')
# Sample application add access to the user
user.oauth_applications.create!(name: 'Sample Application', redirect_uri: 'http://localhost:3000/users/auth/doorkeeper/callback')

# this an admin user to login in active-admin
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')
