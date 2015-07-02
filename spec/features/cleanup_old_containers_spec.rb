require 'fileutils'
require 'docker'
require 'rspec/collection_matchers'

RSpec.describe 'Cleaning up old containers', type: :integration do
  let(:docker_url) { 'tcp://10.11.11.111:4243' }
  let(:centurion) { File.join File.dirname(__FILE__), '..', '..', 'bin', 'centurion' }

  around do |example|
    FileUtils.cd File.dirname(__FILE__) do
      Docker.url =  'tcp://10.11.11.111:4243'
      Docker::Container.all(all: true).each { |c| c.delete(force: true) }
      example.run
      Docker::Container.all(all: true).each { |c| c.delete(force: true) }
    end
  end

  it 'only keeps most recent container' do
    `#{centurion} --project fixture --environment simple --action deploy --tag 3.0.0 2>/dev/null`
    `#{centurion} --project fixture --environment simple --action deploy --tag 3.0.1 2>/dev/null`
    `#{centurion} --project fixture --environment simple --action deploy --tag 3.0.2 2>/dev/null`
    container_names = Docker::Container.all(all: true).map{ |c| c.info["Names"] }.flatten
    expect(container_names).to have(1).items
  end
end
