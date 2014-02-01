# app/workers/hard_worker.rb
class HardWorker
  include Sidekiq::Worker

  def perform(name, count)
    count.times { puts 'Doing hard work' }
  end
end
