RELEASE_NOTES_TEMPLATE_PATH = "packaging/RELEASE_NOTES.md.template"
RELEASE_NOTES_PATH = "build/RELEASE_NOTES.md"

desc 'Generate release notes'
task :generate_release_notes, [:tag] do | t, args |
  require 'fileutils'
  FileUtils.mkdir_p File.dirname(RELEASE_NOTES_PATH)
  tag = args[:tag]
  release_notes_template = File.read(RELEASE_NOTES_TEMPLATE_PATH)
  release_notes_content = release_notes_template.gsub("<TAG_NAME>", tag)
  release_notes_content = release_notes_content.gsub("<PACKAGE_VERSION>", VERSION)
  File.open(RELEASE_NOTES_PATH, "w") { |file| file << release_notes_content }
end

desc 'Upload release notes'
task :upload_release_notes, [:repository_slug, :tag] do |t, args |
  require 'octokit'
  stack = Faraday::RackBuilder.new do |builder|
    builder.response :logger do | logger |
      logger.filter(/(Authorization: )(.*)/,'\1[REMOVED]')
    end
    builder.use Octokit::Response::RaiseError
    builder.adapter Faraday.default_adapter
  end
  Octokit.middleware = stack
  client = Octokit::Client.new(access_token: ENV.fetch('GITHUB_ACCESS_TOKEN'))
  repository_slug = args[:repository_slug]
  tag = args[:tag]
  release_name = "#{PACKAGE_NAME}-#{VERSION}"
  release_notes_content = File.read(RELEASE_NOTES_PATH)
  release =  client.release_for_tag repository_slug, tag
  client.update_release release.url, name: release_name, body: release_notes_content
end
