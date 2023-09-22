
import 'dart:math';

import 'package:atvd/domain/conta_bancaria.dart';
import 'package:atvd/domain/enum/estado_civil.dart';
import 'package:atvd/domain/enum/tipo_conta.dart';
import 'package:atvd/domain/enum/tipo_transacao.dart';
import 'package:atvd/domain/pessoa.dart';
import 'package:test/test.dart';

void main() {
  test('Calcular valor base conta poupança', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var testaSaldoInicial = ContaBancaria(TipoConta.poupanca.saldoInicial, tipoConta: TipoConta.poupanca, isEmpresa: false, pessoa: pessoa);

    expect(testaSaldoInicial.consultarSaldo(), 50.0);
  });
  test('Calcular valor base conta corrente', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var testaSaldoInicial = ContaBancaria(TipoConta.corrente.saldoInicial, tipoConta: TipoConta.corrente, isEmpresa: false, pessoa: pessoa);

    expect(testaSaldoInicial.consultarSaldo(), 0.0);
  });
  test('Calcular valor base conta salario', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var testaSaldoInicial = ContaBancaria(TipoConta.salario.saldoInicial, tipoConta: TipoConta.salario, isEmpresa: false, pessoa: pessoa);

    expect(testaSaldoInicial.consultarSaldo(), 0.0);
  });
  test('Calcular saldo com base no deposito', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var conta = ContaBancaria(TipoConta.poupanca.saldoInicial, tipoConta: TipoConta.poupanca, isEmpresa: false, pessoa: pessoa);
    conta.depositar(150.0);

    expect(conta.consultarSaldo(), 200.0);
  });
  test('Testa pagamento com saldo insuficiente', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var conta = ContaBancaria(TipoConta.poupanca.saldoInicial, tipoConta: TipoConta.poupanca, isEmpresa: false, pessoa: pessoa);

    expect(() => conta.pagar(150.0), throwsException);
  });
  test('Testa pagamento com saldo suficiente', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var conta = ContaBancaria(TipoConta.poupanca.saldoInicial, tipoConta: TipoConta.poupanca, isEmpresa: false, pessoa: pessoa);
    conta.depositar(100.0);
    expect(conta.pagar(150.0), 0.0);
  });
  test('Testa consulta de saldo', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var conta = ContaBancaria(TipoConta.poupanca.saldoInicial, tipoConta: TipoConta.poupanca, isEmpresa: false, pessoa: pessoa);
    conta.depositar(100.0);
    expect(conta.consultarSaldo(), 150.0);
  });
  test('Teste extratoPorPeriodo', () {
    var pessoa = Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro);
    var conta = ContaBancaria(TipoConta.poupanca.saldoInicial, tipoConta: TipoConta.poupanca, isEmpresa: false, pessoa: pessoa);
    conta.depositar(150.0);
    conta.pagar(50.0);

    var inicio = DateTime(2023, 01, 01);
    var fim = DateTime(2023, 09, 15);
    var extrato = conta.extratoPorPeriodo(inicio, fim);

    expect(extrato.length, 2);
    expect(extrato[0].data.isAfter(inicio) && extrato[0].data.isBefore(fim.add(Duration(days: 1))), true);
    expect(extrato[1].data.isAfter(inicio) && extrato[1].data.isBefore(fim.add(Duration(days: 1))), true);
    expect(extrato[0].tipo, TipoTransacao.deposito);
    expect(extrato[1].tipo, TipoTransacao.pagamento);
  });
  test('Teste solicitarEmprestimo com sucesso', () {
    final conta = ContaBancaria(1000.0, tipoConta: TipoConta.corrente, isEmpresa: false, pessoa: Pessoa(nome: "José", estadoCivil: EstadoCivil.solteiro));
    final emprestimoAprovado = (Random().nextInt(10) == 10);
    
    if (emprestimoAprovado) {
      expect(() {conta.solicitarEmprestimo(500.0, 0.9, 12);}, returnsNormally);

      expect(conta.emprestimos.length, 1);
      expect(conta.consultarSaldo(), 1500.0);
      expect(conta.transacoes.length, 1);
      expect(conta.transacoes[0].tipo, TipoTransacao.emprestimo);
    } else {
      
      expect(() { conta.solicitarEmprestimo(500.0, 0.9, 12); }, throwsA(TypeMatcher<Exception>()));
      expect(conta.emprestimos.length, 0);
      expect(conta.consultarSaldo(), 1000.0);
      expect(conta.transacoes.length, 0);
    }
  });
}
