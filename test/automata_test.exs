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
end
