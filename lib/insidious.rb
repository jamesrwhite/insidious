require 'error'

class Insidious
  attr_accessor :pid_file
  attr_accessor :pid
  attr_accessor :stdin
  attr_accessor :stdout
  attr_accessor :stderr

  def initialize(options = {})
    @daemonize = options[:daemonize].nil? ? true : options[:daemonize]
    @pid_file = options[:pid_file]
    @stdin = options[:stdin]
    @stdout = options[:stdout]
    @stderr = options[:stderr]
  end

  # Runs the daemon
  #
  # This will set up `INT` & `TERM` signal handlers to stop execution
  # properly. When this signal handlers are called it will also call
  # the #interrupt method and delete the pid file
  def run!(&block)
    begin
      if @daemonize
        Process.daemon(true, (stdin || stdout || stderr))
      end

      save_pid_file

      block.call
    rescue Interrupt, SignalException
      interrupt
    end
  end

  # Handles an interrupt (`SIGINT` or `SIGTERM`) properly as it
  # deletes the pid file and calles the `stop` method.
  def interrupt
    File.delete(pid_file) if pid_file && File.exists?(pid_file)
  end

  # Starts the daemon
  #
  # If a PID file was provided it will try to store the current
  # PID. If this files exists it will try to check if the stored PID
  # is already running, in which case insidious will exit with an error
  # code.
  def start!(&block)
    if running?
      fail InsidiousError.new("Process is already running with PID #{pid}")
      exit 2
    else
      if pid_file.nil? && daemonize
        fail InsidiousError.new('No PID file is set but daemonize is set to true')
        exit 1
      end

      run!(&block)
    end
  end

  # Stops the daemon execution
  #
  # This method only works when a PID file is given, otherwise it will
  # exit with an error.
  def stop!
    if pid_file && File.exists?(pid_file)
      begin
        Process.kill(:INT, pid)
        File.delete(pid_file)
      rescue Errno::ESRCH
        fail InsidiousError.new("No process is running with PID #{pid}")
        exit 3
      end
    else
      fail InsidiousError.new("Couldn't find the PID file: '#{pid_file}'")
      exit 1
    end
  end

  # Restarts the daemon
  def restart!(&block)
    if running?
      stop!
    end

    start!(&block)
  end

  # Get the pid from the pid_file
  def pid
    File.read(@pid_file).strip.to_i
  end

  # Returns `true` if the daemon is running
  def running?
    # First check if we have a pid file and if it exists
    if pid_file.nil? || !File.exists?(pid_file)
      return false
    end

    begin
      Process.getpgid(pid)
      true
    rescue Errno::ESRCH
      false
    end
  end

  # Returns true if insidious is running as a daemon which is the default
  def daemon?
    @daemonize
  end

  # Changes the working directory
  #
  # All paths will be relative to the working directory unless they're
  # specified as absolute paths.
  #
  # @param [String] path of the new workng directory
  def chdir!(path)
    Dir.chdir(File.absolute_path(path))
  end

  # Set the path where the PID file will be created
  def pid_file=(path)
    @pid_file = File.absolute_path(path)
  end

  # Reopens `STDIN` for reading from `path`
  #
  # This path is relative to the working directory unless an absolute
  # path is given.
  def stdin=(path)
    @stdin = File.absolute_path(path)
    STDIN.reopen(@stdin)
  end

  # Reopens `STDOUT` for writing to `path`
  #
  # This path is relative to the working directory unless an absolute
  # path is given.
  def stdout=(path)
    @stdout = File.absolute_path(path)
    STDOUT.reopen(@stdout, 'a')
  end

  # Reopens `STDERR` for writing to `path`
  #
  # This path is relative to the working directory unless an absolute
  # path is given.
  def stderr=(path)
    @stderr = File.absolute_path(path)
    STDERR.reopen(stderr, 'a')
  end

  private

  # Save the falen angel PID to the PID file specified in `pid_file`
  def save_pid_file
    File.open(pid_file, 'w') do |fp|
      fp.write(Process.pid)
    end if pid_file
  end
end
