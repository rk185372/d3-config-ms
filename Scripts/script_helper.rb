require 'rest-client'
require 'uri'
require 'json'
require 'zip'

class ScriptHelper
    def initialize(jarvis_token, rest_endpoint)
        @jarvis_token = jarvis_token
        @rest_endpoint = rest_endpoint
    end

    def download_environment_zip_for_template(template_id, built_from, mobile_commit)
        options = { raw_response: true }
        perform_request(:get, "templates/#{template_id}/environment_zip?built_from=#{built_from}&mobile_commit=#{mobile_commit}", options) do |response|
            unzip_environment(response.file)
        end
    end

    def download_environment_zip_for_build(build_id)
        options = { raw_response: true }
        perform_request(:get, "builds/#{build_id}/environment_zip", options) do |response|
            unzip_environment(response.file)
        end
    end

    def download_cached_environment_zip_for_active_template(active_template_id)
        perform_request(:get, "active_templates/#{active_template_id}") do |response|
            json = JSON.parse(response.body)
            cached_environment_zip_url = json['cachedEnvironmentZipUrl']
            begin
                headers = { authorization: "Bearer #{@jarvis_token}" }
                zip_response = RestClient::Request.execute(method: :get, url: cached_environment_zip_url, headers: headers, timeout: 300, raw_response: true)
                unzip_environment(zip_response.file)
            rescue RestClient::ExceptionWithResponse => e
                raise "Error with http request: GET #{cached_environment_zip_url}\n#{e.response}"
            end
        end
    end

    def report_build(build_id, status, output_file, failure_email = nil)
        options = {
            body: {
                status: status
            },
            content_type: 'application/x-www-form-urlencoded'
        }
        options[:body][:output] = File.new(output_file) unless output_file.nil?
        options[:body][:failure_email] = failure_email unless failure_email.nil?
        perform_request(:put, "builds/#{build_id}", options) do
            puts 'Build updated.'
        end
    end

    def template_id_for_active_template(active_template_id)
        perform_request(:get, "active_templates/#{active_template_id}") do |response|
            json = JSON.parse(response.body)
            return json['templateId']
        end
    end

    def active_templates(branch_name, os_type)
        perform_request(:get, "active_templates/for_branch_name/#{branch_name}?os=#{os_type}") do |response|
            json = JSON.parse(response.body)
            return json['templateIds']
        end
    end

    def create_build(template_id, built_from, mobile_commit)
        options = {}
        options[:body] = {
            built_from: built_from,
            mobile_commit: mobile_commit
        }.to_json
        perform_request(:post, "templates/#{template_id}/create_build", options) do |response|
            json = JSON.parse(response.body)
            return json['buildId']
        end
    end

    def create_builds_for_active_templates(branch_name, os_type, commit)
        perform_request(:post, "active_templates/create_builds?branch_name=#{branch_name}&os=#{os_type}&commit=#{commit}") do |response|
            json = JSON.parse(response.body)
            return json
        end
    end

    def set_active_template(template_id)
        perform_request(:put, "templates/#{template_id}/set_active") do |response|
            json = JSON.parse(response.body)
            return json
        end
    end

    private

    def perform_request(method, route, options = {}, &block)
        url = "#{@rest_endpoint}#{route}"
        headers = {
            authorization: "Bearer #{@jarvis_token}",
            content_type: options.fetch(:content_type, 'application/json')
        }
        args = { method: method, url: url, headers: headers, timeout: 300 }
        args[:payload] = options[:body] unless options[:body].nil?
        args[:raw_response] = options[:raw_response] unless options[:raw_response].nil?
        begin
            response = RestClient::Request.execute(args)
            block.call response
        rescue RestClient::ExceptionWithResponse => e
            raise "Error with http request: #{method.upcase} #{route}\n#{e.response}"
        end
    end

    def unzip_environment(response_file)
        FileUtils.rm_rf(Dir['../environment/*'])
        environment_zip = 'environment.zip'
        FileUtils.cp response_file.path, environment_zip

        Zip::File.open(environment_zip) do |zip|
            zip.each do |entry|
                entry.extract(entry.name) do
                    true # Replace all duplicates.
                end
            end
        end
    end
end
