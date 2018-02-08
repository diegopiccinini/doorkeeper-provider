def signature_headers
  key=ENV['SOFT_ENCRYPTION_KEY']
  seed=rand(999999999999999).to_s
  time=Time.now.to_i.to_s
  authorization=Digest::SHA1.hexdigest([key,seed,time].join(','))
  { 'Seed' => seed, 'Time' => time, 'Authorization' => authorization }
end
