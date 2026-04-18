defmodule Automata do
  def afn do
    %{
      estados: [0, 1, 2, 3],
      alfabeto: [:a, :b],
      inicial: 0,
      finales: [3],
      transiciones: [
        {0, :a, [0, 1]},
        {0, :b, [0]},
        {1, :b, [2]},
        {2, :b, [3]}
      ]
    }
  end

  def paso_afn(transiciones, estado, simbolo) do
    transiciones
    |> Enum.filter(fn {e, s, _} -> e == estado and s == simbolo end)
    |> Enum.flat_map(fn {_, _, destinos} -> destinos end)
  end

  def mover(transiciones, estados, simbolo) do
    estados
    |> Enum.flat_map(fn e -> paso_afn(transiciones, e, simbolo) end)
    |> Enum.uniq()
    |> Enum.sort()
  end

  def determinizar(afn) do
    inicial = Enum.sort([afn.inicial])

    {estados_afd, transiciones_afd} =
      explorar([inicial], [], [], afn.transiciones, afn.alfabeto)

    finales =
      Enum.filter(estados_afd, fn s ->
        Enum.any?(s, &(&1 in afn.finales))
      end)

    %{
      estados: estados_afd,
      alfabeto: afn.alfabeto,
      inicial: inicial,
      finales: finales,
      transiciones: transiciones_afd
    }
  end

  def e_closure(automaton, estados) do
    buscar_epsilon(estados, estados, automaton.transiciones)
  end

  defp buscar_epsilon([], visitados, _trans), do: Enum.sort(visitados)

  defp buscar_epsilon([actual | cola], visitados, trans) do
    nuevos =
      trans
      |> Enum.filter(fn {e, s, _} -> e == actual and s == :epsilon end)
      |> Enum.flat_map(fn {_, _, destinos} -> destinos end)
      |> Enum.reject(&(&1 in visitados))

    buscar_epsilon(cola ++ nuevos, visitados ++ nuevos, trans)
  end

  def afn_e do
    %{
      estados: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      alfabeto: [:a, :b],
      inicial: 0,
      finales: [10],
      transiciones: [
        {0, :epsilon, [1]},
        {1, :epsilon, [2, 3]},
        {2, :a, [4]},
        {3, :b, [5]},
        {4, :epsilon, [6]},
        {5, :epsilon, [6]},
        {6, :epsilon, [7]},
        {7, :a, [8]},
        {8, :b, [9]},
        {9, :b, [10]}
      ]
    }
  end

  def e_determinizar(afn) do
    inicial_dfa = e_closure(afn, [afn.inicial])

    {estados, transiciones} = explorar_e([inicial_dfa], [], [], afn)

    finales =
      Enum.filter(estados, fn s ->
        Enum.any?(s, &(&1 in afn.finales))
      end)

    %{
      estados: estados,
      alfabeto: afn.alfabeto,
      inicial: inicial_dfa,
      finales: finales,
      transiciones: transiciones
    }
  end

  defp explorar_e([], visitados, transiciones, _afn), do: {visitados, transiciones}

  defp explorar_e([actual | pila], visitados, transiciones, afn) do
    if actual in visitados do
      explorar_e(pila, visitados, transiciones, afn)
    else
      nuevas_trans =
        Enum.reduce(afn.alfabeto, [], fn simbolo, acc ->
          movidos = mover(afn.transiciones, actual, simbolo)
          destino = e_closure(afn, movidos)

          if destino == [] do
            acc
          else
            [{actual, simbolo, destino} | acc]
          end
        end)

      nuevos =
        nuevas_trans
        |> Enum.map(fn {_, _, d} -> d end)
        |> Enum.uniq()
        |> Enum.reject(&(&1 in [actual | visitados]))

      explorar_e(
        nuevos ++ pila,
        [actual | visitados],
        transiciones ++ nuevas_trans,
        afn
      )
    end
  end

  defp explorar([], visitados, transiciones, _trans_afn, _alfabeto) do
    {visitados, transiciones}
  end

  defp explorar([actual | cola], visitados, transiciones, trans_afn, alfabeto) do
    if actual in visitados do
      explorar(cola, visitados, transiciones, trans_afn, alfabeto)
    else
      nuevas_transiciones =
        Enum.map(alfabeto, fn simbolo ->
          destino = mover(trans_afn, actual, simbolo)
          {actual, simbolo, destino}
        end)

      nuevos_estados =
        nuevas_transiciones
        |> Enum.map(fn {_, _, destino} -> destino end)
        |> Enum.reject(&(&1 == []))

      explorar(
        cola ++ nuevos_estados,
        [actual | visitados],
        transiciones ++ nuevas_transiciones,
        trans_afn,
        alfabeto
      )
    end
  end
end
