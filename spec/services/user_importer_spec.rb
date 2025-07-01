# frozen_string_literal: true

require 'rails_helper'
require 'tempfile'

RSpec.describe UserImporter do
  describe '#call' do
    context 'with valid users' do
      it 'successfully imports all users' do
        csv = create_test_csv([
                                [ "merchant", "merchant1@example.com", "Merchant One", "active", "Secret123@", "Secret123@" ],
                                [ "admin", "admin1@example.com", "Admin One", "active", "Secret123@", "Secret123@" ]
                              ])

        importer = UserImporter.new(csv.path)

        expect(importer.call).to be true
        expect(importer.results[:successful].length).to eq 2
        expect(importer.results[:failed]).to be_empty
        expect(User.count).to eq 2

        csv.unlink
      end
    end

    context 'with invalid user' do
      it 'rolls back transaction and records failures' do
        csv = create_test_csv([
                                [ "merchant", "merchant1@example.com", "Merchant One", "active", "Secret123@", "Secret123@" ],
                                [ "invalid", "bad@example.com", "Bad Type", "active", "Secret123@", "Secret123@" ]
                              ])

        importer = UserImporter.new(csv.path)

        expect(importer.call).to be false
        expect(importer.error_message).to include("Failed to create user:")
        expect(importer.results[:successful]).to be_empty
        expect(importer.results[:failed].length).to eq 1
        first = importer.results[:failed].first
        expect(first[:email]).to eq "bad@example.com"
        expect(first[:errors]).to include("Invalid user type: invalid. Valid types are: merchant, admin")
        expect(User.count).to eq 0

        csv.unlink
      end
    end

    context 'with file validation' do
      it 'raises error for missing file path' do
        importer = UserImporter.new(nil)
        expect { importer.call }.to raise_error(ArgumentError, /Missing file path/)
      end

      it 'raises error for non-existent file' do
        importer = UserImporter.new("non_existent_file.csv")
        expect { importer.call }.to raise_error(ArgumentError, /CSV file not found/)
      end
    end
  end

  private

  def create_test_csv(rows)
    file = Tempfile.new([ "users", ".csv" ])
    file.write("type,email,name,status,password,password_confirmation\n")
    rows.each { |r| file.write("#{r.join(',')}\n") }
    file.close
    file
  end
end
