require 'error'

class Insidious
  attr_reader :pid_file

  # Intiailise Insidious, note the correct spelling of initialise.
  def initialize(options = {})
    @daemonize = options[:daemonize].nil? ? true : options[:daemonize]
    @pid_file = options[:pid_file].nil? ? nil : File.absolute_path(options[:pid_file])
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
      if @pid_file.nil? && daemon?
        fail InsidiousError.new('No PID file is set but daemonize is set to true')
        exit 1
      end

      run_daemon!(&block)
    end
  end

  # Stops the daemon execution
  #
  # This method only works when a PID file is given, otherwise it will
  # exit with an error.
  def stop!
    if @pid_file && File.exists?(@pid_file)
      begin
        Process.kill(:INT, pid)
        File.delete(@pid_file)
      rescue Errno::ESRCH
        fail InsidiousError.new("No process is running with PID #{pid}")
        exit 3
      end
    else
      fail InsidiousError.new("Couldn't find the PID file: '#{@pid_file}'")
      exit 1
    end
  end

  # Restarts the daemon, just a convenience method really
  def restart!(&block)
    stop! if running?
    start!(&block)
  end

  # Returns true if the daemon is running
  def running?
    # First check if we have a pid file and if it exists
    return false if @pid_file.nil? || !File.exists?(@pid_file)

    # Then make sure we have a pid
    return false if pid.nil?

    # If we can get the process id then we assume it is running
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

  # Get the pid from the pid_file
  # TODO: should this be 'cached'?
  def pid
    File.read(@pid_file).strip.to_i
  end

  # Save the PID to the PID file specified in @pid_file
  def pid=(pid)
    File.open(@pid_file, 'w') do |file|
      file.write(pid)
    end if @pid_file
  end

  private

  # Runs the daemon
  #
  # This will set up `INT` & `TERM` signal handlers to stop execution
  # properly. When this signal handlers are called it will also call
  # the #interrupt method and delete the pid file
  def run_daemon!(&block)
    begin
      # Only start the process as a daemon if requested
      Process.daemon(true) if daemon?

      # Set the process id, this will save it to @pid_file
      self.pid = Process.pid

      # Call the block of code passed to us
      block.call
    # Handle interruptipns such as someone ctrl-c or killing the process
    rescue Interrupt, SignalException
      interrupt!
    end
  end

  # Handle an interrupt (`SIGINT` or `SIGTERM`) by deleting the
  # pid file if it exists
  def interrupt!
    File.delete(@pid_file) if @pid_file && File.exists?(@pid_file)
  end
end
