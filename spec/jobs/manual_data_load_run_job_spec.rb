require 'rails_helper'

describe ManualDataLoadRunJob do

  let!(:run)                { create(:manual_data_load_run) }

  let(:job)                 { ManualDataLoadRunJob.new }

  before(:each) do
    #stub the service
    allow_any_instance_of(Amr::ProcessAmrReadingData).to receive(:perform).and_return(true)
    allow_any_instance_of(AmrDataFeedImportLog).to receive(:records_imported).and_return(55)
    allow_any_instance_of(AmrDataFeedImportLog).to receive(:records_updated).and_return(99)
  end

  context 'with a valid file' do
    before(:each) do
      expect(run.status).to eq "pending"
      job.load(run.amr_uploaded_reading.amr_data_feed_config, run.amr_uploaded_reading, run)
    end

    it 'updates the status' do
      expect(run.status).to eq "done"
    end

    it 'adds messages' do
      expect(run.manual_data_load_run_log_entries.size > 0).to be true
    end

    it 'marks data as imported' do
      expect(run.amr_uploaded_reading.imported).to be true
    end
  end

  context 'when a problem occurs' do
    before(:each) do
      #stub the service
      allow_any_instance_of(Amr::ProcessAmrReadingData).to receive(:perform).and_raise("An error occured")
      allow_any_instance_of(AmrDataFeedImportLog).to receive(:records_imported).and_return(0)
      allow_any_instance_of(AmrDataFeedImportLog).to receive(:records_updated).and_return(0)
      expect(run.status).to eq "pending"
      job.load(run.amr_uploaded_reading.amr_data_feed_config, run.amr_uploaded_reading, run)
    end

    it 'updates the status' do
      expect(run.status).to eq "failed"
    end

    it 'adds messages' do
      expect(run.manual_data_load_run_log_entries.size > 0).to be true
    end

    it 'marks data as imported' do
      expect(run.amr_uploaded_reading.imported).to be false
    end

  end

end
