class RemoveVacanciesThatExpiredYesterdayFromGoogleIndexJob < ApplicationJob
  queue_as :default

  def perform
    Vacancy.expired_yesterday.find_each do |vacancy|
      RemoveGoogleIndexQueueJob.perform_now(Rails.application.routes.url_helpers.job_url(vacancy))
      vacancy.markers.delete_all # This is to keep the markers table from getting too big
    end
    Rails.logger.info("Finished removing jobs that expired on #{Date.yesterday} from Google index")
  end
end
