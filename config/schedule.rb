every :hour do
  runner "LastfmWorker.record_all"
end

every 1.day do
  runner "FitbitWorker.record_all"
end