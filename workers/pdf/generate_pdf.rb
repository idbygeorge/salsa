cd pdf#!/usr/bin/env ruby
require 'cgi'
require 'yaml'
require 'uber-s3'
require 'open-uri'
require 'shellwords'

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

    tmp_file = Dir.pwd + '/' + (0...32).map{65.+(rand(25)).chr}.join + '.pdf'
    generate(url, tmp_file)

    puts "Uploading syllabus to s3: #{name_w_path}"
    file = IO.read(tmp_file)
    bucket_url, bucket = s3_connect
    bucket.store(name_w_path, file, :access => :public_read)

    puts "Successfully uploaded syllabus:"
    puts "#{bucket_url}/#{name_w_path}"
  end

  def generate(url, tmp_file)
    puts "Generating pdf from url: #{url} -> #{tmp_file}"
    cmdline = "wkhtmltopdf-amd64 --page-size Letter --margin-top .5in --margin-right 0in --margin-bottom .5in --margin-left 0in --encoding UTF-8 -q #{url} #{tmp_file}"
    puts "#{cmdline}"
    # puts `wkhtmltopdf --page-size Letter --margin-top 0in --margin-right 0in --margin-bottom 0in --margin-left 0in --encoding UTF-8 -q #{url} #{tmp_file}`
    puts `#{cmdline}`
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
    config = YAML.load_file('config.yml')['production']
    bucket_name = config['aws_bucket']
    region = config['aws_region']

    puts "AWS Key: #{config['aws_access_key_id']}"
    puts "AWS Secret: #{config['aws_secret_access_key']}"
    puts "AWS Region: #{config['aws_region']}"
    puts "AWS Bucket: #{bucket_name}"

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
