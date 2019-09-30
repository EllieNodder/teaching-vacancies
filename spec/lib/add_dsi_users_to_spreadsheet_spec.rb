require 'rails_helper'
require 'add_dsi_users_to_spreadsheet'

RSpec.describe AddDSIUsersToSpreadsheet do
  let(:dfe_sign_in_api) { double(DFESignIn::API) }
  let(:response_json_1) do
    {
      "users": [{}],
      "page": 1,
      "numberOfPages": 1
    }
  end

  let(:response_json_2) do
    {
      "users": [{}],
      "page": 1,
      "numberOfPages": 2
    }
  end

  let(:response_json_3) do
    {
      "users": [{}],
      "page": 1,
      "numberOfPages": 3
    }
  end

  it 'makes an initial request to get the total number of pages' do
    expect(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
    expect(dfe_sign_in_api).to receive(:users).and_return(response_json_1)

    AddDSIUsersToSpreadsheet.new.total_page_number
  end

  describe '#total_page_number' do
    it 'returns the number of pages value from the API response' do
      allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
      allow(dfe_sign_in_api).to receive(:users).and_return(response_json_2)

      total_page_num = AddDSIUsersToSpreadsheet.new.total_page_number

      expect(total_page_num).to eq(response_json_2[:numberOfPages])
    end
  end

  describe '#all_service_users' do
    context 'when making multiple requests' do
      scenario 'makes one request if there is only one page' do
        allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
        allow(dfe_sign_in_api).to receive(:users).and_return(response_json_1)

        expect(dfe_sign_in_api).to receive(:users).with(page: 1)

        AddDSIUsersToSpreadsheet.new.all_service_users
      end

      scenario 'makes two requests if there are two pages' do
        allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
        allow(dfe_sign_in_api).to receive(:users).and_return(response_json_2)

        expect(dfe_sign_in_api).to receive(:users).with(page: 1)
        expect(dfe_sign_in_api).to receive(:users).with(page: 2)

        AddDSIUsersToSpreadsheet.new.all_service_users
      end

      scenario 'make three requests if there are three pages' do
        allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
        allow(dfe_sign_in_api).to receive(:users).and_return(response_json_3)

        expect(dfe_sign_in_api).to receive(:users).with(page: 1)
        expect(dfe_sign_in_api).to receive(:users).with(page: 2)
        expect(dfe_sign_in_api).to receive(:users).with(page: 3)

        AddDSIUsersToSpreadsheet.new.all_service_users
      end

      scenario 'when a request for a page fails, raises an error' do
        allow(DFESignIn::API).to receive(:new).and_return(dfe_sign_in_api)
        allow(dfe_sign_in_api).to receive(:users).and_return(response_json_3)
        allow(dfe_sign_in_api).to receive(:users).with(page: 2).and_raise(DFESignIn::ExternalServerError)

        expect { AddDSIUsersToSpreadsheet.new.all_service_users }.to raise_error(DFESignIn::ExternalServerError)
      end
    end
  end
end
