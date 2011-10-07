require 'test/unit'
require 'fox16'
require 'testcase'
require 'socket'

include Fox

class TC_FXApp < Test::Unit::TestCase
  def test_exception_for_second_app
    app = FXApp.new
    mainWindow = FXMainWindow.new(app, "")
    app.create
    assert_raise RuntimeError do
      app2 = FXApp.new
    end
  end
end

class TC_FXApp2 < TestCase
  def setup
    super(self.class.name)
  end

  def check_events(pipe_rd, pipe_wr)
    app.addInput(pipe_wr, INPUT_WRITE, app, FXApp::ID_QUIT)
    app.run
    app.removeInput(pipe_wr, INPUT_WRITE)

    app.addInput(pipe_rd, INPUT_READ, app, FXApp::ID_QUIT)
    data_sent = false
    app.addTimeout(1) do
      data_sent = true
      pipe_wr.write " "
    end
    app.run
    app.removeInput(pipe_rd, INPUT_READ)
    pipe_wr.close
    pipe_rd.close

    assert data_sent, "the read input event shouldn't fire before some data is available"
  end

  def test_addInput_on_pipe
    check_events *IO.pipe
  end

  def test_addInput_on_socket
    s = TCPServer.open 'localhost', 0
    pipe_wr = TCPSocket.open 'localhost', s.addr[1]
    pipe_rd = s.accept
    s.close

    check_events pipe_rd, pipe_wr
  end
end
