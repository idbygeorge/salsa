#!/usr/bin/env ruby
require 'cgi'
require 'yaml'
require 'uber-s3'
require 'open-uri'
require 'shellwords'
require 'debugger'

class PdfGenerator

  def run(payload)
    # ENV['PATH'] = "#{ENV['PATH']}:#{Dir.pwd}/phantomjs-1.6.0-linux-x86_64-dynamic/bin/"

    # The payload needs to be decoded first
    params = CGI::parse(payload)
    puts "cgi_parsed: #{params.inspect}"

    url = params['url'][0]
    url = "http:#{url}" if url[0, 2] == '//' # Make sure to provide a protocol

    view_id = url.split('/').last

    name_w_path = "syllabuses/#{view_id}.pdf"

    tmp_file = '/tmp/' + (0...32).map{65.+(rand(25)).chr}.join + '.pdf'
    generate(url, tmp_file)

    puts "Storing file to s3: #{name_w_path}"
    file = IO.read(tmp_file)
    bucket_url, bucket = s3_connect
    bucket.store(name_w_path, file, :access => :public_read)

    puts "#{bucket_url}/#{name_w_path}"
  end

  def generate(url, tmp_file)
    puts `/usr/local/bin/wkhtmltopdf --page-size Letter --margin-top 0.75in --margin-right 0.75in --margin-bottom 0.75in --margin-left 0.75in --encoding UTF-8 -q #{url} #{tmp_file}`
  end

  def download_file(url)
    file_name = File.basename(url)
    File.open(file_name, "wb") do |sf|
      open(url, 'rb') do |rf|
        sf.write(rf.read)
      end
    end
    file_name
  end

  def s3_connect
    # Also parse the config we uploaded with this worker for our Hipchat stuff
    config = YAML.load_file('../../config/config.yml')
    bucket_name = config['aws_bucket']
    region = config['aws_region']

    puts "Region: #{config['aws_region']}"
    puts "Uploading to bucket: #{bucket_name}"
    puts "AWS Key: #{config['aws_access_key_id']}"
    puts "AWS Secret: #{config['aws_secret_access_key']}"

    bucket = UberS3.new({
      :region             => region,
      :access_key         => config['aws_access_key_id'],
      :secret_access_key  => config['aws_secret_access_key'],
      :bucket             => bucket_name
    })

    ["https://s3-#{region}.amazonaws.com/#{bucket_name}", bucket]
  end
end

main = PdfGenerator.new
main.run(payload)
