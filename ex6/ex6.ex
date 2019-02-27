defmodule Ex6 do
    import :erlang, only: [binary_to_term: 1, term_to_binary: 1]

    def run do main(0) end
    
    def main(id) do
        if id != 0 do
            receive do
                :alive -> main(id)
            after
                1_000 -> IO.puts("Process #{id} taking over")
            end
        end

        backup = readbackup()

        child = spawn fn -> main(id+1) end

        sendloop(child, backup, 0, id)        
    end

    defp readbackup do
        case File.read("ex6.bak") do
            {:ok, output} -> 
                binary_to_term(output)
            {:error, :enoent} -> 
                {:ok, file} = File.open("ex6.bak", [:write])
                IO.binwrite(file, term_to_binary([]))
                File.close(file)
                []
        end
    end

    defp sendloop(pid, backup, i, id) do
        if i == 16 and id == 0 do
            Process.exit(self(), :normal) # Simulating a crash
        end
        if i == 19 and id == 1 do
            Process.exit(self(), :normal) # Simulating a crash #2
        end
        if i not in backup do
            IO.puts("#{i} from id: #{id}")
            backup = Enum.concat(backup, [i])
            {:ok, file} = File.open("ex6.bak", [:write])
            IO.binwrite(file, term_to_binary(backup))
            File.close(file)
            :timer.sleep(700)
            send(pid, :alive)
            sendloop(pid, backup, i+1, id)
        end
        sendloop(pid, backup, i+1, id)
    end

end