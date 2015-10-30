set :stage, :production
role :web, %w{slide.meguro.ryuzee.com}

server 'slide.meguro.ryuzee.com', user: ENV['OSS_PRODUCTION_SSH_USER']
set :branch, 'production'
set :ssh_options, {
  keys: [ENV['OSS_PRODUCTION_SSH_PRIVATE_KEY']],
  forward_agent: true
}
