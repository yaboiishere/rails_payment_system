# frozen_string_literal: true

class UserImporter
  attr_reader :file_path, :results
  attr_reader :error_message

  def initialize(file_path)
    @file_path = file_path
    @results = { successful: [], failed: [] }
  end

  def call
    validate_file!

    import_users
  end

  private

  def validate_file!
    raise ArgumentError, "Missing file path" if file_path.nil?
    raise ArgumentError, "CSV file not found at #{file_path}" unless File.exist?(file_path)
  end

  def import_users
    ActiveRecord::Base.transaction do
      CSV.foreach(file_path, headers: true) do |row|
        params = {
          type: row["type"],
          email: row["email"],
          name: row["name"],
          status: row["status"],
          password: row["password"]
        }

        result = User::Create.call(params: params)

        if result.success?
          results[:successful] << { email: params[:email], type: params[:type] }
        else
          results[:failed] << { email: params[:email], errors: result[:errors] }
          results[:successful] = []
          message = "Failed to create user: #{params[:email]} - #{result[:errors].join(', ')}"
          @error_message = message
          raise ActiveRecord::Rollback, message
        end
      end
    end

    results[:failed].empty?
  end
end
