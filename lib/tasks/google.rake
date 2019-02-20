namespace :google do

  desc "download new certificates and delete expired"
  task update_certificates: :environment do

    job=UpdateGoogleCertificatesJob.new

    job.perform

  end

end
