require 'rails_helper'

RSpec.describe ExportTablesToBigQueryJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  before { allow(DisableExpensiveJobs).to receive(:enabled?).and_return(disable_expensive_jobs_enabled?) }

  context 'when DisableExpensiveJobs is not enabled' do
    let(:disable_expensive_jobs_enabled?) { false }

    it 'queues the job' do
      expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    end

    it 'is in the export_tables queue' do
      expect(job.queue_name).to eq('export_tables')
    end

    it 'calls the export tables to big query class' do
      google_cloud_storage = double(:google_cloud_storage)
      expect(ExportTablesToBigQuery).to receive(:new) { google_cloud_storage }
      expect(google_cloud_storage).to receive(:run!)

      perform_enqueued_jobs { job }
    end
  end

  context 'when DisableExpensiveJobs is enabled' do
    let(:disable_expensive_jobs_enabled?) { true }

    it 'does not perform the job' do
      expect(ExportTablesToBigQuery).not_to receive(:new)

      perform_enqueued_jobs { job }
    end
  end
end
