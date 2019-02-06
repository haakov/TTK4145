defmodule Ex4 do
  use GenServer
  import :erlang, only: [binary_to_term: 1, term_to_binary: 1]

  def start_link(port) do
    GenServer.start_link(__MODULE__, port)
  end

  def init(port) do
    :gen_udp.open(port, [:binary, active: true])
  end

  def handle_info({:udp, _socket, _address, _port, data}, socket) do
    tuple = binary_to_term(data)
    IO.inspect(tuple)

    {:noreply, socket}
  end

  def run do
    {:ok, _pid} = Supervisor.start_link([{Ex4, 20013}], strategy: :one_for_one)
  end

  def send do
    {:ok, socket} = :gen_udp.open(0)

    t1 = IO.gets("")
    |> String.trim()

    t2 = IO.gets("")
    |> String.trim()

    t12 = {{t1, :ok}, t2, :ok}

    :gen_udp.send(socket, {127,0,0,1}, 20013, term_to_binary(t12))
  end
end
