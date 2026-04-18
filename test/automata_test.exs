defmodule AutomataTest do
  use ExUnit.Case
  test "afn tiene el estado inicial correcto" do
    assert Automata.afn().inicial == 0
  end
  test "afn tiene los estados finales correctos" do
    assert Automata.afn().finales == [3]
  end
  test "mover calcula la union de transiciones correctamente" do
    afn = Automata.afn()
    assert Automata.mover(afn.transiciones, [0], :a) == [0, 1]
    assert Automata.mover(afn.transiciones, [0], :b) == [0]
    assert Automata.mover(afn.transiciones, [0, 1], :b) == [0, 2]
    assert Automata.mover(afn.transiciones, [0, 2], :b) == [0, 3]
  end
  test "determinizar produce el estado inicial correcto" do
    afd = Automata.determinizar(Automata.afn())
    assert afd.inicial == [0]
  end
  test "determinizar produce los estados finales correctos" do
    afd = Automata.determinizar(Automata.afn())
  assert Enum.any?(afd.finales, fn s -> 3 in s end)
  end
  test "determinizar produce la cantidad correcta de estados alcanzables" do
    afd = Automata.determinizar(Automata.afn())
    assert length(afd.estados) == 4
  end
  test "las transiciones del afd coinciden con la construccion de subconjuntos" do
    afd = Automata.determinizar(Automata.afn())
    trans = afd.transiciones
    assert Enum.member?(trans, {[0], :a, [0, 1]})
    assert Enum.member?(trans, {[0], :b, [0]})
    assert Enum.member?(trans, {[0, 1], :b, [0, 2]})
    assert Enum.member?(trans, {[0, 2], :b, [0, 3]})
    assert Enum.member?(trans, {[0, 3], :b, [0]})
  end

  def afn_con_epsilon do
    %{
      estados: [0, 1, 2, 3],
      alfabeto: [:a],
      inicial: 0,
      finales: [3],
      transiciones: [
        {0, :epsilon, [1]},
        {1, :epsilon, [2]},
        {2, :a, [3]}
      ]
    }
  end

  test "e_closure de un estado sin transiciones epsilon retorna solo ese estado" do
    afn = afn_con_epsilon()
    assert Automata.e_closure(afn, [3]) == [3]
  end

  test "e_closure sigue una transicion epsilon" do
    afn = afn_con_epsilon()
    assert Automata.e_closure(afn, [1]) == [1, 2]
  end

  test "e_closure sigue transiciones epsilon transitivamente" do
    afn = afn_con_epsilon()
    assert Automata.e_closure(afn, [0]) == [0, 1, 2]
  end

  test "e_closure de conjunto ya incluye los estados originales" do
    afn = afn_con_epsilon()
    assert Automata.e_closure(afn, [2, 3]) == [2, 3]
  end

  test "e_closure no entra en loop con ciclos epsilon" do
    afn_ciclico = %{
      estados: [0, 1, 2, 3],
      alfabeto: [:a],
      inicial: 0,
      finales: [3],
      transiciones: [
        {0, :epsilon, [1]},
        {1, :epsilon, [2]},
        {2, :epsilon, [0]},
        {2, :epsilon, [3]}
      ]
    }
    assert Automata.e_closure(afn_ciclico, [0]) == [0, 1, 2, 3]
  end

  test "e_determinizar produce el estado inicial como e_closure del inicial" do
    afd = Automata.e_determinizar(Automata.afn_e())
    assert afd.inicial == [0, 1, 2, 3]
  end

  test "e_determinizar produce la cantidad correcta de estados alcanzables" do
    afd = Automata.e_determinizar(Automata.afn_e())
    assert length(afd.estados) == 6
  end

  test "e_determinizar produce exactamente un estado final" do
    afd = Automata.e_determinizar(Automata.afn_e())
    assert length(afd.finales) == 1
    assert hd(afd.finales) == [10]
  end

  test "e_determinizar transiciones clave del afd resultante" do
    afd = Automata.e_determinizar(Automata.afn_e())
    trans = afd.transiciones
    assert Enum.member?(trans, {[0, 1, 2, 3], :a, [4, 6, 7]})
    assert Enum.member?(trans, {[0, 1, 2, 3], :b, [5, 6, 7]})
    assert Enum.member?(trans, {[4, 6, 7], :a, [8]})
    assert Enum.member?(trans, {[5, 6, 7], :a, [8]})
    assert Enum.member?(trans, {[8], :b, [9]})
    assert Enum.member?(trans, {[9], :b, [10]})
  end
end
