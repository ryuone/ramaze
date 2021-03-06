#          Copyright (c) 2008 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require 'fileutils'
require 'find'

class ProjectCreator
  PROTO = []
  PROTO << '~/.proto/' if ENV["HOME"] # Guard against Windows
  attr_accessor :name, :options

  def initialize(name, options = {})
    @name, @options = name, options
  end

  def target
    File.expand_path(name)
  end

  def proto
    PROTO.map!{|pr| File.expand_path(pr) }
    proto = options[:proto] ||= PROTO.find{|f| File.directory?(f) }
    layout = options[:layout] ||= '/'
    File.expand_path(File.join(proto, layout))
  end

  def create_root?
    return true unless File.directory?(target)
    return true if amend? or force?
    fatal "%p is a directory, choose different project name or use --amend/--force" % target
  end

  def got_proto?
    return true if File.directory?(proto)
    fatal "Cannot create, %p doesn't exist, use --proto or create the proto directory" % proto
  end

  def create
    got_proto?

    puts "Found proto at: %p, proceeding...\n\n" % proto
    mkdir(relate('/')) if create_root?
    proceed
  end

  def proceed
    files, directories = partition{|path| File.file?(path) }
    proceed_directories(directories)
    proceed_files(files)
  end

  def proceed_files(files)
    files.each{|file| copy(file, relate(file)) }
  end

  def proceed_directories(dirs)
    dirs.each{|dir| mkdir(relate(dir)) }
  end

  def mkdir(dir)
    return unless mkdir?(dir)

    relate = dir.sub("#{target}/", '')
    puts  "%12s    %s" % ['mkdir', relate]

    FileUtils.mkdir_p(dir)
  end

  def mkdir?(dir)
    exists = File.directory?(dir)

    !exists && amend? or exists && force? or !exists
  end

  def copy(from, to)
    return unless copy?(to)

    relate = to.sub("#{target}/", '')
    puts  "%12s    %s" % ['create', relate]

    FileUtils.cp(from, to, :preserve => true)
    post_process(to)
  end

  def copy?(file)
    exists = File.file?(file)

    !exists && amend? or exists && force? or !exists
  end

  # Think about a useful way to process the generated files it should be
  # possible to substitute some things like the project name in the
  # configuration

  def post_process(file)
    return
    source = File.read(file)
    File.open(file, 'w+') do |io|
      io.write(source.gsub('$project', "'#@name'"))
    end
  end

  def relate(path)
    File.join(target, path.to_s.sub(proto, ''))
  end

  def amend?; options[:amend] end
  def force?; options[:force] end

  def fatal(message)
    warn message
    exit 1
  end

  def each
    Dir.glob("#{proto}/**/*", File::FNM_DOTMATCH).each{|path| yield(path) }
  end

  include Enumerable
end
