defmodule FactEngine do
  @table :fact_table

  def start do
    :ets.new(@table, [:named_table, :bag, :duplicate_bag])
    :fact_engine
  end

  def input(command) do
    {cmd, values} = parse_command(command)
    :ets.insert(@table, {cmd, values})
    :ok
  end

  def query_facts(query) do
    {query_functor, query_args} = parse_command(query)

    records = get_matches_for_command(query_functor)

    matches =
      records
      |> Enum.filter(fn values -> match_vars_to_values(values, query_args) end)

    if Enum.any?(query_args, &is_var?/1) do
      matches |> Enum.map(&format_result(&1, query_args))
    else
      if matches == [], do: [false], else: matches
    end
  end


  defp parse_command(command) do
    [cmd | values] = String.split(command, ["(", ")", ", "], trim: true)
    {cmd, values}
  end

  def get_matches_for_command(cmd) do
    :ets.lookup(@table, cmd)
    |> Enum.map(fn {_cmd, values} -> values end)
  end

  defp match_vars_to_values(values, vars, var_value_map \\ %{})
       when is_list(values) and is_list(vars) do
    case {values, vars} do
      {[], []} ->
        true

      {[value | t_values], [var | t_vars]} ->
        if is_var?(var) do
          match_with_variable(value, t_values, var, t_vars, var_value_map)
        else
          if value == var do
            match_vars_to_values(t_values, t_vars, var_value_map)
          else
            false
          end
        end

      _ ->
        false
    end
  end

  defp match_with_variable(value, t_values, var, t_vars, var_value_map) do
    if Map.has_key?(var_value_map, var) do
      if Map.get(var_value_map, var) == value do
        match_vars_to_values(t_values, t_vars, var_value_map)
      else
        false
      end
    else
      new_map = Map.put(var_value_map, var, value)
      match_vars_to_values(t_values, t_vars, new_map)
    end
  end

  defp is_var?(var) when is_binary(var), do: String.upcase(var) =~ ~r/^[XYZ]/

  defp format_result(values, vars) do
    zipped = Enum.zip(vars, values)

    grouped = Enum.group_by(zipped, fn {var, _} -> var end, fn {_, val} -> val end)

    valid =
      Enum.all?(grouped, fn
        {_var, [_single_val]} -> true
        {var, vals} -> Enum.uniq(vals) == [Map.get(grouped, var) |> List.first()]
      end)

    if valid do
      result_map =
        Enum.reduce(zipped, %{}, fn {var, value}, acc ->
          if is_var?(var) do
            Map.put(acc, var, value)
          else
            acc
          end
        end)

      case Map.keys(result_map) do
        [_single_key] ->
          [Map.values(result_map) |> List.first()]

        _ ->
          [result_map]
      end
    else
      []
    end
  end

  def match_facts(statement) do
    {functor, args} = parse_statement(statement)

    IO.puts("Parsed functor: #{functor}")
    IO.puts("Parsed args: #{Enum.join(args, ", ")}")

    records = get_matches_for_command(functor)

    IO.puts(
      "Records matching functor: #{Enum.map(records, &Enum.join(&1, ", ")) |> Enum.join(" | ")}"
    )

    match_result =
      records
      |> Enum.any?(&exact_match?(&1, args))

    IO.puts("Match result: #{match_result}")

    match_result
  end

  def exact_match?(fact_args, query_args) do
    fact_args == query_args
  end

  defp parse_statement(command) do
    command =
      String.trim(command)
      |> String.replace(~r/\s*,\s*/, ",")

    IO.puts("Trimmed and replaced command: #{command}")

    if String.contains?(command, "(") do
      parts = String.split(command, ["(", ")"], trim: true)
      IO.puts("Split command parts: #{Enum.join(parts, " | ")}")

      case parts do
        [cmd | rest] ->
          cmd = String.trim(cmd)
          values = String.split(Enum.join(rest, ""), ",", trim: true)
          IO.puts("Values: #{Enum.join(values, " | ")}")
          {cmd, values}

        _ ->
          IO.puts("Unexpected command format!")
          {nil, []}
      end
    else
      parts = String.split(command, " ", trim: true)

      case parts do
        [cmd, args] ->
          cmd = String.trim(cmd)
          values = String.split(args, ",", trim: true)
          {cmd, values}

        _ ->
          IO.puts("Unexpected command format!")
          {nil, []}
      end
    end
  end

  def handle_line("INPUT " <> fact) do
    input(fact)
  end

  def handle_line("QUERY " <> query) do
    query_facts(query)
  end

  def handle_line(_), do: {:error, "Unsupported line"}

  def process_file(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        process_content(content)

      {:error, reason} ->
        IO.puts("Error reading the file: #{reason}")
        :error
    end
  end

  defp process_content(content) do
    lines = String.split(content, "\n", trim: true)

    Enum.each(lines, fn line ->
      case String.split(line, " ", parts: 2) do
        ["INPUT" | [command]] ->
          input(command)

        ["QUERY" | [command]] ->
          result = query_facts(command)
          IO.puts("Result of query #{command}: #{inspect(result)}")

        _ ->
          IO.puts("Unrecognized line format: #{line}")
      end
    end)
  end
end
