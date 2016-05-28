defmodule Stack.Server do
  use GenServer

  ### PUBLIC API

  def start_link(stash_pid) do
    { :ok, _pid } = GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def push(element) do
    GenServer.cast(__MODULE__, { :push, element })
  end

  def pop do
    GenServer.call(__MODULE__, :pop)
  end

  ### IMPLEMENTATION

  def init(stash_pid) do
    { :ok, { Stack.Stash.get_stack(stash_pid), stash_pid } }
  end

  def handle_cast({ :push, element }, { current_stack, stash_pid }) do
    { :noreply, { [element | current_stack], stash_pid } }
  end

  def handle_call(:pop, _from, { [head | tail], stash_pid }) do
    { :reply, head, { tail, stash_pid } }
  end

  def terminate(_reason, { current_stack, stash_pid }) do
    Stack.Stash.save_stack(stash_pid, current_stack)
  end
end
