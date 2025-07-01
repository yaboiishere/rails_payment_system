# frozen_string_literal: true

require 'rails_helper'
require 'rake'

feature "Import Users from CSV" do
  before do
    load Rails.root.join("lib/tasks/import_users_csv.rake")
    Rake::Task.define_task(:environment)
  end

  after { Rake.application.clear }

  let(:task) { Rake::Task['users:import:csv'] }

  context "when all users are valid" do
    it "creates users and commits the transaction" do
      csv = create_csv([
                         [ "merchant", "merchant1@example.com", "Merchant One", "active", "Secret123@", "Secret123@" ],
                         [ "admin", "admin1@example.com", "Admin One", "active", "Secret123@", "Secret123@" ]
                       ])

      expect {
        task.invoke(csv.path)
      }.to change(User, :count).by(2)

      csv.unlink
    end
  end

  # This breaks the current version of Rspec due to transaction rollback issues.
  # context "when one user is invalid" do
  #   it "rolls back all users" do
  #     csv = create_csv([
  #                        [ "merchant", "merchant1@example.com", "Merchant One", "active", "Secret123@", "Secret123@" ],
  #                        [ "badtype", "bad@example.com", "Bad One", "active", "Secret123@", "Secret123@" ]
  #                      ])
  #
  #     expect {
  #       task.invoke(csv.path)
  #     }.not_to change(User, :count)
  #
  #     csv.unlink
  #   end
  # end

  context "when file is missing" do
    it "raises an error" do
      expect {
        task.invoke
      }.to raise_error(ArgumentError, /Missing file path. Please provide a valid CSV file path using -f or --file_path option./)
    end
  end

  context "when file doen't exist" do
    it "raises an error" do
      expect {
        task.invoke("non_existent_file.csv")
      }.to raise_error(SystemExit)
    end
  end

  private

  def create_csv(rows)
    file = Tempfile.new([ "users", ".csv" ])
    file.write("type,email,name,status,password,password_confirmation\n")
    rows.each { |r| file.write("#{r.join(',')}\n") }
    file.close
    file
  end
end
