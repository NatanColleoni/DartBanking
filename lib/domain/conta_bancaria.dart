import 'dart:math';

import 'package:atvd/domain/emprestimo.dart';
import 'package:atvd/domain/enum/tipo_transacao.dart';
import 'package:atvd/domain/pessoa.dart';
import 'package:atvd/domain/transacao.dart';

import 'enum/tipo_conta.dart';

class ContaBancaria {
    TipoConta tipoConta;
    double _saldo;
    bool isEmpresa;
    Pessoa pessoa;
    List<Transacao> transacoes = [];
    List<Emprestimo> emprestimos = [];

    ContaBancaria(this._saldo,
        {
            required this.tipoConta,
            required this.isEmpresa,
            required this.pessoa
        }
    );


    double depositar(double valorDeposito) {
        _saldo += valorDeposito;
        transacoes.add(Transacao(valor: valorDeposito, tipo: TipoTransacao.deposito));
        return _saldo;
    }

    double pagar(double valorPago) {
      if(_saldo >= valorPago) {
        _saldo -= valorPago;
        transacoes.add(Transacao(valor: valorPago, tipo: TipoTransacao.pagamento));
        
        return _saldo;
      } else {
        throw Exception('Saldo insuficiente para pagar.');
      }
    }

    List<Transacao> extratoPorPeriodo(DateTime dataInicio, DateTime dataFim) {
      return transacoes.where((transacao) => transacao.data.isAfter(dataInicio) && transacao.data.isBefore(dataFim.add(Duration(days: 1)))).toList();
    }

    void solicitarEmprestimo(double valorSolicitado, double taxaDeJuros, int prazoEmMeses) {
      if(Random().nextInt(10) == 10){
        final emprestimo = Emprestimo(valor: valorSolicitado, taxaDeJuros: taxaDeJuros, prazoEmMeses: prazoEmMeses);
        emprestimos.add(emprestimo);
        _saldo += valorSolicitado;

        // Registre a transação
        transacoes.add(Transacao(valor: valorSolicitado, tipo: TipoTransacao.emprestimo));
      } else {
        throw Exception('Você não possui as condições necessárias para aprovação do empréstimo');
      }
    }

    double consultarSaldo() {
        return _saldo;
    }
}